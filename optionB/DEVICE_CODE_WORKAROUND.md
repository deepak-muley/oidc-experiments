# Device Code Flow: Workaround

## The Issue

Device code flow in Dex has a redirect_uri validation issue. Even with callback URLs registered, it may still show errors.

## Alternative: Use Authorization Code Flow Instead

**This is simpler and more reliable for demos:**

### Step 1: Port-forward Dex
```bash
kubectl -n auth port-forward svc/dex 5556:5556
```

### Step 2: Open Browser
```
http://localhost:5556
```

### Step 3: Login Directly
- Click "Login"
- Select "ForumSys LDAP"
- Username: `einstein`
- Password: `password`

### Step 4: Get Token from URL
After login, you'll be redirected with tokens in the URL or you can use the authorization code flow.

## Or: Use the Script with Manual Token Extraction

**If device code flow still has issues:**

1. **Port-forward Dex:**
   ```bash
   kubectl -n auth port-forward svc/dex 5556:5556
   ```

2. **Open browser:**
   ```
   http://localhost:5556/auth?client_id=cli&redirect_uri=http://127.0.0.1:5555/callback&response_type=code&scope=openid profile email
   ```

3. **Login with einstein/password**

4. **Copy the `code` from redirect URL**

5. **Exchange for token:**
   ```bash
   ./scripts/exchange-code.sh <code>
   ```

## Why Device Code Flow Has Issues

Device code flow in Dex may have stricter redirect_uri validation. The authorization code flow is more straightforward for demos.

## Quick Fix: Use Browser Login

**Simplest approach:**
1. Port-forward Dex
2. Open `http://localhost:5556` in browser
3. Login directly
4. Extract token from response

This avoids the device code flow complexity entirely.

