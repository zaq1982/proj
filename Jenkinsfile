pipeline {
    agent any

    stages {
        stage('step1') {
            steps {
                sh 'pwd'
                withCredentials([string(credentialsId: 'sec1', variable: 'secret'), string(credentialsId: 'sec2', variable: 'secret2')]) {
                    sh 'export AWS_ACCESS_KEY_ID="$secret"'
                    sh 'export AWS_SECRET_ACCESS_KEY="$secret2"'
                    sh """
                      cd Terraform && pwd
                      PATH=/usr/local/bin
                      terraform init
                      terraform plan"
                    
                }
                
                
                
            }
        }
    }
}

