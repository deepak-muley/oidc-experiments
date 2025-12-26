# Fix: "Unregistered redirect_uri" Error

## The Problem

When using device code flow, you see:
```
Unregistered redirect_uri ("/device/callback")
```

**Why:** Dex client configuration doesn't have the device code callback URL registered.

## The Fix

**Updated `dex/dex-config.yaml` to include:**
```yaml
staticClients:
- id: cli
  redirectURIs:
  - http://127.0.0.1:5555/callback
  - http://localhost:5556/device/callback          # Added
  - http://dex.auth.svc.cluster.local:5556/device/callback  # Added
```

**Applied the fix:**
```bash
kubectl apply -f dex/dex-config.yaml
kubectl -n auth rollout restart deployment/dex
```

## Verification

**After Dex restarts, try again:**
1. Port-forward Dex: `kubectl -n auth port-forward svc/dex 5556:5556`
2. Run: `./scripts/get-token.sh`
3. Visit the URL shown
4. Should work now!

## What Changed

**Before:**
- Only had: `http://127.0.0.1:5555/callback`
- Missing device code callback URLs

**After:**
- Has authorization code callback
- Has device code callback (localhost)
- Has device code callback (cluster)

## Summary

✅ **Fixed:** Added device code callback URLs to Dex client config
✅ **Applied:** Restarted Dex with new config
✅ **Ready:** Device code flow should work now

Try the device code flow again - it should work!

