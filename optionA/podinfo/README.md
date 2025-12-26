# podinfo (Option A)

podinfo is protected by Ingress-NGINX using `auth_request` to oauth2-proxy.

## Configuration

- **Ingress:** `podinfo.localtest.me`
- **Auth:** Protected by oauth2-proxy via `auth_request`
- **Service:** `podinfo.podinfo.svc.cluster.local:9898`

## Files

- `ingress.yaml` - Ingress with auth_request annotations
- `oauth2-proxy-service.yaml` - ExternalName service to reference oauth2-proxy

## Access

Open in browser: `http://podinfo.localtest.me`

You'll be redirected to Dex login, then back to podinfo after authentication.

