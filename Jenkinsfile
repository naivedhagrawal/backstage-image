@Library('k8s-shared-lib') _
pipeline {
    agent {
        kubernetes {
            yaml pod('build-container','node:20-alpine')
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
                        # Install tools and dependencies
                        apk add --no-cache build-base linux-headers docker openrc
                        npm install -g corepack @backstage/create-app
                        corepack enable
                        yarn set version 4.4.1
                    '''
                }
            }
        }

        stage('Create Backstage App') {
            steps {
                container('build-container') {
                    sh '''
                        # Initialize Backstage app
                        echo "backstage" | npx @backstage/create-app@latest --path=${BACKSTAGE_APP} --skip-install
                        # Optionally remove Git initialization
                        rm -rf ${BACKSTAGE_APP}/.git
                    '''
                }
            }
        }

        stage('Install Dependencies') {
            steps {
                container('build-container') {
                    dir("${BACKSTAGE_APP}") {
                        sh '''
                            # Resolve peer dependency conflicts
                            rm yarn.lock || true
                            yarn install --mode update-lockfile
                            yarn add react@17.0.2 react-dom@17.0.2 @testing-library/react@16.14.0 --exact
                            yarn add @types/react --dev
                        '''
                    }
                }
            }
        }

        stage('Build Backstage') {
            steps {
                container('build-container') {
                    dir("${BACKSTAGE_APP}") {
                        sh '''
                            # Build the app
                            yarn tsc
                            yarn build
                            yarn build:backend --config app-config.production.yaml
                        '''
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
