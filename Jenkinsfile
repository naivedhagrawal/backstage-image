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
                    sh 'curl -o- https://fnm.vercel.app/install | bash'
                    sh '. "$HOME/.fnm/fnm.sh"'
                    sh 'fnm install 22'
                    sh 'fnm use 22'
                    sh 'npm -v'
                    sh 'node -v'
                    sh 'corepack enable yarn'
                    sh 'yarn -v'
                }
            }
        }
    }
}
