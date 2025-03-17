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
                    sh 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash'
                    sh '. "$HOME/.nvm/nvm.sh"'
                    sh 'nvm install 22'
                    sh 'nvm use 22'
                    sh 'npm -v'
                    sh 'node -v'
                    sh 'corepack enable yarn'
                    sh 'yarn -v'
                }
            }
        }
    }
}
