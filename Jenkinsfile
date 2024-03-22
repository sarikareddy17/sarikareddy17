node	{
    def app

    stage('Clone repository') {
        checkout scm
    }
	  
    stage('Package jar file with Maven') {
         dir('dms-service') {
            withMaven(
                // Maven installation declared in the Jenkins "Global Tool Configuration"
                maven: 'M3') {
                // Run the maven build
                sh "mvn clean install -DskipTests=true"
            } 
         }
    }
	
	// stage('SonarQube analysis') {
	//     withSonarQubeEnv(credentialsId: 'sonarqube-scanner', installationName: 'sonarqube') { // You can override the credential to be used
	//       sh 'cd dms-service-webservice && mvn org.sonarsource.scanner.maven:sonar-maven-plugin:3.7.0.1746:sonar -Dsonar.branch=p2-dev-branch'
	//     }
	//   }
//		  stage('Sonarqube QualityGate') {
//			waitForQualityGate abortPipeline: true
//	}

	
    stage('Build image with Docker') {
        dir('dms-service') {
            app = docker.build("dms-service-webservice-qa:${env.BUILD_NUMBER}")
        }
    }

   stage('Push image to container registry') {
        docker.withRegistry('https://dmsdevcontainerregistry.azurecr.io', 'DMSDevContainerRegistry') {
            app.push("${env.BUILD_NUMBER}")
            app.push("latest")
        }
    }

   stage("Deploy to QA?") {
        dir('dms-service/kubernetes') {
		      def namespace = "qa"

               def imagetag="${env.BUILD_NUMBER}"
               deploy(namespace,imagetag)    
        }
    }


}

def deploy(namespace,imagetag) {
    // Create a copy for this environment
    sh "cp deployment.yaml deployment.${namespace}.yaml"
    sh "cp namespace.yaml namespace.${namespace}.yaml"
    sh "cp service.yaml service.${namespace}.yaml"


    // String replace namespaces
    sh "sed -i.bak s/XX_NAMESPACE_XX/$namespace/g deployment.${namespace}.yaml"
    sh "sed -i.bak s/XX_NAMESPACE_XX/$namespace/g namespace.${namespace}.yaml"
    sh "sed -i.bak s/XX_NAMESPACE_XX/$namespace/g service.${namespace}.yaml"               
              
    //set dev AKS cluster
    sh 'rm -fr /var/lib/jenkins/.kube/config'
	sh 'rm -fr /var/lib/jenkins/config'	
	sh 'az account set --subscription 6ad3322b-92ff-4b21-9972-8ceac19c4a00'
    sh 'az aks get-credentials --resource-group DMSDev --name devaks'
	sh 'ln -sf /var/lib/jenkins/.kube/config /var/lib/jenkins/config'

    // Create namespace
    kubectl(namespace, "apply -f namespace.${namespace}.yaml")

    // String replace the image name in the deployment and create the deployment
    sh "sed -i.bak s/XX_IMAGETAG_XX/$imagetag/g deployment.${namespace}.yaml"
    kubectl(namespace, "apply -f deployment.${namespace}.yaml")
        
    // Create service
    kubectl(namespace, "apply -f service.${namespace}.yaml")  
 
}

def kubectl(namespace,cmd) {
    return sh(script: "kubectl --kubeconfig /var/lib/jenkins/config --namespace=${namespace} ${cmd}", returnStdout: true)
 }
