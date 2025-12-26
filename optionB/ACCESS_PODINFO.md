# How to Access podinfo After Login

## The Issue

You logged in successfully, but:
- ❌ No redirect to podinfo
- ❌ Token polling failed

## Understanding the Flow

**Device code flow does NOT redirect to podinfo.** Here's why:

1. **Device code flow** = Get token in CLI, then use token manually
2. **Authorization code flow** = Get token via browser redirect
3. **oauth2-proxy** = Automatic redirect to podinfo after login

## Solution 1: Use oauth2-proxy (Automatic Redirect) ⭐ RECOMMENDED

**This gives you the redirect experience you want:**

### Step 1: Port-forward oauth2-proxy
```bash
kubectl -n oidc-proxy port-forward svc/oauth2-proxy 4180:80
```

### Step 2: Open browser
```
http://localhost:4180
```

### Step 3: Login
- You'll be redirected to Dex login
- Enter: `einstein` / `password`
- **After login, you'll be automatically redirected to podinfo!** ✅

**This is what you want!**

## Solution 2: Use Device Code Flow (Fixed Script)

**If you want to use device code flow (now fixed):**

### Step 1: Port-forward Dex
```bash
kubectl -n auth port-forward svc/dex 5556:5556
```

### Step 2: Run script
```bash
cd optionB
./scripts/get-token.sh
```

### Step 3: Login in browser
- Visit the URL shown
- Enter the code
- Login with `einstein` / `password`

### Step 4: Script gets token
- The script will poll and get the token
- **No redirect to podinfo** - you get a token string

### Step 5: Use token to access podinfo
```bash
# Get token (quiet mode)
TOKEN=$(./scripts/get-token.sh --quiet)

# Port-forward podinfo
kubectl -n podinfo port-forward svc/podinfo 9898:9898

# Access with token
curl -H "Authorization: Bearer $TOKEN" http://localhost:9898
```

## Solution 3: Use Authorization Code Flow

**For a redirect experience with token:**

### Step 1: Port-forward Dex
```bash
kubectl -n auth port-forward svc/dex 5556:5556
```

### Step 2: Visit this URL
```
http://localhost:5556/auth?client_id=cli&redirect_uri=http://127.0.0.1:5555/callback&response_type=code&scope=openid profile email
```

### Step 3: Login
- Enter: `einstein` / `password`

### Step 4: Copy code from redirect URL
- You'll be redirected to: `http://127.0.0.1:5555/callback?code=ABC123...`
- Copy the `code` value

### Step 5: Exchange for token
```bash
./scripts/exchange-code.sh <paste-code-here>
```

## Summary

**For automatic redirect to podinfo:**
✅ Use **oauth2-proxy** (Solution 1)

**For manual token usage:**
✅ Use **device code flow** (Solution 2) - now fixed!
✅ Or use **authorization code flow** (Solution 3)

**The script bug is fixed - try device code flow again if you want!**

