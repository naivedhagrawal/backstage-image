@Library('k8s-shared-lib') _
pipeline {
    agent {
        kubernetes {
            yaml pod('build-container', 'node:20-alpine')
            showRawYaml false
        }
    }

    stages {
        stage('Setup Environment') {
            steps {
                container('build-container') {
                    sh '''
                    node -v
                    corepack enable yarn
                    yarn -v
                    corepack enable
                    yarn set version 4.4.1
                    yarn -v
                    '''
                }
            }
        }

        stage('Create Backstage App') {
            steps {
                container('build-container') {
                    sh '''
                        echo "backstage" | npx @backstage/create-app@latest --skip-install --path /home/node/backstage
                        ls -lrt /home/node/backstage
                    '''
                }
            }
        }

        stage('Install Dependencies') {
            steps {
                container('build-container') {
                    sh '''
                    cd /home/node/backstage
                    yarn install --mode update-lockfile
                    yarn tsc
                    yarn build:backend
                    '''
                }
            }
        }
    }
}
