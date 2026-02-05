pipeline {
    agent any

    environment {
        DOCKER_HUB_CREDS = credentials('docker-hub')
        SONAR_TOKEN = credentials('sonar-token')

        BACKEND_IMAGE = "gig-router-backend"
        FRONTEND_IMAGE = "gig-router-frontend"
        IMAGE_TAG = "${env.GIT_COMMIT}"
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

        stage('Trivy FS Scan') {
            steps {
                sh 'trivy fs . --severity CRITICAL,HIGH'
            }
        }

        stage('Build Backend Image') {
            steps {
                sh """
                docker build -t ${DOCKER_HUB_CREDS_USR}/${BACKEND_IMAGE}:${IMAGE_TAG} ./backend
                """
            }
        }

        stage('Trivy Backend Image') {
            steps {
                sh """
                trivy image ${DOCKER_HUB_CREDS_USR}/${BACKEND_IMAGE}:${IMAGE_TAG} --severity CRITICAL,HIGH
                """
            }
        }

        stage('Build Frontend Image') {
            steps {
                sh """
                docker build -t ${DOCKER_HUB_CREDS_USR}/${FRONTEND_IMAGE}:${IMAGE_TAG} ./frontend
                """
            }
        }

        stage('Trivy Frontend Image') {
            steps {
                sh """
                trivy image ${DOCKER_HUB_CREDS_USR}/${FRONTEND_IMAGE}:${IMAGE_TAG} --severity CRITICAL,HIGH
                """
            }
        }

        stage('Push Images (master only)') {
            when {
                branch 'master'
            }
            steps {
                sh """
                echo $DOCKER_HUB_CREDS_PSW | docker login -u $DOCKER_HUB_CREDS_USR --password-stdin
                docker push ${DOCKER_HUB_CREDS_USR}/${BACKEND_IMAGE}:${IMAGE_TAG}
                docker push ${DOCKER_HUB_CREDS_USR}/${FRONTEND_IMAGE}:${IMAGE_TAG}
                """
            }
        }
    }
}
