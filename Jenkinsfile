// Define the variables
def dockerPublisherName = "rahulraju"
def dockerRepoName = "simple-spring-app"

def gitRepoName = "https://github.com/lRAHULl/simple-spring-app.git"
def customLocalImage = "sample-spring-app-image"

def gitBranch

properties([pipelineTriggers([githubPush()])])
pipeline {
    agent {
        node {
            label 'linux-slave'
        }
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: "**", url: "${gitRepoName}"
                script {
                    gitBranch=getBranchName "${GIT_BRANCH}"
                }
                echo "CHECKING OUT BRANCH   ------  ${gitBranch}"
            }
        }


        stage('Build') {
            steps {
                script {
                    if (gitBranch.contains('release') || gitBranch == 'master'){
                        
                        sh "docker rmi ${customLocalImage} || true"
                        sh "docker build -t ${customLocalImage} ."
                        sendSlackMessage "Build Successul"
                        // sh "printenv"
                    } else if (gitBranch == 'qa' || gitBranch == 'develop') {
                        echo "It is a ${gitBranch} branch"
                    } else if (gitBranch.contains('feature')) {
                        echo "It is a ${gitBranch} branch"
                    }
                }
            }
        }

        stage('Publish') {
            steps {
                script {
                    if (gitBranch.contains('release')){
                        def buildTag = "build-${BUILD_NUMBER}"
                        def gitUrl = "https://${env.GITHUB_USERNAME}:${env.GITHUB_PASSWORD}@github.com/lRAHULl/simple-spring-app.git"

                        sh "git tag ${buildTag}"
                        sh "git push ${gitUrl} ${buildTag}"

                        def ECS_REGISTRY = env.ECS_REGISTRY
                        def ECR_REPO = env.SIMPLE_JAVA_ECR_REPO
                        
                        sh "`aws ecr get-login --registry-ids ${env.AWS_ID} --no-include-email)`"
                        sh """
                            docker tag ${customLocalImage} ${ECS_REGISTRY}/${ECR_REPO}:${buildTag}
                            docker tag ${customLocalImage} ${ECS_REGISTRY}/${ECR_REPO}:latest
                            echo "${ECS_REGISTRY}/${ECR_REPO}"
                            docker push ${ECS_REGISTRY}/${ECR_REPO}
                        """ 

                        sendSlackMessage "Publish Successul"
                    } else if (gitBranch == 'master') {
                        sh "docker tag ${customLocalImage} ${dockerPublisherName}/${dockerRepoName}:build-${BUILD_NUMBER}"
                        sh "docker tag ${customLocalImage} ${dockerPublisherName}/${dockerRepoName}:latest"
                        sh "docker push ${dockerPublisherName}/${dockerRepoName}"
                    } else if (gitBranch == 'qa' || gitBranch == 'develop') {
                        echo "It is a ${gitBranch} branch"
                    } else if (gitBranch.contains('feature')) {
                        echo "It is a ${gitBranch} branch"
                    }
                }
            }
        }
    }
}

String getBranchName(String inputString) {
    echo "INPUT ====> ${inputString}"
    return inputString.split("/")[1]
}

void sendSlackMessage(String message) {
    slackSend botUser: true, channel: 'private_s3_file_upload', failOnError: true, message: "Message From http://3.231.228.54:8080/: \n${message}", teamDomain: 'codaacademy2020', tokenCredentialId: 'coda-academy-slack'
}
