pipeline {
    agent any
    
    environment {
        DOCKER_HUB_USER = 'san647'
        DOCKER_HUB_REPO = 'webapp'
        DOCKER_HUB_CREDS = 'docker-hub-credentials'
    }
    
    stages {
        stage('Cleanup & Checkout') {
            steps {
                // Wipe the workspace to prevent "not a git directory" errors
                cleanWs()
                // Retrieve the latest code from the source control
                checkout scm
            }
        }
        
        stage('Build Docker Image') {
            steps {
                // Build the image using the unique Build ID and tag it as 'latest'
                sh "docker build -t ${DOCKER_HUB_USER}/${DOCKER_HUB_REPO}:${env.BUILD_ID} ."
                sh "docker tag ${DOCKER_HUB_USER}/${DOCKER_HUB_REPO}:${env.BUILD_ID} ${DOCKER_HUB_USER}/${DOCKER_HUB_REPO}:latest"
            }
        }
        
        stage('Push to Docker Hub') {
            steps {
                // Securely login to Docker Hub and push both specific and latest tags
                withCredentials([usernamePassword(credentialsId: "${DOCKER_HUB_CREDS}", passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                    sh "echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin"
                    sh "docker push ${DOCKER_HUB_USER}/${DOCKER_HUB_REPO}:${env.BUILD_ID}"
                    sh "docker push ${DOCKER_HUB_USER}/${DOCKER_HUB_REPO}:latest"
                }
            }
        }
        
        stage('Deploy') {
            steps {
                // Remove the existing container if it exists and run the new one
                sh "docker rm -f my-app || true"
                sh "docker run -d --name my-app -p 80:80 ${DOCKER_HUB_USER}/${DOCKER_HUB_REPO}:latest"
            }
        }
    }
}
