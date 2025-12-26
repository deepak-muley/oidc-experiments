# Quick Start: Gateway API with Traefik

## Overview

This solution uses **Gateway API** with **Traefik** to eliminate port-forwards and fix the redirect issue.

## Benefits

✅ **Only 1 port-forward** (for Traefik) instead of 2
✅ **Fixes redirect issue** (uses hostnames)
✅ **Production-like** setup
✅ **Stable** (survives pod restarts)

## Quick Setup

### Step 1: Install Gateway API CRDs

```bash
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml
```

### Step 2: Run Setup Script

```bash
cd gateway-api
./setup.sh
```

### Step 3: Access Traefik

**For Kind (port-forward Traefik):**
```bash
kubectl -n traefik-system port-forward svc/traefik 8080:80
```

**For LoadBalancer (get external IP):**
```bash
kubectl -n traefik-system get svc traefik
# Use the external IP
```

### Step 4: Configure /etc/hosts

```bash
# Add to /etc/hosts
127.0.0.1 dex.local
127.0.0.1 podinfo.local
```

### Step 5: Access

**Open browser:**
```
http://podinfo.local
```

**Login:** `einstein` / `password`

**You'll be redirected to `http://dex.local` for login, then back to podinfo!**

## How It Works

```
Browser → podinfo.local → Traefik Gateway → oauth2-proxy → podinfo
                              ↓
                         dex.local → Dex (auth)
```

**Key changes:**
- Dex issuer: `http://dex.local` (instead of cluster URL)
- oauth2-proxy redirect: `http://podinfo.local/oauth2/callback`
- HTTPRoutes route hostnames to services

## Troubleshooting

**Check Gateway:**
```bash
kubectl get gateway main-gateway
```

**Check HTTPRoutes:**
```bash
kubectl get httproute -A
```

**Check Traefik:**
```bash
kubectl -n traefik-system get pods
kubectl -n traefik-system logs -l app.kubernetes.io/name=traefik
```

**Test routing:**
```bash
curl -H "Host: dex.local" http://localhost/.well-known/openid-configuration
curl -H "Host: podinfo.local" http://localhost/
```

## Summary

✅ **Only 1 port-forward** (Traefik) instead of 2
✅ **Redirect issue fixed** (uses hostnames)
✅ **Production-like** Gateway API solution

**This is the best solution for eliminating port-forwards!**

