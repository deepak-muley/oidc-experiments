# How oauth2-proxy Caches Your Login (Cookies)

## Yes, Credentials Are Cached!

**After your first login, oauth2-proxy remembers you using cookies.**

## How It Works

### First Visit
1. **Browser** → `http://localhost:4180`
2. **oauth2-proxy** → "No cookie, redirect to login"
3. **Dex** → Login page
4. **You login** → `einstein` / `password`
5. **Dex** → Validates, gives token to oauth2-proxy
6. **oauth2-proxy** → Creates session cookie, stores it in browser
7. **Browser** → Redirected to podinfo

### Subsequent Visits
1. **Browser** → `http://localhost:4180`
2. **oauth2-proxy** → "Cookie found! Valid session!"
3. **Browser** → Directly shows podinfo (no login needed!)

## Cookie Details

**From oauth2-proxy logs:**
```
Cookie settings: name:_oauth2_proxy secure(https):false httponly:true 
expiry:168h0m0s domains: path:/ samesite: refresh:disabled
```

**What this means:**
- **Cookie name:** `_oauth2_proxy`
- **Expiry:** 168 hours = **7 days**
- **HttpOnly:** Yes (JavaScript can't access it - security)
- **Secure:** No (works on http://localhost)
- **Path:** `/` (works for all paths)

## Where Is the Cookie Stored?

**In your browser:**
- Chrome: DevTools → Application → Cookies → `http://localhost:4180`
- Firefox: DevTools → Storage → Cookies → `http://localhost:4180`

**You'll see:**
- Name: `_oauth2_proxy`
- Value: (encrypted session token)
- Expires: (7 days from login)

## How to Clear the Session

### Method 1: Clear Browser Cookies
1. Open DevTools (F12)
2. Go to Application/Storage → Cookies
3. Delete `_oauth2_proxy` cookie
4. Refresh page → Will ask for login again

### Method 2: Use Incognito/Private Window
- Opens without cookies
- Will ask for login

### Method 3: Clear All Site Data
- Browser settings → Clear browsing data
- Select cookies for `localhost`

## Session Expiry

**Default:** 7 days (168 hours)

**After 7 days:**
- Cookie expires
- oauth2-proxy won't recognize you
- Will redirect to login again

## Security Notes

**What's NOT cached:**
- ❌ Your password (never stored)
- ❌ Your username (not in cookie)

**What IS cached:**
- ✅ Session token (encrypted)
- ✅ OIDC token (encrypted in cookie)
- ✅ Your identity (from token)

**The cookie contains:**
- Encrypted session information
- OIDC access token (encrypted)
- User identity (from token claims)

## Configuration

**Current settings in `oauth2-proxy.yaml`:**
```yaml
- --cookie-secure=false          # Works on http://localhost
- --cookie-secret=...            # Encryption key for cookie
```

**Cookie expiry is hardcoded in oauth2-proxy:**
- Default: 168 hours (7 days)
- Can't easily change without recompiling

## Why This Is Good

**Benefits:**
- ✅ No need to login every time
- ✅ Better user experience
- ✅ Password never stored (only session token)
- ✅ Session expires automatically

**Security:**
- ✅ Cookie is HttpOnly (XSS protection)
- ✅ Cookie is encrypted
- ✅ Expires after 7 days
- ✅ Password never in cookie

## Testing Session

**To test if session is working:**

1. **Login once:**
   ```
   http://localhost:4180
   Login: einstein / password
   ```

2. **Close browser, reopen:**
   ```
   http://localhost:4180
   Should go directly to podinfo (no login)
   ```

3. **Clear cookie:**
   - DevTools → Application → Cookies → Delete `_oauth2_proxy`
   - Refresh → Will ask for login again

## Summary

✅ **Yes, credentials are cached** (as session cookie)
✅ **Cookie expires in 7 days**
✅ **Password is NOT stored** (only session token)
✅ **To force re-login:** Clear the `_oauth2_proxy` cookie

**This is normal OAuth2/OIDC behavior - sessions are cached for better UX!**

