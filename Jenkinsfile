pipeline {
    agent {
        kubernetes {
            yaml '''
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: jnlp
    image: jenkins/inbound-agent:latest
  - name: node
    image: node:18
    command: ["cat"]
    tty: true
  - name: docker
    image: docker:latest
    command: ["cat"]
    tty: true
            '''
        }
    }

    environment {
        BACKSTAGE_APP = "my-backstage-app"
        DOCKER_IMAGE = "naivedh/backstage:latest"
    }

    stages {
        stage('Create Backstage App') {
            steps {
                container('node') {
                    sh "npm install -g @backstage/create-app"
                    sh "echo '${BACKSTAGE_APP}\\n' | npx @backstage/create-app@latest --path=${BACKSTAGE_APP}"
                }
            }
        }

        stage('Install Dependencies') {
            steps {
                container('node') {
                    dir("${BACKSTAGE_APP}") {
                        sh 'yarn install --mode update-lockfile || true'
                        sh 'yarn add react@17.x react-dom@17.x @testing-library/react@16.x --exact'
                    }
                }
            }
        }

        stage('Build Backstage') {
            steps {
                container('node') {
                    dir("${BACKSTAGE_APP}") {
                        sh 'yarn tsc'
                        sh 'yarn build'
                        sh 'yarn build:backend --config app-config.production.yaml'
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                container('docker') {
                    dir("${BACKSTAGE_APP}") {
                        sh "docker build -t ${DOCKER_IMAGE} ."
                    }
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                container('docker') {
                    withDockerRegistry([credentialsId: 'docker-hub-up', url: 'https://index.docker.io/v1/']) {
                        sh "docker push ${DOCKER_IMAGE}"
                    }
                }
            }
        }
    }

    post {
        success {
            echo '✅ Backstage Setup and Build Successful!'
        }
        failure {
            echo '❌ Backstage Setup Failed!'
        }
    }
}
