// Declarative Jenkins Pipeline definition for building and publishing the Jenkins Navigator Docker image
pipeline {
    // Executes this pipeline on any available Jenkins agent/executor slot
    agent any

    // Automatically triggers the build by polling the SCM for changes
    triggers {
        // Polls the SCM (Git repository) every minute for any updates or new commits
        pollSCM('* * * * *')
    }

    // Defines global environment variables used across multiple build stages
    environment {
        DOCKER_HUB_USER = 'ajaygangwar945'        // Target Docker Hub username/namespace
        IMAGE_NAME      = 'jenkins-navigator'      // Target repository/image name
        IMAGE_TAG       = "${env.BUILD_NUMBER}"    // Unique tag derived from current Jenkins build execution number
    }

    stages {

        // Stage 1: Fetches the latest source code from the configured Git repository
        stage('Checkout Code') {
            steps {
                // checkout scm automatically configures the checkout stage based on job parameters
                checkout scm
            }
        }

        // Stage 2: Builds the production-ready Nginx Docker image using the Dockerfile
        stage('Build Docker Image') {
            steps {
                echo 'Building Docker Image...'

                // Compiles the image using current folder context and tags it with the unique build number
                bat "docker build -t %DOCKER_HUB_USER%/%IMAGE_NAME%:%BUILD_NUMBER% ."

                // Tags the newly built build-number image as the latest image locally
                bat "docker tag %DOCKER_HUB_USER%/%IMAGE_NAME%:%BUILD_NUMBER% %DOCKER_HUB_USER%/%IMAGE_NAME%:latest"
            }
        }

        // Stage 3: Authenticates and publishes the image tags to the Docker Hub registry
        stage('Push to Docker Hub') {
            steps {

                // Safely extracts credentials from Jenkins secure credentials store
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-creds', // ID of the credential saved in Jenkins
                        usernameVariable: 'DOCKER_USER',   // Variable mapped to username
                        passwordVariable: 'DOCKER_PASS'    // Variable mapped to password/token
                    )
                ]) {

                    // Logs into Docker Hub registry using credentials variables
                    bat "docker login -u %DOCKER_USER% -p %DOCKER_PASS%"

                    // Pushes the unique build-number versioned tag to Docker Hub
                    bat "docker push %DOCKER_HUB_USER%/%IMAGE_NAME%:%BUILD_NUMBER%"

                    // Pushes the latest tracking tag to Docker Hub
                    bat "docker push %DOCKER_HUB_USER%/%IMAGE_NAME%:latest"
                }
            }
        }
    }

    // Lifecycle hooks executed after the pipeline completes
    post {

        // Always executes to clean up credentials session
        always {
            // Logs out of Docker registry to prevent lingering secure credentials in session memory
            bat "docker logout"
        }

        // Executes only when all stages in the pipeline run successfully
        success {
            echo 'Pipeline completed successfully!'
        }

        // Executes if any stage in the pipeline fails
        failure {
            echo 'Pipeline failed!'
        }
    }
}
