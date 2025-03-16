@Library('k8s-shared-lib') _
pipeline {
    agent {
            kubernetes {
                yaml pod('build-container','alpine:latest')
                showRawYaml false
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
                    apk add --no-cache build-base
                    apk add --no-cache linux-headers
                    apk add --no-cache python3 python3-pip
                    apk add --no-cache curl bash git jq wget
                    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash
                    . "$HOME/.nvm/nvm.sh"
                    nvm install 23
                    node -v
                    nvm current
                    npm -v
                    npm install -g corepack
                    corepack enable
                    yarn init -2
                    yarn set version stable
                    yarn install
                    apk add --update docker openrc
                    run rc-update add docker boot
                    run service docker start
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
                        sh 'yarn tsc'
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
