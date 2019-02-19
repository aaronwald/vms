
# Istio

[Helm Install](https://istio.io/docs/setup/kubernetes/helm-install/)

Install instio release

```bash
curl -L https://git.io/getLatestIstio | sh -

```

# Cluster and helm

```bash
terraform apply
gcloud container clusters get-credentials coypu-cluster --zone us-east1-b
kubectl create namespace istio-system
kubectl apply -f kiali-secret.yaml
cd istio-1.0.6
kubectl apply -f install/kubernetes/helm/helm-service-account.yaml
helm init --service-account tiller
```

## Install istio with helm

After tiller pod starts we can install istio. Set ```tracing.enabled=true``` to start jaeger.

```bash
helm install install/kubernetes/helm/istio --name istio --namespace istio-system --set tracing.enabled=true --set grafana.enabled=true --set kiali.enabled=true
cd ..
```

## DEploy coypu app and service to istio-app namespace

Deploy coypu in namespace with istio injection enable

```bash
kubectl create namespace istio-apps
kubectl label namespace istio-apps istio-injection=enabled
kubectl apply -f coypu-istio.yaml -n istio-apps
```

## Check ingress IP and ports 

```bash
kubectl get svc istio-ingressgateway -n istio-system
```

## Port forward Grafna, Jaeger, Kiali

In these examples we set the interface to _0.0.0.0_.

```bash
kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=grafana -o jsonpath='{.items[0].metadata.name}') 3000:3000 --address 0.0.0.0 &
kubectl port-forward -n istio-system $(kubectl -n istio-system get pod -l app=jaeger -o jsonpath='{.items[0].metadata.name}') 16686:16686 --address 0.0.0.0  & 
kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=kiali -o jsonpath='{.items[0].metadata.name}') 20001:20001 --address 0.0.0.0 &

```

# Set ingress host and port
```bash
export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
```

# Reference

## Reference Links

 * https://medium.com/pismolabs/istio-envoy-grpc-metrics-winning-with-service-mesh-in-practice-d67a08acd8f7
 * https://istio.io/docs/examples/bookinfo/
 * https://istio.io/docs/examples/advanced-egress/egress-gateway/

## Change kiali password

```bash
echo -n admin | base64
```
