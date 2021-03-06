def dockerImage = "${env.ECS_REGISTRY}/${env.SIMPLE_JAVA_ECR_REPO}:${params.imageTag}"

def deploymentEnv = "http://34.224.5.40"
def appPort = "8080"
def devPort = "8080"
def qaPort = "8085"
def appName = "java-spring-app"
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
                localDeploy(appName: appName, 
                            stage: 'dev',
                            hostPort: devPort,
                            containerPort: appPort,
                            dockerImage: dockerImage
                            )
            }
        }
        
        stage('DEV Approval') {
            steps {
                sendSlackMessage "Check the Dev environment at ${deploymentEnv}:${devPort}/"
                sendSlackMessage "GOTO: ${BUILD_URL}console to proceed the deployment to QA environment"
                timeout(time: 1, unit: 'HOURS') {
                    input message: 'Proceed to Deploy to QA environment?', ok: 'Yes'
                }
            }
        }
        
        stage('QA Deploy') {
            steps {
                localDeploy(appName: appName, 
                            stage: 'qa',
                            hostPort: qaPort,
                            containerPort: appPort,
                            dockerImage: dockerImage
                            )
            }
        }
        
        stage('Cleanup') {
            steps {
                sh "docker system prune -f || true"
            }
        }
    }
}

def localDeploy(Map args) {
    sh "docker stop ${args.appName}-${args.stage} || true"
    sh "docker rm ${args.appName}-${args.stage} || true"
    sh "docker run -d -p ${args.hostPort}:${args.containerPort} --name ${args.appName}-${args.stage} ${args.dockerImage}"
}

void sendSlackMessage(String message) {
    slackSend botUser: true, channel: 'private_s3_file_upload', failOnError: true, message: "${message}", teamDomain: 'codaacademy2020', tokenCredentialId: 'coda-academy-slack'
}