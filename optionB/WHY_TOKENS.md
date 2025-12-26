# Why Tokens? Why Not Just Username/Password?

## The Simple Answer

**You're right to ask!** For a demo, it seems like overkill. But here's why:

## The Problem with Direct Username/Password

### Security Issues

**If apps checked passwords directly:**
```
You → App → LDAP (with your password)
```

**Problems:**
1. **App sees your password** - Security risk!
2. **Password travels everywhere** - Can be intercepted
3. **No expiration** - Password works forever
4. **Hard to revoke** - Can't invalidate without changing password

### The Token Solution

**With tokens:**
```
You → Dex (checks password once) → Get Token → Use Token
```

**Benefits:**
1. ✅ **Password stays with Dex** - App never sees it
2. ✅ **Token expires** - Automatically stops working after time
3. ✅ **Can revoke tokens** - Invalidate without changing password
4. ✅ **Token is scoped** - Only works for specific things

## Real-World Analogy

**Direct password = Giving someone your house key**
- They can use it anytime
- Hard to take back
- If lost, big problem

**Token = Temporary visitor pass**
- Expires after time
- Can be revoked
- Limited access

## Why Device Code Flow?

**You asked: "Why device code? Why not just username/password?"**

**The answer:** Dex doesn't support password grant with LDAP connectors (security policy).

**But you CAN use username/password directly with Dex's local password DB!**

## The Simple Solution: Use Local Password DB

**Instead of LDAP (which requires tokens), use Dex's built-in password database:**

```yaml
enablePasswordDB: true
staticPasswords:
- email: einstein@example.com
  hash: <bcrypt-hash>
  username: einstein
  userID: einstein
```

**Then you can:**
- Login directly with username/password
- No device code flow needed
- Simpler for demos!

## What You Actually Want

**For a demo, you probably want:**
```
User enters: einstein / password
↓
Dex checks it
↓
User gets access
```

**Not:**
```
User enters: einstein / password
↓
Get device code
↓
Visit URL
↓
Enter code
↓
Get token
↓
Use token
```

## The Simplest Approach

**Use Dex's local password DB instead of LDAP:**

1. **No LDAP bind issues**
2. **Direct username/password login**
3. **No device code complexity**
4. **Works immediately**

**Would you like me to:**
1. Switch to local password DB (simpler)?
2. Or explain more about why tokens are used in production?

## Summary

**Why tokens?**
- Security (password doesn't travel everywhere)
- Expiration (auto-expires)
- Revocation (can invalidate)

**Why not just password?**
- For demos, you CAN use direct password!
- Just use local password DB instead of LDAP
- Much simpler!

**Bottom line:** Tokens are for production security. For demos, direct password login is fine!

