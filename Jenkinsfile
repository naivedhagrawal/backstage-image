@Library('k8s-shared-lib') _
pipeline {
    agent {
        kubernetes {
            yaml pod('build-container','naivedh/backstage-node:latest')
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
                        yarn --version
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
