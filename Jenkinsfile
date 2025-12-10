pipeline {
    agent any

    environment {
        TF_VAR_key_name = 'jenkins-key'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
                    sh 'terraform init -input=false'
                    sh 'terraform validate'
                    sh 'terraform plan -out=tfplan -input=false'
                    sh 'terraform apply -input=false -auto-approve'
                }
            }
        }

        stage('Wait for instances') {
            steps {
                sh 'sleep 30'
            }
        }

        stage('Run Ansible - Frontend') {
    ansiblePlaybook(
        playbook: 'amazon-playbook.yml',
        inventory: 'inventory.yaml',
        credentialsId: 'jenkins-key',
        extras: '-u ec2-user',
        become: true,
        becomeUser: 'root'
    )
}

        stage('Run Ansible - Backend') {
    ansiblePlaybook(
        playbook: 'ubuntu-playbook.yml',
        inventory: 'inventory.yaml',
        credentialsId: 'jenkins-key',
        extras: '-u ubuntu',
        become: true,
        becomeUser: 'root'
    )
}

        stage('Post-checks') {
            steps {
                script {
                    def backend_ip = sh(returnStdout: true, script: "terraform output -raw backend_public_ip").trim()
                    def frontend_ip = sh(returnStdout: true, script: "terraform output -raw frontend_public_ip").trim()

                    echo "Frontend IP: ${frontend_ip}"
                    echo "Backend IP: ${backend_ip}"

                    sh "curl -m 10 -I http://${frontend_ip} || true"
                    sh "curl -m 10 -I http://${backend_ip}:19999 || true"
                }
            }
        }
    }
}
