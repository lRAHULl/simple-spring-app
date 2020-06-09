// To Work with this script - SET the ENV variables ECS_REGISTRY - your AWS ECR Registry, SIMPLE_JAVA_ECR_REPO - Your AWS ECR Repo in the JENKINS server.
// Create a ECS cluster named simple-java-cluster and ECS service named simple-java-service
// Add the AWS creds in ~/.aws/credentials in the node the job is run.

// Define the variables.
def dockerImage = "${env.ECS_REGISTRY}/${env.SIMPLE_JAVA_ECR_REPO}:${params.imageTag}"

def deploymentEnv = "http://34.224.5.40"
def stageEnv = "3.92.78.73"
def stageEnvUser = "ubuntu"
def appPort = "8080"
def devPort = "8080"
def qaPort = "8085"
def stagePort = "8080"
def appName = "java-spring-app"

// Add Properties.
// 1. parameter to get the input before building 
properties([parameters([string(defaultValue: 'latest', description: 'Tag of the image to be built from simple-spring-app repository in ECR.', name: 'imageTag', trim: false)])])
// Declarative Pipeline Script.
pipeline {
    // Define agents block
    agent {
        // The Slave node for the job to run.
        node {
            // Label of the slave node
            label 'linux-slave'
        }
    }
    
    // Define Stages block
    stages {
        // Deploy to Developement enironment.
        stage('Dev Deploy') {
            steps {
                simpleDeploy(appName: appName, 
                            stage: 'dev',
                            hostPort: devPort,
                            containerPort: appPort,
                            dockerImage: dockerImage
                            )
            }
        }
        
        // Get Approval from Develpement team to proceed to QA Deployment
        stage('DEV Approval') {
            steps {
                sendSlackMessage "Check the Dev environment at ${deploymentEnv}:${devPort}/"
                sendSlackMessage "GOTO: ${BUILD_URL}console to proceed the deployment to QA environment"
                timeout(time: 1, unit: 'HOURS') {
                    input message: 'Proceed to Deploy to QA environment?', ok: 'Yes'
                }
            }
        }
        
        // Deploy to QA enironment.
        stage('QA Deploy') {
            steps {
                simpleDeploy(appName: appName, 
                            stage: 'qa',
                            hostPort: qaPort,
                            containerPort: appPort,
                            dockerImage: dockerImage
                            )
            }
        }
        
        // Get Approval from QA team to proceed to 'Stage' Deployment
        stage('QA Approval') {
            steps {
                sendSlackMessage "Check the QA environment at ${deploymentEnv}:${qaPort}/"
                sendSlackMessage "GOTO: ${BUILD_URL}console to proceed the deployment to Prod environment"
                timeout(time: 1, unit: 'HOURS') {
                    input message: 'Proceed to Deploy to Staging environment?', ok: 'Yes'
                }
            }   
        }

        stage('Staging Deploy') {
            steps {
                sshagent(['ubuntu']) {
                    sh "ssh -o StrictHostKeyChecking=no ${stageEnvUser}@${stageEnv} docker pull ${dockerImage}"
                    // sh "ssh ${stageEnvUser}@${stageEnv} docker ps"
                    script {
                        try {
                            sh "ssh ${stageEnvUser}@${stageEnv} docker service update --image ${dockerImage} ${appName}-stage"
                        } catch(err) {
                            sh "ssh ${stageEnvUser}@${stageEnv} docker service create --replicas 5 -p ${stagePort}:${appPort} --name ${appName}-stage --update-delay 30s ${dockerImage}"
                        }
                    }
                }
            }
        }
        

        // Get Approval from Project Manager or Lead Engineer to proceed to 'Production' Deployment
        stage('Staging Approval') {
            steps {
                sendSlackMessage "Check the Staging environment at ${stageEnv}:${stagePort}/"
                sendSlackMessage "GOTO: ${BUILD_URL}console to proceed the deployment to Prod environment"
                timeout(time: 1, unit: 'HOURS') {
                    input message: 'Proceed to Deploy to Production environment?', ok: 'Yes'
                }
            }   
        }

        // Deploy to Prod enironment(AWS ECS).
        stage('Prod Deploy') {
           steps {
                git branch: "**", url: "https://github.com/lRAHULl/simple-spring-app.git"
                sh """
                    sed -e "s;DOCKER_IMAGE_NAME;${dockerImage};g" ${WORKSPACE}/template.json > taskDefinition.json
                """
                // create a new revision of Task-deinition with the given template in the https://github.com/lRAHULl/simple-spring-app/template.json
                // Update the ECS service with the new task definition.
                sh '''
                    aws ecs register-task-definition --family simple-java-app --cli-input-json file://taskDefinition.json --region us-east-1
                    aws ecs update-service --cluster simple-java-cluster --service simple-java-service --task-definition simple-java-app --desired-count 1
                '''
           }
        }
        
        // Cleanup the unused Docker resources.
        stage('Cleanup') {
            steps {
                sh "docker system prune -f || true"
            }
        }
    }
}

// Used for the deployment of dev and qa environments for testing if the desired code changes are working.
def simpleDeploy(Map args) {
    sh "docker stop ${args.appName}-${args.stage} || true"
    sh "docker rm ${args.appName}-${args.stage} || true"
    sh "docker run -d -p ${args.hostPort}:${args.containerPort} --name ${args.appName}-${args.stage} ${args.dockerImage}"
}

// Method to
void sendSlackMessage(String message) {
    slackSend botUser: true, channel: 'private_s3_file_upload', failOnError: true, message: "${message}", teamDomain: 'codaacademy2020', tokenCredentialId: 'coda-academy-slack'
}