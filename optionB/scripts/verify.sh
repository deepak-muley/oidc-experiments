#!/bin/bash

set -e

echo "🔍 Verifying Option B Setup"
echo "=============================="
echo ""

# Check if cluster exists
if ! kind get clusters | grep -q "oidc-proxy-demo"; then
    echo "❌ Cluster 'oidc-proxy-demo' not found"
    echo "   Run: ./scripts/setup.sh first"
    exit 1
fi

echo "1️⃣  Checking pods..."
echo ""

# Check Dex
echo "   Dex:"
if kubectl -n auth get pods -l app=dex 2>/dev/null | grep -q Running; then
    kubectl -n auth get pods -l app=dex --no-headers | awk '{print "      ✅ " $1 " - " $3}'
else
    echo "      ❌ Dex pod not running"
    exit 1
fi

# Check podinfo
echo "   podinfo:"
if kubectl -n podinfo get pods -l app=podinfo 2>/dev/null | grep -q Running; then
    kubectl -n podinfo get pods -l app=podinfo --no-headers | awk '{print "      ✅ " $1 " - " $3}'
else
    echo "      ❌ podinfo pod not running"
    exit 1
fi

# Check kube-oidc-proxy (optional)
echo "   kube-oidc-proxy (optional):"
if kubectl -n oidc-proxy get pods -l app=kube-oidc-proxy 2>/dev/null | grep -q Running; then
    kubectl -n oidc-proxy get pods -l app=kube-oidc-proxy --no-headers | awk '{print "      ✅ " $1 " - " $3}'
else
    echo "      ⚠️  Not deployed (optional - not needed for core demo)"
fi

echo ""
echo "2️⃣  Testing Dex connectivity..."
echo ""

# Port-forward Dex in background
kubectl -n auth port-forward svc/dex 5556:5556 > /tmp/dex-verify.log 2>&1 &
DEX_PF_PID=$!
sleep 3

# Test Dex
if curl -s http://localhost:5556/.well-known/openid-configuration > /dev/null 2>&1; then
    ISSUER=$(curl -s http://localhost:5556/.well-known/openid-configuration | jq -r '.issuer' 2>/dev/null || echo "unknown")
    echo "   ✅ Dex is accessible"
    echo "      Issuer: $ISSUER"
else
    echo "   ❌ Cannot connect to Dex"
    kill $DEX_PF_PID 2>/dev/null || true
    exit 1
fi

echo ""
echo "3️⃣  Testing podinfo (direct access)..."
echo ""

# Port-forward podinfo in background
kubectl -n podinfo port-forward svc/podinfo 9898:9898 > /tmp/podinfo-verify.log 2>&1 &
PODINFO_PF_PID=$!
sleep 2

# Test podinfo
if curl -s http://localhost:9898 > /dev/null 2>&1; then
    echo "   ✅ podinfo is accessible"
    echo "      Try: curl http://localhost:9898"
else
    echo "   ❌ Cannot connect to podinfo"
    kill $DEX_PF_PID $PODINFO_PF_PID 2>/dev/null || true
    exit 1
fi

# Cleanup port-forwards
kill $DEX_PF_PID $PODINFO_PF_PID 2>/dev/null || true
wait $DEX_PF_PID 2>/dev/null || true
wait $PODINFO_PF_PID 2>/dev/null || true

echo ""
echo "✅ Verification Complete!"
echo ""
echo "📝 Summary:"
echo "   • Dex: Running and accessible"
echo "   • podinfo: Running and accessible"
echo "   • kube-oidc-proxy: Optional (not required for core demo)"
echo ""
echo "💡 Next steps:"
echo "   1. Port-forward Dex: kubectl -n auth port-forward svc/dex 5556:5556"
echo "   2. Get token: ./scripts/get-token.sh"
echo "   3. Access podinfo: kubectl -n podinfo port-forward svc/podinfo 9898:9898"
echo ""
echo "   Note: kube-oidc-proxy is optional. The core demo works with just Dex + podinfo."

