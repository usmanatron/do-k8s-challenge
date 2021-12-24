#!/bin/bash

# Install helm, kubectl
# Install Nginx Ingress Controller and LB via Digital Ocean
# Create DNS A record to LB IP for hello.k8s.usmanatron.co.uk and registry.k8s.usmanatron.co.uk

# Test connection
kubectl cluster-info

# Helm setup
helm repo add jetstack https://charts.jetstack.io
helm repo add trow https://trow.io
helm repo update

# nginx ingress via https://kubernetes.github.io/ingress-nginx/deploy/#digital-ocean
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.1.0/deploy/static/provider/do/deploy.yaml

# Install cert-manager
kubectl create namespace cert-manager
helm install cert-manager jetstack/cert-manager --namespace cert-manager --version v1.6.1 --set installCRDs=true

# Test cert-manager
# Should be 3:
kubectl get pods --namespace cert-manager
kubectl apply -f .\cert-manager-test.yml
kubectl describe certificate -n cert-manager-test # Check it works
kubectl delete -f test-resources.yaml

# Add config to use LetsEncrypt
kubectl apply -f "02_cert-manager\le-staging.yml"
kubectl apply -f "02_cert-manager\le-prod.yml"

# Make sure nginx is wrking - look for External IP:
kubectl get service ingress-nginx-controller --namespace=ingress-nginx

# Install trow
helm install -f trow_values.yml trow trow/trow

# check cert
kubectl describe certificate trow-cert
