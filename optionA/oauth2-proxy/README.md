# oauth2-proxy (Option A)

oauth2-proxy acts as an OIDC client that handles the browser-based authentication flow.

## Configuration

- **Provider:** OIDC (Dex)
- **Issuer:** `http://dex.localtest.me`
- **Upstream:** `http://podinfo.podinfo.svc.cluster.local:9898`
- **Cookie Secret:** Generated automatically during setup

## Files

- `oauth2-proxy.yaml` - Deployment and Service

## References

- [oauth2-proxy GitHub](https://github.com/oauth2-proxy/oauth2-proxy)

