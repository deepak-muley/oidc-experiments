# Fix: Device Code Flow - Token Not Received After Login

## The Problem

After successful login in the browser ("Login Successful for cli"), the CLI script keeps waiting and shows:
```
⏳ Waiting for authentication...
   Still waiting... (attempt 5/60)
❌ Failed to get token. Response:
```

## Root Cause

**Bug in the script:** The script had a variable name error (`$RESPONSE` instead of `$TOKEN_RESPONSE`), but more importantly, it wasn't handling all error cases properly.

## The Fix

**Updated `scripts/get-token.sh` to:**
1. ✅ Properly extract token from `$TOKEN_RESPONSE`
2. ✅ Handle `slow_down` error (rate limiting)
3. ✅ Show better error messages
4. ✅ Remove duplicate token extraction code

## How Device Code Flow Works

**Important:** Device code flow does NOT redirect to podinfo. Here's the flow:

1. **CLI requests device code** → Gets `device_code` and `user_code`
2. **User visits URL in browser** → Enters `user_code`
3. **User logs in** → Dex validates credentials
4. **CLI polls for token** → Keeps checking `/token` endpoint
5. **Token is returned** → CLI gets `id_token`
6. **Use token to access podinfo** → Token is used in Authorization header

## After Getting Token

**Once you have the token, use it to access podinfo:**

```bash
# Get token
TOKEN=$(./scripts/get-token.sh --quiet)

# Port-forward podinfo
kubectl -n podinfo port-forward svc/podinfo 9898:9898

# Access podinfo with token
curl -H "Authorization: Bearer $TOKEN" http://localhost:9898
```

## Alternative: Use Authorization Code Flow (Redirects to podinfo)

**If you want a redirect to podinfo after login, use authorization code flow:**

1. **Port-forward oauth2-proxy:**
   ```bash
   kubectl -n oidc-proxy port-forward svc/oauth2-proxy 4180:80
   ```

2. **Open browser:**
   ```
   http://localhost:4180
   ```

3. **Login** → You'll be redirected to podinfo automatically!

**This is simpler for demos!**

## Summary

✅ **Fixed:** Script now properly extracts tokens
✅ **Clarified:** Device code flow doesn't redirect - you get a token, then use it
✅ **Alternative:** Use oauth2-proxy for automatic redirect to podinfo

**Try the script again - it should work now!**

