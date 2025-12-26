# Kubernetes API Adapter for podinfo

## Purpose

This adapter makes podinfo work with kube-oidc-proxy by:
1. Receiving Kubernetes API requests from kube-oidc-proxy
2. Converting them to podinfo HTTP requests
3. Converting podinfo responses to Kubernetes API format

## The Problem

**kube-oidc-proxy expects:**
```
GET /api/v1/namespaces/podinfo/pods
→ Returns Kubernetes API PodList format
```

**podinfo provides:**
```
GET /
→ Returns JSON with podinfo data
```

**They don't match!** Need an adapter.

## How It Works

```
kubectl → kube-oidc-proxy → Adapter → podinfo
         (validates token)  (converts) (actual app)
```

**Flow:**
1. kubectl sends: `GET /api/v1/namespaces/podinfo/pods`
2. kube-oidc-proxy validates token, forwards to adapter
3. Adapter converts to: `GET http://podinfo:9898/`
4. Adapter gets podinfo JSON
5. Adapter converts to Kubernetes API format
6. Returns to kube-oidc-proxy → kubectl

## Implementation Options

### Option 1: Simple Script (Nginx + Lua)
- Use nginx with lua scripting
- Convert requests/responses on the fly

### Option 2: Go Service
- Write a Go service that:
  - Implements Kubernetes API server interface
  - Proxies to podinfo
  - Transforms responses

### Option 3: Python/Node Service
- Similar to Go, but in Python or Node.js
- Easier for quick prototyping

## Example Conversion

**Kubernetes API Request:**
```
GET /api/v1/namespaces/podinfo/pods
```

**Adapter converts to:**
```
GET http://podinfo.podinfo.svc.cluster.local:9898/
```

**podinfo returns:**
```json
{
  "name": "podinfo",
  "version": "6.0.0",
  "status": "running"
}
```

**Adapter converts to Kubernetes API format:**
```json
{
  "kind": "PodList",
  "apiVersion": "v1",
  "items": [{
    "metadata": {
      "name": "podinfo",
      "namespace": "podinfo"
    },
    "status": {
      "phase": "Running"
    }
  }]
}
```

## Status

**This is a template/concept.** 

To make it work, you'd need to:
1. Implement the actual adapter logic
2. Handle all Kubernetes API endpoints you want to support
3. Map podinfo data to Kubernetes resource formats

## Alternative: Use kube-oidc-proxy Correctly

Instead of forcing it to work with podinfo, use it for its actual purpose:

```bash
# Use kube-oidc-proxy with kubectl
kubectl --server=https://kube-oidc-proxy:8443 \
        --token="$TOKEN" \
        get pods -A
```

This shows kube-oidc-proxy working with actual Kubernetes API!

