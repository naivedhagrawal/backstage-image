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
                    sh "apk add --no-cache curl bash git jq wget docker-cli"
                    sh "curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash"
                    sh '''
                    export NVM_DIR="$HOME/.nvm"
                    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
                    nvm install lts/iron
                    nvm use lts/iron
                    corepack enable
                    yarn set version 4.4.1
                    npm install -g npm  # Ensure npm is installed globally
                    '''
                }
            }
        }

        stage('Create Backstage App') {
            steps {
                container('build-container') {
                    sh '''
                    export NVM_DIR="$HOME/.nvm"
                    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
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
                        sh 'corepack enable'  // Enable Corepack to manage Yarn
                        sh 'yarn set version 4.4.1'  // Set a specific Yarn version
                        sh 'yarn add react@18.2.0 react-dom@18.2.0 @testing-library/react@16.0.0 @types/react'
                        sh 'yarn install --mode=update-lockfile --check-cache'  // Allow updates while ensuring consistency
                    }
                }
            }
        }

        stage('Ensure Compatible Dependencies') {
            steps {
                container('build-container') {
                    dir("${BACKSTAGE_APP}") {
                        sh 'yarn backstage-cli versions:bump'  // Keep Backstage packages updated
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