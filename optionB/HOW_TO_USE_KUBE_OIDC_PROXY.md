# How to Use kube-oidc-proxy with podinfo

## The Challenge

**kube-oidc-proxy expects Kubernetes API format, but podinfo is a regular HTTP app.**

They speak different "languages":
- kube-oidc-proxy expects: `/api/v1/namespaces`, `/api/v1/pods`, etc.
- podinfo provides: `/` (JSON response)

## Why It's Hard

**kube-oidc-proxy is hardcoded to:**
1. Forward to Kubernetes API server
2. Expect Kubernetes API responses
3. Handle Kubernetes API error formats
4. Use Kubernetes impersonation

**podinfo is:**
1. A simple HTTP app
2. Returns JSON, not Kubernetes API format
3. Doesn't understand Kubernetes API requests

## Solution Options

### Option 1: Create an Adapter/Proxy (Recommended for Demo)

Create a middleware that:
1. Receives Kubernetes API requests from kube-oidc-proxy
2. Converts them to podinfo requests
3. Converts podinfo responses to Kubernetes API format

**Architecture:**
```
kubectl → kube-oidc-proxy → Adapter → podinfo
         (validates token)  (converts) (actual app)
```

### Option 2: Make podinfo Respond to K8s API Endpoints

Modify podinfo to:
1. Accept Kubernetes API requests
2. Return Kubernetes API format responses
3. Map podinfo data to Kubernetes resources

**Example:**
- `GET /api/v1/namespaces/podinfo/pods` → Returns podinfo as a "Pod" resource
- `GET /api/v1/namespaces/podinfo/services` → Returns podinfo service info

### Option 3: Use kube-oidc-proxy for Its Intended Purpose

Instead of forcing it to work with podinfo, use it correctly:
- Use kube-oidc-proxy to access Kubernetes API with OIDC
- Show how `kubectl` works with it
- This demonstrates the actual use case

## Practical Implementation: Option 1 (Adapter)

### Create an Adapter Service

**adapter.yaml:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: k8s-api-adapter
  namespace: podinfo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: k8s-api-adapter
  template:
    metadata:
      labels:
        app: k8s-api-adapter
    spec:
      containers:
      - name: adapter
        image: nginx:alpine
        # Or use a custom script that:
        # 1. Listens for K8s API requests
        # 2. Converts to podinfo requests
        # 3. Converts responses back to K8s API format
```

**How it works:**
1. kube-oidc-proxy sends: `GET /api/v1/namespaces/podinfo/pods`
2. Adapter converts to: `GET http://podinfo:9898/`
3. Adapter gets podinfo JSON
4. Adapter converts to K8s API format:
   ```json
   {
     "kind": "PodList",
     "apiVersion": "v1",
     "items": [{
       "metadata": {"name": "podinfo", ...},
       "status": {...}
     }]
   }
   ```
5. Returns to kube-oidc-proxy

## Practical Implementation: Option 2 (Modify podinfo)

### Add Kubernetes API Endpoints to podinfo

**Modify podinfo to respond to:**
```go
// Pseudo-code
func handleK8sAPI(w http.ResponseWriter, r *http.Request) {
    path := r.URL.Path
    
    switch path {
    case "/api/v1/namespaces/podinfo/pods":
        // Return podinfo as a Pod resource
        pod := &v1.Pod{
            Metadata: &metav1.ObjectMeta{
                Name: "podinfo",
                Namespace: "podinfo",
            },
            Status: &v1.PodStatus{
                Phase: "Running",
            },
        }
        json.NewEncoder(w).Encode(pod)
        
    case "/api/v1/namespaces/podinfo/services":
        // Return podinfo service info
        // ...
    }
}
```

**This requires:**
- Modifying podinfo source code
- Adding Kubernetes API client libraries
- Implementing Kubernetes API endpoints

## Practical Implementation: Option 3 (Use Correctly)

### Show kube-oidc-proxy Working with kubectl

**This is what it's actually designed for:**

```bash
# 1. Deploy kube-oidc-proxy (pointing to K8s API)
kubectl apply -f kube-oidc-proxy/kube-oidc-proxy.yaml

# 2. Port-forward
kubectl -n oidc-proxy port-forward svc/kube-oidc-proxy 8443:8443

# 3. Get OIDC token
./scripts/get-token.sh

# 4. Use kubectl with kube-oidc-proxy
kubectl --server=https://localhost:8443 \
        --insecure-skip-tls-verify \
        --token="$TOKEN" \
        get pods -A

# This works! Shows actual Kubernetes pods
```

**This demonstrates:**
- ✅ kube-oidc-proxy validating OIDC tokens
- ✅ kubectl working with OIDC authentication
- ✅ Accessing Kubernetes API through proxy

## Recommended Approach for Demo

**For a demo showing kube-oidc-proxy with podinfo:**

1. **Create a simple adapter** (Option 1)
   - Easiest to implement
   - Doesn't require modifying podinfo
   - Shows the concept clearly

2. **Or use it correctly** (Option 3)
   - Show kubectl with kube-oidc-proxy
   - This is what it's actually for
   - More realistic use case

## Simple Adapter Example

**adapter-service.yaml:**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: k8s-api-adapter
  namespace: podinfo
spec:
  selector:
    app: k8s-api-adapter
  ports:
  - port: 443
    targetPort: 8443
```

**The adapter would:**
- Listen on port 8443
- Accept Kubernetes API requests
- Forward to podinfo:9898
- Transform responses to Kubernetes API format
- Return to kube-oidc-proxy

## Summary

**To use kube-oidc-proxy with podinfo, you need:**

1. **An adapter** that converts between:
   - Kubernetes API format (what kube-oidc-proxy expects)
   - Regular HTTP format (what podinfo provides)

2. **Or modify podinfo** to respond to Kubernetes API endpoints

3. **Or use kube-oidc-proxy correctly** with kubectl (its actual purpose)

**The easiest:** Create a simple adapter service that translates between the two formats.

