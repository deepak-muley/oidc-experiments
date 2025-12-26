# oauth2-proxy for Token Validation

## Purpose

This is the **missing piece** that actually validates tokens and protects podinfo.

## What It Does

1. **Validates OIDC tokens** from Dex
2. **Blocks requests** without valid tokens
3. **Forwards valid requests** to podinfo

## Why We Need This

**Without it:**
- Dex gives tokens ✅
- But podinfo doesn't check them ❌
- Anyone can access podinfo directly ❌

**With it:**
- Dex gives tokens ✅
- oauth2-proxy validates them ✅
- Only authorized users can access podinfo ✅

## Configuration

- **Upstream:** `http://podinfo.podinfo.svc.cluster.local:9898`
- **OIDC Issuer:** `http://dex.auth.svc.cluster.local:5556`
- **Client:** `cli` (same as Dex client)

## Deployment

```bash
# Generate cookie secret
COOKIE_SECRET=$(python3 -c "import os,base64; print(base64.b64encode(os.urandom(32)).decode())")

# Deploy
sed "s/\${COOKIE_SECRET}/$COOKIE_SECRET/" oauth2-proxy.yaml | kubectl apply -f -
```

## Usage

```bash
# Port-forward
kubectl -n oidc-proxy port-forward svc/oauth2-proxy 4180:80

# Access with token
curl -H "Authorization: Bearer $TOKEN" http://localhost:4180

# Without token (should fail)
curl http://localhost:4180  # ❌ 401
```

## Files

- `oauth2-proxy.yaml` - Deployment configuration

