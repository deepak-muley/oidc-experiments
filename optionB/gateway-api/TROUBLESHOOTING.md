# Troubleshooting: Gateway API 404 Error

## The Problem

Accessing `http://podinfo.local:8080/` returns 404.

**Gateway status shows:** "Waiting for controller"

## Root Cause

Traefik Gateway Controller isn't recognizing the Gateway resource. This could be because:
1. Controller name mismatch
2. Traefik version doesn't fully support Gateway API
3. Gateway API implementation needs different configuration

## Quick Fix: Use Traefik IngressRoute Instead

**Since Gateway API isn't working, let's use Traefik's native IngressRoute (simpler and more reliable):**

### Step 1: Install Traefik CRDs

```bash
kubectl apply -f https://raw.githubusercontent.com/traefik/traefik/v3.0/docs/content/reference/dynamic-configuration/kubernetes-crd-definition-v1.yml
```

### Step 2: Create IngressRoute for Dex

```yaml
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: dex
  namespace: auth
spec:
  entryPoints:
  - web
  routes:
  - match: Host(`dex.local`)
    kind: Rule
    services:
    - name: dex
      port: 5556
```

### Step 3: Create IngressRoute for podinfo

```yaml
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: podinfo
  namespace: oidc-proxy
spec:
  entryPoints:
  - web
  routes:
  - match: Host(`podinfo.local`)
    kind: Rule
    services:
    - name: oauth2-proxy
      port: 80
```

## Alternative: Use NGINX Gateway API

**If you want to stick with Gateway API, try NGINX Gateway Fabric instead:**

```bash
# Install NGINX Gateway Fabric
kubectl apply -f https://raw.githubusercontent.com/nginxinc/nginx-gateway-fabric/main/deploy/manifests/install.yaml
```

**Then update GatewayClass:**
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: nginx
spec:
  controllerName: gateway.nginx.org/nginx-gateway-controller
```

## Current Status

**What's working:**
- ✅ Traefik is running
- ✅ Port-forward is active
- ✅ Gateway API resources created

**What's not working:**
- ❌ Gateway not recognized by Traefik
- ❌ Routing returns 404

## Recommendation

**For now, use the simpler port-forward solution or switch to Traefik IngressRoute (CRD-based).**

**Gateway API with Traefik might need:**
- Official Traefik Helm chart installation
- Different Traefik version
- Different controller configuration

**Would you like me to:**
1. Switch to Traefik IngressRoute (simpler, works immediately)?
2. Try NGINX Gateway API instead?
3. Keep debugging Traefik Gateway API?

