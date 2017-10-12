// Configuration variables
github_org             = "samsung-cnct"
quay_org               = "samsung_cnct"
publish_branch         = "master"
image_tag              = "${env.RELEASE_VERSION}" != "null" ? "${env.RELEASE_VERSION}" : "latest"
kraken_tools_image_tag = "${env.K2_TOOLS_VERSION}" != "null" ? "${env.K2_TOOLS_VERSION}" : "latest"

aws_cloud_test_timeout = 32  // Should be about 16 min (or longer due to etcd cluster health checks)
gke_cloud_test_timeout = 60  // Should be about 4 min but can be as long as 50 for non-default versions
e2e_test_timeout       = 18  // Should be about 15 min
cleanup_timeout        = 60  // Should be about 6 min

e2e_kubernetes_version = "v1.7.6"
e2etester_version      = "0.2"
custom_jnlp_version    = "0.1"

jnlp_image             = "quay.io/${quay_org}/custom-jnlp:${custom_jnlp_version}"
kraken_tools_image     = "quay.io/${quay_org}/kraken-tools:${kraken_tools_image_tag}"
ansible_lint           = "quay.io/${quay_org}/ansible-lint:latest"
e2e_tester_image       = "quay.io/${quay_org}/e2etester:${e2etester_version}"
docker_image           = "docker"

