# Quick Guide: Getting a Token

## The Problem

The script shows: `http://dex.auth.svc.cluster.local:5556/device`

**This won't work** - it's a cluster-internal URL your browser can't access!

## The Solution (3 Steps)

### Step 1: Port-Forward Dex

**Open Terminal 1 and run:**
```bash
kubectl -n auth port-forward svc/dex 5556:5556
```

**Keep this terminal open!**

### Step 2: Get Device Code

**Open Terminal 2 and run:**
```bash
cd optionB
./scripts/get-token.sh
```

**The script will show:**
```
👉 Please visit this URL in your browser:
   http://localhost:5556/device?user_code=ABC-123
```

**Note:** The script now automatically converts to localhost URL!

### Step 3: Visit the URL

**Open in your browser:**
```
http://localhost:5556/device?user_code=ABC-123
```

**You should see:**
- A form with the code pre-filled
- A "Submit" button
- After submitting, a login form

**Login with:**
- Username: `einstein`
- Password: `password`

**The script will automatically get your token!**

## What If It Still Doesn't Work?

### Check 1: Is port-forward running?
```bash
# Should show the process
ps aux | grep "port-forward.*dex"
```

### Check 2: Can you access Dex homepage?
```bash
# Open in browser:
http://localhost:5556

# Should show Dex login page
```

### Check 3: Try the device endpoint directly
```bash
# Open in browser:
http://localhost:5556/device

# Should show a form to enter user code
```

## Alternative: Simpler Browser Flow

If device code is too complex:

**1. Port-forward Dex:**
```bash
kubectl -n auth port-forward svc/dex 5556:5556
```

**2. Open in browser:**
```
http://localhost:5556
```

**3. Login directly with einstein/password**

**4. You'll get redirected with tokens in the URL**

## Summary

**The key:** Always use `http://localhost:5556` (not the cluster URL)

**Steps:**
1. ✅ Port-forward Dex
2. ✅ Run get-token.sh
3. ✅ Visit the localhost URL shown
4. ✅ Login
5. ✅ Get token!

