
# Setup Google SDK

Install [Google SDK](https://cloud.google.com/sdk/install). Use a versioned archived to include docker support (not supported via apt).

# Deploy to GKE with terraform

Create ```file.json``` at _APIs & Services->Credentials->Create credentials->API Key_

A second key will be needed to pull from the _Container Registry_ in GCP.


```
export GOOGLE_CLOUD_KEYFILE_JSON=<file.json>
terraform init
terraform apply
```

# Setup creds for docker

```
docker-credential-gcr configure-docker
```

# Setup credentials for kubectl from gcloud

```
gcloud container clusters get-credentials coypu-cluster --zone us-east1-b
```

# Deploy build with docker

```
docker tag coypu gcr.io/massive-acrobat-227416/coypu
docker push gcr.io/massive-acrobat-227416/coypu:v5
```

# Roll a deployment to a new image

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

# Check health commands
```
kubectl get deployments
kubectl get pods
kubectl get services
kubectl describe pods
```

# Teardown

```
terraform destroy
```
