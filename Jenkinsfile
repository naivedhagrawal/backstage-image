@Library('k8s-shared-lib') _
pipeline {
    agent {
        kubernetes {
            yaml pod('build-container','alpine:latest')
            showRawYaml false
        }
    }

    stages {
        stage('Setup Environment') {
            steps {
                container('build-container') {
                    sh 'apk add --no-cache build-base make curl wget git bash python3 python3-dev py3-pip'
                    sh 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash'
                    sh 'nvm install --lts'
                    sh 'node -v'
                    sh 'corepack enable'
                    sh 'corepack prepare yarn@4.4.1 --activate'
                    sh 'yarn -v'
                }
            }
        }
    }
}
