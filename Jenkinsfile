pipeline {
    agent any
    
    environment {
        DOCKER_HUB_USER = 'san647'
        DOCKER_HUB_REPO = 'webapp'
        DOCKER_HUB_CREDS = credentials('docker-hub-credentials')
        AWS_CREDS = credentials('aws-creds') // Jo aapne abhi add kiye
    }

    stages {
        stage('Terraform Infrastructure') {
            steps {
                dir('terraform') {
                    // Terraform commands with AWS credentials
                    withEnv(["AWS_ACCESS_KEY_ID=${AWS_CREDS_USR}", "AWS_SECRET_ACCESS_KEY=${AWS_CREDS_PSW}", "AWS_DEFAULT_REGION=ap-south-1"]) {
                        sh 'terraform init'
                        sh 'terraform plan'
                        sh 'terraform apply -auto-approve'
                    }
                }
            }
        }

        stage('Build & Push Image') {
            steps {
                sh "docker build -t ${DOCKER_HUB_USER}/${DOCKER_HUB_REPO}:${env.BUILD_NUMBER} ."
                sh "docker tag ${DOCKER_HUB_USER}/${DOCKER_HUB_REPO}:${env.BUILD_NUMBER} ${DOCKER_HUB_USER}/${DOCKER_HUB_REPO}:latest"
                
                sh "echo ${DOCKER_HUB_CREDS_PSW} | docker login -u ${DOCKER_HUB_CREDS_USR} --password-stdin"
                sh "docker push ${DOCKER_HUB_USER}/${DOCKER_HUB_REPO}:${env.BUILD_NUMBER}"
                sh "docker push ${DOCKER_HUB_USER}/${DOCKER_HUB_REPO}:latest"
            }
        }

        stage('Deploy with Docker Compose') {
            steps {
                sh "DOCKER_HUB_USER=${DOCKER_HUB_USER} DOCKER_HUB_REPO=${DOCKER_HUB_REPO} docker-compose pull"
                sh "DOCKER_HUB_USER=${DOCKER_HUB_USER} DOCKER_HUB_REPO=${DOCKER_HUB_REPO} docker-compose up -d"
            }
        }
    }
}
