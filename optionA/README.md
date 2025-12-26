# Option A: Ingress-NGINX + Dex(LDAP) + oauth2-proxy protecting podinfo

**Browser-based authentication** - Perfect for web applications.

## Architecture

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
podinfo service (HTTP)
```

**Browser login UI** - Users authenticate via web interface.

## Quick Start

See the detailed setup instructions in this README or run:

```bash
./scripts/setup.sh
```

## Components

This option uses:
- **Ingress-NGINX** - Ingress controller with auth_request support
- **Dex** - OIDC provider backed by ForumSys LDAP
- **oauth2-proxy** - OIDC client that handles browser login flow
- **podinfo** - Protected web application

## Directory Structure

```
optionA/
├── cluster/              # Kind cluster with ingress ports
├── dex/                  # Dex OIDC provider
├── oauth2-proxy/         # oauth2-proxy deployment
├── ingress-nginx/         # Ingress controller config
├── podinfo/              # podinfo with ingress
└── scripts/              # Setup and test scripts
```

## Setup Instructions

### 0) Prereqs

* `kind`, `kubectl` installed locally
* DNS trick: we'll use `*.localtest.me` (it resolves to 127.0.0.1 automatically)

### 1) Create a kind cluster with ingress ports

See `cluster/kind.yaml` for configuration.

### 2) Install ingress-nginx

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
```

### 3) Install podinfo

```bash
kubectl create ns podinfo
kubectl -n podinfo apply -f https://raw.githubusercontent.com/stefanprodan/podinfo/master/kustomize/deployment.yaml
kubectl -n podinfo apply -f https://raw.githubusercontent.com/stefanprodan/podinfo/master/kustomize/service.yaml
```

### 4) Deploy Dex configured to use ForumSys LDAP

See `dex/` directory for configuration files.

### 5) Deploy oauth2-proxy

See `oauth2-proxy/` directory for configuration.

### 6) Create Ingress for podinfo

See `podinfo/ingress.yaml` for the protected ingress configuration.

### 7) Try it

Open in a browser:
- `http://podinfo.localtest.me`

You should get redirected to Dex login, and you can log in with a ForumSys LDAP user like:
- username: `einstein`
- password: `password`

## ForumSys LDAP Test Users

- `einstein` / `password`
- `newton` / `password`
- `galieleo` / `password`
- `tesla` / `password`
- `riemann` / `password`

See: https://www.forumsys.com/tutorials/integration-how-to/ldap/online-ldap-test-server/

## References

- [Dex](https://github.com/dexidp/dex)
- [oauth2-proxy](https://github.com/oauth2-proxy/oauth2-proxy)
- [Ingress-NGINX](https://github.com/kubernetes/ingress-nginx)
- [podinfo](https://github.com/stefanprodan/podinfo)

