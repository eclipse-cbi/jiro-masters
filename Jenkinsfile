pipeline {

  agent {
      kubernetes {
          label 'docker-agent'
          yaml '''
              apiVersion: v1
              kind: Pod
              spec:
                containers:
                  - name: docker-agent
                    image: eclipsecbi/docker-kubectl:0.0.1
                    command:
                      - cat
                    tty: true
                    resources:
                      limits:
                        cpu: 1
                        memory: 1Gi
                    volumeMounts:
                      - mountPath: /home/jenkins/agent/.docker
                        name: dot-docker
                        readOnly: false
                      - mountPath: /home/default/.kube
                        name: dot-kube
                        readOnly: false
                    env:
                    - name: "HOME"
                      value: "/home/jenkins/agent"
                  - name: jnlp
                    resources:
                      limits:
                        cpu: 1
                        memory: 1Gi
                volumes:
                  - name: dot-docker
                    emptyDir: {}
                  - name: dot-kube
                    emptyDir: {}
          '''
      }
  }

  options {
    buildDiscarder(logRotator(numToKeepStr: '5'))
    disableConcurrentBuilds()
    timeout(time: 30, unit: 'MINUTES')
  }

  triggers {
    cron('H H * * */3')
  }

  stages {
    stage('Build and push JIRO masters images') {
      steps {
        container('docker-agent') {
          withCredentials([usernamePassword(credentialsId: 'e93ba8f9-59fc-4fe4-a9a7-9a8bd60c17d9', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
            sh 'docker login -u $USERNAME -p $PASSWORD'
            sh 'make all'
          }
        }
      }
    }
  }

  post {
    failure {
      mail to: 'releng-team@eclipse-foundation.org, frederic.gurr@eclipse-foundation.org',
        subject: "[CBI] Build Failure ${currentBuild.fullDisplayName}",
        mimeType: 'text/html',
        body: "Project: ${env.JOB_NAME}<br/>Build Number: ${env.BUILD_NUMBER}<br/>Build URL: ${env.BUILD_URL}<br/>Console: ${env.BUILD_URL}console"
    }
    fixed {
      mail to: 'releng-team@eclipse-foundation.org, frederic.gurr@eclipse-foundation.org',
        subject: "[CBI] Back to normal ${currentBuild.fullDisplayName}",
        mimeType: 'text/html',
        body: "Project: ${env.JOB_NAME}<br/>Build Number: ${env.BUILD_NUMBER}<br/>Build URL: ${env.BUILD_URL}<br/>Console: ${env.BUILD_URL}console"
    }
  }
}
