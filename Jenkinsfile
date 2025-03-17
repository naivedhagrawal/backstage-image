@Library('k8s-shared-lib') _
pipeline {
    agent {
        kubernetes {
            yaml pod('build-container','naivedh/alpine:latest')
            showRawYaml false
        }
    }

    stages {
        stage('Setup Environment') {
            steps {
                container('build-container') {
                    sh '''
                        node -v
                        npm -v
                        npm install -g corepack
                        corepack enable
                        yarn set version stable
                        yarn install
                        yarn --version
                        node -v
                    '''
                }
            }
        }
        stage('Create Backstage App') {
            steps {
                container('build-container') {
                    sh '''
                        echo "backstage" | npx @backstage/create-app@latest --path=app
                    '''
                }
            }
        }
    }
}
