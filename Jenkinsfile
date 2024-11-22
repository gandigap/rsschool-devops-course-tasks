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
          - name: node
            image: timbru31/node-alpine-git
            command:
            - cat
            tty: true
          - name: docker
            image: docker:24.0.5
            command:
            - cat
            tty: true
            volumeMounts:
            - name: docker-socket
              mountPath: /var/run/docker.sock
          volumes:
          - name: docker-socket
            hostPath:
              path: /var/run/docker.sock
      '''
      retries 2
    }
  }
  triggers {
    GenericTrigger(
      causeString: 'Triggered by GitHub Push',
      token: 'my-github-token', 
      printPostContent: true,   
      printContributedVariables: true, 
      silentResponse: false
    )
  }
  stages {
    stage('Prepare') {
      steps {
        container('node') {
          script {
            echo "Cloning repository..."
            sh '''
              git clone https://github.com/gandigap/js-app.git repo
              cd repo
              echo "Contents of the repository:"
              ls -la
            '''
          }
        }
      }
    }

    stage('Install Dependencies') {
      steps {
        container('node') {
          script {
            echo "Installing dependencies..."
            sh '''
              cd repo
              npm install
            '''
          }
        }
      }
    }

    stage('Run Tests') {
      steps {
        container('node') {
          script {
            echo "Running tests..."
            sh '''
              cd repo
              npm test
            '''
          }
        }
      }
    }

    stage('Install AWS CLI') {
      steps {
        container('docker') {
          script {
            echo "Installing AWS CLI..."
            sh '''
              apk add --no-cache python3 py3-pip
              pip3 install awscli
              aws --version
            '''
          }
        }
      }
    }

    stage('Build Docker Image') {
      steps {
        container('docker') {
          script {
            echo "Building Docker image..."
            sh '''
              cd repo
              pwd
              docker build -t js-app:latest -f Dockerfile .
            '''
          }
        }
      }
    }

    stage('Publish to ECR') {
      steps {
        container('docker') {
          script {
            echo "Publishing Docker image to ECR..."
            sh '''
              aws ecr get-login-password --region eu-north-1 | docker login --username AWS --password-stdin 195690311722.dkr.ecr.eu-north-1.amazonaws.com
              docker tag js-app:latest 195690311722.dkr.ecr.eu-north-1.amazonaws.com/js-app:latest
              docker push 195690311722.dkr.ecr.eu-north-1.amazonaws.com/js-app:latest
            '''
          }
        }
      }
    }
    stage('Deploy to Kubernetes') {
      steps {
          container('docker') {
              script {
                  echo "Deploying Docker image to Kubernetes..."
                  sh '''
                      kubectl set image deployment/js-app js-app=195690311722.dkr.ecr.eu-north-1.amazonaws.com/js-app:latest
                  '''
              }
          }
        }
      }
  }
  post {
    success {
      script {
        echo "Pipeline completed successfully!"
        emailext(
          subject: 'Jenkins Pipeline Success',
          body: "Pipeline '${env.JOB_NAME}' (#${env.BUILD_NUMBER}) завершился успешно.\n\nПосмотреть результат: ${env.BUILD_URL}",
          to: 'igor.simatic@gmail.com' 
        )
      }
    }
    failure {
      script {
        echo "Pipeline failed!"
        emailext(
          subject: 'Jenkins Pipeline Failure',
          body: "Pipeline '${env.JOB_NAME}' (#${env.BUILD_NUMBER}) завершился с ошибкой.\n\nПосмотреть результат: ${env.BUILD_URL}",
          to: 'igor.simatic@gmail.com' 
        )
      }
    }
  }
}

