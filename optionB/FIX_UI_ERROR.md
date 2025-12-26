# Fix: UI Error in Device Code Flow

## The Problem

When using device code flow, you might see errors like:
- "Unregistered redirect_uri"
- "Invalid request"
- Other OAuth errors

## Why This Happens

Device code flow in Dex can be finicky with redirect_uri validation, even when properly configured.

## Simple Solution: Use Browser Login Instead

**This is much simpler and more reliable:**

### Method 1: Direct Browser Login (Easiest)

**Step 1: Port-forward Dex**
```bash
kubectl -n auth port-forward svc/dex 5556:5556
```

**Step 2: Open browser**
```
http://localhost:5556
```

**Step 3: Login**
- Click "Login"
- Select "ForumSys LDAP" 
- Username: `einstein`
- Password: `password`

**Step 4: You're logged in!**
- The page will show your user info
- For tokens, use Method 2 below

### Method 2: Authorization Code Flow (For Tokens)

**Step 1: Port-forward Dex**
```bash
kubectl -n auth port-forward svc/dex 5556:5556
```

**Step 2: Visit this URL in browser**
```
http://localhost:5556/auth?client_id=cli&redirect_uri=http://127.0.0.1:5555/callback&response_type=code&scope=openid profile email
```

**Step 3: Login**
- Username: `einstein`
- Password: `password`

**Step 4: Copy the code**
- After login, you'll be redirected to: `http://127.0.0.1:5555/callback?code=ABC123...`
- Copy the `code` value

**Step 5: Exchange for token**
```bash
./scripts/exchange-code.sh <paste-code-here>
```

## Quick Script

**Use the simpler script:**
```bash
./scripts/get-token-simple-browser.sh
```

This shows you the exact steps without device code flow complexity.

## Why Skip Device Code Flow?

- ✅ Browser login is simpler
- ✅ More reliable
- ✅ Works immediately
- ✅ No redirect_uri issues
- ✅ Better for demos

## Summary

**Instead of device code flow:**
1. ✅ Use browser login: `http://localhost:5556`
2. ✅ Or use authorization code flow for tokens
3. ✅ Both are simpler and more reliable

**The device code flow is mainly for CLI tools that can't open browsers. For demos, browser login is better!**

