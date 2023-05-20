pipeline {
  agent any

  environment {
        TEST="test"
  }
  
  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build and push Docker images') {
      steps {
        sh 'docker-compose build'
        sh 'docker-compose push'
      }
    }

    stage('Deploy') {
      steps {
        script {
          sh 'ssh user@example.com "docker-compose pull && docker-compose up -d"'
        }
      }
    }
  }
}