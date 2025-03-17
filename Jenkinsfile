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
                        apk add --no-cache git docker openrc make curl build-base wget python3 py3-pip
                        rc-update add docker boot
                        docker --version
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
