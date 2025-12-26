# Gateway API Solution with Traefik

## Overview

This solution uses **Kubernetes Gateway API** with **Traefik** to eliminate port-forwards and provide a production-like setup.

## Benefits

✅ **No port-forwards needed** - Access via hostnames
✅ **Fixes redirect issue** - Proper hostname routing
✅ **Production-like** - Real Gateway API implementation
✅ **Stable** - Survives pod restarts
✅ **Better UX** - Use friendly hostnames (dex.local, podinfo.local)

## Architecture

```
Browser → Traefik Gateway → HTTPRoute → Service → Pod
```

**Flow:**
1. Browser → `http://podinfo.local`
2. Traefik Gateway → Routes to oauth2-proxy
3. oauth2-proxy → Redirects to `http://dex.local` for auth
4. Dex → Validates credentials
5. oauth2-proxy → Forwards to podinfo
6. Browser → Sees podinfo

## Components

1. **Gateway API CRDs** - Standard Kubernetes API
2. **Traefik Gateway Controller** - Implements Gateway API
3. **Gateway** - Entry point (port 80)
4. **HTTPRoute** - Routes traffic to services
5. **Dex** - OIDC provider (dex.local)
6. **oauth2-proxy** - Token validation (podinfo.local)
7. **podinfo** - Demo app

## Setup

### Step 1: Install Gateway API CRDs

```bash
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml
```

### Step 2: Run Setup Script

```bash
cd gateway-api
./setup.sh
```

**Or manually:**

```bash
# Install Traefik via Helm (recommended)
./install-traefik.sh

# Or install manually:
helm repo add traefik https://traefik.github.io/charts
helm repo update
helm upgrade --install traefik traefik/traefik \
  --namespace traefik-system \
  --create-namespace \
  --values traefik-helm-values.yaml \
  --skip-crds

# Create Gateway
kubectl apply -f gateway.yaml

# Update Dex config (uses dex.local)
kubectl apply -f dex-config-gateway.yaml
kubectl -n auth rollout restart deployment/dex

# Update oauth2-proxy config (uses hostnames)
kubectl apply -f oauth2-proxy-gateway.yaml
kubectl -n oidc-proxy rollout restart deployment/oauth2-proxy

# Create HTTPRoutes
kubectl apply -f dex-route.yaml
kubectl apply -f podinfo-route.yaml
```

### Step 3: Configure Access

**Get Traefik service:**
```bash
kubectl -n traefik-system get svc traefik
```

**For Kind (use port-forward):**
```bash
kubectl -n traefik-system port-forward svc/traefik 8080:80
```

**Add to /etc/hosts:**
```
127.0.0.1 dex.local
127.0.0.1 podinfo.local
```

**For LoadBalancer (MetalLB or cloud):**
```bash
# Get external IP
EXTERNAL_IP=$(kubectl -n traefik-system get svc traefik -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Add to /etc/hosts
echo "$EXTERNAL_IP dex.local" | sudo tee -a /etc/hosts
echo "$EXTERNAL_IP podinfo.local" | sudo tee -a /etc/hosts
```

### Step 4: Access

**Open browser:**
```
http://podinfo.local
```

**Login:**
- Username: `einstein`
- Password: `password`

**You'll be redirected to `http://dex.local` for login, then back to podinfo!**

## How It Fixes Issues

### Port-Forward Issue
- ✅ **Before:** Need 2 port-forwards (Dex + oauth2-proxy)
- ✅ **After:** No port-forwards, access via hostnames

### Redirect Issue
- ✅ **Before:** oauth2-proxy redirects to cluster URL (browser can't access)
- ✅ **After:** oauth2-proxy redirects to `dex.local` (browser can access)

### Pod Restart Issue
- ✅ **Before:** Port-forwards crash when pods restart
- ✅ **After:** Gateway API routes to services (survives pod restarts)

## Configuration Details

### Dex Configuration
- **Issuer:** `http://dex.local` (instead of cluster URL)
- **Redirect URIs:** `http://podinfo.local/oauth2/callback`

### oauth2-proxy Configuration
- **OIDC Issuer:** `http://dex.local`
- **Redirect URL:** `http://podinfo.local/oauth2/callback`
- **Upstream:** `http://podinfo.podinfo.svc.cluster.local:9898`

### HTTPRoutes
- **dex.local** → Routes to Dex service
- **podinfo.local** → Routes to oauth2-proxy service

## Troubleshooting

### Check Gateway status:
```bash
kubectl get gateway main-gateway
```

### Check HTTPRoute status:
```bash
kubectl get httproute -A
```

### Check Traefik logs:
```bash
kubectl -n traefik-system logs -l app.kubernetes.io/name=traefik
```

### Test routing:
```bash
curl -H "Host: dex.local" http://localhost/.well-known/openid-configuration
curl -H "Host: podinfo.local" http://localhost/
```

## Comparison

| Feature | Port-Forward | Gateway API |
|---------|-------------|-------------|
| **Port-forwards needed** | 2 | 0 (or 1 for Traefik) |
| **Redirect issue** | Manual URL edit | Fixed |
| **Pod restart** | Port-forward crashes | Survives |
| **Production-like** | No | Yes |
| **Setup complexity** | Simple | Medium |

## Summary

✅ **Gateway API + Traefik eliminates port-forwards**
✅ **Fixes redirect URL issue** (uses hostnames)
✅ **Production-like solution**
✅ **Better user experience** (friendly hostnames)

**This is the recommended solution for production-like setups!**

