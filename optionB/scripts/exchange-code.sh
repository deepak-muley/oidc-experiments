#!/bin/bash

# Exchange authorization code for token
# Usage: ./exchange-code.sh <authorization_code>

CODE=${1}

if [ -z "$CODE" ]; then
    echo "❌ Usage: ./exchange-code.sh <authorization_code>"
    echo ""
    echo "   Get the code from the redirect URL after logging in via:"
    echo "   http://localhost:5556/auth?client_id=cli&redirect_uri=http://127.0.0.1:5555/callback&response_type=code&scope=openid profile email"
    exit 1
fi

RESPONSE=$(curl -s -X POST http://localhost:5556/token \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=authorization_code" \
  -d "code=$CODE" \
  -d "client_id=cli" \
  -d "client_secret=cli-secret" \
  -d "redirect_uri=http://127.0.0.1:5555/callback")

TOKEN=$(echo "$RESPONSE" | jq -r '.id_token // empty' 2>/dev/null)

if [ -z "$TOKEN" ] || [ "$TOKEN" = "null" ]; then
    echo "❌ Failed to get token. Response:"
    echo "$RESPONSE" | jq . 2>/dev/null || echo "$RESPONSE"
    exit 1
fi

echo "✅ Token obtained!"
echo ""
echo "📋 Token:"
echo "$TOKEN"
echo ""
echo "💡 Export it:"
echo "   export TOKEN=\"$TOKEN\""

