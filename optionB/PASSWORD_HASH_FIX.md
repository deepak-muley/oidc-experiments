# Fix: Invalid Username/Password Error

## The Problem

Login keeps failing with "Invalid username and password" even though credentials should be correct.

## The Issue

The bcrypt hash in the configuration might be incorrect or in the wrong format.

## What I Did

1. **Generated new hash using htpasswd:**
   ```bash
   htpasswd -nbBC 10 einstein password
   ```

2. **Updated Dex configuration** with the new hash

3. **Restarted Dex**

## Try Login Now

**Step 1: Port-forward Dex**
```bash
kubectl -n auth port-forward svc/dex 5556:5556
```

**Step 2: Open browser**
```
http://localhost:5556
```

**Step 3: Login**
- **Username/Email:** `einstein`
- **Password:** `password`

## If Still Failing

**The hash format might be the issue:**

- **$2y$** - Used by htpasswd (might not work with Dex)
- **$2a$** - Standard bcrypt (Dex might prefer this)

**To generate a proper $2a$ hash:**

```bash
# Install bcrypt
pip3 install bcrypt

# Generate hash
python3 -c "import bcrypt; print(bcrypt.hashpw(b'password', bcrypt.gensalt(rounds=10)).decode())"
```

**Or use Docker:**
```bash
docker run --rm python:3.11 python3 -c "import bcrypt; print(bcrypt.hashpw(b'password', bcrypt.gensalt(rounds=10)).decode())"
```

## Alternative: Use Dex API to Create Password

Dex might have an API endpoint to create passwords that generates the correct hash automatically.

## Current Hash Format

**Using:** `$2y$10$...` (from htpasswd)

**If this doesn't work, try:** `$2a$10$...` format instead.

## Summary

✅ **Updated:** New hash generated with htpasswd
✅ **Restarted:** Dex with new configuration
⏳ **Test:** Try login now

If it still fails, we need to generate a $2a$ format hash instead.

