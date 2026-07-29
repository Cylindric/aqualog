# Kubeernetes Install Process

## Global Setup

1. Install the nginx ingress controller

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install nginx-ingress ingress-nginx/ingress-nginx --set controller.publishService.enabled=true
kubectl --namespace default get services -o wide -w nginx-ingress-ingress-nginx-controller
```

1. Install the CertManager

```bash
kubectl create namespace cert-manager
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager --namespace cert-manager --version v1.10.1 --set installCRDs=true
kubectl apply -f production_issuer.yaml
```

1. Create a Namespace for AquaLog components
```bash
kubectl create namespace aqualog
```

1. Push AquaLog images into the registry

```bash
doctl registry login
docker image tag aqualog-backend:latest registry.digitalocean.com/aqualog/aqualog-backend:latest
docker image push registry.digitalocean.com/aqualog/aqualog-backend:latest
```

## Deploy the application

```bash
kubectl apply -f .
```

## Cleaning up the registry
```bash
doctl registries garbage-collection start --include-untagged-manifests aqualog
```