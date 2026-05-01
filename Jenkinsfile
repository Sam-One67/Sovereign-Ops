pipeline {
    agent any
    
    environment {
        DOCKER_HUB_USER = 'san647'
        DOCKER_HUB_REPO = 'webapp'
        DOCKER_HUB_CREDS = 'docker-hub-credentials'
    }
    
    stages {
        stage('Fix Git Ownership') {
            steps {
                // This command tells Git to trust the workspace directory inside the container
                sh "git config --global --add safe.directory ${WORKSPACE} || true"
            }
        }
        
        stage('Cleanup & Checkout') {
            steps {
                // Standard cleanup and checkout
                cleanWs()
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${DOCKER_HUB_USER}/${DOCKER_HUB_REPO}:${env.BUILD_ID} ."
                sh "docker tag ${DOCKER_HUB_USER}/${DOCKER_HUB_REPO}:${env.BUILD_ID} ${DOCKER_HUB_USER}/${DOCKER_HUB_REPO}:latest"
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${DOCKER_HUB_CREDS}", passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                    sh "echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin"
                    sh "docker push ${DOCKER_HUB_USER}/${DOCKER_HUB_REPO}:${env.BUILD_ID}"
                    sh "docker push ${DOCKER_HUB_USER}/${DOCKER_HUB_REPO}:latest"
                }
            }
        }

        stage('Deploy') {
            steps {
                sh "docker rm -f my-app || true"
                sh "docker run -d --name my-app -p 80:80 ${DOCKER_HUB_USER}/${DOCKER_HUB_REPO}:latest"
            }
        }
    }
}
