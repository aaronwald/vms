# Introduction

The environment below will use [kubernetes](https://kubernetes.io/) in [GCP](https://cloud.google.com/) to deploy a custom app [coypu](https://github.com/aaronwald/coypu). The initial deployment is done with [terraform](https://www.hashicorp.com/products/terraform).

[Helm](https://helm.sh/) is then used to deploy [Jenkins](https://jenkins.io/) into the existing GCP cluster. The jenkins steps then show how to deploy slaves into k8s pods and optionally pull docker images from the Google container registry.

# Setup Google SDK

Install [Google SDK](https://cloud.google.com/sdk/install). Use a versioned archived to include docker support (not supported via apt).

# Deploy to GKE with terraform

Create ```file.json``` at _APIs & Services->Credentials->Create credentials->API Key_

A second key will be needed to pull from the _Container Registry_ in GCP (if using k8s with Jenkins then you can reuse the existing service account with your pods since k8s is already setup to talk to the regsitry).

See [Example](main.tf) for simple deployment that sets up a cluster, firewall, network, service, and deployment. 

```
export GOOGLE_CLOUD_KEYFILE_JSON=<file.json>
terraform init 
terraform apply
```
 
Setup creds for docker

```
docker-credential-gcr configure-docker
```

Setup credentials for kubectl from gcloud

```
gcloud container clusters get-credentials coypu-cluster --zone us-east1-b
```

# Install Helm

```
sudo snap install helm --classic
kubectl create -f tiller.yaml
helm init --canary-image --service-account tiller --upgrade
```

## Check Helm Status
```
kubectl -n kube-system describe deployment tiller-deploy
kubectl get pods --namespace kube-system
```

## Helm Cleanup
```
kubectl delete deployment tiller-deploy --namespace kube-system
```

# Install Jenkins
```
helm install stable/jenkins --set rbac.install=true --name coypu-release
helm status
kubectl create -f jenkins.yaml
```

# Teardown Environment

```
terraform destroy
```

## Jenkins from command line

Retrieve the api key from http://jenkins_host:8080/me/configure . 
Retrieve the pod name from ```helm status coypu-release```

```
kubectl exec -it coypu-release-jenkins-7cdc4bf985-8srr4 -- /bin/bash
java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://127.0.0.1:8080/ -auth admin:api_key install-plugin docker-build-step
java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://127.0.0.1:8080/ -auth admin:api_key install-plugin google-container-registry-auth
java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://127.0.0.1:8080/ -auth admin:api_key install-plugin google-oauth-plugin
java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://127.0.0.1:8080/ -auth admin:api_key restart
java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://127.0.0.1:8080/ -auth admin:api_key create-job coypu < coypu.xml

```

## Jenkins plugins needed (Not needed when using docker via kubernetes)

Under configure Jenkins -- Update the credentials config in the cloud section to use the service account credential you created in the step above.

* docker-build-step
* Google Container Registry Auth
* Google OAuth Credentials

# Docker 

## Deploy build with docker

```
docker tag coypu gcr.io/massive-acrobat-227416/coypu
docker push gcr.io/massive-acrobat-227416/coypu:v5
```

# Roll a deployment to a new image in k8s

Set the version for the deployment. Set container name to a new image. Image name is set on container specific in workload (pod or controller).

_pod (po), replicationcontroller (rc), deployment (deploy), daemonset (ds), replicaset (rs)_

```
kubectl set image deployments/coypu-server coypu=gcr.io/massive-acrobat-227416/coypu:v3
```

## Check rollout status

```
kubectl rollout status deployments/coypu-server
```

```
kubectl rollout history deployments/coypu-server
```

## Rollback

```
kubectl rollout undo deployments/coypu-server
```

## Check health commands
```
kubectl get deployments
kubectl get pods
kubectl get services
kubectl get namespaces
kubectl describe pods
```



## Config docker-build-step (NOT NEEDED)

 * _Global Tool Configuration->Docker Installations_
   * Install automatically
   * Restart required
 * _Configure System->Docker Builder->Docker URL_
