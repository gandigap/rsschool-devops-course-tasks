pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "my-app:${env.BUILD_NUMBER}" // Уникальный тег для образа
        ECR_REGISTRY = "<ECR_REGISTRY_URL>"         // URL вашего ECR
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                script {
                    sh 'npm install'
                }
            }
        }

        stage('Run Tests') {
            steps {
                script {
                    sh 'npm test'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh """
                    docker build -t $ECR_REGISTRY/$DOCKER_IMAGE .
                    docker tag $ECR_REGISTRY/$DOCKER_IMAGE:latest $ECR_REGISTRY/$DOCKER_IMAGE
                    """
                }
            }
        }

        stage('Push to ECR') {
            steps {
                script {
                    sh """
                    aws ecr get-login-password --region <AWS_REGION> | docker login --username AWS --password-stdin $ECR_REGISTRY
                    docker push $ECR_REGISTRY/$DOCKER_IMAGE
                    """
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    sh """
                    helm upgrade --install js-app ./helm/js-app-chart \
                        --set image.repository=$ECR_REGISTRY/$DOCKER_IMAGE
                    """
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline completed.'
        }
        failure {
            echo 'Pipeline failed.'
        }
    }
}
