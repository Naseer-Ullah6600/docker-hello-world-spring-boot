#!/bin/bash

# Script to apply initial Kubernetes resources
# Run this script once to set up the initial deployment

set -e

echo "Creating namespace..."
kubectl apply -f namespace.yaml

echo "Applying deployment and service..."
kubectl apply -f deployment.yaml

echo "Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/hello-world-app -n zad-demo-app

echo "Resources applied successfully!"
echo "You can now run the GitHub Actions pipeline to deploy updates."
