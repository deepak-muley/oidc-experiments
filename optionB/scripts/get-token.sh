#!/bin/bash

# Script to get an OIDC token from Dex using device code flow
# Note: Password grant is not supported with LDAP connectors
# Usage: ./get-token.sh [--quiet]
#
# Alternative: Use ./get-token-simple.sh for browser-based flow

QUIET=false

# Parse arguments
for arg in "$@"; do
    if [[ "$arg" == "--quiet" ]]; then
        QUIET=true
    fi
done

if [ "$QUIET" = false ]; then
    echo "🔑 Getting OIDC token from Dex"
    echo "=========================================="
fi

# Check if Dex is port-forwarded
if ! curl -s http://localhost:5556/.well-known/openid-configuration > /dev/null 2>&1; then
    if [ "$QUIET" = false ]; then
        echo "❌ Dex is not accessible on localhost:5556"
        echo "   Please run: kubectl -n auth port-forward svc/dex 5556:5556"
    fi
    exit 1
fi

if [ "$QUIET" = false ]; then
    echo ""
    echo "📡 Requesting device code from Dex..."
fi

# Step 1: Get device code
DEVICE_RESPONSE=$(curl -s -X POST http://localhost:5556/device/code \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "client_id=cli" \
  -d "client_secret=cli-secret" \
  -d "scope=openid profile email")

DEVICE_CODE=$(echo "$DEVICE_RESPONSE" | jq -r '.device_code // empty' 2>/dev/null)
USER_CODE=$(echo "$DEVICE_RESPONSE" | jq -r '.user_code // empty' 2>/dev/null)
VERIFICATION_URI=$(echo "$DEVICE_RESPONSE" | jq -r '.verification_uri // empty' 2>/dev/null)
VERIFICATION_URI_COMPLETE=$(echo "$DEVICE_RESPONSE" | jq -r '.verification_uri_complete // empty' 2>/dev/null)
INTERVAL=$(echo "$DEVICE_RESPONSE" | jq -r '.interval // 5' 2>/dev/null)

if [ -z "$DEVICE_CODE" ] || [ "$DEVICE_CODE" = "null" ]; then
    if [ "$QUIET" = false ]; then
        echo "❌ Failed to get device code. Response:"
        echo "$DEVICE_RESPONSE" | jq . 2>/dev/null || echo "$DEVICE_RESPONSE"
    fi
    exit 1
fi

if [ "$QUIET" = false ]; then
    echo ""
    echo "📱 Device code obtained!"
    echo ""
    echo "👉 Please visit this URL in your browser:"
    # Convert cluster URL to localhost if port-forward is active
    LOCAL_URI=$(echo "$VERIFICATION_URI_COMPLETE" | sed 's|http://dex.auth.svc.cluster.local:5556|http://localhost:5556|')
    echo "   $LOCAL_URI"
    echo ""
    echo "   Or manually visit:"
    LOCAL_VERIFICATION_URI=$(echo "$VERIFICATION_URI" | sed 's|http://dex.auth.svc.cluster.local:5556|http://localhost:5556|')
    echo "   $LOCAL_VERIFICATION_URI"
    echo "   And enter code: $USER_CODE"
    echo ""
    echo "   Login with ForumSys LDAP credentials (e.g., einstein/password)"
    echo ""
    echo "   Note: Make sure Dex is port-forwarded:"
    echo "   kubectl -n auth port-forward svc/dex 5556:5556"
    echo ""
    echo "⏳ Waiting for authentication..."
fi

# Step 2: Poll for token
MAX_ATTEMPTS=60
ATTEMPT=0
TOKEN=""

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    sleep $INTERVAL
    ATTEMPT=$((ATTEMPT + 1))
    
    TOKEN_RESPONSE=$(curl -s -X POST http://localhost:5556/token \
      -H "Content-Type: application/x-www-form-urlencoded" \
      -d "grant_type=urn:ietf:params:oauth:grant-type:device_code" \
      -d "device_code=$DEVICE_CODE" \
      -d "client_id=cli" \
      -d "client_secret=cli-secret")
    
    ERROR=$(echo "$TOKEN_RESPONSE" | jq -r '.error // empty' 2>/dev/null)
    
    if [ "$ERROR" = "authorization_pending" ]; then
        if [ "$QUIET" = false ] && [ $((ATTEMPT % 5)) -eq 0 ]; then
            echo "   Still waiting... (attempt $ATTEMPT/$MAX_ATTEMPTS)"
        fi
        continue
    fi
    
    if [ "$ERROR" = "expired_token" ]; then
        if [ "$QUIET" = false ]; then
            echo "❌ Device code expired. Please run the script again."
        fi
        exit 1
    fi
    
    TOKEN=$(echo "$TOKEN_RESPONSE" | jq -r '.id_token // empty' 2>/dev/null)
    
    if [ -n "$TOKEN" ] && [ "$TOKEN" != "null" ]; then
        break
    fi
    
    if [ -n "$ERROR" ] && [ "$ERROR" != "authorization_pending" ] && [ "$ERROR" != "slow_down" ]; then
        if [ "$QUIET" = false ]; then
            echo "❌ Error: $ERROR"
            echo "$TOKEN_RESPONSE" | jq . 2>/dev/null || echo "$TOKEN_RESPONSE"
        fi
        exit 1
    fi
    
    # Handle slow_down error (increase polling interval)
    if [ "$ERROR" = "slow_down" ]; then
        INTERVAL=$((INTERVAL + 5))
        if [ "$QUIET" = false ]; then
            echo "   Rate limited, slowing down... (new interval: ${INTERVAL}s)"
        fi
    fi
done

if [ -z "$TOKEN" ] || [ "$TOKEN" = "null" ]; then
    if [ "$QUIET" = false ]; then
        echo "❌ Failed to get token after $MAX_ATTEMPTS attempts"
        echo "   Make sure you completed authentication in the browser"
        echo "   Last response:"
        echo "$TOKEN_RESPONSE" | jq . 2>/dev/null || echo "$TOKEN_RESPONSE"
    fi
    exit 1
fi

if [ "$QUIET" = true ]; then
    # In quiet mode, just output the token
    echo "$TOKEN"
else
    echo ""
    echo "✅ Token obtained successfully!"
    echo ""
    echo "📋 Token (save this):"
    echo "$TOKEN"
    echo ""
    echo "💡 To use this token:"
    echo "   export TOKEN=\"$TOKEN\""
    echo "   curl -k -H \"Authorization: Bearer \$TOKEN\" https://localhost:8443"
    echo ""
    echo "   Or run: ./test-podinfo.sh \"$TOKEN\""
fi

