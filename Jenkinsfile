podTemplate(label: 'k2', containers: [
    containerTemplate(name: 'jnlp', image: 'jenkinsci/jnlp-slave:2.62-alpine', args: '${computer.jnlpmac} ${computer.name}'),
    containerTemplate(name: 'k2-tools', image: 'quay.io/samsung_cnct/k2-tools:latest', ttyEnabled: true, command: 'cat'),
    containerTemplate(name: 'e2e-tester', image: 'quay.io/samsung_cnct/e2etester:0.1', ttyEnabled: true, command: 'cat'),
    containerTemplate(name: 'docker', image: 'docker', command: 'cat', ttyEnabled: true)
  ], volumes: [
    hostPathVolume(hostPath: '/var/run/docker.sock', mountPath: '/var/run/docker.sock'),
    hostPathVolume(hostPath: '/var/lib/docker/scratch', mountPath: '/mnt/scratch'),
    secretVolume(mountPath: '/home/jenkins/.docker/', secretName: 'coffeepac-quay-robot-dockercfg')
  ]) {
    node('k2') {
        container('k2-tools'){

            stage('checkout') {
                checkout scm
            }    

            stage('fetch credentials') {
                sh 'build-scripts/fetch-credentials.sh'
            }

            // Dry Run Test
            stage('aws config generation') {
                sh './up.sh --generate cluster/aws/config.yaml'
            }

            stage('update generated aws config') {
                sh "build-scripts/update-generated-config.sh cluster/aws/config.yaml ${env.JOB_BASE_NAME}-${env.BUILD_ID}"
            }

            stage('create k2 templates - dryrun') {
                sh 'PWD=`pwd` && ./up.sh --config $PWD/cluster/aws/config.yaml --output $PWD/cluster/aws/ -t dryrun'
            }

            // Unit tests go here

            parallel (
                aws: {
                    stage('aws config generation') {
                        sh './up.sh --generate cluster/aws/config.yaml'
                    }

                    stage('update generated aws config') {
                        sh "build-scripts/update-generated-config.sh cluster/aws/config.yaml ${env.JOB_BASE_NAME}-${env.BUILD_ID}"
                    }

                    try {
                        stage('create k2 cluster') {
                            sh 'PWD=`pwd` && ./up.sh --config $PWD/cluster/aws/config.yaml --output $PWD/cluster/aws/'
                        }

                        container('e2e-tester') {
                            stage('run e2e tests') {
                                sh "PWD=`pwd` && build-scripts/conformance-tests.sh v1.5.6 ${env.JOB_BASE_NAME}-${env.BUILD_ID} /mnt/scratch"
                            }
                        }
                    } finally {
                        container('k2-tools') {
                            stage('destroy k2 cluster') {
                                junit "output/artifacts/*.xml"
                                sh 'PWD=`pwd` && ./down.sh --config $PWD/cluster/aws/config.yaml --output $PWD/cluster/aws/'                        
                            }
                        }
                    }
                },
                gke: {
                    stage('gke config generation') {
                        sh 'mkdir -p cluster/gke'
                        sh 'cp ansible/roles/kraken.config/files/gke-config.yaml cluster/gke/config.yaml'
                    }

                    stage('update generated gke config') {
                        sh "build-scripts/update-generated-config.sh cluster/gke/config.yaml ${env.JOB_BASE_NAME}-${env.BUILD_ID}"
                    }

                    try {
                        stage('create gke cluster') {
                            sh 'PWD=`pwd` && ./up.sh --config $PWD/cluster/gke/config.yaml --output $PWD/cluster/gke/'
                        }
                    } finally {
                        stage('destroy gke cluster') {
                            sh 'PWD=`pwd` && ./down.sh --config $PWD/cluster/gke/config.yaml --output $PWD/cluster/gke/'
                        }
                    }

                }
            )
        }

        container('docker') {
            // add a docker rmi/docker purge/etc
            stage('docker build') {
                sh 'docker build -t quay.io/coffeepac/k2:jenkins docker/'
            }

            //only push from master.   assume we are on samsung-cnct fork
            //  ToDo:  check for correct fork
            stage('docker push') {
                if (env.BRANCH == "master") {
                    sh 'docker push quay.io/coffeepac/k2:jenkins'
                } else {
                    echo 'not master branch, not pushing to docker repo'
                }
            }
        }
    }
  }  

// vi: ft=groovy
