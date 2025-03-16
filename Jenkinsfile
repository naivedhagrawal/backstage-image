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
                        # Install necessary tools, including Python
                        apk add --no-cache build-base linux-headers python3 python3-dev py3-pip docker openrc
                        ln -sf python3 /usr/bin/python
                        npm install -g corepack @backstage/create-app
                        corepack enable
                        yarn set version 4.4.1
                        rm -f /home/jenkins/agent/workspace/backstage-image/yarn.lock
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
                        # Remove Git initialization
                        rm -rf ${BACKSTAGE_APP}/.git
                        # Ensure the app is treated as an independent project
                        touch ${BACKSTAGE_APP}/yarn.lock
                    '''
                }
            }
        }

        stage('Install Dependencies') {
            steps {
                container('build-container') {
                    dir("${BACKSTAGE_APP}") {
                        sh '''
                            # Clear Yarn cache to ensure fresh dependency resolution
                            yarn cache clean

                            # Install dependencies with compatibility resolutions
                            yarn install --mode update-lockfile
                            yarn add react react-dom
                            yarn add @types/react @testing-library/dom --dev

                            # Optionally add resolutions to package.json to lock versions
                            jq '.resolutions |= {"react": "^18.2.0", "react-dom": "^18.2.0"}' package.json > package.tmp && mv package.tmp package.json
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
                            # Add build script if not present
                            if ! grep -q '"build":' package.json; then
                                jq '.scripts.build = "yarn tsc && yarn build:backend --config app-config.production.yaml"' package.json > package.json.tmp
                                mv package.json.tmp package.json
                            fi
                            # Run build
                            yarn tsc
                            yarn build
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
