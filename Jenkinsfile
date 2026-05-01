pipeline {
    agent any
    environment {
        DOCKER_HUB_USER = 'san647'
        DOCKER_HUB_REPO = 'webapp'
        DOCKER_HUB_CREDS = 'docker-hub-credentials'
    }
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build("${DOCKER_HUB_USER}/${DOCKER_HUB_REPO}:${env.BUILD_ID}")
                }
            }
        }
        stage('Push to Docker Hub') {
            steps {
                script {
                    docker.withRegistry('', DOCKER_HUB_CREDS) {
                        dockerImage.push()
                        dockerImage.push('latest')
                    }
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
