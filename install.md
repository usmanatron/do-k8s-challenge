# Installation

## Workstation Setup

* Install kubectl
* Install Helm
* Install doctl
* Use VSCode

## DigitalOcean Setup

* Setup K8s Cluster
  * 3 nodes
  * Smallest size is fine
  * Setup kubectl via the doctl command given

## Test connection to cluster

```bash
kubectl cluster-info
```

## Setup Helm

```bash
helm repo add jetstack https://charts.jetstack.io
helm repo add trow https://trow.io
helm repo update
```

## Install ingress-nginx

DO provide a 1-click installer.  Alternatively, the k8s docs has [DO-specific installation details](https://kubernetes.github.io/ingress-nginx/deploy/#digital-ocean).  I went for the latter:

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.1.0/deploy/static/provider/do/deploy.yaml
```

## Install cert-manager

```bash
kubectl create namespace cert-manager
helm install cert-manager jetstack/cert-manager --namespace cert-manager --version v1.6.1 --set installCRDs=true
```

To test:

```bash
# There should be 3 running pods
kubectl get pods --namespace cert-manager

kubectl apply -f ".\cert-manager-test.yml"

# Check the self-signed Cert is setup correctly
kubectl describe certificate -n cert-manager-test

# Tidy up
kubectl delete -f test-resources.yaml
```

## LetsEncrypt config for cert-manager

Don't forget to update these files to add your Email address

```bash
kubectl apply -f "issuer_letsencrypt-staging.yml"
kubectl apply -f "issuer_letsencrypt-prod.yml"
```

## Check ingress-nginx

Need to wait for the DO LB to be preovisioned before we can check

```bash
# External IP should be provisioned:
kubectl get service ingress-nginx-controller --namespace=ingress-nginx
```

## DNS

Add DNS A record for `registry.k8s.usmanatron.co.uk`, pointing to the External IP above.

## Install trow

```bash
helm install -f helm_trow.yml trow trow/trow
```

## Test trow

### Browser

<https://registry.k8s.usmanatron.co.uk>

### Docker CLI

Credentials in [helm_trow.yml](./helm_trow.yml)

```bash
docker login https://registry.k8s.usmanatron.co.uk

docker pull debian:latest
docker tag debian:latest registry.k8s.usmanatron.co.uk/debian:latest
docker push registry.k8s.usmanatron.co.uk/debian:latest
```

## Troubleshooting

### Check trow cert

```bash
kubectl describe certificate trow-cert
```
