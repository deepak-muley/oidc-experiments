#!/bin/bash

# Simple script to get OIDC token - uses browser-based flow
# This is simpler than device code flow for demos

echo "🔑 Getting OIDC Token from Dex"
echo "================================"
echo ""

# Check if Dex is port-forwarded
if ! curl -s http://localhost:5556/.well-known/openid-configuration > /dev/null 2>&1; then
    echo "❌ Dex is not accessible on localhost:5556"
    echo ""
    echo "   Please run in another terminal:"
    echo "   kubectl -n auth port-forward svc/dex 5556:5556"
    exit 1
fi

echo "✅ Dex is accessible"
echo ""
echo "📝 To get a token, you have two options:"
echo ""
echo "Option 1: Use Dex Web UI (Recommended for demos)"
echo "   1. Open browser: http://localhost:5556"
echo "   2. Click 'Login' and use ForumSys LDAP credentials"
echo "   3. After login, you'll get redirected with a token"
echo ""
echo "Option 2: Use curl with authorization code flow"
echo "   1. Visit: http://localhost:5556/auth?client_id=cli&redirect_uri=http://127.0.0.1:5555/callback&response_type=code&scope=openid profile email"
echo "   2. Login with einstein/password"
echo "   3. Copy the 'code' from the redirect URL"
echo "   4. Run: ./scripts/exchange-code.sh <code>"
echo ""
echo "💡 For automated testing, device code flow is better but requires browser interaction."
echo "   See: ./scripts/get-token.sh (uses device code flow)"

