pipeline {
    agent {
    kubernetes {
      yaml '''
        apiVersion: v1
        kind: Pod
        metadata:
          labels:
            some-label: some-label-value
        spec:
          containers:
          - name: maven
            image: maven:3.9.9-eclipse-temurin-17
            command:
            - cat
            tty: true
          - name: busybox
            image: busybox
            command:
            - cat
            tty: true
        '''
      retries 2
    }
  }

    environment {
        AWS_REGION = credentials('aws-region') // Регион AWS
        ECR_REPO  = 'js-app-repository'       // Имя репозитория ECR
        AWS_ACCOUNT_ID = credentials('aws-account-id')      // AWS Account ID
        AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')  // Имя учетных данных
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')// Имя учетных данных
    }

    stages {
        stage('Checkout') {
            agent { label 'Permanent Agent' }
            steps {
                echo 'Просто старт'
            }
        }

        stage('Validate Inputs') {
            agent { label 'Permanent Agent' }
            steps {
                script {
                    if (!AWS_REGION || !ECR_REPO) {
                        error("AWS_REGION или ECR_REPO не заданы!")
                    }
                }
            }
        }

        stage('Authenticate with ECR') {
            agent { label 'Permanent Agent' }
            steps {
                script {
                    echo "Аутентификация в AWS ECR"
                    sh '''
                    aws ecr get-login-password --region ${AWS_REGION} | \
                    docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                    '''
                }
            }
        }

        stage('SuperPuper') {
            agent { label 'Permanent Agent' }
            steps {
                script {
                    echo "Show images"
                    sh '''
                    aws ecr describe-images --repository-name js-app-repository --output json
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            agent { label 'Permanent Agent' }
            steps {
                script {
                    echo "Разворачивание приложения в Kubernetes..."
                    withCredentials([file(credentialsId: 'my-deployment-file', variable: 'DEPLOYMENT_FILE')]) {
                        sh 'kubectl apply -f $DEPLOYMENT_FILE'
                    }
                }
            }
        }

        stage('Check Deployment Status') {
            agent { label 'Permanent Agent' }
            steps {
                script {
                    echo "Проверка статуса развертывания..."
                    sh '''
                    kubectl get pods -l app=js-app
                    kubectl get svc js-app-service
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed. Please check logs.'
        }
    }
}
