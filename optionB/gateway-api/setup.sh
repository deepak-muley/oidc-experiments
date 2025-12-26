#!/bin/bash

# Setup script for Gateway API solution with Traefik

set -e

echo "🚀 Setting up Gateway API Solution with Traefik"
echo "================================================"
echo ""

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed"
    exit 1
fi

# Check if cluster is accessible
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Cannot access Kubernetes cluster"
    exit 1
fi

echo "📦 Step 1: Installing Gateway API CRDs..."
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.1/standard-install.yaml

echo ""
echo "⏳ Waiting for Gateway API CRDs to be ready..."
kubectl wait --for=condition=Established crd/gateways.gateway.networking.k8s.io --timeout=60s || true
kubectl wait --for=condition=Established crd/httproutes.gateway.networking.k8s.io --timeout=60s || true

echo ""
echo "📦 Step 2: Installing Traefik Gateway Controller via Helm..."
if ! command -v helm &> /dev/null; then
    echo "❌ helm is not installed. Please install Helm first."
    exit 1
fi

helm repo add traefik https://traefik.github.io/charts
helm repo update

helm upgrade --install traefik traefik/traefik \
  --namespace traefik-system \
  --create-namespace \
  --values traefik-helm-values.yaml \
  --skip-crds

echo ""
echo "⏳ Waiting for Traefik to be ready..."
kubectl -n traefik-system wait --for=condition=ready pod -l app.kubernetes.io/name=traefik --timeout=120s || true

echo ""
echo "📦 Step 3: Creating Gateway..."
kubectl apply -f gateway.yaml

echo ""
echo "📦 Step 4: Updating Dex configuration..."
kubectl apply -f dex-config-gateway.yaml
kubectl -n auth rollout restart deployment/dex || true

echo ""
echo "📦 Step 5: Updating oauth2-proxy configuration..."
kubectl apply -f oauth2-proxy-gateway.yaml
kubectl -n oidc-proxy rollout restart deployment/oauth2-proxy || true

echo ""
echo "📦 Step 6: Creating HTTPRoutes..."
kubectl apply -f dex-route.yaml
kubectl apply -f podinfo-route.yaml

echo ""
echo "⏳ Waiting for services to be ready..."
sleep 10

echo ""
echo "✅ Setup complete!"
echo ""
echo "📋 Next steps:"
echo ""
echo "1. Port-forward Traefik service:"
echo "   kubectl -n traefik-system port-forward svc/traefik 8080:80"
echo ""
echo "2. Add to /etc/hosts:"
echo "   127.0.0.1 dex.local podinfo.local"
echo ""
echo "3. Access:"
echo "   http://podinfo.local:8080"
echo "   http://dex.local:8080"
echo ""
echo "4. Login with: einstein / password"
echo ""
echo "💡 Alternative: Use NodePort (check with kubectl -n traefik-system get svc traefik)"

