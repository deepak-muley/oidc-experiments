# Dex - OIDC Provider (Option A)

Dex is configured to use ForumSys LDAP and expose via Ingress for browser-based authentication.

## Configuration

- **Issuer URL:** `http://dex.localtest.me`
- **Client:** `oauth2-proxy` (for browser OAuth flow)
- **LDAP:** ForumSys public test server

## Files

- `dex-config.yaml` - ConfigMap with Dex configuration
- `dex.yaml` - Deployment, Service, RBAC, and Ingress

