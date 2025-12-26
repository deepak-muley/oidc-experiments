# How to Check and Kill Port-Forward Processes

## Quick Commands

### Check Running Port-Forwards

**Method 1: Check kubectl processes**
```bash
ps aux | grep "port-forward" | grep -v grep
```

**Method 2: Check specific ports**
```bash
lsof -i :5556  # Dex
lsof -i :4180  # oauth2-proxy
lsof -i :9898  # podinfo
lsof -i :8443  # kube-oidc-proxy
```

**Method 3: Use the script**
```bash
cd optionB
./scripts/check-port-forwards.sh
```

### Kill All Port-Forwards

**Method 1: Kill all kubectl port-forward processes**
```bash
pkill -f "port-forward"
```

**Method 2: Kill by PID**
```bash
# Find PIDs
ps aux | grep "port-forward" | grep -v grep | awk '{print $2}'

# Kill specific PID
kill -9 <PID>
```

**Method 3: Kill processes on specific ports**
```bash
# Kill process on port 5556
lsof -ti:5556 | xargs kill -9

# Kill all common ports at once
lsof -ti:5556,4180,9898,8443 | xargs kill -9 2>/dev/null
```

**Method 4: Use the script**
```bash
cd optionB
./scripts/kill-port-forwards.sh
```

## One-Liner Commands

### Check all port-forwards
```bash
ps aux | grep "kubectl.*port-forward" | grep -v grep || echo "No port-forwards running"
```

### Kill all port-forwards
```bash
pkill -f "port-forward" && echo "✅ Stopped all port-forwards" || echo "No port-forwards to kill"
```

### Free all common ports
```bash
lsof -ti:5556,4180,9898,8443 2>/dev/null | xargs kill -9 2>/dev/null && echo "✅ Freed ports" || echo "Ports already free"
```

## Common Ports Reference

| Port | Service | Namespace |
|------|---------|-----------|
| 5556 | Dex | auth |
| 4180 | oauth2-proxy | oidc-proxy |
| 9898 | podinfo | podinfo |
| 8443 | kube-oidc-proxy | oidc-proxy |

## Troubleshooting

**If port is still in use after killing:**
```bash
# Check what's using the port
lsof -i :5556

# Force kill
kill -9 $(lsof -ti:5556)
```

**If you see "Address already in use":**
```bash
# Find and kill the process
lsof -ti:5556 | xargs kill -9
```

## Scripts Available

- **`scripts/check-port-forwards.sh`** - Lists all running port-forwards
- **`scripts/kill-port-forwards.sh`** - Kills all port-forwards and frees ports

## Example Workflow

```bash
# 1. Check what's running
./scripts/check-port-forwards.sh

# 2. Kill everything
./scripts/kill-port-forwards.sh

# 3. Start new port-forwards
kubectl -n auth port-forward svc/dex 5556:5556 &
kubectl -n oidc-proxy port-forward svc/oauth2-proxy 4180:80 &
```

