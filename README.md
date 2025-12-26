# OIDC Proxy Experiments

This repository contains experiments demonstrating different approaches to OIDC authentication for Kubernetes applications using **podinfo** as the demo application.

## Options

### [Option A: Browser-based Authentication](optionA/)

**Ingress-NGINX + Dex(LDAP) + oauth2-proxy protecting podinfo**

- ✅ Browser login UI
- ✅ Perfect for web applications
- ✅ Uses Ingress-NGINX with `auth_request`
- ✅ oauth2-proxy handles OIDC flow

**Quick Start:**
```bash
cd optionA
./scripts/setup.sh
# Then open: http://podinfo.localtest.me
```

### [Option B: Token-based Authentication](optionB/)

**kube-oidc-proxy protecting podinfo (CLI/automation style)**

- ✅ No browser, no ingress, no UI
- ✅ Pure token-gated access
- ✅ Perfect for CLI, automation, GitOps
- ✅ Uses kube-oidc-proxy with token validation

**Quick Start:**
```bash
cd optionB
./scripts/setup.sh
./scripts/test.sh
```

## Architecture Comparison

### Option A (Browser-based)
```
Browser
   |
   v
Ingress-NGINX (auth_request)
   |
   v
oauth2-proxy (OIDC client)
   |
   v
Dex (LDAP → OIDC)
   |
   v
podinfo service
```

### Option B (Token-based)
```
curl (Bearer token)
   |
   v
kube-oidc-proxy (validates token)
   |
   v
podinfo service
```

## Prerequisites

```bash
brew install kind kubectl
```

For Option A, you also need:
- Python 3 (for cookie secret generation)

## ForumSys LDAP Test Users

Both options use ForumSys public LDAP server. Available test users:

- `einstein` / `password`
- `newton` / `password`
- `galieleo` / `password`
- `tesla` / `password`
- `riemann` / `password`

See: https://www.forumsys.com/tutorials/integration-how-to/ldap/online-ldap-test-server/

## Project Structure

```
.
├── optionA/              # Browser-based auth (Ingress + oauth2-proxy)
│   ├── cluster/
│   ├── dex/
│   ├── oauth2-proxy/
│   ├── ingress-nginx/
│   ├── podinfo/
│   └── scripts/
├── optionB/              # Token-based auth (kube-oidc-proxy)
│   ├── cluster/
│   ├── dex/
│   ├── kube-oidc-proxy/
│   ├── podinfo/
│   └── scripts/
└── README.md
```

## Which Option to Choose?

- **Choose Option A** if you need:
  - Browser-based login for web applications
  - User-friendly authentication flow
  - Standard OAuth2/OIDC web flow

- **Choose Option B** if you need:
  - CLI/automation-friendly authentication
  - Token-based API access
  - GitOps, CI/CD, or scripted access
  - No browser interaction required

## References

- [kube-oidc-proxy](https://github.com/jetstack/kube-oidc-proxy)
- [oauth2-proxy](https://github.com/oauth2-proxy/oauth2-proxy)
- [Dex](https://github.com/dexidp/dex)
- [podinfo](https://github.com/stefanprodan/podinfo)
- [Ingress-NGINX](https://github.com/kubernetes/ingress-nginx)
- [ForumSys LDAP Test Server](https://www.forumsys.com/tutorials/integration-how-to/ldap/online-ldap-test-server/)
# oidc-experiments
# oidc-experiments
