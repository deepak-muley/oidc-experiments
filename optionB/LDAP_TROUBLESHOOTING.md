# LDAP Bind Credentials Troubleshooting

## The Error

```
Login error: ldap: initial bind for user "uid=read-only-admin,dc=example,dc=com" failed: 
LDAP Result Code 49 "Invalid Credentials"
```

## Possible Causes

1. **ForumSys server credentials changed** - The public test server may have updated credentials
2. **Server temporarily down** - ForumSys test server might be experiencing issues
3. **Network/firewall** - LDAP port 389 might be blocked
4. **Bind DN format** - The format might need to be different

## Solutions to Try

### Solution 1: Verify Server is Reachable

```bash
# Test connectivity
nc -zv ldap.forumsys.com 389

# Should show: Connection succeeded
```

### Solution 2: Try Anonymous Bind

**Edit `dex/dex-config.yaml`:**
```yaml
# Comment out bindDN and bindPW
# bindDN: "uid=read-only-admin,dc=example,dc=com"
# bindPW: "password"
```

**Apply and restart:**
```bash
kubectl apply -f dex/dex-config.yaml
kubectl -n auth rollout restart deployment/dex
```

### Solution 3: Check ForumSys Documentation

Visit: https://www.forumsys.com/tutorials/integration-how-to/ldap/online-ldap-test-server/

Verify current credentials.

### Solution 4: Use Local Password DB (Workaround)

If LDAP continues to fail, use Dex's built-in password database:

**Edit `dex/dex-config.yaml`:**
```yaml
enablePasswordDB: true
# Remove or comment out LDAP connector
# connectors:
# - type: ldap
#   ...
```

**Then create users via Dex API or use static users.**

## Current Configuration

**Using:**
- bindDN: `uid=read-only-admin,dc=example,dc=com`
- bindPW: `password`
- Host: `ldap.forumsys.com:389`

## Test Login

**After any changes:**
1. Port-forward Dex: `kubectl -n auth port-forward svc/dex 5556:5556`
2. Open: `http://localhost:5556`
3. Try login with: einstein / password
4. Check logs: `kubectl -n auth logs -l app=dex --tail=20`

## If Still Failing

**Check recent logs:**
```bash
kubectl -n auth logs -l app=dex --tail=50 | grep -i "ldap\|bind\|error"
```

**Try anonymous bind** (remove bindDN/bindPW) - ForumSys might allow it for read operations.

**Or switch to local password DB** for the demo if LDAP is unreliable.

