#!/bin/bash

# Script to start all required port-forwards for podinfo access
# This handles the redirect issue by making Dex accessible from browser

echo "🚀 Starting All Port-Forwards for podinfo Access"
echo "================================================="
echo ""

# Kill any existing port-forwards first
echo "🧹 Cleaning up existing port-forwards..."
pkill -f "port-forward" 2>/dev/null
lsof -ti:5556,4180 2>/dev/null | xargs kill -9 2>/dev/null
sleep 1

# Check if Dex is running
if ! kubectl -n auth get pods -l app=dex 2>/dev/null | grep -q Running; then
    echo "❌ Dex is not running"
    echo "   Please deploy Dex first"
    exit 1
fi

# Check if oauth2-proxy is running
if ! kubectl -n oidc-proxy get pods -l app=oauth2-proxy 2>/dev/null | grep -q Running; then
    echo "❌ oauth2-proxy is not running"
    echo "   Please deploy oauth2-proxy first"
    exit 1
fi

echo "📡 Starting port-forwards..."
echo ""

# Start Dex port-forward
echo "1️⃣  Starting Dex port-forward (port 5556)..."
kubectl -n auth port-forward svc/dex 5556:5556 > /tmp/dex-pf.log 2>&1 &
DEX_PID=$!
sleep 2

if lsof -i :5556 >/dev/null 2>&1; then
    echo "   ✅ Dex port-forward started (PID: $DEX_PID)"
else
    echo "   ❌ Failed to start Dex port-forward"
    kill $DEX_PID 2>/dev/null
    exit 1
fi

# Start oauth2-proxy port-forward
echo "2️⃣  Starting oauth2-proxy port-forward (port 4180)..."
kubectl -n oidc-proxy port-forward svc/oauth2-proxy 4180:80 > /tmp/oauth2-proxy-pf.log 2>&1 &
OAUTH2_PID=$!
sleep 2

if lsof -i :4180 >/dev/null 2>&1; then
    echo "   ✅ oauth2-proxy port-forward started (PID: $OAUTH2_PID)"
else
    echo "   ❌ Failed to start oauth2-proxy port-forward"
    kill $DEX_PID $OAUTH2_PID 2>/dev/null
    exit 1
fi

echo ""
echo "✅ All port-forwards started!"
echo ""
echo "📋 Port-Forward Summary:"
echo "   Dex:         localhost:5556  (PID: $DEX_PID)"
echo "   oauth2-proxy: localhost:4180  (PID: $OAUTH2_PID)"
echo ""
echo "🌐 Open in browser:"
echo "   http://localhost:4180"
echo ""
echo "📝 Login with:"
echo "   Username: einstein"
echo "   Password: password"
echo ""
echo "✨ After login, you'll be redirected to podinfo!"
echo ""
echo "💡 To stop all port-forwards:"
echo "   kill $DEX_PID $OAUTH2_PID"
echo "   Or: ./scripts/kill-port-forwards.sh"
echo ""
echo "📝 Logs:"
echo "   Dex:         tail -f /tmp/dex-pf.log"
echo "   oauth2-proxy: tail -f /tmp/oauth2-proxy-pf.log"

