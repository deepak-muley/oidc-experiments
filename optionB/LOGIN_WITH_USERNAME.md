# Login with Username (Not Email)

## The Issue

Dex was asking for email instead of username.

## The Fix

Updated configuration to use `username` field in staticPasswords.

## How to Login Now

**Step 1: Port-forward Dex**
```bash
kubectl -n auth port-forward svc/dex 5556:5556
```

**Step 2: Open browser**
```
http://localhost:5556
```

**Step 3: Login**
- **Username:** `einstein` (not email!)
- **Password:** `password`

## Available Users

All passwords are: `password`

- Username: `einstein`
- Username: `newton`
- Username: `galieleo`
- Username: `tesla`
- Username: `riemann`

## What Changed

**Before:**
- Dex asked for email
- Had to use: `einstein@example.com`

**After:**
- Dex asks for username
- Use: `einstein`

**Much simpler!**

## Summary

✅ **Fixed:** Now uses username instead of email
✅ **Login:** Just username + password
✅ **No tokens needed:** For basic login

Try it now - should work with username!

