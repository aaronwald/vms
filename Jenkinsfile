pipeline {
    agent {
        kubernetes {
            label 'mypod'
            defaultContainer 'jnlp'
            yamlFile 'pod.yaml'
        }
    }

    stages {
        stage('Build image') {
            steps {
					 container('rundocker') {
						  echo 'Starting to build docker image'
					 
						  script {
								def customImage = docker.build("coypu_llvm:${env.BUILD_ID}")
								//                    customImage.push()
						  }
					 }
            }
        }
    }
}
