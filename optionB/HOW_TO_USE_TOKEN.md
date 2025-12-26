# How to Use Your OIDC Token

## The Problem

You got a token, but this fails:
```bash
curl -k -H "Authorization: Bearer $TOKEN" https://localhost:8443
# Error: Failed to connect to localhost port 8443
```

**Why:** Nothing is listening on port 8443. You need to port-forward first!

## Understanding the Services

**Three different services, three different purposes:**

1. **`kube-oidc-proxy`** (port 8443) → Proxies **Kubernetes API**, not podinfo
2. **`oauth2-proxy`** (port 4180) → Protects **podinfo** with automatic login
3. **`podinfo`** (port 9898) → The actual app (can use token directly)

## Option 1: Access podinfo Directly with Token ⭐ SIMPLEST

**Port-forward podinfo and use your token:**

```bash
# Terminal 1: Port-forward podinfo
kubectl -n podinfo port-forward svc/podinfo 9898:9898

# Terminal 2: Use your token
export TOKEN="eyJhbGciOiJSUzI1NiIsImtpZCI6IjIxMWI2NzQ4YjFmYjc2ZWZkOWFlMmZhZDBhYWM2Y2M2YzljZTNlNDMifQ..."

# Access podinfo (if it validates tokens)
curl -H "Authorization: Bearer $TOKEN" http://localhost:9898
```

**Note:** podinfo itself doesn't validate tokens - it's just a demo app. This will work but won't actually check the token.

## Option 2: Access podinfo Through oauth2-proxy ⭐ RECOMMENDED

**This actually validates your token and protects podinfo:**

```bash
# Terminal 1: Port-forward oauth2-proxy
kubectl -n oidc-proxy port-forward svc/oauth2-proxy 4180:80

# Terminal 2: Use your token
export TOKEN="eyJhbGciOiJSUzI1NiIsImtpZCI6IjIxMWI2NzQ4YjFmYjc2ZWZkOWFlMmZhZDBhYWM2Y2M2YzljZTNlNDMifQ..."

# Access through oauth2-proxy (validates token!)
curl -H "Authorization: Bearer $TOKEN" http://localhost:4180
```

**Or just open in browser:**
```
http://localhost:4180
```

After login, you'll see podinfo!

## Option 3: Access Kubernetes API Through kube-oidc-proxy

**If you want to use kube-oidc-proxy (for K8s API, not podinfo):**

```bash
# Terminal 1: Port-forward kube-oidc-proxy
kubectl -n oidc-proxy port-forward svc/kube-oidc-proxy 8443:8443

# Terminal 2: Use your token to access K8s API
export TOKEN="eyJhbGciOiJSUzI1NiIsImtpZCI6IjIxMWI2NzQ4YjFmYjc2ZWZkOWFlMmZhZDBhYWM2Y2M2YzljZTNlNDMifQ..."

# Access Kubernetes API (not podinfo!)
curl -k -H "Authorization: Bearer $TOKEN" https://localhost:8443/api/v1/namespaces
```

**This accesses the Kubernetes API, not podinfo!**

## Quick Reference

| Service | Port | Purpose | Command |
|---------|------|---------|---------|
| **podinfo** | 9898 | Demo app | `kubectl -n podinfo port-forward svc/podinfo 9898:9898` |
| **oauth2-proxy** | 4180 | Protects podinfo | `kubectl -n oidc-proxy port-forward svc/oauth2-proxy 4180:80` |
| **kube-oidc-proxy** | 8443 | Proxies K8s API | `kubectl -n oidc-proxy port-forward svc/kube-oidc-proxy 8443:8443` |

## Summary

**For podinfo access:**
✅ Use **oauth2-proxy** (Option 2) - validates token and shows podinfo
✅ Or use **podinfo** directly (Option 1) - but doesn't validate token

**For Kubernetes API access:**
✅ Use **kube-oidc-proxy** (Option 3) - but this is for K8s API, not podinfo!

**The error happened because nothing was port-forwarded. Port-forward first, then use the token!**

