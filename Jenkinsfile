@Library('k8s-shared-lib') _
pipeline {
    agent {
        kubernetes {
            yaml pod('build-container', 'node:20')
            showRawYaml false
        }
    }

    stages {
        stage('Setup Environment') {
            steps {
                container('build-container') {
                    sh '''
                    node -v
                    corepack enable
                    corepack prepare yarn@4.4.1 --activate
                    yarn set version 4.4.1
                    yarn -v
                    yarn config set nodeLinker node-modules
                    echo "nodeLinker: node-modules" > .yarnrc.yml
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
                    yarn cache clean
                    rm -rf .yarn node_modules yarn.lock
                    mkdir -p .yarn/releases
                    yarn install --mode update-lockfile --inline-builds
                    ls -la node_modules || { echo "node_modules missing!"; exit 1; }
                    yarn tsc || { echo "TypeScript compilation failed!"; exit 1; }
                    yarn build:backend || { echo "Backend build failed!"; exit 1; }
                    '''
                }
            }
        }
    }
}
