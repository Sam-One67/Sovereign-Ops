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
                // Ensuring no permission issues inside the container
                sh "git config --global --add safe.directory ${WORKSPACE} || true"
            }
        }
        
        stage('Cleanup & Checkout') {
            steps {
                cleanWs()
                checkout scm
            }
        }

        stage('Build & Push Image') {
            steps {
                // Building the image with a unique tag
                sh "docker build -t ${DOCKER_HUB_USER}/${DOCKER_HUB_REPO}:${env.BUILD_ID} ."
                sh "docker tag ${DOCKER_HUB_USER}/${DOCKER_HUB_REPO}:${env.BUILD_ID} ${DOCKER_HUB_USER}/${DOCKER_HUB_REPO}:latest"
                
                // Pushing to Docker Hub using stored credentials
                withCredentials([usernamePassword(credentialsId: "${DOCKER_HUB_CREDS}", passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                    sh "echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin"
                    sh "docker push ${DOCKER_HUB_USER}/${DOCKER_HUB_REPO}:${env.BUILD_ID}"
                    sh "docker push ${DOCKER_HUB_USER}/${DOCKER_HUB_REPO}:latest"
                }
            }
        }

        stage('Deploy with Docker Compose') {
            steps {
                // Using Docker Compose to pull the latest image and restart the service
                // We pass environment variables so the YAML file knows which image to use
                sh "DOCKER_HUB_USER=${DOCKER_HUB_USER} DOCKER_HUB_REPO=${DOCKER_HUB_REPO} docker-compose pull"
                sh "DOCKER_HUB_USER=${DOCKER_HUB_USER} DOCKER_HUB_REPO=${DOCKER_HUB_REPO} docker-compose up -d"
            }
        }
    }
}
