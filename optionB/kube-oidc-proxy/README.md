# kube-oidc-proxy

kube-oidc-proxy is a reverse proxy that validates OIDC tokens before forwarding requests to upstream services.

## Configuration

This directory contains the kube-oidc-proxy deployment:

- `kube-oidc-proxy.yaml` - Deployment and Service for kube-oidc-proxy

## Architecture

kube-oidc-proxy:
- Listens on port `8443`
- Validates OIDC tokens from Dex
- Forwards authenticated requests to `podinfo` service
- **No Kubernetes impersonation** - pure token validation and forwarding

## Configuration Details

- **Upstream:** `http://podinfo.podinfo.svc.cluster.local:9898`
- **OIDC Issuer:** `http://dex.auth.svc.cluster.local:5556`
- **Client ID:** `cli`
- **Impersonation:** Disabled (`--disable-impersonation=true`)

## References

- [kube-oidc-proxy GitHub](https://github.com/jetstack/kube-oidc-proxy)

