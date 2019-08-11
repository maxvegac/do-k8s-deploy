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

INSTALL_TILLER=${INSTALL_TILLER:-false}

echo "+ [DOCTL] Authenticating with DO..."
doctl auth init -t $DO_TOKEN > /dev/null

echo "+ [DOCTL] Get kubernetes cluster configuration..."
doctl kubernetes cluster kubeconfig save $DO_CLUSTER_NAME

echo "+ [SYSTEM] Replacing environment variables in files..."
perl -pi -e 's{\$(\{)?(\w+)(?(1)\})}{$ENV{$2} // $&}ge' k8s/manifests/*
perl -pi -e 's{\$(\{)?(\w+)(?(1)\})}{$ENV{$2} // $&}ge' k8s/charts/*

DIR="k8s/manifests"
if [ -d "$DIR" ]; then
   echo "+ [K8S] plan with manifests"
   kubectl apply --dry-run -f k8s/manifests/

   echo "+ [K8S] Apply!"
   kubectl apply -f k8s/manifests/
else
  echo "- [K8S] k8s/manifests directory not found"
fi



if [ "$INSTALL_TILLER" = "true" ]; then
    echo "+ [HELM] Installing Tiller..."
    helm init --upgrade
fi

DIR="k8s/charts"
if [ -d "$DIR" ]; then
  echo "+ [HELM] plan for installing charts"
  helm install --dry-run k8s/charts

  echo "+ [HELM] install!"
  helm install k8s/charts/*
fi
