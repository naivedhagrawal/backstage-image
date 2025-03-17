@Library('k8s-shared-lib') _
pipeline {
    agent {
        kubernetes {
            yaml pod('build-container','node:lts-alpine')
            showRawYaml false
        }
    }

    stages {
        stage('Setup Environment') {
            steps {
                container('build-container') {
                    sh '''
                        apk add --no-cache git
                        if ! command -v yarn &> /dev/null; then
                          npm install -g yarn
                        fi
                        npm install -g corepack
                        corepack enable
                        yarn --version
                        node -v
                    '''
                }
            }
        }
    }
}
