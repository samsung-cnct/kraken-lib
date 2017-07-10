podTemplate(label: 'k2', containers: [
    containerTemplate(name: 'jnlp', image: 'quay.io/samsung_cnct/custom-jnlp:0.1', args: '${computer.jnlpmac} ${computer.name}'),
    containerTemplate(name: 'k2-tools', image: 'quay.io/samsung_cnct/k2-tools:latest', ttyEnabled: true, command: 'cat', alwaysPullImage: true, resourceRequestMemory: '1Gi', resourceLimitMemory: '1Gi'),
    containerTemplate(name: 'e2e-tester', image: 'quay.io/samsung_cnct/e2etester:0.2', ttyEnabled: true, command: 'cat', alwaysPullImage: true, resourceRequestMemory: '1Gi', resourceLimitMemory: '1Gi'),
    containerTemplate(name: 'docker', image: 'docker', command: 'cat', ttyEnabled: true)
  ], volumes: [
    hostPathVolume(hostPath: '/var/run/docker.sock', mountPath: '/var/run/docker.sock'),
    hostPathVolume(hostPath: '/var/lib/docker/scratch', mountPath: '/mnt/scratch'),
    secretVolume(mountPath: '/home/jenkins/.docker/', secretName: 'samsung-cnct-quay-robot-dockercfg')
  ]) {
    node('k2') {
        customContainer('k2-tools'){

            stage('checkout') {
                checkout scm
            }

            stage('fetch credentials') {
                kubesh 'build-scripts/fetch-credentials.sh'
            }

            // Dry Run Test
            stage('aws config generation') {
                kubesh './up.sh --generate cluster/aws/config.yaml'
            }

            stage('update generated aws config') {
                kubesh "build-scripts/update-generated-config.sh cluster/aws/config.yaml ${env.JOB_BASE_NAME}-${env.BUILD_ID}"
            }

            stage('create k2 templates - dryrun') {
                kubesh 'PWD=`pwd` && ./up.sh --config $PWD/cluster/aws/config.yaml --output $PWD/cluster/aws/ -t dryrun'
            }

            // Unit tests go here

            parallel (
                aws: {
                    stage('aws config generation') {
                        kubesh './up.sh --generate cluster/aws/config.yaml'
                    }

                    stage('update generated aws config') {
                        kubesh "build-scripts/update-generated-config.sh cluster/aws/config.yaml ${env.JOB_BASE_NAME}-${env.BUILD_ID}"
                    }

                    try {
                        stage('create k2 cluster') {
                            kubesh 'PWD=`pwd` && ./up.sh --config $PWD/cluster/aws/config.yaml --output $PWD/cluster/aws/'
                        }

                        customContainer('e2e-tester') {
                            stage('run e2e tests') {
                                kubesh "PWD=`pwd` && build-scripts/conformance-tests.sh v1.6.7 ${env.JOB_BASE_NAME}-${env.BUILD_ID} /mnt/scratch"
                            }
                        }
                    } finally {
                        customContainer('k2-tools') {
                            stage('destroy k2 cluster') {
                                kubesh 'PWD=`pwd` && ./down.sh --config $PWD/cluster/aws/config.yaml --output $PWD/cluster/aws/ || true'
                                junit "output/artifacts/*.xml"
                            }
                        }
                    }
                },
                gke: {
                    stage('gke config generation') {
                        kubesh 'mkdir -p cluster/gke'
                        kubesh 'cp ansible/roles/kraken.config/files/gke-config.yaml cluster/gke/config.yaml'
                    }

                    stage('update generated gke config') {
                        kubesh "build-scripts/update-generated-config.sh cluster/gke/config.yaml ${env.JOB_BASE_NAME}-${env.BUILD_ID}"
                    }

                    try {
                        stage('create gke cluster') {
                            kubesh 'PWD=`pwd` && ./up.sh --config $PWD/cluster/gke/config.yaml --output $PWD/cluster/gke/'
                        }
                    } finally {
                        stage('destroy gke cluster') {
                            kubesh 'PWD=`pwd` && ./down.sh --config $PWD/cluster/gke/config.yaml --output $PWD/cluster/gke/'
                        }
                    }

                }
            )
        }

        customContainer('docker') {
            // add a docker rmi/docker purge/etc.
            stage('docker build') {
                kubesh 'docker build -t quay.io/samsung_cnct/k2:latest docker/'
            }

            //only push from master.   assume we are on samsung-cnct fork
            //  ToDo:  check for correct fork
            stage('docker push') {
                if (env.BRANCH_NAME == "master") {
                    kubesh 'docker push quay.io/samsung_cnct/k2:latest'
                } else {
                    echo 'not master branch, not pushing to docker repo'
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
