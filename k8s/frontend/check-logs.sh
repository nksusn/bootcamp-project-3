#!/bin/bash

# Get the pod name
POD_NAME=$(kubectl get pods -l app=frontend -o jsonpath="{.items[0].metadata.name}")

# Check the logs
echo "Checking logs for pod $POD_NAME..."
kubectl logs $POD_NAME

# Describe the pod
echo -e "\nDescribing pod $POD_NAME..."
kubectl describe pod $POD_NAME