#!/bin/bash

# Simple script to access podinfo with ONE port-forward
# This uses oauth2-proxy which handles everything

echo "🚀 Simple podinfo Access (One Port-Forward)"
echo "==========================================="
echo ""

# Check if oauth2-proxy is already port-forwarded
if lsof -i :4180 >/dev/null 2>&1; then
    echo "✅ oauth2-proxy is already port-forwarded on port 4180"
    echo ""
    echo "🌐 Open in browser:"
    echo "   http://localhost:4180"
    echo ""
    echo "📝 Login with:"
    echo "   Username: einstein"
    echo "   Password: password"
    echo ""
    echo "✨ After login, you'll automatically see podinfo!"
    exit 0
fi

# Check if oauth2-proxy pod exists
if ! kubectl -n oidc-proxy get pods -l app=oauth2-proxy 2>/dev/null | grep -q Running; then
    echo "❌ oauth2-proxy is not running"
    echo ""
    echo "   Please deploy oauth2-proxy first:"
    echo "   kubectl apply -f oauth2-proxy/oauth2-proxy.yaml"
    exit 1
fi

echo "📡 Starting port-forward for oauth2-proxy..."
echo ""
echo "   This will run in the background"
echo "   To stop: ./scripts/kill-port-forwards.sh"
echo ""

# Start port-forward in background
kubectl -n oidc-proxy port-forward svc/oauth2-proxy 4180:80 > /tmp/oauth2-proxy-pf.log 2>&1 &
PF_PID=$!

# Wait a moment for port-forward to start
sleep 2

# Check if it's running
if lsof -i :4180 >/dev/null 2>&1; then
    echo "✅ Port-forward started (PID: $PF_PID)"
    echo ""
    echo "🌐 Open in browser:"
    echo "   http://localhost:4180"
    echo ""
    echo "📝 Login with:"
    echo "   Username: einstein"
    echo "   Password: password"
    echo ""
    echo "✨ After login, you'll automatically see podinfo!"
    echo ""
    echo "💡 To stop port-forward:"
    echo "   kill $PF_PID"
    echo "   Or: ./scripts/kill-port-forwards.sh"
else
    echo "❌ Failed to start port-forward"
    echo "   Check logs: tail -f /tmp/oauth2-proxy-pf.log"
    kill $PF_PID 2>/dev/null
    exit 1
fi

