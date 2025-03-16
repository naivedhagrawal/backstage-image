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
                    sh '''
                        # Install necessary tools, including Python
                        apk add --no-cache build-base 
                    '''
                }
            }
        }
    }
}

        