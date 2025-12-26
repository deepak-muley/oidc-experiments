#!/bin/bash
# Install Traefik via Helm with Gateway API support

set -e

echo "🔧 Installing Gateway API CRDs..."
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.1/standard-install.yaml

echo "📦 Adding Traefik Helm repository..."
helm repo add traefik https://traefik.github.io/charts
helm repo update

echo "🚀 Installing Traefik with Gateway API support..."
helm upgrade --install traefik traefik/traefik \
  --namespace traefik-system \
  --create-namespace \
  --values traefik-helm-values.yaml \
  --skip-crds

echo "⏳ Waiting for Traefik to be ready..."
kubectl -n traefik-system wait --for=condition=ready pod -l app.kubernetes.io/name=traefik --timeout=120s

echo "✅ Traefik installed successfully!"
echo ""
echo "📊 Checking Gateway API status..."
kubectl get gatewayclass
kubectl get gateway -A

echo ""
echo "🌐 Traefik NodePort:"
kubectl -n traefik-system get service traefik -o jsonpath='{.spec.ports[?(@.name=="web")].nodePort}'
echo ""

