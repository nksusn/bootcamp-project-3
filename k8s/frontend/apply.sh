#!/bin/bash

# Apply the updated deployment, service, and configmap
kubectl apply -f configmap.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

# Check the status
echo "Checking deployment status..."
kubectl get deployment frontend

echo "Checking service status..."
kubectl get service frontend

echo "Checking pods..."
kubectl get pods -l app=frontend,app.kubernetes.io/name=frontend,app.kubernetes.io/instance=frontend