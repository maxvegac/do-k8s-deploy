#!/bin/sh

set -e

echo "Validating required params..."

if [ -z $DO_TOKEN ]; then
  echo "DO_TOKEN is missing"
  exit 1
fi

if [ -z $DO_CLUSTER_NAME ]; then
  echo "DO_CLUSTER_NAME is missing"
  exit 1
fi

echo "Authenticating with DO..."
doctl auth init -t $DO_TOKEN > /dev/null

echo "Get kubernetes cluster configuration..."
doctl kubernetes cluster kubeconfig save $DO_CLUSTER_NAME

echo "Kubernetes plan with manifests"
kubectl apply --dry-run -f /workspace/k8s/

echo "Apply!"
kubectl apply -f /workspace/k8s/
