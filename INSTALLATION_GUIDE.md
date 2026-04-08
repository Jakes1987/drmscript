# Kayo Script Generator - Installation Guide

## Overview

This guide provides multiple installation methods for the Kayo Script Generator on Ubuntu/Debian servers. Choose the method that best suits your environment.

---

## Method 1: Git Clone (Recommended - Most Reliable)

**Best for:** Most environments, good network connectivity, development teams

```bash
# Clone the repository
git clone https://github.com/Jakes1987/drmscript.git
cd drmscript

# Run the installation
bash install-one-liner.sh
```

**Why it works:**
- No download corruption issues
- Git ensures file integrity with checksums
- Handles line endings automatically with `.gitattributes`
- Full source code available for inspection

**Time:** ~3-5 minutes

---

## Method 2: Download Script (Robust Fallback)

**Best for:** Restricted firewalls, unstable network, shell environment restrictions

```bash
# Download the setup script
curl -fsSL https://raw.githubusercontent.com/Jakes1987/drmscript/main/setup-download.sh -o setup.sh

# Run it
bash setup.sh
```

**Features:**
- 5-retry logic for each file download
- Automatic line ending fixing (CRLF → LF)
- No shell process substitution (works in restricted shells)
- 120-second timeout per file
- Detailed error reporting

**When to use:**
- `curl: (23) Failed writing body` errors
- `bash: /dev/fd/63: No such file or directory` errors
- Restricted shell environments

**Time:** ~5-10 minutes (varies with retries)

---

## Method 3: Complete Installer (Balanced Approach)

**Best for:** Users who want automated retry logic and better error handling

```bash
# Download the complete installer
curl -fsSL https://raw.githubusercontent.com/Jakes1987/drmscript/main/install-complete.sh -o install.sh

# Run it
bash install.sh
```

**Features:**
- Up to 3 retry attempts for installation
- Automatic line ending correction
- Can install dos2unix if available
- Comprehensive progress output

**Time:** ~3-8 minutes

---

## Method 4: Direct One-Liner (Quick)

**Best for:** Clean environments, fast deployments

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Jakes1987/drmscript/main/install-one-liner.sh)
```

**When it fails:**
- Restricted shells that don't support process substitution
- High packet loss or connection instability
- Use Method 2 (Download Script) instead

**Time:** ~3-5 minutes

---

## Troubleshooting Installation Issues

### Issue: `curl: (23) Failed writing body (515 != 1378)`

**Cause:** Incomplete file download due to network issues or CRLF line ending corruption

**Solution (in order):**
1. Try Method 2 (setup-download.sh) with automatic retries
2. Check your network connection: `ping google.com`
3. Increase timeout: `curl --max-time 300 <url>` (5 minutes)
4. Use Method 1 (git clone) instead

**Verify fix:**
```bash
# After installation completes
kayo-script-gen --version
```

---

### Issue: `bash: /dev/fd/63: No such file or directory`

**Cause:** Shell environment doesn't support process substitution

**Solution:**
```bash
# Don't use the one-liner with <(...)
# Use Method 2 instead:
curl -fsSL https://raw.githubusercontent.com/Jakes1987/drmscript/main/setup-download.sh -o setup.sh
bash setup.sh
```

**Verify shell compatibility:**
```bash
# Test if your shell supports process substitution
bash -c 'echo <(echo test)' 2>/dev/null && echo "Supported" || echo "Not supported"
```

---

### Issue: `Port 8080 already in use`

**Cause:** Another service is using the port

**Solution:**
```bash
# Find what's using the port
sudo lsof -i :8080

# Or use the provided fix script
bash fix-port-conflict.sh
```

---

### Issue: `Nginx certificate not found`

**Cause:** SSL certificate hasn't been obtained yet

**Solution (choose one):**

1. Use Let's Encrypt (recommended):
```bash
sudo apt-get install certbot python3-certbot-nginx
sudo certbot certonly --standalone -d your-domain.com
```

2. Use self-signed certificate:
```bash
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/nginx-selfsigned.key \
  -out /etc/ssl/certs/nginx-selfsigned.crt
```

3. Or use the provided fix script:
```bash
bash fix-nginx-ssl.sh
```

---

## Post-Installation Verification

After installation completes, verify everything is working:

```bash
# 1. Check application is running on port 5000
curl -s http://localhost:5000 | head -20

# 2. Check Nginx is running
sudo systemctl status nginx

# 3. Verify external access on port 8080
# From your local machine, replace SERVER_IP with actual IP:
curl -s http://SERVER_IP:8080 | head -20

# 4. Check logs for errors
sudo tail -30 /var/log/nginx/kayo-script-gen.error.log
sudo tail -30 /var/log/nginx/kayo-script-gen.access.log
```

---

## Installation Port Configuration

By default:
- **Port 5000:** Kayo Script Generator (localhost only)
- **Port 8080:** Nginx reverse proxy (external access)
- **Port 80:** Reserved for O11V4 panel

To customize ports during installation:
```bash
# Edit install-one-liner.sh before running
nano install-one-liner.sh

# Look for NGINX_PORT and change as needed
NGINX_PORT=8080  # Change this to your desired port
```

---

## Uninstalling

To uninstall the Kayo Script Generator:

```bash
# Stop services
kayo-script-gen stop
sudo systemctl stop nginx

# Disable Nginx (if no longer needed)
sudo systemctl disable nginx

# Remove installation
rm -rf ~/.local/kayo-script-gen/

# Remove Nginx config (if installed only for Kayo)
sudo rm /etc/nginx/sites-available/kayo-script-gen
sudo rm /etc/nginx/sites-enabled/kayo-script-gen

# Restart Nginx
sudo systemctl restart nginx
```

---

## Network Requirements

- **Outbound HTTPS (443):** Required for GitHub and Kayo API
- **Inbound HTTP (8080):** Required for remote web GUI access
- **Inbound Port 5000:** Not required (localhost only by default)

---

## Getting Help

If you encounter issues:

1. Check the relevant troubleshooting section above
2. Review logs: `~/.local/kayo-script-gen/logs/`
3. Verify system requirements:
   ```bash
   python3 --version    # Should be 3.10+
   nginx -v             # Should display version
   git --version        # Should display version
   ```

4. If download fails repeatedly, use Method 1 (git clone)

---

## Summary Table

| Method | Speed | Reliability | Ease | When to Use |
|--------|-------|-------------|------|------------|
| Git Clone | Fast | Highest | Medium | Recommended default |
| Download Script | Slower | High | Medium | When curl fails |
| Complete Installer | Medium | High | Easy | Balanced choice |
| One-Liner | Fastest | Medium | Easy | Clean environments |

