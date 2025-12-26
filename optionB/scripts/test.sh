#!/bin/bash

# Automated end-to-end test script
# This script will:
# 1. Check if services are running
# 2. Port-forward Dex and proxy (in background)
# 3. Get a token
# 4. Test podinfo access

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPTION_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🧪 Running automated test for podinfo OIDC auth"
echo "================================================"

# Check if cluster exists
if ! kind get clusters | grep -q "oidc-proxy-demo"; then
    echo "❌ Cluster 'oidc-proxy-demo' not found. Run ./scripts/setup.sh first."
    exit 1
fi

# Check if pods are running
echo ""
echo "📋 Checking pod status..."
kubectl -n podinfo get pods
kubectl -n auth get pods
kubectl -n oidc-proxy get pods

# Port-forward Dex
echo ""
echo "🔌 Setting up port-forwards..."
echo "   Port-forwarding Dex to localhost:5556..."
kubectl -n auth port-forward svc/dex 5556:5556 > /tmp/dex-portforward.log 2>&1 &
DEX_PF_PID=$!
sleep 3

# Port-forward proxy
echo "   Port-forwarding kube-oidc-proxy to localhost:8443..."
kubectl -n oidc-proxy port-forward svc/kube-oidc-proxy 8443:8443 > /tmp/proxy-portforward.log 2>&1 &
PROXY_PF_PID=$!
sleep 3

# Cleanup function
cleanup() {
    echo ""
    echo "🧹 Cleaning up port-forwards..."
    kill $DEX_PF_PID 2>/dev/null || true
    kill $PROXY_PF_PID 2>/dev/null || true
    wait $DEX_PF_PID 2>/dev/null || true
    wait $PROXY_PF_PID 2>/dev/null || true
}
trap cleanup EXIT

# Wait for services to be ready
echo ""
echo "⏳ Waiting for services to be ready..."
sleep 5

# Get token
echo ""
echo "🔑 Getting OIDC token..."
TOKEN=$(bash "$SCRIPT_DIR/get-token.sh" einstein password --quiet 2>/dev/null)

if [ -z "$TOKEN" ]; then
    echo "❌ Failed to get token"
    exit 1
fi

# Test podinfo
echo ""
bash "$SCRIPT_DIR/test-podinfo.sh" "$TOKEN"

echo ""
echo "✅ All tests passed!"

