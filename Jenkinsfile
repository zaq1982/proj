pipeline {
    agent any

    stages {
        stage('Terraform apply') {
            steps {
                sh 'pwd'
                withCredentials([string(credentialsId: 'sec1', variable: 'secret'), string(credentialsId: 'sec2', variable: 'secret2')]) {
                    sh '''
                      export AWS_ACCESS_KEY_ID=$secret
                      export AWS_SECRET_ACCESS_KEY=$secret2
                      cd Terraform && pwd
                      PATH=/usr/local/bin
                      terraform init
                      terraform plan
                    '''
                    
                }
                
                
                
            }
        }
        stage('Ansible apply') {
            steps {
                sh '''
                 cd Ansible && pwd
                '''
            }
        }

    }
}

