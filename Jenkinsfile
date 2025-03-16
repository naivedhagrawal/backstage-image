pipeline {
    agent {
        kubernetes {
            yaml '''
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: build-container
    image: alpine:latest
    command: ["sh", "-c", "while true; do sleep 30; done"]
    tty: true
    securityContext:
      privileged: true
    env:
      - name: NODE_OPTIONS
        value: "--max_old_space_size=4096"
            '''
        }
    }

    environment {
        BACKSTAGE_APP = "my-backstage-app"
        DOCKER_IMAGE = "naivedh/backstage:latest"
    }

    stages {
        stage('Setup Environment') {
            steps {
                container('build-container') {
                    sh '''
                    apk add --no-cache curl bash git jq wget docker-cli nodejs npm
                    corepack enable
                    corepack prepare yarn@stable --activate
                    npm install -g npm  # Ensure latest npm is installed
                    '''
                }
            }
        }

        stage('Create Backstage App') {
            steps {
                container('build-container') {
                    sh '''
                    npm install -g @backstage/create-app
                    echo '${BACKSTAGE_APP}\n' | npx @backstage/create-app@latest --path=${BACKSTAGE_APP}
                    '''
                }
            }
        }

        stage('Install Dependencies') {
            steps {
                container('build-container') {
                    dir("${BACKSTAGE_APP}") {
                        sh 'yarn set version stable'
                        sh 'yarn install --immutable'
                    }
                }
            }
        }

        stage('Ensure Compatible Dependencies') {
            steps {
                container('build-container') {
                    dir("${BACKSTAGE_APP}") {
                        sh 'yarn backstage-cli versions:bump'
                    }
                }
            }
        }

        stage('Build Backstage') {
            steps {
                container('build-container') {
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
                container('build-container') {
                    dir("${BACKSTAGE_APP}") {
                        sh "docker build -t ${DOCKER_IMAGE} ."
                    }
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                container('build-container') {
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
