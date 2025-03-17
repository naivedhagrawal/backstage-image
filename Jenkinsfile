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
                    sh 'echo "backstage" | npx @backstage/create-app@latest --skip-install'
                    sh 'ls -lh'
                    sh 'cd backstage-app'
                    sh 'ls -lh'
                }
            }
        }
        stage('Install Dependencies') {
            steps {
                container('build-container') {
                    sh 'cd backstage-app'
                    sh 'yarn install'
                    sh 'yarn dev'
                }
            }
        }
    }
}