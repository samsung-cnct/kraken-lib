// Configuration variables
github_org             = "samsung-cnct"
quay_org               = "samsung_cnct"

aws_cloud_test_timeout = 32  // Should be about 16 min (longer due to etcd cluster separation)
gke_cloud_test_timeout = 60  // Should be about 4 min but can be as long as 50 for non-default versions
e2e_test_timeout       = 18  // Should be about 15 min
cleanup_timeout        = 60  // Should be about 6 min

e2e_kubernetes_version = "v1.6.7"
e2etester_version      = "0.2"
custom_jnlp_version    = "0.1"

jnlp_image             = "quay.io/${quay_org}/custom-jnlp:${custom_jnlp_version}"
k2_tools_image         = "quay.io/${quay_org}/k2-tools:latest"
e2e_tester_image       = "quay.io/${quay_org}/e2etester:${e2etester_version}"
docker_image           = "docker"

podTemplate(label: 'k2', containers: [
    containerTemplate(name: 'jnlp', image: jnlp_image, args: '${computer.jnlpmac} ${computer.name}'),
    containerTemplate(name: 'k2-tools', image: k2_tools_image, ttyEnabled: true, command: 'cat', alwaysPullImage: true, resourceRequestMemory: '1Gi', resourceLimitMemory: '1Gi'),
    containerTemplate(name: 'e2e-tester', image: e2e_tester_image, ttyEnabled: true, command: 'cat', alwaysPullImage: true, resourceRequestMemory: '1Gi', resourceLimitMemory: '1Gi'),
    containerTemplate(name: 'docker', image: docker_image, command: 'cat', ttyEnabled: true)
  ], volumes: [
    hostPathVolume(hostPath: '/var/run/docker.sock', mountPath: '/var/run/docker.sock'),
    hostPathVolume(hostPath: '/var/lib/docker/scratch', mountPath: '/mnt/scratch'),
    secretVolume(mountPath: '/home/jenkins/.docker/', secretName: 'samsung-cnct-quay-robot-dockercfg')
  ]) {
    node('k2') {
        customContainer('k2-tools'){

            stage('Checkout') {
                checkout scm
                // retrieve the URI used for checking out the source
                // this assumes one branch with one uri
                git_uri = scm.getRepositories()[0].getURIs()[0].toString()
            }
            stage('Configure') {
                kubesh 'build-scripts/fetch-credentials.sh'
                kubesh './up.sh --generate cluster/aws/config.yaml'
                kubesh "build-scripts/update-generated-config.sh cluster/aws/config.yaml ${env.JOB_BASE_NAME}-${env.BUILD_ID}"
                kubesh 'mkdir -p cluster/gke'
                kubesh 'cp ansible/roles/kraken.config/files/gke-config.yaml cluster/gke/config.yaml'
                kubesh "build-scripts/update-generated-config.sh cluster/gke/config.yaml ${env.JOB_BASE_NAME}-${env.BUILD_ID}"
        }
            // Dry Run Test
            stage('Test: Dry Run') {
                kubesh 'PWD=`pwd` && ./up.sh --config $PWD/cluster/aws/config.yaml --output $PWD/cluster/aws/ -t dryrun'
            }

            // Unit tests
            stage('Test: Unit') {
                kubesh 'true' // Add unit test call here
            }

            // Live tests
            try {
                try {
                    err=false
                    stage('Test: Cloud') {
                        parallel (
                            "aws": {
                                timeout(aws_cloud_test_timeout) {
                                    kubesh 'PWD=`pwd` && ./up.sh --config $PWD/cluster/aws/config.yaml --output $PWD/cluster/aws/'
                                }
                            },
                            "gke": {
                                timeout(gke_cloud_test_timeout) {
                                    kubesh 'PWD=`pwd` && ./up.sh --config $PWD/cluster/gke/config.yaml --output $PWD/cluster/gke/'
                                }
                            }
                        )
                    }
                } catch (caughtError) {
                    err = caughtError
                    currentBuild.result = "FAILURE"                
                } finally {
                    // This keeps the stage view from deleting prior history when the E2E test isn't run
                    if (err) {
                        stage('Test: E2E') {
                            echo 'E2E test not run due to stage failure.'
                        }
                        throw err
                    }
                }
                timeout(e2e_test_timeout) {
                    stage('Test: E2E') {
                        customContainer('e2e-tester') {
                            try {
                                kubesh "PWD=`pwd` && build-scripts/conformance-tests.sh ${e2e_kubernetes_version} ${env.JOB_BASE_NAME}-${env.BUILD_ID} /mnt/scratch"
                            } catch (caughtError) {
                                err = caughtError
                                currentBuild.result = "FAILURE"
                            } finally {
                                junit "output/artifacts/*.xml"
                                if (err) {
                                    throw err
                                }
                            }
                        }
                    }
                }
            } finally {
                timeout(cleanup_timeout) {
                    stage('Clean up') {
                        parallel (
                            "aws": {
                                kubesh 'PWD=`pwd` && ./down.sh --config $PWD/cluster/aws/config.yaml --output $PWD/cluster/aws/ || true'
                            },
                            "gke": {
                                kubesh 'PWD=`pwd` && ./down.sh --config $PWD/cluster/gke/config.yaml --output $PWD/cluster/gke/'
                            }
                        )
                    }
                }
            }
        }

        customContainer('docker') {
            // add a docker rmi/docker purge/etc.
            stage('Build') {
                kubesh "docker rmi quay.io/${quay_org}/k2:k2-${env.JOB_BASE_NAME}-${env.BUILD_ID} || true"
                kubesh "docker rmi quay.io/${quay_org}/k2:latest || true"
                kubesh "docker build --no-cache --force-rm -t quay.io/${quay_org}/k2:k2-${env.JOB_BASE_NAME}-${env.BUILD_ID} docker/"
            }

            //only push from master if we are on samsung-cnct fork
            stage('Publish') {
                if (env.BRANCH_NAME == "master" && git_uri.contains(github_org)) {
                    kubesh "docker tag quay.io/${quay_org}/k2:k2-${env.JOB_BASE_NAME}-${env.BUILD_ID} quay.io/${quay_org}/k2:latest"
                    kubesh "docker push quay.io/${quay_org}/k2:latest"
                } else {
                    echo "Not pushing to docker repo:\n    BRANCH_NAME='${env.BRANCH_NAME}'\n    git_uri='${git_uri}'"
                }
            }
        }
    }
}

def kubesh(command) {
  if (env.CONTAINER_NAME) {
    if ((command instanceof String) || (command instanceof GString)) {
      command = kubectl(command)
    }

    if (command instanceof LinkedHashMap) {
      command["script"] = kubectl(command["script"])
    }
  }

  sh(command)
}

def kubectl(command) {
  "kubectl exec -i ${env.HOSTNAME} -c ${env.CONTAINER_NAME} -- /bin/sh -c 'cd ${env.WORKSPACE} && ${command}'"
}

def customContainer(String name, Closure body) {
  withEnv(["CONTAINER_NAME=$name"]) {
    body()
  }
}

// vi: ft=groovy
