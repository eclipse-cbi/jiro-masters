pipeline {

  agent {
    label 'docker-build'
  }

  options { 
    buildDiscarder(logRotator(numToKeepStr: '5'))
    disableConcurrentBuilds()
  }

  triggers {
    cron('H H * * */3')
  }

  stages {
    stage('Build and push JIRO master images') {
      steps {
        withDockerRegistry([credentialsId: 'e93ba8f9-59fc-4fe4-a9a7-9a8bd60c17d9', url: 'https://index.docker.io/v1/']) {
          sh 'make all'
        }
      }
    }
  }

  post {
    failure {
      mail to: '',
        subject: "[CBI] Build Failure ${currentBuild.fullDisplayName}",
        body: "Project: ${env.JOB_NAME}<br/>Build Number: ${env.BUILD_NUMBER}<br/>Build URL: ${env.BUILD_URL}"
    }
    fixed {
      mail to: '',
        subject: "[CBI] Back to normal ${currentBuild.fullDisplayName}",
        body: "Project: ${env.JOB_NAME}<br/>Build Number: ${env.BUILD_NUMBER}<br/>Build URL: ${env.BUILD_URL}"
    }
    cleanup {
      deleteDir() /* clean up workspace */
    }
  }
}
