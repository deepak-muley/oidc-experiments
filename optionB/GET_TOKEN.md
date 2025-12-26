# How to Get OIDC Token

## The Issue

Dex with LDAP connectors **does not support password grant type**. This is a Dex limitation, not a bug.

## Simple Solution (Recommended)

**Use the browser-based flow:**

```bash
# Terminal 1: Port-forward Dex
kubectl -n auth port-forward svc/dex 5556:5556

# Terminal 2: Get instructions
cd optionB
./scripts/get-token-simple.sh
```

This will show you:
1. Open http://localhost:5556 in browser
2. Login with ForumSys credentials (einstein/password)
3. Get your token

## Alternative: Authorization Code Flow

```bash
# 1. Visit this URL in browser:
http://localhost:5556/auth?client_id=cli&redirect_uri=http://127.0.0.1:5555/callback&response_type=code&scope=openid profile email

# 2. Login with einstein/password

# 3. Copy the 'code' from redirect URL (looks like: ?code=abc123...)

# 4. Exchange code for token:
./scripts/exchange-code.sh <code>
```

## Why Password Grant Doesn't Work

- Dex password grant only works with built-in password database
- LDAP connectors use different authentication flow
- This is by design for security reasons

## Summary

✅ **What works:** Browser login, authorization code flow, device code flow  
❌ **What doesn't work:** Password grant with LDAP

For demos, use the browser flow - it's simpler!

