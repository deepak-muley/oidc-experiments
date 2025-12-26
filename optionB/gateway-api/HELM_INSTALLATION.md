# Traefik Gateway API Installation via Helm

This guide explains how to install Traefik and Gateway API CRDs using Helm charts.

## Prerequisites

- Kubernetes cluster (Kind, Minikube, or any K8s cluster)
- `kubectl` configured
- `helm` v3.x installed

## Installation Steps

### 1. Install Gateway API CRDs

```bash
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.1/standard-install.yaml
```

### 2. Add Traefik Helm Repository

```bash
helm repo add traefik https://traefik.github.io/charts
helm repo update
```

### 3. Install Traefik with Gateway API Support

Use the provided `install-traefik.sh` script:

```bash
cd optionB/gateway-api
./install-traefik.sh
```

Or install manually:

```bash
helm upgrade --install traefik traefik/traefik \
  --namespace traefik-system \
  --create-namespace \
  --values traefik-helm-values.yaml \
  --skip-crds
```

**Note:** We use `--skip-crds` because Gateway API CRDs are already installed in step 1.

### 4. Verify Installation

```bash
# Check Traefik pod
kubectl -n traefik-system get pods

# Check GatewayClass (should show "True" for ACCEPTED)
kubectl get gatewayclass

# Check Gateway status
kubectl get gateway -A
```

## Configuration

The `traefik-helm-values.yaml` file configures:

- **Gateway API Provider:** Enabled
- **Kubernetes CRD Provider:** Enabled (for IngressRoute support)
- **Ports:** HTTP (80), HTTPS (443), Traefik Dashboard (9000)
- **Service Type:** NodePort
- **NodePorts:** 30080 (web), 30443 (websecure), 30090 (traefik)

## Accessing Services

### Option 1: Port-Forward (Recommended for local testing)

```bash
# Port-forward Traefik service
kubectl -n traefik-system port-forward svc/traefik 8080:80

# Access services via localhost with Host header
curl -H "Host: podinfo.local" http://localhost:8080/
curl -H "Host: dex.local" http://localhost:8080/.well-known/openid-configuration
```

### Option 2: NodePort (Kind/Minikube)

```bash
# Get NodePort
NODEPORT=$(kubectl -n traefik-system get service traefik -o jsonpath='{.spec.ports[?(@.name=="web")].nodePort}')

# Access via NodePort (Kind exposes NodePort on localhost)
curl -H "Host: podinfo.local" http://localhost:${NODEPORT}/
```

### Option 3: Update /etc/hosts (for browser access)

Add to `/etc/hosts`:
```
127.0.0.1 podinfo.local dex.local
```

Then access:
- http://podinfo.local:8080 (with port-forward)
- http://dex.local:8080 (with port-forward)

## Gateway API Resources

After installation, create your Gateway and HTTPRoute resources:

```bash
# Apply Gateway
kubectl apply -f gateway.yaml

# Apply HTTPRoutes
kubectl apply -f dex-route.yaml
kubectl apply -f podinfo-route.yaml
```

## Troubleshooting

### Gateway shows "Waiting for controller"

1. Check Traefik pod is running:
   ```bash
   kubectl -n traefik-system get pods
   ```

2. Check Traefik logs:
   ```bash
   kubectl -n traefik-system logs -l app.kubernetes.io/name=traefik | grep -i gateway
   ```

3. Verify GatewayClass exists:
   ```bash
   kubectl get gatewayclass
   ```

### Routes not working

1. Check HTTPRoute status:
   ```bash
   kubectl get httproute -A -o yaml
   ```

2. Check Gateway listeners:
   ```bash
   kubectl get gateway main-gateway -o yaml | grep -A 10 "listeners:"
   ```

3. Check Traefik logs for routing errors:
   ```bash
   kubectl -n traefik-system logs -l app.kubernetes.io/name=traefik | grep -i "route\|error"
   ```

## Cleanup

To remove Traefik:

```bash
helm uninstall traefik -n traefik-system
kubectl delete namespace traefik-system
```

To remove Gateway API CRDs:

```bash
kubectl delete -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.1/standard-install.yaml
```

