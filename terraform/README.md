
# Setup creds

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
docker push gcr.io/massive-acrobat-227416/coypu:latest
```

# Roll a deployment to a new image

Set the version for the deployment. Set container name to a new image. Image is set on a workload (pod or controllers)

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
