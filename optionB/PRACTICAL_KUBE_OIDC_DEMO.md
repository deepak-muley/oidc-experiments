# Practical Demo: kube-oidc-proxy with podinfo

## The Challenge

**kube-oidc-proxy is designed for Kubernetes API, not podinfo.**

To make them work together, you need to bridge the gap.

## Three Approaches

### Approach 1: Create an Adapter (Most Practical)

**What:** A service that translates between Kubernetes API format and podinfo format.

**Why:** Doesn't require modifying podinfo or kube-oidc-proxy.

**How:**
1. kube-oidc-proxy sends K8s API requests to adapter
2. Adapter converts to podinfo requests
3. Adapter gets podinfo response
4. Adapter converts to K8s API format
5. Returns to kube-oidc-proxy

**Implementation:**
- See `k8s-api-adapter/` folder
- Would need to implement conversion logic
- Can use nginx+lua, Go, Python, etc.

### Approach 2: Modify podinfo (More Work)

**What:** Add Kubernetes API endpoints to podinfo.

**Why:** Makes podinfo directly compatible with kube-oidc-proxy.

**How:**
1. Add Kubernetes API client libraries to podinfo
2. Implement K8s API endpoints:
   - `/api/v1/namespaces/podinfo/pods`
   - `/api/v1/namespaces/podinfo/services`
   - etc.
3. Map podinfo data to Kubernetes resource format

**Implementation:**
- Modify podinfo source code
- Add Kubernetes API server interface
- Return Kubernetes API responses

### Approach 3: Use kube-oidc-proxy Correctly (Easiest)

**What:** Use kube-oidc-proxy with actual Kubernetes API.

**Why:** This is what it's designed for!

**How:**
```bash
# 1. Deploy kube-oidc-proxy (already configured for K8s API)
kubectl apply -f kube-oidc-proxy/kube-oidc-proxy.yaml

# 2. Port-forward
kubectl -n oidc-proxy port-forward svc/kube-oidc-proxy 8443:8443

# 3. Get token
kubectl -n auth port-forward svc/dex 5556:5556
./scripts/get-token.sh

# 4. Use kubectl with kube-oidc-proxy
export TOKEN="<your-token>"
kubectl --server=https://localhost:8443 \
        --insecure-skip-tls-verify \
        --token="$TOKEN" \
        get pods -A

# This works! Shows actual Kubernetes pods
```

**This demonstrates:**
- ✅ kube-oidc-proxy validating OIDC tokens
- ✅ kubectl working with OIDC
- ✅ Accessing Kubernetes API through proxy

## Recommended: Approach 3

**For a demo, use kube-oidc-proxy correctly:**

1. **Show kubectl with OIDC authentication**
   - This is the actual use case
   - Works out of the box
   - No modifications needed

2. **Explain that for podinfo, you'd need:**
   - An adapter (Approach 1)
   - Or modify podinfo (Approach 2)
   - Or use oauth2-proxy instead (simpler)

## If You Really Want podinfo + kube-oidc-proxy

**Create a simple adapter service:**

```yaml
# adapter.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: k8s-api-adapter
spec:
  template:
    spec:
      containers:
      - name: adapter
        image: your-adapter-image
        # Implements:
        # - Kubernetes API server interface
        # - Converts requests to podinfo format
        # - Converts responses to K8s API format
```

**The adapter would:**
- Listen on port 8443 (Kubernetes API port)
- Accept requests like: `GET /api/v1/namespaces/podinfo/pods`
- Convert to: `GET http://podinfo:9898/`
- Transform podinfo JSON to Kubernetes PodList format
- Return to kube-oidc-proxy

## Summary

**To use kube-oidc-proxy with podinfo:**

1. **Easiest:** Use kube-oidc-proxy with kubectl (its actual purpose)
2. **For podinfo demo:** Create an adapter service
3. **Alternative:** Modify podinfo to support Kubernetes API endpoints

**The adapter approach is most practical** because:
- ✅ Doesn't require modifying podinfo
- ✅ Doesn't require modifying kube-oidc-proxy
- ✅ Shows the concept clearly
- ⚠️ But requires implementing the adapter logic

**See `k8s-api-adapter/` for a template to get started.**

