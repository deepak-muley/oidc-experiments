#!/bin/bash

# Script to check running port-forward processes

echo "🔍 Checking for port-forward processes..."
echo "=========================================="
echo ""

# Method 1: Check kubectl port-forward processes
echo "📋 kubectl port-forward processes:"
PF_PROCESSES=$(ps aux | grep "kubectl.*port-forward" | grep -v grep)

if [ -z "$PF_PROCESSES" ]; then
    echo "   ✅ No kubectl port-forward processes running"
else
    echo "$PF_PROCESSES" | while read line; do
        PID=$(echo "$line" | awk '{print $2}')
        CMD=$(echo "$line" | awk '{for(i=11;i<=NF;i++) printf "%s ", $i; print ""}')
        echo "   🔴 PID: $PID"
        echo "      Command: $CMD"
        echo ""
    done
fi

echo ""
echo "📋 Processes listening on common ports:"
echo "   Port 5556 (Dex):"
lsof -i :5556 2>/dev/null | grep LISTEN || echo "      ✅ Free"
echo "   Port 4180 (oauth2-proxy):"
lsof -i :4180 2>/dev/null | grep LISTEN || echo "      ✅ Free"
echo "   Port 9898 (podinfo):"
lsof -i :9898 2>/dev/null | grep LISTEN || echo "      ✅ Free"
echo "   Port 8443 (kube-oidc-proxy):"
lsof -i :8443 2>/dev/null | grep LISTEN || echo "      ✅ Free"

