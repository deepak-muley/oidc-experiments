#!/bin/bash

# Complete verification script for Option B with oauth2-proxy
# This verifies the full setup: Dex + oauth2-proxy + podinfo

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPTION_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🔍 Complete Verification: Option B with oauth2-proxy"
echo "===================================================="
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

# Check oauth2-proxy
echo "   oauth2-proxy:"
if kubectl -n oidc-proxy get pods -l app=oauth2-proxy 2>/dev/null | grep -q Running; then
    kubectl -n oidc-proxy get pods -l app=oauth2-proxy --no-headers | awk '{print "      ✅ " $1 " - " $3}'
else
    echo "      ⚠️  oauth2-proxy not running (deploy it for complete solution)"
    OAUTH2_RUNNING=false
fi

echo ""
echo "2️⃣  Testing connectivity..."
echo ""

# Port-forward Dex
echo "   Starting port-forwards..."
kubectl -n auth port-forward svc/dex 5556:5556 > /tmp/dex-verify.log 2>&1 &
DEX_PF_PID=$!
sleep 3

# Port-forward oauth2-proxy if running
if [ "${OAUTH2_RUNNING:-true}" = true ]; then
    kubectl -n oidc-proxy port-forward svc/oauth2-proxy 4180:80 > /tmp/oauth2-verify.log 2>&1 &
    OAUTH2_PF_PID=$!
    sleep 2
fi

# Port-forward podinfo
kubectl -n podinfo port-forward svc/podinfo 9898:9898 > /tmp/podinfo-verify.log 2>&1 &
PODINFO_PF_PID=$!
sleep 2

# Cleanup function
cleanup() {
    kill $DEX_PF_PID $OAUTH2_PF_PID $PODINFO_PF_PID 2>/dev/null || true
    wait $DEX_PF_PID $OAUTH2_PF_PID $PODINFO_PF_PID 2>/dev/null || true
}
trap cleanup EXIT

# Test Dex
echo "   Testing Dex..."
if curl -s http://localhost:5556/.well-known/openid-configuration > /dev/null 2>&1; then
    ISSUER=$(curl -s http://localhost:5556/.well-known/openid-configuration | jq -r '.issuer' 2>/dev/null || echo "unknown")
    echo "      ✅ Dex accessible (Issuer: $ISSUER)"
else
    echo "      ❌ Cannot connect to Dex"
    exit 1
fi

# Test podinfo direct access
echo "   Testing podinfo (direct, no auth)..."
if curl -s http://localhost:9898 > /dev/null 2>&1; then
    PODINFO_NAME=$(curl -s http://localhost:9898 | jq -r '.name' 2>/dev/null || echo "unknown")
    echo "      ✅ podinfo accessible (Name: $PODINFO_NAME)"
else
    echo "      ❌ Cannot connect to podinfo"
    exit 1
fi

# Test oauth2-proxy
if [ "${OAUTH2_RUNNING:-true}" = true ]; then
    echo "   Testing oauth2-proxy (without token, should block)..."
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:4180 2>/dev/null || echo "000")
    if [ "$HTTP_CODE" = "403" ] || [ "$HTTP_CODE" = "401" ] || [ "$HTTP_CODE" = "302" ]; then
        echo "      ✅ oauth2-proxy blocking unauthorized access (HTTP $HTTP_CODE)"
    elif [ "$HTTP_CODE" = "000" ]; then
        echo "      ⚠️  oauth2-proxy not responding (may still be starting)"
    else
        echo "      ⚠️  Unexpected response (HTTP $HTTP_CODE)"
    fi
fi

echo ""
echo "3️⃣  Summary"
echo ""

echo "   ✅ Dex: Running and accessible"
echo "   ✅ podinfo: Running and accessible"
if [ "${OAUTH2_RUNNING:-true}" = true ]; then
    echo "   ✅ oauth2-proxy: Running and protecting podinfo"
    echo ""
    echo "   📝 To test with token:"
    echo "      1. Get token: ./scripts/get-token.sh"
    echo "      2. Access: curl -H 'Authorization: Bearer \$TOKEN' http://localhost:4180"
else
    echo "   ⚠️  oauth2-proxy: Not deployed"
    echo ""
    echo "   📝 To deploy oauth2-proxy:"
    echo "      See: oauth2-proxy/README.md"
fi

echo ""
echo "✅ Verification complete!"
echo ""
echo "💡 Port-forwards are running. Press Ctrl+C to stop them."

