# For Junior Developers: Maintenance Guide

## What This Project Does

This project shows how to:
1. Authenticate users using LDAP (ForumSys test server)
2. Get OIDC tokens from Dex
3. Use those tokens to access services

## The Components (Simple Version)

### 1. Dex (`dex/` folder)
**What it is:** Authentication server
**What it does:** 
- Connects to LDAP to check usernames/passwords
- Gives you OIDC tokens if login succeeds

**Files:**
- `dex-config.yaml` - Configuration (LDAP settings, clients)
- `dex.yaml` - Kubernetes deployment

**To modify:** Edit `dex-config.yaml` to change LDAP settings or add clients

### 2. podinfo (`podinfo/` folder)
**What it is:** Demo application
**What it does:** Shows JSON data (just for testing)

**Files:**
- `README.md` - Documentation

**To modify:** Usually deployed from upstream, but you can customize

### 3. kube-oidc-proxy (`kube-oidc-proxy/` folder)
**What it is:** A proxy (but we don't use it!)
**Why it's here:** It was planned but not needed
**Status:** Can ignore it

**Files:**
- `kube-oidc-proxy.yaml` - Deployment (currently broken, that's OK)

**To modify:** Don't worry about it unless you need Kubernetes API proxying

## The Scripts (`scripts/` folder)

### `setup.sh`
**What it does:** Sets up everything
**When to run:** First time, or after deleting cluster
**What it does:**
1. Creates Kubernetes cluster
2. Deploys Dex
3. Deploys podinfo
4. (Tries to deploy kube-oidc-proxy, but it's OK if it fails)

### `verify.sh`
**What it does:** Checks if everything is running
**When to run:** Anytime to check status
**What it checks:**
- Are Dex pods running?
- Is podinfo running?
- Can we connect to them?

### `get-token.sh`
**What it does:** Gets an OIDC token from Dex
**When to run:** When you need a token
**How it works:**
1. Asks Dex for a device code
2. Shows you URL to visit
3. You login in browser
4. Script gets token and shows it

**Important:** You need Dex port-forwarded first!

### `get-token-simple.sh`
**What it does:** Shows simpler way to get token
**When to run:** If you prefer browser-based flow
**What it does:** Just shows instructions

### `test-podinfo.sh`
**What it does:** Tests if you can access podinfo with a token
**When to run:** After getting a token
**How to use:** `./test-podinfo.sh <your-token>`

## Common Tasks

### "I want to change the LDAP server"

Edit `dex/dex-config.yaml`:
```yaml
connectors:
- type: ldap
  config:
    host: your-ldap-server.com:389  # Change this
    bindDN: "your-bind-dn"          # Change this
    bindPW: "your-password"         # Change this
```

Then:
```bash
kubectl apply -f dex/dex-config.yaml
kubectl -n auth rollout restart deployment/dex
```

### "I want to add a new OIDC client"

Edit `dex/dex-config.yaml`:
```yaml
staticClients:
- id: cli
  # ... existing client ...
- id: my-new-client          # Add this
  name: My New Client
  secret: my-secret
  redirectURIs:
  - http://localhost:8080/callback
```

Then:
```bash
kubectl apply -f dex/dex-config.yaml
kubectl -n auth rollout restart deployment/dex
```

### "I want to use a different user"

The users come from ForumSys LDAP. Available users:
- einstein / password
- newton / password
- galieleo / password
- tesla / password
- riemann / password

Just use a different username when logging in!

### "Something is broken, how do I debug?"

1. **Check if pods are running:**
   ```bash
   ./scripts/verify.sh
   ```

2. **Check Dex logs:**
   ```bash
   kubectl -n auth logs -l app=dex --tail=50
   ```

3. **Check if Dex is accessible:**
   ```bash
   kubectl -n auth port-forward svc/dex 5556:5556
   # In another terminal:
   curl http://localhost:5556/.well-known/openid-configuration
   ```

4. **Restart everything:**
   ```bash
   kubectl -n auth rollout restart deployment/dex
   kubectl -n podinfo rollout restart deployment/podinfo
   ```

### "I want to start fresh"

```bash
# Delete the cluster
kind delete cluster --name oidc-proxy-demo

# Run setup again
./scripts/setup.sh
```

## Understanding Grant Types (Simple)

**Grant type = How you ask for a token**

### Device Code Grant (What we use)
**Like:** Getting a code at a restaurant, then showing it to get your food

```
1. Ask: "Give me a code"
2. Get: "Code is ABC-123, go to website"
3. Visit website, enter code, login
4. Get: "Here's your token"
```

**Why we use it:** Works with LDAP, good for CLI tools

### Password Grant (Doesn't work with LDAP)
**Like:** Just telling the guard your password directly

```
1. Say: "I'm einstein, password is password"
2. Get: "Here's your token"
```

**Why it doesn't work:** Dex doesn't allow this with LDAP (security)

### Authorization Code Grant (For web apps)
**Like:** Logging in on a website, getting redirected

```
1. Visit login page
2. Login
3. Get redirected with a code
4. Exchange code for token
```

**When to use:** Web applications

## File Structure (What's Where)

```
optionB/
├── cluster/
│   └── kind.yaml              # Kubernetes cluster config
├── dex/
│   ├── dex-config.yaml        # Dex settings (LDAP, clients)
│   └── dex.yaml               # Dex deployment
├── kube-oidc-proxy/           # (Can ignore)
├── podinfo/                    # (Just docs)
└── scripts/
    ├── setup.sh               # Initial setup
    ├── verify.sh              # Check status
    ├── get-token.sh           # Get token (device code)
    └── get-token-simple.sh    # Get token (instructions)
```

## Quick Reference

**Start everything:**
```bash
./scripts/setup.sh
```

**Check status:**
```bash
./scripts/verify.sh
```

**Get a token:**
```bash
# Terminal 1
kubectl -n auth port-forward svc/dex 5556:5556

# Terminal 2
./scripts/get-token.sh
```

**Access podinfo:**
```bash
kubectl -n podinfo port-forward svc/podinfo 9898:9898
curl http://localhost:9898
```

## Troubleshooting

### "get-token.sh says 'unsupported_grant_type'"
**Fixed!** The script now uses device code flow. Make sure you're using the latest version.

### "Dex pod keeps restarting"
Check logs: `kubectl -n auth logs -l app=dex`
Usually means:
- LDAP server unreachable
- Wrong LDAP credentials
- ConfigMap has syntax error

### "Can't connect to Dex"
Make sure port-forward is running:
```bash
kubectl -n auth port-forward svc/dex 5556:5556
```

### "kube-oidc-proxy is broken"
**That's OK!** We don't need it. Just ignore it.

## Key Concepts to Remember

1. **Dex** = Authentication (checks who you are)
2. **OIDC Token** = Proof you're authenticated
3. **Grant Type** = Method to get the token
4. **LDAP** = User directory (where usernames/passwords are)
5. **kube-oidc-proxy** = Not needed for this demo

## Questions?

- **"Why is kube-oidc-proxy here if we don't use it?"** - It was planned but not needed. Can be removed.
- **"Can I use password grant?"** - No, Dex doesn't support it with LDAP. Use device code.
- **"How do I protect podinfo?"** - For demo, you don't need to. For production, add token validation to the app or use a different proxy.

