def dockerImage = "${env.ECS_REGISTRY}/${env.SIMPLE_JAVA_ECR_REPO}:${params.imageTag}"

properties([parameters([string(defaultValue: 'latest', description: 'Tag of the image to be built from simple-spring-app repository in ECR.', name: 'imageTag', trim: false)])])
pipeline {
    agent {
        node {
            label 'linux-slave'
        }
    }
    
    stages {
        stage('Dev Deploy') {
            steps {
                sh "docker stop java-spring-app-dev || true"
                sh "docker rm java-spring-app-dev || true"
                sh "docker run -d -p 8080:8080 --name java-spring-app-dev ${dockerImage}"
            }
        }
        
        stage('QA Approval') {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    input message: 'Proceed to Deploy to QA environment?', ok: 'Yes'
                }
            }
        }
        
        stage('QA Deploy') {
            steps {
                sh "docker stop java-spring-app-qa || true"
                sh "docker rm java-spring-app-qa || true"
                sh "docker run -d -p 8085:8080 --name java-spring-app-qa ${dockerImage}"
            }
        }
        
        stage('Cleanup') {
            steps {
                sh "docker system prune -f || true"
            }
        }
    }
}