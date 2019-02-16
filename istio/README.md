
# Cluster

```
terraform apply
gcloud container clusters get-credentials coypu-cluster --zone us-east1-b
```

# Istio

[Helm Install](https://istio.io/docs/setup/kubernetes/helm-install/)


Install instio 
```
curl -L https://git.io/getLatestIstio | sh -
cd istio-1.0.6

```

# Setup helm
```
kubectl apply -f install/kubernetes/helm/helm-service-account.yaml
helm init --service-account tiller
```

After tiller pod starts we can install istio
```
helm install install/kubernetes/helm/istio --name istio --namespace istio-system
```

# Setup Application

Deploy coypu in namespace with istio injection enable

```
kubectl create namespace istio-apps
kubectl label namespace istio-apps istio-injection=enabled
kubectl apply -f coypu-istio.yaml -n istio-apps
```

# Check ingress IP and ports 
```
kubectl get svc istio-ingressgateway -n istio-system
```
 

# Links

 * https://medium.com/pismolabs/istio-envoy-grpc-metrics-winning-with-service-mesh-in-practice-d67a08acd8f7
 * https://istio.io/docs/examples/bookinfo/
 * https://istio.io/docs/examples/advanced-egress/egress-gateway/

