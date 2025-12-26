# Fix: Browser Redirect to Cluster URL

## Problem

When accessing podinfo, oauth2-proxy was redirecting the browser to:
```
http://dex.auth.svc.cluster.local:5556/auth?...
```

This fails because:
- Browsers cannot resolve cluster-internal DNS names (`*.svc.cluster.local`)
- The browser needs to access Dex via the Gateway API route at `dex.local`

## Solution

Updated oauth2-proxy configuration to use:
- **`--login-url=http://dex.local/auth`** - For browser redirects (accessible via Gateway)
- **`--redeem-url=http://dex.auth.svc.cluster.local:5556/token`** - For server-to-server token exchange
- **`--oidc-jwks-url=http://dex.auth.svc.cluster.local:5556/keys`** - For server-to-server JWKS fetch

## Key Points

1. **Browser redirects** must use `dex.local` (routed via Gateway API)
2. **Server-to-server calls** (token redemption, JWKS) can use cluster-internal URLs
3. **OIDC issuer** is set to `http://dex.local` to match Dex's configuration

## Verification

After the fix, the redirect should be:
```
http://dex.local/auth?approval_prompt=force&client_id=cli&redirect_uri=...
```

## Access Requirements

For the browser to access `dex.local`, you need:

1. **Port-forward Traefik:**
   ```bash
   kubectl -n traefik-system port-forward svc/traefik 8080:80
   ```

2. **Add to /etc/hosts:**
   ```
   127.0.0.1 dex.local podinfo.local
   ```

3. **Access in browser:**
   - http://podinfo.local:8080 (will redirect to dex.local for login)
   - http://dex.local:8080 (Dex login page)

