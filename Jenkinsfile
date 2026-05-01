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
                // Purana kachra saaf karne ke liye
                cleanWs()
                // Naye siray se code uthane ke liye
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
                // Docker Hub par login aur push
                withCredentials([usernamePassword(credentialsId: "${DOCKER_HUB_CREDS}", passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                    sh "echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin"
                    sh "docker push ${DOCKER_HUB_USER}/${DOCKER_HUB_REPO}:${env.BUILD_ID}"
                    sh "docker push ${DOCKER_HUB_USER}/${DOCKER_HUB_REPO}:latest"
                }
            }
        }
        stage('Deploy') {
            steps {
                // Purana container hata kar naya chalana
                sh "docker rm -f my-app || true"
                sh "docker run -d --name my-app -p 80:80 ${DOCKER_HUB_USER}/${DOCKER_HUB_REPO}:latest"
            }
        }
    }
}
