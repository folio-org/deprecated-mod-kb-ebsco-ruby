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

          // always 'true' for now
          env.snapshot = true

          env.project_name = foliociLib.getProjName()
          env.name = env.project_name

          // getting current version from MD.  Not ideal. Good enough for now.
          def version = foliociLib.getModuleDescriptorIdVer('ModuleDescriptor.json')

          if (env.snapshot) {
            echo "This is a snapshot release"
            env.version = "${version}-SNAPSHOT.${env.BUILD_NUMBER}"
          }
          else {
            env.version = version
          }
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
          def dockerRepo = 'folioci'
          env.dockerImage = "$dockerRepo/${env.name}"
          docker.build("${env.dockerImage}:${env.version}", '--no-cache .')
        }
      }
    }

    stage('Publish Docker image') {
      when {
        branch 'master'
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
        branch 'master'
      }
      steps {
        script {
          if (env.snapshot) {
            def foliociLib = new org.folio.foliociCommands()
            foliociLib.updateModDescriptorId('ModuleDescriptor.json')
          }
        }
        postModuleDescriptor('ModuleDescriptor.json')
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
