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
                    sh 'node -v'
                    sh 'corepack enable yarn'
                    sh 'yarn -v'
                    sh 'corepack enable'
                    sh 'yarn set version 4.4.1'
                    sh 'yarn -v'
                }
            }
        }
        stage('Create Backstage App') {
            steps {
                container('build-container') {
                    sh 'echo "backstage" | npx @backstage/create-app@latest'
                    sh 'pwd'
                    sh 'ls -lrt'
                    sh 'chown -R node:node backstage'
                    sh 'cd backstage'
                    sh 'ls -lrt'
                }
            }
        }
        stage('Install Dependencies') {
            steps {
                container('build-container') {
                    sh 'cd backstage'
                    sh 'ls -lrt'
                    sh 'yarn install --immutable'
                    sh 'yarn tsc'
                    sh 'yarn build:backend'
                }
            }
        }
    }
}