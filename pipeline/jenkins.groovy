pipeline {
    agent any
    parameters {
        choice(name: 'OS', choices: ['linux', 'darwin', 'windows'], description: 'Pick OS')
        choice(name: 'ARCH', choices: ['amd64', 'arm64'], description: 'Pick ARCH')
    }

    environment {
        GITHUB_TOKEN=credentials('styre79')
        REPO = 'https://github.com/Styre79/skbot'
        BRANCH = 'main'
    }

    stages {

        stage('clone') {
            steps {
                echo 'Clone Repository'
                git branch: "${BRANCH}", url: "${REPO}"
            }
        }

        stage('test') {
            steps {
                echo 'Testing started'
                sh "make test"
            }
        }

        stage('build') {
            steps {
                echo "Building for platform ${params.OS} on ${params.ARCH}"
                sh "make ${params.OS} ${params.ARCH}"
            }
        }

        stage('image') {
            steps {
                echo "Making image for platform ${params.OS} on ${params.ARCH}"
                sh "make image-${params.OS} ${params.ARCH}"
            }
        }
        
        stage('push image') {
            steps {
                sh "make -n ${params.OS} ${params.ARCH} image push"
            }
        } 
    }
}