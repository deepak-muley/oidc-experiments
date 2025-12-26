# Gateway API Solution with Traefik

## Overview

This solution uses **Kubernetes Gateway API** with **Traefik** to provide:
- ✅ No port-forwards needed
- ✅ Proper routing with hostnames
- ✅ OIDC integration
- ✅ Production-like setup

## Architecture

```
Browser → Traefik Gateway → Dex (auth) → oauth2-proxy → podinfo
```

**Flow:**
1. Browser accesses `http://podinfo.local`
2. Traefik Gateway routes to oauth2-proxy
3. oauth2-proxy redirects to Dex for authentication
4. After login, oauth2-proxy forwards to podinfo

## Components

1. **Traefik Gateway Controller** - Handles Gateway API
2. **Gateway** - Defines entry point
3. **HTTPRoute** - Routes traffic to services
4. **Dex** - OIDC provider
5. **oauth2-proxy** - Token validation proxy
6. **podinfo** - Demo application

## Benefits Over Port-Forwards

✅ **No port-forwards** - Access via hostnames
✅ **Stable** - Survives pod restarts
✅ **Production-like** - Real ingress solution
✅ **Fixes redirect issue** - Proper hostname routing
✅ **Better UX** - Use friendly hostnames

## Prerequisites

- Kubernetes cluster (Kind works)
- kubectl configured
- `helm` v3.x installed

## Installation

### Quick Install

```bash
cd optionB/gateway-api
./install-traefik.sh
```

This will:
1. Install Gateway API CRDs
2. Install Traefik via Helm with Gateway API support
3. Wait for Traefik to be ready

See [HELM_INSTALLATION.md](./HELM_INSTALLATION.md) for detailed instructions.

## Accessing Services

After installation, port-forward Traefik:

```bash
kubectl -n traefik-system port-forward svc/traefik 8080:80
```

Then access:
- **Dex:** `http://dex.local:8080` (or `curl -H "Host: dex.local" http://localhost:8080`)
- **podinfo:** `http://podinfo.local:8080` (or `curl -H "Host: podinfo.local" http://localhost:8080`)

For browser access, add to `/etc/hosts`:
```
127.0.0.1 podinfo.local dex.local
```

