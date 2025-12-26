# Fixed: Token Generation Issue

## The Problem

`./scripts/get-token.sh` was failing with:
```
❌ Failed to get token. Response:
{
  "error": "unsupported_grant_type"
}
```

## The Cause

**Dex does not support password grant type with LDAP connectors.** This is by design - password grant only works with Dex's built-in password database, not with external LDAP.

## The Solution

Updated `get-token.sh` to use **device code flow** instead, which is the proper way to get tokens from CLI tools when using LDAP.

## How to Use (Updated)

**1. Port-forward Dex:**
```bash
kubectl -n auth port-forward svc/dex 5556:5556
```

**2. Run the script:**
```bash
cd optionB
./scripts/get-token.sh
```

**3. The script will:**
- Generate a device code
- Show you a URL to visit
- Wait for you to authenticate in browser
- Return the token once you complete login

**4. Visit the URL shown and login with:**
- Username: `einstein`
- Password: `password`

## Alternative: Simpler Browser Flow

If you prefer a simpler approach:

```bash
./scripts/get-token-simple.sh
```

This shows you how to:
1. Open http://localhost:5556 in browser
2. Login directly
3. Get token from the response

## Summary

✅ **Fixed:** Script now uses device code flow  
✅ **Works:** Can get tokens from Dex with LDAP  
✅ **Simple:** Browser-based flow also available

The core issue was using password grant (not supported) instead of device code flow (supported).

