#!/bin/bash

# Script to kill all port-forward processes

echo "🛑 Killing port-forward processes..."
echo "====================================="
echo ""

# Kill kubectl port-forward processes
PF_PIDS=$(ps aux | grep "kubectl.*port-forward" | grep -v grep | awk '{print $2}')

if [ -z "$PF_PIDS" ]; then
    echo "✅ No kubectl port-forward processes to kill"
else
    echo "Found port-forward processes:"
    ps aux | grep "kubectl.*port-forward" | grep -v grep | awk '{print "   PID " $2 ": " substr($0, index($0,$11))}'
    echo ""
    echo "Killing processes..."
    echo "$PF_PIDS" | xargs kill -9 2>/dev/null
    echo "✅ Killed all port-forward processes"
fi

echo ""
echo "Freeing ports..."

# Free specific ports if anything is listening
for port in 5556 4180 9898 8443; do
    PIDS=$(lsof -ti:$port 2>/dev/null)
    if [ -n "$PIDS" ]; then
        echo "   Killing processes on port $port..."
        echo "$PIDS" | xargs kill -9 2>/dev/null
    fi
done

echo "✅ All port-forwards stopped!"
echo ""
echo "Ports freed:"
echo "  - 5556 (Dex)"
echo "  - 4180 (oauth2-proxy)"
echo "  - 9898 (podinfo)"
echo "  - 8443 (kube-oidc-proxy)"

