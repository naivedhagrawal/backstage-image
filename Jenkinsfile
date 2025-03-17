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
                    sh 'echo "backstage" | npx @backstage/create-app@latest --path=${BACKSTAGE_APP} --skip-install'
                }
            }
        }
    }
}
