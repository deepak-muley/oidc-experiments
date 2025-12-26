# Option B: Token-based OIDC Authentication

**Simple explanation:** Get a token from Dex, use it to access services.

## What This Does (In Plain English)

1. **Dex** checks your username/password against LDAP
2. If correct, **Dex** gives you an OIDC token
3. You use that token to access services

**That's it!** No complex proxy needed.

## Quick Start

```bash
# 1. Setup everything
./scripts/setup.sh

# 2. Verify it's working
./scripts/verify.sh

# 3. Get a token
kubectl -n auth port-forward svc/dex 5556:5556  # Terminal 1
./scripts/get-token.sh                            # Terminal 2
```

## Architecture (Simple)

```
You → Dex (checks LDAP) → Get Token → Use Token
```

**What's NOT needed:**
- ❌ kube-oidc-proxy (optional, can ignore)
- ❌ Complex proxies
- ❌ Ingress controllers

**What IS needed:**
- ✅ Dex (authentication)
- ✅ Token (proof of authentication)

## Components

### Dex (`dex/`)
- **Purpose:** Authenticates users via LDAP
- **Gives:** OIDC tokens
- **Status:** ✅ Required

### podinfo (`podinfo/`)
- **Purpose:** Demo application
- **Status:** ✅ Required (what we're protecting)

### kube-oidc-proxy (`kube-oidc-proxy/`)
- **Purpose:** Was supposed to validate tokens
- **Status:** ⚠️ Optional - Not needed for this demo
- **Why:** Designed for Kubernetes API, not regular apps

## Why kube-oidc-proxy Is Optional

**Simple answer:** We can get tokens from Dex and use them directly. We don't need a proxy.

**What it was supposed to do:**
- Validate tokens before forwarding requests

**Why we don't need it:**
- Dex already validates you
- You get a valid token
- Use the token directly
- No proxy needed for demos

**Think of it like:**
- **With proxy:** You → Guard → Proxy → Building
- **Without proxy:** You → Guard → Building (simpler!)

## Grant Types (Simple Explanation)

**Grant type = How you ask for a token**

### Device Code Grant (What we use)
1. Ask Dex: "Give me a code"
2. Dex: "Go to this URL, enter code ABC-123"
3. You login in browser
4. Dex gives you token

**Why:** Works with LDAP, good for CLI tools

### Password Grant (Doesn't work)
1. You: "I'm einstein, password is password"
2. Dex: "Nope, not supported with LDAP"

**Why it doesn't work:** Security reasons - Dex doesn't allow direct password with LDAP

## Documentation

- **[SIMPLE_EXPLANATION.md](SIMPLE_EXPLANATION.md)** - Detailed explanation of everything
- **[FOR_JUNIOR_DEVS.md](FOR_JUNIOR_DEVS.md)** - Maintenance guide for junior developers
- **[GET_TOKEN.md](GET_TOKEN.md)** - How to get tokens
- **[SIMPLE_VERIFY.md](SIMPLE_VERIFY.md)** - Simple verification guide

## Common Questions

**Q: Why can't I use password grant?**  
A: Dex doesn't support it with LDAP. Use device code flow instead.

**Q: Do I need kube-oidc-proxy?**  
A: No! It's optional. The demo works fine without it.

**Q: What if kube-oidc-proxy pods are down?**  
A: Doesn't matter! We don't need them.

**Q: How do I protect podinfo then?**  
A: For a demo, you don't need to. For production, add token validation to the app or use a different proxy.

## Important: The Missing Piece

**Current setup shows authentication, but NOT protection.**

For apps like podinfo that don't check tokens, you need:
- ✅ Dex (authentication) - **We have this**
- ❌ **Token validator** - **We're missing this**
- ✅ podinfo (the app) - **We have this**

**See [COMPLETE_SOLUTION.md](COMPLETE_SOLUTION.md) for how to add token validation.**

## Summary

- ✅ **Dex** = Authentication server (required)
- ✅ **podinfo** = Demo app (required)
- ⚠️ **kube-oidc-proxy** = Optional (wrong tool for this)
- ❌ **oauth2-proxy** = Needed for complete solution (see COMPLETE_SOLUTION.md)

**Current flow:** Get token from Dex → Use token → **But podinfo doesn't check it!**

**Complete flow:** Get token from Dex → oauth2-proxy validates → podinfo (protected)
