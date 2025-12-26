# Fixed: oauth2-proxy Redirect Issue

## The Problem

oauth2-proxy was redirecting to:
```
http://dex.auth.svc.cluster.local:5556/auth?...
```

**This is a cluster-internal URL that browsers can't access!**

## The Fix

**Updated two configurations:**

### 1. Dex Configuration
**Added oauth2-proxy callback URL to Dex's redirectURIs:**
```yaml
redirectURIs:
- http://localhost:4180/oauth2/callback  # Added this
```

### 2. oauth2-proxy Configuration
**Added explicit localhost URLs for OIDC endpoints:**
```yaml
- --login-url=http://localhost:5556/auth
- --redeem-url=http://localhost:5556/token
- --oidc-jwks-url=http://localhost:5556/keys
```

**This forces oauth2-proxy to use localhost URLs instead of cluster URLs for browser redirects.**

## How It Works Now

1. **Browser** → `http://localhost:4180`
2. **oauth2-proxy** → Redirects to `http://localhost:5556/auth` (now accessible!)
3. **Dex** → Login page
4. **User logs in** → `einstein` / `password`
5. **Dex** → Redirects back to `http://localhost:4180/oauth2/callback`
6. **oauth2-proxy** → Validates token, forwards to podinfo
7. **Browser** → Shows podinfo! ✅

## Test It

**Make sure both port-forwards are running:**
```bash
# Terminal 1
kubectl -n auth port-forward svc/dex 5556:5556

# Terminal 2
kubectl -n oidc-proxy port-forward svc/oauth2-proxy 4180:80
```

**Or use the script:**
```bash
./scripts/start-all-port-forwards.sh
```

**Then open:**
```
http://localhost:4180
```

**You should now be redirected to `http://localhost:5556/auth` (not the cluster URL)!**

## What Changed

**Before:**
- oauth2-proxy used cluster URL for redirects
- Browser couldn't access cluster URLs
- Login failed

**After:**
- oauth2-proxy uses localhost URLs for redirects
- Browser can access localhost URLs
- Login works! ✅

## Summary

✅ **Fixed:** oauth2-proxy now redirects to localhost:5556
✅ **Updated:** Dex accepts oauth2-proxy callback
✅ **Ready:** Try `http://localhost:4180` now!

