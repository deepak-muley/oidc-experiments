#!/bin/bash

# Script to test podinfo access through kube-oidc-proxy
# Usage: ./test-podinfo.sh [TOKEN]

TOKEN=${1:-$TOKEN}

if [ -z "$TOKEN" ]; then
    echo "❌ No token provided"
    echo "   Usage: ./test-podinfo.sh <TOKEN>"
    echo "   Or: export TOKEN=<token> && ./test-podinfo.sh"
    exit 1
fi

echo "🧪 Testing podinfo access through kube-oidc-proxy"
echo "================================================="

# Check if proxy is port-forwarded
if ! curl -s -k https://localhost:8443 > /dev/null 2>&1; then
    echo "⚠️  Proxy might not be accessible on localhost:8443"
    echo "   Make sure to run: kubectl -n oidc-proxy port-forward svc/kube-oidc-proxy 8443:8443"
    echo ""
fi

echo ""
echo "❌ Test 1: Access WITHOUT token (should fail)..."
echo "-----------------------------------"
RESPONSE=$(curl -s -k -w "\nHTTP_CODE:%{http_code}" https://localhost:8443)
HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | sed '/HTTP_CODE/d')

if [ "$HTTP_CODE" = "401" ] || [ "$HTTP_CODE" = "403" ]; then
    echo "   ✅ Correctly rejected (HTTP $HTTP_CODE)"
else
    echo "   ⚠️  Unexpected response (HTTP $HTTP_CODE)"
fi
echo "   Response: $BODY"

echo ""
echo "✅ Test 2: Access WITH token (should succeed)..."
echo "-----------------------------------"
RESPONSE=$(curl -s -k -w "\nHTTP_CODE:%{http_code}" \
  -H "Authorization: Bearer $TOKEN" \
  https://localhost:8443)
HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | sed '/HTTP_CODE/d')

if [ "$HTTP_CODE" = "200" ]; then
    echo "   ✅ Successfully accessed podinfo (HTTP $HTTP_CODE)"
    echo ""
    echo "   📄 Response:"
    echo "$BODY" | jq . 2>/dev/null || echo "$BODY"
else
    echo "   ❌ Failed to access (HTTP $HTTP_CODE)"
    echo "   Response: $BODY"
    exit 1
fi

