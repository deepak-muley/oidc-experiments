# What Does "K8s API Only" Mean?

## The Confusion

You asked: *"What do you mean by kube-oidc-proxy works with HTTP apps: No (K8s API only)?"*

Let me explain clearly.

## What kube-oidc-proxy Actually Does

**kube-oidc-proxy is designed for ONE specific purpose:**
- Proxy requests to the **Kubernetes API server**
- That's it!

## What This Means

### ✅ What kube-oidc-proxy CAN Do

**Proxy Kubernetes API requests:**
```bash
# Instead of:
kubectl get pods --server=https://k8s-api-server:6443

# You can do:
kubectl get pods --server=https://kube-oidc-proxy:8443
```

**It handles:**
- `GET /api/v1/pods`
- `POST /api/v1/namespaces`
- `GET /apis/apps/v1/deployments`
- All Kubernetes API endpoints

### ❌ What kube-oidc-proxy CANNOT Do

**Proxy to regular HTTP apps:**
```bash
# This DOESN'T work:
curl https://kube-oidc-proxy:8443  # Tries to reach K8s API, not podinfo!

# It expects Kubernetes API requests like:
GET /api/v1/namespaces
GET /api/v1/pods
```

**It cannot:**
- Proxy to `http://podinfo:9898` ❌
- Proxy to `http://my-app:8080` ❌
- Proxy to any regular web app ❌
- Act as a general HTTP reverse proxy ❌

## Why This Matters

### For Kubernetes API Access ✅

**Use case:** "I want to use `kubectl` with OIDC authentication"

```
kubectl → kube-oidc-proxy → Kubernetes API Server
           ↑
      Validates OIDC token
      Uses impersonation
```

**This works!** kube-oidc-proxy is perfect for this.

### For Regular Apps ❌

**Use case:** "I want to protect podinfo with OIDC"

```
curl → kube-oidc-proxy → podinfo
       ↑
  Tries to reach K8s API!
  Doesn't know about podinfo
```

**This doesn't work!** kube-oidc-proxy doesn't know how to proxy to podinfo.

## The Technical Reason

**kube-oidc-proxy is hardcoded to:**
1. Forward requests to the Kubernetes API server
2. Use Kubernetes impersonation headers
3. Handle Kubernetes API response formats
4. Work with `kubectl` and Kubernetes clients

**It's NOT:**
- A general HTTP reverse proxy
- Configurable to point to arbitrary backends
- Designed for web applications

## Real Example

### What Happens If You Try

**Configuration (what we tried):**
```yaml
args:
- --upstream=http://podinfo.podinfo.svc.cluster.local:9898  # ❌ Doesn't work!
```

**What kube-oidc-proxy does:**
1. Receives request: `GET /`
2. Tries to forward to Kubernetes API server (hardcoded)
3. Doesn't use the `--upstream` flag (it's ignored or causes errors)
4. Request fails or goes to wrong place

**Why:** The code is built to only talk to Kubernetes API, not arbitrary HTTP services.

## Comparison: What Each Tool Does

### kube-oidc-proxy
```
Purpose: Proxy kubectl → K8s API with OIDC
Input:  Kubernetes API requests
Output: Kubernetes API responses
Backend: Always Kubernetes API server
```

### oauth2-proxy
```
Purpose: Protect any HTTP app with OIDC
Input:  Any HTTP request
Output: Any HTTP response
Backend: Configurable (podinfo, my-app, anything)
```

## Visual Comparison

### kube-oidc-proxy (K8s API Only)
```
kubectl → kube-oidc-proxy → Kubernetes API Server
         (validates token)   (hardcoded destination)
```

### oauth2-proxy (Any HTTP App)
```
curl → oauth2-proxy → podinfo
      (validates token) (configurable: --upstream)
```

## The Key Difference

| Feature | kube-oidc-proxy | oauth2-proxy |
|---------|----------------|--------------|
| **Backend** | Kubernetes API (hardcoded) | Any HTTP app (configurable) |
| **Use case** | `kubectl` with OIDC | Protect web apps |
| **Flexibility** | ❌ Fixed to K8s API | ✅ Any backend |
| **For podinfo** | ❌ Won't work | ✅ Perfect fit |

## Summary

**"K8s API only" means:**
- kube-oidc-proxy **only** proxies to Kubernetes API server
- It **cannot** proxy to podinfo or any other HTTP app
- It's **hardcoded** for Kubernetes API requests
- It's **not** a general-purpose HTTP proxy

**For protecting podinfo, you need:**
- ✅ oauth2-proxy (or similar) - Can proxy to any HTTP app
- ❌ kube-oidc-proxy - Only works with Kubernetes API

## Why This Confusion Happens

**The name is misleading:**
- "kube-oidc-proxy" sounds like it could proxy anything
- But it's actually "kube-oidc-proxy-for-kubernetes-api-only"

**Better name would be:**
- "k8s-api-oidc-proxy"
- "kubectl-oidc-proxy"
- "kubernetes-api-oidc-gateway"

But it's called "kube-oidc-proxy" which makes it sound general-purpose!

## Bottom Line

**kube-oidc-proxy:**
- ✅ Great for: `kubectl` with OIDC auth
- ❌ Not for: Protecting regular HTTP apps like podinfo

**For podinfo, use oauth2-proxy instead!**

