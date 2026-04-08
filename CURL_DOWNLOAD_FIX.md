# Curl Download Error Troubleshooting

## Problem: `curl: (23) Failed writing body`

This error means the download got corrupted or has line ending issues.

**Error looks like:**
```
curl: (23) Failed writing body (1349 != 1378)
```

**Common Causes:**
1. Windows line endings (CRLF) in bash scripts
2. Network interruption
3. Disk full or permission issues
4. Corrupted download

---

## Solution 1: Use the Fixed Installer (Easiest)

If you're having download issues, use the fixed installer that auto-corrects line endings:

```bash
# Method A: Download and run locally (recommended)
curl -fsSL https://raw.githubusercontent.com/Jakes1987/drmscript/main/install-complete.sh -o install.sh
bash install.sh

# Method B: Direct execution
bash <(curl -fsSL https://raw.githubusercontent.com/Jakes1987/drmscript/main/install-complete.sh)
```

The `install-complete.sh` script:
- ✅ Downloads with retry logic (up to 3 attempts)
- ✅ Automatically fixes line endings (CRLF → LF)
- ✅ Better error handling
- ✅ More detailed output

---

## Solution 2: Manual Fix

If you already downloaded the script and got the error:

### Option A: Fix and Re-run (Recommended)

```bash
# Download the script
curl -fsSL https://raw.githubusercontent.com/Jakes1987/drmscript/main/install-one-liner.sh -o install.sh

# Fix line endings (convert CRLF to LF)
dos2unix install.sh  # If dos2unix is available
# OR
sed -i 's/\r$//' install.sh  # Works on all systems

# Make executable
chmod +x install.sh

# Run it
bash install.sh
```

### Option B: Re-download with Line Ending Fix

```bash
# Download and fix line endings in one command
curl -fsSL https://raw.githubusercontent.com/Jakes1987/drmscript/main/install-one-liner.sh | sed 's/\r$//' > install.sh && bash install.sh
```

### Option C: Clone Then Run

```bash
# Clone the entire repository
git clone https://github.com/Jakes1987/drmscript.git

# Enter directory
cd drmscript

# Run the script (git automatically fixes line endings)
bash install-one-liner.sh
```

---

## Solution 3: Check Your System

### Verify curl is working:

```bash
# Test basic curl
curl -fsSL https://www.google.com -o /dev/null -w "%{http_code}\n"

# Should return: 200
```

### Check disk space:

```bash
df -h
# Make sure you have at least 500MB free
```

### Check temp directory:

```bash
ls -la /tmp
# Should be writable
```

---

## Solution 4: Use Alternative Methods

### Method 1: Clone Repository

```bash
# Install git if needed
sudo apt-get install -y git

# Clone repo
git clone https://github.com/Jakes1987/drmscript.git

# Run installer
cd drmscript
bash install-one-liner.sh
```

### Method 2: Manual Installation

If all else fails, do it step by step:

```bash
# 1. Update system
sudo apt-get update
sudo apt-get upgrade -y

# 2. Install dependencies
sudo apt-get install -y python3 python3-pip git python3-venv

# 3. Create directory
mkdir -p ~/.local/kayo-script-gen
cd ~/.local/kayo-script-gen

# 4. Clone repo
git clone https://github.com/Jakes1987/drmscript.git .

# 5. Install Python dependencies
pip3 install -r requirements.txt --user

# 6. Create launcher
mkdir -p ~/.local/bin
cat > ~/.local/bin/kayo-script-gen << 'EOF'
#!/bin/bash
cd "$HOME/.local/kayo-script-gen"
python3 launcher.py "$@"
EOF
chmod +x ~/.local/bin/kayo-script-gen

# 7. Add to PATH
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# 8. Setup Nginx
sudo bash setup-nginx-remote.sh $(hostname -I | awk '{print $1}') 8080

# 9. Start application
kayo-script-gen
```

---

## Debugging Tips

### If download fails:

```bash
# Check URL is accessible
curl -I https://raw.githubusercontent.com/Jakes1987/drmscript/main/install-one-liner.sh

# Should show: HTTP/1.1 200 OK
```

### If script has errors after download:

```bash
# Check file for line ending issues
file install.sh
# Should show: shell script, ASCII text, with LF line terminators (not CRLF)

# Fix it
dos2unix install.sh || sed -i 's/\r$//' install.sh

# Verify fix
file install.sh
```

### If execution fails:

```bash
# Run with debugging
bash -x install.sh

# Or line by line
bash -n install.sh  # Syntax check only
```

---

## Line Ending Issue Explained

**What's happening:**
- Script created on Windows: Uses CRLF (Carriage Return + Line Feed) = `\r\n`
- Script expected on Linux: Uses LF only = `\n`
- When bash reads CRLF lines, it gets confused and causes errors

**Fix options:**

```bash
# Option 1: dos2unix (if installed)
dos2unix script.sh

# Option 2: sed (works everywhere)
sed -i 's/\r$//' script.sh

# Option 3: tr
tr -d '\r' < script.sh > script_fixed.sh && mv script_fixed.sh script.sh

# Option 4: perl
perl -pi -e 's/\r\n/\n/' script.sh
```

---

## Recommended Setup Command

Use this if you're having any issues:

```bash
# All-in-one reliable command
bash <(curl -fsSL https://raw.githubusercontent.com/Jakes1987/drmscript/main/install-complete.sh 2>/dev/null | sed 's/\r$//')
```

Or simpler version:

```bash
# Clone repo (most reliable)
git clone https://github.com/Jakes1987/drmscript.git && cd drmscript && bash install-one-liner.sh
```

---

## Still Having Issues?

### Collect debug info:

```bash
# System info
uname -a
lsb_release -a

# Bash version
bash --version

# Curl version
curl --version

# Try the download
curl -v https://raw.githubusercontent.com/Jakes1987/drmscript/main/install-one-liner.sh 2>&1 | head -50
```

### Report issue with:
```bash
bash -x <(curl -fsSL https://raw.githubusercontent.com/Jakes1987/drmscript/main/install-complete.sh 2>&1) 2>&1 | tee debug.log
```

Then share `debug.log` for support.

---

## Quick Summary

| Problem | Solution |
|---------|----------|
| `curl: (23) Failed writing body` | Use `install-complete.sh` instead |
| Line ending issues | Run `sed -i 's/\r$//' script.sh` |
| Network issues | Use git clone method |
| Disk issues | Check `df -h`, free up space |
| Permissions issues | Use `sudo` if needed |

**Best Practice:** Always use `install-complete.sh` on Ubuntu servers - it handles all these issues automatically!
