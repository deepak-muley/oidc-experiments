# Workaround: Switch to Local Passwords (No LDAP)

## The Problem

ForumSys LDAP bind is failing with "Invalid Credentials" error.

## Quick Workaround: Use Local Password DB

**Instead of LDAP, use Dex's built-in password database.**

### Step 1: Generate Password Hashes

**For password "password" (used by ForumSys users):**

```bash
# Install bcrypt if needed
pip3 install bcrypt

# Generate hash
python3 -c "import bcrypt; print(bcrypt.hashpw(b'password', bcrypt.gensalt()).decode())"
```

**Save the hash output.**

### Step 2: Update Dex Config

**Edit `dex/dex-config.yaml` and replace LDAP connector with:**

```yaml
enablePasswordDB: true

staticPasswords:
- email: einstein@ldap.forumsys.com
  hash: <paste-hash-here>
  username: einstein
  userID: einstein
- email: newton@ldap.forumsys.com
  hash: <paste-hash-here>
  username: newton
  userID: newton
```

**Remove or comment out the LDAP connector section.**

### Step 3: Apply and Restart

```bash
kubectl apply -f dex/dex-config.yaml
kubectl -n auth rollout restart deployment/dex
```

### Step 4: Test Login

```bash
kubectl -n auth port-forward svc/dex 5556:5556
# Open: http://localhost:5556
# Login with: einstein / password
```

## Alternative: Try Anonymous LDAP Bind First

**Before switching to local passwords, try removing bind credentials:**

```yaml
# Comment out these lines:
# bindDN: "uid=read-only-admin,dc=example,dc=com"
# bindPW: "password"
```

**ForumSys might allow anonymous binds for read operations.**

## Summary

**If LDAP bind fails:**
1. ✅ Try anonymous bind (remove bindDN/bindPW)
2. ✅ Or switch to local password DB
3. ✅ Both work for the demo!

**Local passwords are simpler and more reliable for demos anyway!**

