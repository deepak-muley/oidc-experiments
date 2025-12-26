# Fix: LDAP Bind Credentials Error

## The Error

```
Login error: ldap: initial bind for user "uid=read-only-admin,dc=example,dc=com" failed: 
LDAP Result Code 49 "Invalid Credentials"
```

## The Problem

ForumSys LDAP test server bind credentials may have changed or the bind DN format is incorrect.

## Solutions to Try

### Solution 1: Try Different Bind DN Format

**Changed from:**
```yaml
bindDN: "uid=read-only-admin,dc=example,dc=com"
```

**To:**
```yaml
bindDN: "cn=read-only-admin,dc=example,dc=com"
```

**Applied:** Configuration updated and Dex restarted.

### Solution 2: Try Anonymous Bind

If the bind DN doesn't work, try removing bind credentials entirely:

```yaml
# Comment out bindDN and bindPW
# bindDN: "uid=read-only-admin,dc=example,dc=com"
# bindPW: "password"
```

**Note:** ForumSys might allow anonymous binds for read operations.

### Solution 3: Verify ForumSys Server Status

**Test LDAP connection:**
```bash
# Test if server is reachable
nc -zv ldap.forumsys.com 389

# Should show: Connection succeeded
```

**Check ForumSys documentation:**
- Visit: https://www.forumsys.com/tutorials/integration-how-to/ldap/online-ldap-test-server/
- Verify current bind credentials

### Solution 4: Use Static Users Instead (Workaround)

If LDAP continues to fail, you can use Dex's built-in password database:

```yaml
enablePasswordDB: true
# Then create users via Dex API or use static users
```

## Current Status

**Trying:** `cn=read-only-admin,dc=example,dc=com` instead of `uid=`

**Test it:**
1. Port-forward Dex: `kubectl -n auth port-forward svc/dex 5556:5556`
2. Open: `http://localhost:5556`
3. Try login with: einstein / password

## If Still Failing

**Check Dex logs:**
```bash
kubectl -n auth logs -l app=dex --tail=50 | grep -i "ldap\|bind\|error"
```

**Possible issues:**
- ForumSys server credentials changed
- Server is temporarily down
- Network/firewall blocking LDAP port 389
- Bind DN format incorrect

## Alternative: Use Local Password DB

If LDAP continues to fail, we can configure Dex to use local password database instead of LDAP for the demo.

**Would you like me to:**
1. Try more bind DN variations?
2. Set up local password database?
3. Check ForumSys server status?

