# How to Verify Option B (Complete Setup)

## Quick Verification

**Run this one command:**
```bash
cd optionB
./scripts/verify-complete.sh
```

This checks everything and shows you the status.

## Manual Verification (Step by Step)

### Step 1: Check All Pods Are Running

```bash
# Check Dex
kubectl -n auth get pods
# Should show: dex-xxx-xxx  1/1   Running

# Check podinfo
kubectl -n podinfo get pods
# Should show: podinfo-xxx-xxx  1/1   Running

# Check oauth2-proxy
kubectl -n oidc-proxy get pods
# Should show: oauth2-proxy-xxx-xxx  1/1   Running
```

### Step 2: Test Direct Access (No Auth)

**Terminal 1: Port-forward podinfo**
```bash
kubectl -n podinfo port-forward svc/podinfo 9898:9898
```

**Terminal 2: Access podinfo directly**
```bash
curl http://localhost:9898
```

**Expected:** ✅ Should work (returns JSON) - podinfo doesn't check auth

### Step 3: Test oauth2-proxy (With Protection)

**Terminal 1: Port-forward oauth2-proxy**
```bash
kubectl -n oidc-proxy port-forward svc/oauth2-proxy 4180:80
```

**Terminal 2: Try to access WITHOUT token**
```bash
curl http://localhost:4180
```

**Expected:** ❌ Should be blocked (HTTP 302 redirect or 403)

**This proves:** oauth2-proxy is protecting podinfo!

### Step 4: Get a Token

**Terminal 1: Port-forward Dex**
```bash
kubectl -n auth port-forward svc/dex 5556:5556
```

**Terminal 2: Get token**
```bash
cd optionB
./scripts/get-token.sh
```

**Follow the instructions:**
1. Visit the URL shown
2. Login with: einstein / password
3. Script will get the token

### Step 5: Test With Token

**Terminal 2: Access through oauth2-proxy WITH token**
```bash
export TOKEN="<paste-token-here>"
curl -H "Authorization: Bearer $TOKEN" http://localhost:4180
```

**Expected:** ✅ Should work (returns podinfo JSON)

**This proves:** Token validation works!

## What Each Test Proves

| Test | What It Proves |
|------|----------------|
| Direct podinfo access | ✅ podinfo works (no auth) |
| oauth2-proxy without token | ✅ Protection is working |
| oauth2-proxy with token | ✅ Token validation works |
| Dex token generation | ✅ Authentication works |

## Complete Flow Verification

**The complete flow:**
```
1. User → Dex → Get Token ✅
2. User → oauth2-proxy (with token) → podinfo ✅
3. User → oauth2-proxy (without token) → Blocked ✅
```

## Quick Test Script

**All-in-one test:**
```bash
cd optionB

# Start port-forwards
kubectl -n auth port-forward svc/dex 5556:5556 &
kubectl -n oidc-proxy port-forward svc/oauth2-proxy 4180:80 &
kubectl -n podinfo port-forward svc/podinfo 9898:9898 &

sleep 3

# Test 1: Direct podinfo (should work)
echo "Test 1: Direct podinfo access"
curl -s http://localhost:9898 | jq -r '.version' && echo "✅ Works"

# Test 2: oauth2-proxy without token (should fail)
echo "Test 2: oauth2-proxy without token"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:4180)
[ "$HTTP_CODE" = "302" ] || [ "$HTTP_CODE" = "403" ] && echo "✅ Blocked (HTTP $HTTP_CODE)"

# Test 3: Get token and test
echo "Test 3: Get token (follow browser instructions)"
./scripts/get-token.sh
# Then test with: curl -H "Authorization: Bearer $TOKEN" http://localhost:4180
```

## Summary

**To verify everything:**
1. ✅ Run `./scripts/verify-complete.sh`
2. ✅ Or follow manual steps above

**What you should see:**
- ✅ All pods running
- ✅ Direct podinfo access works
- ✅ oauth2-proxy blocks without token
- ✅ oauth2-proxy allows with valid token

**This proves the complete solution works!**

