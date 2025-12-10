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
            steps {
                ansiblePlaybook(
                    credentialsId: 'jenkins-key',
                    disableHostKeyChecking: true,
                    installation: 'ansible',
                    inventory: 'inventory.yaml',
                    playbook: 'amazon-playbook.yml',
                    become: true,                    // recommended for Nginx tasks
                    extraVars: [
                        ansible_user: "ec2-user"
                    ]
                )
            }
        }

        stage('Run Ansible - Backend') {
            steps {
                ansiblePlaybook(
                    credentialsId: 'jenkins-key',
                    disableHostKeyChecking: true,
                    installation: 'ansible',
                    inventory: 'inventory.yaml',
                    playbook: 'ubuntu-playbook.yml',
                    become: true,                     // REQUIRED
                    extraVars: [
                        ansible_user: "ubuntu"
                    ]
                )
            }
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
