# Simple Explanation: "K8s API Only"

## Your Question

*"What do you mean by kube-oidc-proxy works with HTTP apps: No (K8s API only)?"*

## The Simple Answer

**kube-oidc-proxy is hardcoded to only talk to the Kubernetes API server.**

It's like a phone that can only call one number - the Kubernetes API.

## Look at Our Config

In `kube-oidc-proxy/kube-oidc-proxy.yaml`, notice:

```yaml
env:
- name: KUBERNETES_SERVICE_HOST
  value: "kubernetes.default.svc"    # ← Points to K8s API!
- name: KUBERNETES_SERVICE_PORT
  value: "443"                        # ← K8s API port!
```

**There's NO `--upstream` flag!** 

Why? Because kube-oidc-proxy doesn't let you configure the backend - it's **always** the Kubernetes API server.

## What This Means

### What kube-oidc-proxy Does ✅

```
kubectl → kube-oidc-proxy → Kubernetes API Server
         (validates token)   (hardcoded: kubernetes.default.svc)
```

**Example:**
```bash
kubectl get pods --server=https://kube-oidc-proxy:8443
# This works! Goes to K8s API
```

### What kube-oidc-proxy Cannot Do ❌

```
curl → kube-oidc-proxy → podinfo
      (validates token)  (doesn't know about podinfo!)
```

**Example:**
```bash
curl https://kube-oidc-proxy:8443
# This tries to reach K8s API, not podinfo!
# Gets Kubernetes API response, not podinfo response
```

## Real-World Analogy

**kube-oidc-proxy is like:**
- A security guard at a **specific building** (Kubernetes API)
- Can only let people into **that one building**
- Doesn't know about other buildings (podinfo, my-app, etc.)

**oauth2-proxy is like:**
- A security guard that can work at **any building**
- You tell it which building to protect (`--upstream=podinfo`)
- Can protect podinfo, my-app, or anything

## The Code Evidence

**kube-oidc-proxy code does:**
```go
// Pseudo-code (simplified)
backend := "kubernetes.default.svc:443"  // Hardcoded!
// No --upstream flag, always K8s API
```

**oauth2-proxy code does:**
```go
// Pseudo-code (simplified)
backend := config.Upstream  // Configurable!
// Can be podinfo, my-app, anything
```

## Why This Design?

**kube-oidc-proxy is built for:**
- Making `kubectl` work with OIDC
- Proxying Kubernetes API requests
- Using Kubernetes impersonation

**It's NOT built for:**
- General HTTP proxying
- Protecting web applications
- Arbitrary backends

## Comparison Table (Simplified)

| Can it proxy to... | kube-oidc-proxy | oauth2-proxy |
|-------------------|----------------|--------------|
| Kubernetes API | ✅ Yes (only this!) | ✅ Yes |
| podinfo | ❌ No | ✅ Yes |
| my-app:8080 | ❌ No | ✅ Yes |
| Any HTTP app | ❌ No | ✅ Yes |

## The Key Point

**"K8s API only" means:**
- The backend is **hardcoded** to Kubernetes API
- You **cannot** configure it to point elsewhere
- It's **designed** for `kubectl`, not `curl` to apps

**Think of it as:**
- kube-oidc-proxy = "kubectl authentication proxy"
- oauth2-proxy = "general HTTP app protection proxy"

## Summary

**kube-oidc-proxy:**
- ✅ Purpose: Make `kubectl` work with OIDC
- ✅ Backend: Always Kubernetes API (hardcoded)
- ❌ Cannot: Proxy to podinfo or other apps

**For podinfo, you need oauth2-proxy instead!**

See `KUBE_OIDC_PROXY_EXPLAINED.md` for more details.

