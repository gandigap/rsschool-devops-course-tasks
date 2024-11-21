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
  stages {
    stage('Prepare') {
      steps {
        container('node') {
          script {
            echo "Cloning repository..."
            sh '''
              git clone https://github.com/gandigap/rsschool-devops-course-tasks.git repo
              cd repo
              git checkout task-6
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
              cd repo/js-app
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
              cd repo/js-app
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
              cd repo/js-app
              pwd
              ls -la
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
  }
}
