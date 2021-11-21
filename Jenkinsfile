pipeline {
    agent {
        docker {
            alwaysPull true
            image 'archlinux:base-devel'
        }
    }
    stages {
        stage('Build') {
            steps {
                sh 'bash ./build.sh'
            }
        }
        stage('Deliver') {
            steps {
                sh 'echo TODO: not implemented'
            }
        }
    }
}
