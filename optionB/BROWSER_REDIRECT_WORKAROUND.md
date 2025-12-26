# Workaround: Browser Redirect to Cluster URL

## The Problem

oauth2-proxy redirects to:
```
http://dex.auth.svc.cluster.local:5556/auth?...
```

**This is a cluster-internal URL that browsers can't access.**

## Why This Happens

**oauth2-proxy does OIDC discovery:**
1. Connects to `http://dex.auth.svc.cluster.local:5556/.well-known/openid-configuration`
2. Gets the authorization endpoint from the discovery document
3. The discovery document has: `"authorization_endpoint": "http://dex.auth.svc.cluster.local:5556/auth"`
4. oauth2-proxy uses this URL for browser redirects

**The problem:** oauth2-proxy can't easily override the authorization endpoint URL from discovery.

## Workaround: Manual URL Edit in Browser

**When you see the redirect to the cluster URL:**

1. **Copy the full URL** from the browser address bar
2. **Replace** `dex.auth.svc.cluster.local` with `localhost`
3. **Press Enter**

**Example:**
```
Before: http://dex.auth.svc.cluster.local:5556/auth?approval_prompt=force&client_id=cli&...
After:  http://localhost:5556/auth?approval_prompt=force&client_id=cli&...
```

## Better Solution: Browser Extension

**Use a browser extension to automatically rewrite URLs:**
- **Requestly** (Chrome/Firefox)
- **ModHeader** (Chrome)
- **Redirector** (Firefox)

**Configure to rewrite:**
```
From: dex.auth.svc.cluster.local:5556
To:   localhost:5556
```

## Alternative: Use Authorization Code Flow Directly

**Skip oauth2-proxy and use Dex directly:**

1. **Port-forward Dex:**
   ```bash
   kubectl -n auth port-forward svc/dex 5556:5556
   ```

2. **Visit this URL:**
   ```
   http://localhost:5556/auth?client_id=cli&redirect_uri=http://127.0.0.1:5555/callback&response_type=code&scope=openid profile email
   ```

3. **Login** → Get redirected with code

4. **Exchange code for token:**
   ```bash
   ./scripts/exchange-code.sh <code>
   ```

5. **Access podinfo directly:**
   ```bash
   kubectl -n podinfo port-forward svc/podinfo 9898:9898
   curl http://localhost:9898
   ```

## Best Solution: Fix Dex Discovery Document

**The real fix would be to make Dex return localhost in its discovery document when accessed via port-forward, but that's not possible without changing Dex's issuer configuration.**

**For production, you'd use:**
- Ingress with proper hostnames
- LoadBalancer services
- NodePort services

**For local testing, the manual URL edit is the simplest workaround.**

## Summary

**Quick fix:** Manually edit the URL in browser (replace cluster URL with localhost)

**Better fix:** Use browser extension to auto-rewrite URLs

**Best fix:** Use authorization code flow directly, skip oauth2-proxy for local testing

