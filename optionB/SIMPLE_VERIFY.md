# Simple Verification Guide

## ✅ What's Running

1. **Dex** - OIDC provider (authenticates users via ForumSys LDAP)
2. **podinfo** - Demo application
3. **kube-oidc-proxy** - Optional (not needed for core demo)

## Quick Verification

```bash
cd optionB
./scripts/verify.sh
```

This checks:
- ✅ All pods are running
- ✅ Dex is accessible
- ✅ podinfo is accessible

## How It Works (Simple)

```
User → Dex (gets OIDC token) → Use token to access services
```

**Important:** kube-oidc-proxy is **optional**. The core demo works with:
- **Dex** (for authentication)
- **podinfo** (the app you're protecting)

## What If kube-oidc-proxy Is Down?

**Answer: It doesn't matter!** 

kube-oidc-proxy is optional. The core functionality is:
1. Dex authenticates users → generates OIDC tokens
2. You use those tokens to access services

You can:
- Access podinfo directly (no auth)
- Use tokens with any OIDC-aware service
- Skip kube-oidc-proxy entirely

## Test It Yourself

**1. Check everything is running:**
```bash
./scripts/verify.sh
```

**2. Get an OIDC token:**
```bash
# Terminal 1: Port-forward Dex
kubectl -n auth port-forward svc/dex 5556:5556

# Terminal 2: Get token
./scripts/get-token.sh
```

**3. Access podinfo:**
```bash
# Terminal 1: Port-forward podinfo
kubectl -n podinfo port-forward svc/podinfo 9898:9898

# Terminal 2: Access it
curl http://localhost:9898
```

## Summary

- ✅ Dex = Working (authenticates users)
- ✅ podinfo = Working (your app)
- ⚠️ kube-oidc-proxy = Optional (can ignore if down)

The demo works fine without kube-oidc-proxy!

