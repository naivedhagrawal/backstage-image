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
                        apk add --no-cache build-base make curl wget git bash python3 python3-dev py3-pip && \
                        ln -sf python3 /usr/bin/python && \
                        wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash && \
                        export NVM_DIR="$HOME/.nvm" && \
                        [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" && \
                        nvm install 20
                    '''
                }
            }
        }
    }
}
