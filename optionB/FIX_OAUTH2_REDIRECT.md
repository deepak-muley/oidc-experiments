# Fix: oauth2-proxy Redirects to Cluster URL (Browser Can't Access)

## The Problem

When you open `http://localhost:4180`, oauth2-proxy redirects to:
```
http://dex.auth.svc.cluster.local:5556/auth?...
```

**This is a cluster-internal URL that your browser can't access!**

## Why This Happens

**oauth2-proxy is configured with:**
```yaml
- --oidc-issuer-url=http://dex.auth.svc.cluster.local:5556
```

**When oauth2-proxy redirects to Dex, it uses this URL, which only works inside the cluster.**

## The Solution: Port-Forward Dex Too

**You need TWO port-forwards:**
1. **Dex** (port 5556) - So browser can access Dex for login
2. **oauth2-proxy** (port 4180) - So browser can access the app

**But we can't change oauth2-proxy's config to use localhost because it runs inside the cluster!**

## Workaround: Use Dex's Public URL

**Actually, we need to configure oauth2-proxy to use a URL that works from both:**
- Inside cluster (for oauth2-proxy to talk to Dex)
- Outside cluster (for browser to access Dex)

**But wait - we can't have both!**

## Best Solution: Two Port-Forwards (Minimal)

**This is the simplest working solution:**

### Step 1: Port-Forward Dex
```bash
kubectl -n auth port-forward svc/dex 5556:5556
```

### Step 2: Port-Forward oauth2-proxy
```bash
kubectl -n oidc-proxy port-forward svc/oauth2-proxy 4180:80
```

### Step 3: Update oauth2-proxy Config (Temporary)

**We need to tell oauth2-proxy to use localhost for redirects, but cluster URL for validation.**

**Actually, oauth2-proxy doesn't support this split configuration easily.**

## Alternative: Use Ingress or NodePort

**For production, you'd use:**
- Ingress controller
- NodePort service
- LoadBalancer

**But for local testing, two port-forwards is the simplest.**

## Quick Fix Script

**Create a script that starts both port-forwards:**

```bash
#!/bin/bash
# Start both port-forwards

# Port-forward Dex
kubectl -n auth port-forward svc/dex 5556:5556 &
DEX_PID=$!

# Port-forward oauth2-proxy
kubectl -n oidc-proxy port-forward svc/oauth2-proxy 4180:80 &
OAUTH2_PID=$!

echo "✅ Started port-forwards:"
echo "   Dex: PID $DEX_PID (port 5556)"
echo "   oauth2-proxy: PID $OAUTH2_PID (port 4180)"
echo ""
echo "🌐 Open: http://localhost:4180"
echo ""
echo "To stop: kill $DEX_PID $OAUTH2_PID"
```

## Better Solution: Fix oauth2-proxy Config

**We can configure oauth2-proxy to use a different redirect URL:**

**Update `oauth2-proxy.yaml` to use environment variable for issuer URL that can be overridden.**

**But actually, the real issue is that oauth2-proxy needs to:**
1. Talk to Dex (cluster URL works)
2. Redirect browser to Dex (needs localhost)

**This is a limitation of running oauth2-proxy in-cluster.**

## Practical Solution: Use Dex's External URL

**If we had Dex exposed via Ingress or NodePort, we could use that URL.**

**For now, the simplest is two port-forwards.**

## Summary

**The issue:** oauth2-proxy redirects to cluster-internal Dex URL that browser can't access.

**The fix:** Port-forward Dex so browser can access it.

**You need TWO port-forwards:**
1. Dex (5556) - For browser login
2. oauth2-proxy (4180) - For app access

**This is the simplest working solution for local testing!**

