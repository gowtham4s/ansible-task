pipeline {
    agent any

    stages {
        

        stage('Checkout') {
            steps {
                sh 'echo cloning repo'
                git branch: 'main' , url: 'https://github.com/saivarun0509/ansible-task.git' 
            }
        }
        
        stage('Terraform Apply') {
            steps {
                script {
                    dir("${WORKSPACE}") {
                    sh 'terraform init'
                    sh 'terraform validate'
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds]]) {
                        sh 'terraform plan'
                        sh 'terraform apply'
                    }
                }
            }
        }
    }
        
        stage('Ansible Deployment') {
            steps {
                script {
                    ansiblePlaybook becomeUser: 'ec2-user', credentialsId: 'amazonlinux', disableHostKeyChecking: true, installation: 'ansible', inventory: '/var/lib/jenkins/workspace/challenge' , playbook: '/var/lib/jenkins/workspace/challenge', vaultTmpPath: ''
                    ansiblePlaybook become: true, credentialsId: 'ubuntuuser', disableHostKeyChecking: true, installation: 'ansible', inventory: '/var/lib/jenkins/workspace/challenge', playbook: '/var/lib/jenkins/workspace/challenge', vaultTmpPath: ''
                }
            }
        }
    }
}
