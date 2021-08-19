pipeline {
    agent any

    stages {
        stage('Terraform apply') {
            steps {
                sh 'pwd'
                withCredentials([string(credentialsId: 'sec1', variable: 'AWSID'), string(credentialsId: 'sec2', variable: 'AWSKEY')]) {
                    sh '''
                      export AWS_ACCESS_KEY_ID=$AWSID
                      export AWS_SECRET_ACCESS_KEY=$AWSKEY
                      cd Terraform && pwd
                      PATH=/usr/local/bin
                      terraform version
                      terraform init
                      terraform plan
                      terraform apply --auto-approve
                    '''
                }
            }
        }
        stage('Ansible apply') {
            steps {
                sh '''
                 cd Ansible && pwd
                 chmod 400 key1.pem
                 ansible-playbook -i inventory playbook.yml -v
                '''
            }
        }

    }
}

