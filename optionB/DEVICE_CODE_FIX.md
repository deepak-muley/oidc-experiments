# Fix: Device Code URL Not Showing UI

## The Problem

When you run `./scripts/get-token.sh`, it shows:
```
http://dex.auth.svc.cluster.local:5556/device?user_code=ABC-123
```

**This URL won't work** because:
- It's a cluster-internal URL
- Your browser can't access it directly
- You need to port-forward Dex first

## The Solution

### Step 1: Port-Forward Dex

**In Terminal 1:**
```bash
kubectl -n auth port-forward svc/dex 5556:5556
```

**Keep this running!**

### Step 2: Get Device Code

**In Terminal 2:**
```bash
cd optionB
./scripts/get-token.sh
```

**The script will show:**
```
👉 Please visit this URL in your browser:
   http://localhost:5556/device?user_code=ABC-123
```

### Step 3: Visit the URL

**Open in your browser:**
```
http://localhost:5556/device?user_code=ABC-123
```

**Or visit:**
```
http://localhost:5556/device
```
**And enter the code manually when prompted.**

## What You Should See

**The device code page should show:**
- A form to enter the user code
- Option to login with LDAP credentials
- Fields for username and password

**If you see a blank page or error:**
1. Make sure port-forward is running
2. Check the URL uses `localhost:5556` (not cluster URL)
3. Try accessing `http://localhost:5556` first to see Dex homepage

## Quick Test

**Test if Dex is accessible:**
```bash
# Should show Dex homepage HTML
curl http://localhost:5556
```

**Get device code manually:**
```bash
curl -X POST http://localhost:5556/device/code \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "client_id=cli" \
  -d "client_secret=cli-secret" \
  -d "scope=openid profile email" | jq .
```

**Then visit the `verification_uri_complete` URL (converted to localhost)**

## Updated Script

The script has been updated to automatically convert cluster URLs to localhost URLs when port-forward is active.

**Just make sure:**
1. ✅ Port-forward Dex first
2. ✅ Use the localhost URL shown by the script
3. ✅ Login with einstein/password

## Alternative: Use Browser Flow

If device code flow is too complex, use the simpler browser flow:

```bash
# Just open in browser:
http://localhost:5556

# Then login directly
```

See `get-token-simple.sh` for browser-based instructions.

