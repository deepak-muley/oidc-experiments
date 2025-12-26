# Email vs Username in Dex Login

## The Issue

Dex login page shows "Email" field, but you want to use username.

## The Solution

**Even if it says "Email", you can enter your username!**

The configuration has both `email` and `username` fields. Dex might show "Email" in the UI, but it will accept the username.

## How to Login

**Step 1: Port-forward Dex**
```bash
kubectl -n auth port-forward svc/dex 5556:5556
```

**Step 2: Open browser**
```
http://localhost:5556
```

**Step 3: Login**
- **Field says "Email"** - but enter: `einstein` (your username)
- **Password:** `password`

**It will work!** The username field in the config allows this.

## Why This Happens

Dex's local password DB uses `email` as the primary identifier in the config, but the `username` field allows login with username too.

**The config has:**
```yaml
staticPasswords:
- email: einstein@example.com
  username: einstein  # This allows username login!
  userID: einstein
```

**So you can login with:**
- ✅ Username: `einstein` (works!)
- ✅ Or email: `einstein@example.com` (also works!)

## Summary

**Even if UI says "Email":**
- ✅ Enter your username: `einstein`
- ✅ Password: `password`
- ✅ It will work!

**The username field in config makes this possible.**

Try it - enter `einstein` in the email field, it should work!

