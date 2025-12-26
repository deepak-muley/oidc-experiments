#!/bin/bash

set -e

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPTION_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(cd "$OPTION_DIR/.." && pwd)"

echo "🚀 Setting up Option A: Ingress-NGINX + Dex + oauth2-proxy"
echo "=========================================================="

# Check prerequisites
echo ""
echo "📋 Checking prerequisites..."
command -v kind >/dev/null 2>&1 || { echo "❌ kind is required but not installed. Install with: brew install kind"; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "❌ kubectl is required but not installed. Install with: brew install kubectl"; exit 1; }
command -v python3 >/dev/null 2>&1 || { echo "❌ python3 is required for cookie secret generation"; exit 1; }

# 1. Create kind cluster
echo ""
echo "1️⃣  Creating kind cluster with ingress ports..."
if kind get clusters | grep -q "oidc-demo"; then
    echo "   ⚠️  Cluster 'oidc-demo' already exists. Skipping creation."
else
    kind create cluster --config "$OPTION_DIR/cluster/kind.yaml"
    echo "   ✅ Cluster created"
fi
kubectl cluster-info --context kind-oidc-demo

# 2. Install ingress-nginx
echo ""
echo "2️⃣  Installing ingress-nginx..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
echo "   ⏳ Waiting for ingress-nginx to be ready..."
kubectl -n ingress-nginx rollout status deploy/ingress-nginx-controller --timeout=120s

# 3. Install podinfo
echo ""
echo "3️⃣  Installing podinfo..."
kubectl create namespace podinfo --dry-run=client -o yaml | kubectl apply -f -
kubectl -n podinfo apply -f https://raw.githubusercontent.com/stefanprodan/podinfo/master/kustomize/deployment.yaml
kubectl -n podinfo apply -f https://raw.githubusercontent.com/stefanprodan/podinfo/master/kustomize/service.yaml
echo "   ⏳ Waiting for podinfo to be ready..."
kubectl -n podinfo wait --for=condition=available --timeout=120s deployment/podinfo || true

# 4. Deploy Dex
echo ""
echo "4️⃣  Deploying Dex (OIDC provider backed by ForumSys LDAP)..."
kubectl create namespace auth --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f "$OPTION_DIR/dex/dex-config.yaml"
kubectl apply -f "$OPTION_DIR/dex/dex.yaml"
echo "   ⏳ Waiting for Dex to be ready..."
kubectl -n auth rollout status deployment/dex --timeout=120s

# 5. Deploy oauth2-proxy
echo ""
echo "5️⃣  Deploying oauth2-proxy..."
kubectl create namespace oauth2 --dry-run=client -o yaml | kubectl apply -f -

# Generate cookie secret
COOKIE_SECRET=$(python3 -c "import os,base64; print(base64.b64encode(os.urandom(32)).decode())")
echo "   Generated cookie secret"

# Create oauth2-proxy deployment with cookie secret
cat "$OPTION_DIR/oauth2-proxy/oauth2-proxy.yaml" | sed "s/\${COOKIE_SECRET}/$COOKIE_SECRET/" | kubectl apply -f -
echo "   ⏳ Waiting for oauth2-proxy to be ready..."
kubectl -n oauth2 rollout status deployment/oauth2-proxy --timeout=120s

# 6. Create podinfo ingress
echo ""
echo "6️⃣  Creating podinfo ingress with oauth2-proxy protection..."
kubectl apply -f "$OPTION_DIR/podinfo/oauth2-proxy-service.yaml"
kubectl apply -f "$OPTION_DIR/podinfo/ingress.yaml"

echo ""
echo "✅ Setup complete!"
echo ""
echo "📝 Next steps:"
echo "   Open in browser: http://podinfo.localtest.me"
echo "   Login with ForumSys LDAP user (e.g., einstein/password)"
echo ""
echo "   Note: *.localtest.me resolves to 127.0.0.1 automatically"

