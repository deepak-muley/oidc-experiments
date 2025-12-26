#!/bin/bash

# Script to restart port-forwards if they crash
# This handles the common issue where port-forwards break after pod restarts

echo "🔄 Restarting Port-Forwards"
echo "============================"
echo ""

# Kill existing port-forwards
echo "🧹 Cleaning up existing port-forwards..."
pkill -f "port-forward.*4180" 2>/dev/null
pkill -f "port-forward.*5556" 2>/dev/null
lsof -ti:4180,5556 2>/dev/null | xargs kill -9 2>/dev/null
sleep 2

# Check if pods are running
echo "📋 Checking pods..."
if ! kubectl -n auth get pods -l app=dex 2>/dev/null | grep -q Running; then
    echo "❌ Dex pod is not running"
    exit 1
fi

if ! kubectl -n oidc-proxy get pods -l app=oauth2-proxy 2>/dev/null | grep -q Running; then
    echo "❌ oauth2-proxy pod is not running"
    exit 1
fi

echo "✅ Pods are running"
echo ""

# Use service port-forwards (more stable - survive pod restarts)
echo "📡 Starting port-forwards using services..."
echo "   (Using services instead of pods - more stable)"
echo ""

# Start Dex port-forward (using service)
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

# Start oauth2-proxy port-forward (using service)
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
echo "✅ Port-forwards restarted!"
echo ""
echo "📋 Port-Forward Summary:"
echo "   Dex:         localhost:5556  (PID: $DEX_PID, Service: dex)"
echo "   oauth2-proxy: localhost:4180  (PID: $OAUTH2_PID, Service: oauth2-proxy)"
echo ""
echo "🌐 Open in browser:"
echo "   http://localhost:4180"
echo ""
echo "💡 If port-forward crashes again:"
echo "   ./scripts/restart-port-forwards.sh"
echo ""
echo "📝 Logs:"
echo "   Dex:         tail -f /tmp/dex-pf.log"
echo "   oauth2-proxy: tail -f /tmp/oauth2-proxy-pf.log"

