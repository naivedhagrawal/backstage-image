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
                }
            }
        }
    }
}
