@Library ('folio_jenkins_shared_libs') _

pipeline {

  agent {
    node {
      label 'jenkins-slave-all'
    }
  }

  environment {
     EBSCO_RESOURCE_MANAGEMENT_API_BASE_URL = "https://api.ebsco.io"
     TEST_CUSTOMER_ID = credentials('ebsco-rmapi-custid')
     TEST_API_KEY = credentials('ebsco-rmapi-key')
     TEST_OKAPI_TOKEN = 'XXXXXXX'
     RUBY_VERSION = '2.4.2'
     PATH= "$PATH:/usr/share/rvm/bin"
  }

  stages {
    stage('Prep') {
      steps {
        script {
          currentBuild.displayName = "#${env.BUILD_NUMBER}-${env.JOB_BASE_NAME}"
        }
        sendNotifications 'STARTED'
      }
    }

    stage('Checkout') {
      steps {
        checkout([
             $class: 'GitSCM',
             branches: scm.branches,
             extensions: scm.extensions + [[$class: 'SubmoduleOption',
                                                     disableSubmodules: false,
                                                     parentCredentials: false,
                                                     recursiveSubmodules: true,
                                                     reference: '',
                                                     trackingSubmodules: false]],
             userRemoteConfigs: scm.userRemoteConfigs
        ])
        echo " Checked out $env.BRANCH_NAME"
      }
    }

    stage('Build and Unit Tests') {
      steps {
        script {
          def foliociLib = new org.folio.foliociCommands()

          env.project_name = foliociLib.getProjName()
          env.name = env.project_name

          // getting current version from MD.  Not ideal. Good enough for now.
          def version = foliociLib.getModuleDescriptorIdVer('ModuleDescriptor.json')

          // if release tag
          if ( env.BRANCH_NAME ==~ /^v\d+\.\d+\.\d+$/ ) {
            env.version = version
            env.dockerRepo = 'folioorg'
            echo "This is a release build."
          }
          else {
            env.version = "${version}-SNAPSHOT.${env.BUILD_NUMBER}"
            env.dockerRepo = 'folioci'
            echo "This is a snapshot build."
          }

        echo "Building Ruby artifact: ${env.name} Version: ${env.version}"

        sh "/bin/bash -l -c '. /usr/share/rvm/scripts/rvm && rvm use ${env.RUBY_VERSION}'"
        sh "sudo /bin/bash -l -c '. /usr/share/rvm/scripts/rvm && gem install bundler'"

        sh "sudo /bin/bash -l -c '. /usr/share/rvm/scripts/rvm && bundle install'"

        echo "Run unit tests..."
        sh "/bin/bash -l -c '. /usr/share/rvm/scripts/rvm && rake spec'"
      }
    }

    stage('Build Docker') {
      steps {
        echo "Building Docker image..."
        script {
          env.dockerImage = "${env.dockerRepo}/${env.name}"
          docker.build("${env.dockerImage}:${env.version}", '--no-cache .')
        }
      }
    }

    stage('Publish Docker image') {
      when {
        anyOf {
          branch 'master'; tag pattern: "^v\\d+\\.\\d+\\.\\d+\$", comparator: "REGEXP"
        }
      }
      steps {
        echo "Pushing Docker image ${env.name} to Docker Hub..."
        script {
          docker.withRegistry('https://index.docker.io/v1/', 'DockerHubIDJenkins') {
            def dockerImage =  docker.image("${env.dockerImage}:${env.version}")
            dockerImage.push()
            dockerImage.push('latest')
          }
        }
      }
    }

    stage('Publish Module Descriptor') {
      when {
        anyOf {
          branch 'master'; tag pattern: "^v\\d+\\.\\d+\\.\\d+\$", comparator: "REGEXP"
        }
      }
      steps {
        script {
          def foliociLib = new org.folio.foliociCommands()
          foliociLib.updateModDescriptor('ModuleDescriptor.json')
        }
        postModuleDescriptor('ModuleDescriptor.json')
      }
    }

    stage('Publish API docs') { 
      when {
        anyOf {
          branch 'master'; tag pattern: "^v\\d+\\.\\d+\\.\\d+\$", comparator: "REGEXP"
        }
      }
      steps { 
        echo "Publishing API docs"
        sh "python3 /usr/local/bin/generate_api_docs.py -r $env.project_name -v -o folio-api-docs"
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', 
                          accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
                          credentialsId: 'jenkins-aws', 
                          secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
              sh 'aws s3 sync folio-api-docs s3://foliodocs/api'
        }
      }
    }

  } // end 'stages'

  post {
    always {
      sh "docker rmi ${env.dockerImage}:${env.version} || exit 0"
      sh "docker rmi ${env.dockerImage}:latest || exit 0"
      sendNotifications currentBuild.result
    }
  }

}