podTemplate(label: 'kraken-lib', containers: [
    containerTemplate(name: 'jnlp', image: jnlp_image, args: '${computer.jnlpmac} ${computer.name}'),
    containerTemplate(name: 'kraken-tools',
                      image: kraken_tools_image,
                      ttyEnabled: true,
                      command: 'cat',
                      alwaysPullImage: true,
                      resourceRequestMemory: '1Gi',
                      resourceLimitMemory: '1Gi'),
    containerTemplate(name: 'ansible-lint',
                      image: ansible_lint,
                      ttyEnabled: true,
                      command: 'cat',
                      alwaysPullImage: true,
                      resourceRequestMemory: '1Gi',
                      resourceLimitMemory: '1Gi'),
    containerTemplate(name: 'e2e-tester',
                      image: e2e_tester_image,
                      ttyEnabled: true,
                      command: 'cat',
                      alwaysPullImage: true,
                      resourceRequestMemory: '1Gi',
                      resourceLimitMemory: '1Gi'),
    containerTemplate(name: 'docker',
                      image: docker_image,
                      command: 'cat',
                      ttyEnabled: true)
  ], volumes: [
    hostPathVolume(hostPath: '/var/run/docker.sock', mountPath: '/var/run/docker.sock'),
    hostPathVolume(hostPath: '/var/lib/docker/scratch', mountPath: '/mnt/scratch'),
    secretVolume(mountPath: '/home/jenkins/.docker/', secretName: 'samsung-cnct-quay-robot-dockercfg')
  ]) {
    node('kraken-lib') {
        customContainer('kraken-tools'){

            stage('Checkout') {
                checkout scm
                // retrieve the URI used for checking out the source
                // this assumes one branch with one uri
                git_uri = scm.getRepositories()[0].getURIs()[0].toString()
                git_branch = scm.getBranches()[0].toString()
            }

            stage('Configure') {
                kubesh 'build-scripts/fetch-credentials.sh'
                kubesh './bin/up.sh --generate cluster/aws/config.yaml'
                kubesh "build-scripts/update-generated-config.sh cluster/aws/config.yaml ${env.JOB_BASE_NAME}-${env.BUILD_ID}"
                kubesh 'mkdir -p cluster/gke'
                kubesh 'cp ansible/roles/kraken.config/files/gke-config.yaml cluster/gke/config.yaml'
                kubesh "build-scripts/update-generated-config.sh cluster/gke/config.yaml ${env.JOB_BASE_NAME}-${env.BUILD_ID}"
                kubesh "build-scripts/docker-update.sh ${kraken_tools_image} docker/Dockerfile"
            }
            // Dry Run Test

            stage('Test: Dry Run') {
                kubesh "env helm_override_`echo ${JOB_BASE_NAME}-${BUILD_ID} " + '| tr \'[:upper:]\' \'[:lower:]\' | tr \'-\' \'_\'`=false PWD=`pwd` ./bin/up.sh --config $PWD/cluster/aws/config.yaml --output $PWD/cluster/aws/ -t dryrun'
            }

            // Unit tests
            stage('Test: Unit') {
                customContainer('ansible-lint') {
                    kubesh 'ansible-lint ansible/*.yaml'
                }
            }

            // Live tests
            try {
                try {
                    err=false
                    stage('Test: Cloud') {
                        parallel (
                            "aws": {
                                timeout(aws_cloud_test_timeout) {
                                    kubesh "env helm_override_`echo ${JOB_BASE_NAME}-${BUILD_ID} " + '| tr \'[:upper:]\' \'[:lower:]\' | tr \'-\' \'_\'`=false PWD=`pwd` ./bin/up.sh --config $PWD/cluster/aws/config.yaml --output $PWD/cluster/aws/'
                                }
                            },
                            "gke": {
                                timeout(gke_cloud_test_timeout) {
                                    kubesh "env helm_override_`echo ${JOB_BASE_NAME}-${BUILD_ID} " + '| tr \'[:upper:]\' \'[:lower:]\' | tr \'-\' \'_\'`=false PWD=`pwd` ./bin/up.sh --config $PWD/cluster/gke/config.yaml --output $PWD/cluster/gke/'
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
                            if (! git_branch.contains(publish_branch)) {
                                githubNotify context: "continuous-integration/jenkins/e2e", description: "This commit did not run e2e tests", status: "FAILURE"
                            }
                            echo 'E2E test not run due to stage failure.'
                        }
                        throw err
                    }
                }
                timeout(e2e_test_timeout) {
                    stage('Test: E2E') {
                        customContainer('e2e-tester') {
                            try {
                                kubesh "PWD=`pwd` build-scripts/conformance-tests.sh ${e2e_kubernetes_version} ${env.JOB_BASE_NAME}-${env.BUILD_ID} /mnt/scratch"
                                if (! git_branch.contains(publish_branch)) {
                                    githubNotify context: "continuous-integration/jenkins/e2e", description: "This commit passed e2e tests", status: "SUCCESS"
                                }
                            } catch (caughtError) {
                                if (! git_branch.contains(publish_branch)) {
                                    githubNotify context: "continuous-integration/jenkins/e2e", description: "This commit failed e2e tests", status: "FAILURE"
                                }
                            } finally {
                                junit testResults: "output/artifacts/*.xml", healthScaleFactor: 0.0                                
                            }
                        }
                    }
                }
            } finally {
                timeout(cleanup_timeout) {
                    stage('Clean up') {
                        parallel (
                            "aws": {
                                kubesh "env helm_override_`echo ${JOB_BASE_NAME}-${BUILD_ID} " + '| tr \'[:upper:]\' \'[:lower:]\' | tr \'-\' \'_\'`=false PWD=`pwd` ./bin/down.sh --config $PWD/cluster/aws/config.yaml --output $PWD/cluster/aws/ || true'
                            },
                            "gke": {
                                kubesh "env helm_override_`echo ${JOB_BASE_NAME}-${BUILD_ID} " + '| tr \'[:upper:]\' \'[:lower:]\' | tr \'-\' \'_\'`=false PWD=`pwd` ./bin/down.sh --config $PWD/cluster/gke/config.yaml --output $PWD/cluster/gke/'
                            }
                        )
                    }
                }
            }
        }

        customContainer('docker') {
            // add a docker rmi/docker purge/etc.
            stage('Build') {
                kubesh "docker rmi quay.io/${quay_org}/kraken-lib:kraken-${env.JOB_BASE_NAME}-${env.BUILD_ID} || true"
                kubesh "docker rmi quay.io/${quay_org}/kraken-lib:latest || true"
                kubesh "docker build --no-cache --force-rm -t quay.io/${quay_org}/kraken-lib:kraken-${env.JOB_BASE_NAME}-${env.BUILD_ID} docker/"

                // The k2 image is built for compatibility with older versions of Kraken.
                kubesh "docker rmi quay.io/${quay_org}/k2:k2-${env.JOB_BASE_NAME}-${env.BUILD_ID} || true"
                kubesh "docker rmi quay.io/${quay_org}/k2:latest || true"
                kubesh "docker build --no-cache --force-rm -t quay.io/${quay_org}/k2:k2-${env.JOB_BASE_NAME}-${env.BUILD_ID} docker/"
            }

            //only push from master if we are on samsung-cnct fork
            stage('Publish') {
                if (git_branch.contains(publish_branch) && git_uri.contains(github_org)) {
                    kubesh "docker tag quay.io/${quay_org}/kraken-lib:kraken-${env.JOB_BASE_NAME}-${env.BUILD_ID} quay.io/${quay_org}/kraken-lib:${image_tag}"
                    kubesh "docker push quay.io/${quay_org}/kraken-lib:${image_tag}"

                    // The k2 image is built for compatibility with older versions of Kraken.
                    kubesh "docker tag quay.io/${quay_org}/k2:k2-${env.JOB_BASE_NAME}-${env.BUILD_ID} quay.io/${quay_org}/k2:${image_tag}"
                    kubesh "docker push quay.io/${quay_org}/k2:${image_tag}"
                } else {
                    echo "Not pushing to docker repo:\n    BRANCH_NAME='${env.BRANCH_NAME}'\n    GIT_BRANCH='${git_branch}'\n    git_uri='${git_uri}'"
                }
                
                //  custom overall health notification
                //  junit plugin will always set build to UNSTABLE if any tests (e2e) fail.  This will cause notificaiton to github
                //  to be a big red X.  Send another one that 'if status is unstable, passed all but e2e'
                if (! git_branch.contains(publish_branch)) {
                    if (currentBuild.result == "UNSTABLE" || currentBuild.result == null) {
                        githubNotify context: "continuous-integration/jenkins/all-but-e2e", description: "This comit passed all phases of CI excluding e2e", status: "SUCCESS"
                    } else {
                        githubNotify context: "continuous-integration/jenkins/all-but-e2e", description: "This comit failed some phase of CI except e2e", status: "FAILURE"
                    }
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
