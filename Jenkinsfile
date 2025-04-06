def AGENT_LABEL = "decentralizedagent"

pipeline {
    agent {
        label AGENT_LABEL
    }

    environment {
        AWS_ACCESS_KEY_ID = credentials('aws_key')
        AWS_SECRET_ACCESS_KEY = credentials('aws_secret')
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', credentialsId: 'TerraformPull', url: 'https://github.com/johnmlhll/pub-iac_tf-jenkins_kubeinfra'
            }
        }
        stage('Terraform Init') {
            steps {
                sh 'terraform -chdir=iac init'
            }
        }
        stage('Terraform Apply') {
            steps {
                sh 'terraform -chdir=iac ${action} --auto-approve'
            }
        }
    }
    post {
        always {
            cleanWs()
        }
    }
}