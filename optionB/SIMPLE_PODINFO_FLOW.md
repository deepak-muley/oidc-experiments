# Simple Flow: From Token to podinfo (One Port-Forward!)

## The Problem

You're asking: "I got a token, but how do I actually open podinfo? Do I need another port-forward?"

**Answer:** Yes, but there's a simpler way with just ONE port-forward!

## Current Flow (Multiple Port-Forwards) ❌

**What you're doing now:**
```
1. Port-forward Dex (port 5556)
   kubectl -n auth port-forward svc/dex 5556:5556

2. Get token via device code flow
   ./scripts/get-token.sh

3. Port-forward podinfo (port 9898)  ← Another port-forward!
   kubectl -n podinfo port-forward svc/podinfo 9898:9898

4. Access podinfo with token
   curl -H "Authorization: Bearer $TOKEN" http://localhost:9898
```

**Problems:**
- ❌ Multiple port-forwards
- ❌ Token validation not automatic
- ❌ Manual curl commands
- ❌ No browser experience

## Simple Flow (ONE Port-Forward) ✅

**Use oauth2-proxy - it handles everything!**

```
1. Port-forward oauth2-proxy (port 4180)  ← Just ONE!
   kubectl -n oidc-proxy port-forward svc/oauth2-proxy 4180:80

2. Open browser
   http://localhost:4180

3. Login automatically redirects to Dex
   Enter: einstein / password

4. Automatically redirected to podinfo! ✅
   You see podinfo in browser!
```

**Benefits:**
- ✅ Only ONE port-forward
- ✅ Automatic token validation
- ✅ Browser experience
- ✅ Automatic redirect to podinfo

## Step-by-Step: Simple Flow

### Step 1: Kill All Port-Forwards (Clean Start)

```bash
cd optionB
./scripts/kill-port-forwards.sh
```

### Step 2: Port-Forward oauth2-proxy (ONLY ONE!)

```bash
kubectl -n oidc-proxy port-forward svc/oauth2-proxy 4180:80
```

**Keep this running!**

### Step 3: Open Browser

```
http://localhost:4180
```

### Step 4: Login

**What happens:**
1. oauth2-proxy redirects you to Dex
2. You login: `einstein` / `password`
3. Dex redirects back to oauth2-proxy
4. oauth2-proxy validates token
5. **Automatically shows podinfo!** ✅

**That's it!** You're now viewing podinfo in your browser!

## What oauth2-proxy Does

**oauth2-proxy is a smart proxy that:**
- ✅ Handles OIDC authentication
- ✅ Validates tokens automatically
- ✅ Forwards requests to podinfo
- ✅ Gives you a browser experience

**Flow:**
```
Browser → oauth2-proxy → Dex (login) → oauth2-proxy → podinfo
```

**All in one!**

## Alternative: If You Already Have a Token

**If you already got a token via device code flow:**

```bash
# Port-forward oauth2-proxy
kubectl -n oidc-proxy port-forward svc/oauth2-proxy 4180:80

# Use token in Authorization header
curl -H "Authorization: Bearer $TOKEN" http://localhost:4180
```

**But the browser flow is simpler!**

## Comparison

| Method | Port-Forwards | Experience | Complexity |
|--------|---------------|------------|------------|
| **Device code + podinfo** | 2 (Dex + podinfo) | CLI/curl | Complex |
| **oauth2-proxy** | 1 (oauth2-proxy) | Browser | Simple ✅ |

## Quick Reference

**To access podinfo with ONE port-forward:**

```bash
# Terminal 1: Port-forward oauth2-proxy
kubectl -n oidc-proxy port-forward svc/oauth2-proxy 4180:80

# Browser: Open
http://localhost:4180

# Login: einstein / password
# → Automatically redirected to podinfo!
```

## Troubleshooting

**If oauth2-proxy doesn't redirect to podinfo:**

1. Check oauth2-proxy logs:
   ```bash
   kubectl -n oidc-proxy logs -l app=oauth2-proxy --tail=20
   ```

2. Check oauth2-proxy config:
   ```bash
   kubectl -n oidc-proxy get deployment oauth2-proxy -o yaml | grep upstream
   ```

3. Make sure podinfo is running:
   ```bash
   kubectl -n podinfo get pods
   ```

## Summary

**Simple answer:**
- ✅ Use **oauth2-proxy** with ONE port-forward
- ✅ Open browser to `http://localhost:4180`
- ✅ Login → Automatically see podinfo!

**No need for:**
- ❌ Multiple port-forwards
- ❌ Device code flow
- ❌ Manual token handling
- ❌ curl commands

**Just one port-forward and a browser!**

