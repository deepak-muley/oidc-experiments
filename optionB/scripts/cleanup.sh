#!/bin/bash

# Script to cleanup the kind cluster and resources

echo "🧹 Cleaning up OIDC Proxy Demo"
echo "==============================="

# Delete kind cluster
if kind get clusters | grep -q "oidc-proxy-demo"; then
    echo ""
    echo "🗑️  Deleting kind cluster..."
    kind delete cluster --name oidc-proxy-demo
    echo "   ✅ Cluster deleted"
else
    echo ""
    echo "   ℹ️  Cluster 'oidc-proxy-demo' not found"
fi

# Note: YAML files are now organized in component directories
# (cluster/, dex/, kube-oidc-proxy/) and should be kept for reference

echo ""
echo "✅ Cleanup complete!"

