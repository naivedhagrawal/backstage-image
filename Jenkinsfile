@Library('k8s-shared-lib') _
pipeline {
    agent {
        kubernetes {
            yaml pod('build-container','node:20-alpine')
            showRawYaml false
        }
    }

    stages {
        stage('Setup Environment') {
            steps {
                container('build-container') {
                    sh '''
                        apk add --no-cache git
                        npm install -g corepack
                        corepack enable
                        corepack prepare yarn@4.4.1 --activate # or any desired version
                        yarn --version
                        node -v
                    '''
                }
            }
        }
    }
}
