#!/bin/bash

set -e  # Stop script if any command fails

echo "Starting SaleProject deployment..."

# 1. Create namespace
echo "Creating namespace..."
kubectl apply -f namespace.yaml

# 2. Set namespace as default for this context
echo "Setting namespace 'saleproject' as default..."
kubectl config set-context --current --namespace=saleproject

# 3. Apply secrets and configs
echo "Applying secrets and Prometheus config..."
kubectl apply -f secret.yaml
kubectl apply -f prometheus-configmap.yaml

# 4. Deploy backend and frontend
echo "Deploying backend (careerpath)..."
kubectl apply -f careerpath-deployment.yaml
kubectl apply -f careerpath-service.yaml

echo "Deploying frontend..."
kubectl apply -f frontend-deployment.yaml
kubectl apply -f frontend-service.yaml

# 5. Deploy monitoring
echo "Deploying Prometheus and cAdvisor..."
kubectl apply -f prometheus-deployment.yaml
kubectl apply -f prometheus-service.yaml
# kubectl apply -f cadvisor-deployment.yaml
# kubectl apply -f cadvisor-service.yaml

# 6. Apply ingress
echo "Applying ingress resources..."
kubectl apply -f ingress.yaml

echo "All services are deployed!"
echo "Access your services via the configured ingress hostnames or URLs."
