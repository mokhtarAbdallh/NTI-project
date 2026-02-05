pipeline {
    agent any

    environment {
        DOCKER_HUB_USERNAME = credentials('docker-hub').username
        DOCKER_HUB_PASSWORD = credentials('docker-hub').password

        BACKEND_IMAGE = "gig-router-backend"
        FRONTEND_IMAGE = "gig-router-frontend"
        IMAGE_TAG = "${env.GIT_COMMIT}"

        SONAR_TOKEN = credentials('sonar-token')
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('SonarCloud Analysis') {
        steps {
            sh """
            sonar-scanner \
            -Dsonar.projectKey=gig-router-platform-ci \
            -Dsonar.organization=gig-router-org \
            -Dsonar.sources=. \
            -Dsonar.host.url=https://sonarcloud.io \
            -Dsonar.login=$SONAR_TOKEN
            """
        }
}

        // stage('SonarCloud Analysis') {
        //     steps {
        //         sh """
        //         sonar-scanner \
        //           -Dsonar.projectKey=YOUR_PROJECT_KEY \
        //           -Dsonar.organization=YOUR_ORG \
        //           -Dsonar.sources=. \
        //           -Dsonar.host.url=https://sonarcloud.io \
        //           -Dsonar.login=$SONAR_TOKEN
        //         """
        //     }
        // }

        stage('Trivy FS Scan') {
            steps {
                sh 'trivy fs . --severity CRITICAL,HIGH'
            }
        }

        stage('Build Backend Image') {
            steps {
                sh """
                docker build -t $DOCKER_HUB_USERNAME/$BACKEND_IMAGE:$IMAGE_TAG ./backend
                """
            }
        }
IMAGE_TAG
        stage('Trivy Backend Image') {
            steps {
                sh """
                trivy image $DOCKER_HUB_USERNAME/$BACKEND_IMAGE:$IMAGE_TAG --severity CRITICAL,HIGH
                """
            }
        }

        stage('Build Frontend Image') {
            steps {
                sh """
                docker build -t $DOCKER_HUB_USERNAME/$FRONTEND_IMAGE:$IMAGE_TAG ./frontend
                """
            }
        }

        stage('Trivy Frontend Image') {
            steps {
                sh """
                trivy image $DOCKER_HUB_USERNAME/$FRONTEND_IMAGE:$IMAGE_TAG --severity CRITICAL,HIGH
                """
            }
        }

        stage('Push Images (master only)') {
            when {
                branch 'master'
            }
            steps {
                sh """
                echo $DOCKER_HUB_PASSWORD | docker login -u $DOCKER_HUB_USERNAME --password-stdin
                docker push $DOCKER_HUB_USERNAME/$BACKEND_IMAGE:$IMAGE_TAG
                docker push $DOCKER_HUB_USERNAME/$FRONTEND_IMAGE:$IMAGE_TAG
                """
            }
        }
    }
}
