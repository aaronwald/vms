pipeline {
	 agent {
        kubernetes {
            label 'jnlp'
        }
    }

    stages {
        stage('Build image') {
				steps {
					 echo 'Starting to build docker image'
					 
					 script {
						  def customImage = docker.build("coypu_llvm:${env.BUILD_ID}")
						  //                    customImage.push()
					 }
				}
        }
    }
}