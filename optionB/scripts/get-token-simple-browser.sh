#!/bin/bash

# Simple browser-based token retrieval
# This avoids device code flow issues

echo "🔑 Simple Token Retrieval (Browser Login)"
echo "=========================================="
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
echo "📝 Steps to get token:"
echo ""
echo "1️⃣  Open this URL in your browser:"
echo "   http://localhost:5556"
echo ""
echo "2️⃣  Click 'Login' and select 'ForumSys LDAP'"
echo ""
echo "3️⃣  Login with:"
echo "   Username: einstein"
echo "   Password: password"
echo ""
echo "4️⃣  After login, you'll see a page with your user info"
echo ""
echo "💡 Alternative: Use authorization code flow"
echo ""
echo "   Visit this URL:"
AUTH_URL="http://localhost:5556/auth?client_id=cli&redirect_uri=http://127.0.0.1:5555/callback&response_type=code&scope=openid profile email"
echo "   $AUTH_URL"
echo ""
echo "   After login, copy the 'code' parameter from the redirect URL"
echo "   Then run: ./scripts/exchange-code.sh <code>"
echo ""

