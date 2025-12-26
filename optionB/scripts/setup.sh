#!/bin/bash

set -e

# Get script directory and option directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPTION_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🚀 Setting up OIDC Proxy Demo with podinfo"
echo "=========================================="

# Check prerequisites
echo ""
echo "📋 Checking prerequisites..."
command -v kind >/dev/null 2>&1 || { echo "❌ kind is required but not installed. Install with: brew install kind"; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "❌ kubectl is required but not installed. Install with: brew install kubectl"; exit 1; }

# 1. Create kind cluster
echo ""
echo "1️⃣  Creating kind cluster..."
if kind get clusters | grep -q "oidc-proxy-demo"; then
    echo "   ⚠️  Cluster 'oidc-proxy-demo' already exists. Skipping creation."
else
    kind create cluster --config "$OPTION_DIR/cluster/kind.yaml"
    echo "   ✅ Cluster created"
fi
kubectl cluster-info

# 2. Install podinfo
echo ""
echo "2️⃣  Installing podinfo..."
kubectl create namespace podinfo --dry-run=client -o yaml | kubectl apply -f -
kubectl -n podinfo apply -f https://raw.githubusercontent.com/stefanprodan/podinfo/master/kustomize/deployment.yaml
kubectl -n podinfo apply -f https://raw.githubusercontent.com/stefanprodan/podinfo/master/kustomize/service.yaml
echo "   ⏳ Waiting for podinfo to be ready..."
kubectl -n podinfo wait --for=condition=available --timeout=120s deployment/podinfo || true
kubectl -n podinfo get pods

# 3. Deploy Dex
echo ""
echo "3️⃣  Deploying Dex (OIDC provider backed by ForumSys LDAP)..."
kubectl create namespace auth --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f "$OPTION_DIR/dex/dex-config.yaml"
kubectl apply -f "$OPTION_DIR/dex/dex.yaml"
echo "   ⏳ Waiting for Dex to be ready..."
kubectl -n auth rollout status deployment/dex --timeout=120s
kubectl -n auth get pods

# 4. Deploy kube-oidc-proxy
echo ""
echo "4️⃣  Deploying kube-oidc-proxy..."
kubectl create namespace oidc-proxy --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f "$OPTION_DIR/kube-oidc-proxy/kube-oidc-proxy.yaml"
echo "   ⏳ Waiting for kube-oidc-proxy to be ready..."
kubectl -n oidc-proxy rollout status deployment/kube-oidc-proxy --timeout=120s
kubectl -n oidc-proxy get pods

echo ""
echo "✅ Setup complete!"
echo ""
echo "📝 Next steps:"
echo "   1. Port-forward the proxy: kubectl -n oidc-proxy port-forward svc/kube-oidc-proxy 8443:8443"
echo "   2. Port-forward Dex: kubectl -n auth port-forward svc/dex 5556:5556"
echo "   3. Get a token using: ./scripts/get-token.sh"
echo "   4. Test podinfo using: ./scripts/test-podinfo.sh <TOKEN>"
echo ""
echo "   Or use the automated test script: ./scripts/test.sh"
