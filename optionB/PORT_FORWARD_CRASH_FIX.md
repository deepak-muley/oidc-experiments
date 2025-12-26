# Fix: Port-Forward Crashed After Login

## The Problem

Port-forward crashed with error:
```
error forwarding port 4180 to pod ... failed to find sandbox ... in store: not found
lost connection to pod
```

**This happens when:**
- Pod restarts or is recreated
- Port-forward loses connection to the old pod
- Network issues

## Why It Happens

**Port-forwards are not persistent:**
- They connect to a specific pod
- If the pod restarts, the connection breaks
- The port-forward process crashes

**Common causes:**
1. Pod was restarted (deployment update, crash, etc.)
2. Pod was recreated (new pod name)
3. Network connectivity issues
4. Kubernetes API server issues

## The Fix

### Quick Fix: Restart Port-Forwards

**Use the restart script:**
```bash
cd optionB
./scripts/restart-port-forwards.sh
```

**This script:**
- Kills old port-forwards
- Finds current pod names
- Starts new port-forwards with current pods

### Manual Fix

**Step 1: Kill old port-forwards**
```bash
pkill -f "port-forward"
lsof -ti:4180,5556 | xargs kill -9 2>/dev/null
```

**Step 2: Get current pod names**
```bash
kubectl -n auth get pods -l app=dex
kubectl -n oidc-proxy get pods -l app=oauth2-proxy
```

**Step 3: Start new port-forwards with specific pods**
```bash
# Get pod names
DEX_POD=$(kubectl -n auth get pods -l app=dex -o jsonpath='{.items[0].metadata.name}')
OAUTH2_POD=$(kubectl -n oidc-proxy get pods -l app=oauth2-proxy -o jsonpath='{.items[0].metadata.name}')

# Port-forward to specific pods
kubectl -n auth port-forward pod/$DEX_POD 5556:5556 &
kubectl -n oidc-proxy port-forward pod/$OAUTH2_POD 4180:4180 &
```

## Prevention: Use Service Port-Forward

**Instead of pod port-forward, use service port-forward:**

```bash
# These are more stable (survive pod restarts)
kubectl -n auth port-forward svc/dex 5556:5556 &
kubectl -n oidc-proxy port-forward svc/oauth2-proxy 4180:80 &
```

**Benefits:**
- ✅ Survives pod restarts
- ✅ Automatically routes to new pods
- ✅ More stable

**The restart script uses service port-forwards for stability.**

## After Restarting Port-Forwards

**If you were in the middle of login:**
1. Restart port-forwards
2. Go back to: `http://localhost:4180`
3. Login again (you might need to clear cookies if session expired)

**The login should complete and redirect to podinfo.**

## Troubleshooting

**If port-forward keeps crashing:**

1. **Check pod status:**
   ```bash
   kubectl -n oidc-proxy get pods -l app=oauth2-proxy
   kubectl -n auth get pods -l app=dex
   ```

2. **Check pod logs:**
   ```bash
   kubectl -n oidc-proxy logs -l app=oauth2-proxy --tail=20
   ```

3. **Check if pods are restarting:**
   ```bash
   kubectl -n oidc-proxy get pods -l app=oauth2-proxy -w
   ```

4. **Restart pods if needed:**
   ```bash
   kubectl -n oidc-proxy rollout restart deployment/oauth2-proxy
   kubectl -n auth rollout restart deployment/dex
   ```

## Summary

✅ **Fixed:** Port-forwards restarted with current pods
✅ **Prevention:** Use service port-forwards (more stable)
✅ **Script:** `./scripts/restart-port-forwards.sh` handles this automatically

**Try accessing `http://localhost:4180` again after restarting port-forwards!**

