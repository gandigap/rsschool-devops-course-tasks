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
  }
}