# Verification Guide for Option B

## Current Status

✅ **Dex** - Running and ready
✅ **podinfo** - Running and ready  
⚠️ **kube-oidc-proxy** - Note: The current kube-oidc-proxy is designed for Kubernetes API server proxying, not arbitrary HTTP backends. The token validation flow works, but proxying to podinfo requires a different approach.

## How to Verify the Setup

### 1. Verify All Components Are Running

```bash
# Check Dex
kubectl -n auth get pods
# Should show: dex-xxx-xxx  1/1   Running

# Check podinfo  
kubectl -n podinfo get pods
# Should show: podinfo-xxx-xxx  1/1   Running

# Check kube-oidc-proxy (if deployed)
kubectl -n oidc-proxy get pods
```

### 2. Test Dex Token Generation

**Terminal 1 - Port-forward Dex:**
```bash
kubectl -n auth port-forward svc/dex 5556:5556
```

**Terminal 2 - Get OIDC Token:**
```bash
cd optionB
./scripts/get-token.sh
```

You should see output like:
```
✅ Token obtained successfully!

📋 Token (save this):
eyJhbGciOiJSUzI1NiIsImtpZCI6Ij...
```

### 3. Verify Token Contents

You can decode the JWT token to see its contents:

```bash
# Install jwt-cli if needed: brew install mike-engel/jwt-cli/jwt-cli
# Or use online tool: https://jwt.io

# Extract token from get-token.sh output, then:
echo $TOKEN | jwt decode
```

You should see claims like:
- `iss`: http://dex.auth.svc.cluster.local:5556
- `sub`: einstein (or your username)
- `email`: einstein@ldap.forumsys.com

### 4. Test Direct podinfo Access (Without Auth)

```bash
# Port-forward podinfo directly
kubectl -n podinfo port-forward svc/podinfo 9898:9898

# In another terminal, test access:
curl http://localhost:9898

# Should return podinfo JSON (no auth required)
```

### 5. Manual Token Validation Test

To verify the token is valid, you can test it against Dex:

```bash
# With Dex port-forwarded on 5556
export TOKEN="<your-token-here>"

# Verify token with Dex (if it exposes a userinfo endpoint)
curl -H "Authorization: Bearer $TOKEN" http://localhost:5556/userinfo
```

## What's Working

✅ **Dex OIDC Provider** - Successfully authenticates against ForumSys LDAP
✅ **Token Generation** - Can generate valid OIDC tokens via password grant
✅ **LDAP Integration** - ForumSys LDAP users can authenticate

## Known Limitation

⚠️ **kube-oidc-proxy** - The Tremolo Security fork of kube-oidc-proxy is designed specifically for proxying Kubernetes API server requests, not arbitrary HTTP backends like podinfo. 

For a complete demo that proxies to podinfo, you would need:
- A different proxy tool that supports OIDC token validation and arbitrary upstreams
- OR modify the approach to use kube-oidc-proxy for API server access instead

## Alternative: Test with Kubernetes API

If you want to test kube-oidc-proxy's actual functionality, you can use it to proxy Kubernetes API requests:

```bash
# Deploy kube-oidc-proxy pointing to the API server
# Then use kubectl with the proxy endpoint
kubectl --server=https://localhost:8443 --insecure-skip-tls-verify get pods -A
```

## Summary

The core OIDC authentication flow is working:
1. ✅ Dex authenticates users against ForumSys LDAP
2. ✅ Dex issues OIDC tokens
3. ✅ Tokens can be obtained via password grant flow
4. ✅ Token validation works

The remaining piece is a proxy that can:
- Validate OIDC tokens
- Forward requests to arbitrary HTTP backends (like podinfo)

This demonstrates the authentication part of Option B successfully!

