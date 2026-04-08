# Remote GUI Access - Windows Setup Guide

For Windows users who want to share the Kayo Script Generator GUI remotely.

## Option 1: Port Forwarding (Easiest)

### Prerequisites
- Static IP or Dynamic DNS
- Router access
- Application running on port 5000

### Steps

1. **Find your local IP:**
   ```powershell
   ipconfig
   ```
   Look for IPv4 Address (usually 192.168.x.x)

2. **Open port 5000 on your router:**
   - Access router settings (usually 192.168.1.1)
   - Find Port Forwarding section
   - Forward port 5000 to your computer's local IP
   - Example: External 5000 → Internal IP 192.168.x.x:5000

3. **Test locally first:**
   ```
   http://localhost:5000
   ```

4. **Test remotely:**
   ```
   http://your-public-ip:5000
   ```

### Advantages
- ✅ Simple setup
- ✅ No additional software
- ✅ Direct connection

### Disadvantages
- ❌ Port visible to internet
- ❌ No HTTPS/encryption
- ❌ No SSL certificate
- ❌ Security risks

---

## Option 2: Ngrok (Best for Testing)

Ngrok creates a secure tunnel to expose your local server.

### Installation

1. **Download from:** https://ngrok.com/download

2. **Extract and setup:**
   ```powershell
   # Extract ngrok.exe to a folder
   cd C:\path\to\ngrok
   ```

3. **Create account:** https://dashboard.ngrok.com/signup

4. **Authenticate:**
   ```powershell
   ngrok config add-authtoken YOUR_AUTH_TOKEN
   ```

### Usage

**Start the tunnel:**
```powershell
ngrok http 5000
```

Output will show:
```
Forwarding    https://xxxx-xx-xxx-xxx-xx.ngrok.io -> http://localhost:5000
```

**Access remotely:**
```
https://xxxx-xx-xxx-xxx-xx.ngrok.io
```

### Advantages
- ✅ Automatic HTTPS
- ✅ No router access needed
- ✅ Works behind NAT/firewalls
- ✅ Temporary URLs for security

### Disadvantages
- ❌ URL changes on restart (free tier)
- ❌ Requires internet connection
- ❌ Rate limits
- ❌ Paid plans for static URLs

---

## Option 3: IIS (Internet Information Services)

Use Windows IIS as a reverse proxy.

### Installation

1. **Open Server Manager**
   - Press Windows+R
   - Type `servermanager`
   - Click "Add Roles and Features"

2. **Select IIS:**
   - Check "Web Server (IIS)"
   - Include URL Rewrite Module

3. **Install**

### Configuration

1. **Create a site in IIS Manager:**
   - Application Name: kayo-script-gen
   - Physical path: Any folder
   - Binding: Port 80 (or 443 for HTTPS)

2. **Set up reverse proxy:**
   - Right-click site → Manage Website → Add Virtual Directory
   - Alias: kayo
   - Physical path: C:\kayo-app

3. **Add rewrite rules:**
   - Right-click site → URL Rewrite → Add Rule
   - Pattern: `(.*)`
   - Action: Rewrite to `http://localhost:5000/{R:1}`

### Access
```
http://your-computer-name/kayo
```

---

## Option 4: SSH Tunnel (Advanced)

Create a secure tunnel over SSH.

### On Remote Machine

```powershell
# SSH command to create tunnel
ssh -L 5000:localhost:5000 user@your-server

# Then access locally
# http://localhost:5000
```

### On Your Server (Linux/WSL)

```bash
# Client connects and port is tunneled to their machine
```

---

## Option 5: CloudFlare Tunnel (Recommended Production)

Creates a secure tunnel using CloudFlare.

### Setup

1. **Install CloudFlare connector:**
   ```powershell
   # Download from https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/
   ```

2. **Authenticate:**
   ```powershell
   cloudflared login
   ```

3. **Create tunnel:**
   ```powershell
   cloudflared tunnel create kayo-script-gen
   ```

4. **Configure tunnel:**
   ```powershell
   # Edit config file at:
   # C:\Users\[User]\.cloudflared\config.yml
   ```
   ```yaml
   url: http://localhost:5000
   tunnel: kayo-script-gen
   credentials-file: C:\Users\[User]\.cloudflared\[tunnel-id].json
   ```

5. **Route through CloudFlare:**
   ```powershell
   cloudflared tunnel route dns kayo-script-gen your-domain.com
   ```

### Advantages
- ✅ Production-ready
- ✅ Free tier available
- ✅ DDoS protection
- ✅ Automatic SSL
- ✅ Content caching

### Access
```
https://kayo-script-gen.your-domain.com
```

---

## Option 6: WSL with Nginx (Advanced)

Run Nginx in Windows Subsystem for Linux (WSL).

### Prerequisites
- WSL 2 installed
- Ubuntu on WSL

### Setup

1. **In PowerShell (Admin):**
   ```powershell
   wsl --install
   ```

2. **In WSL Ubuntu terminal:**
   ```bash
   # Install Nginx
   sudo apt-get update
   sudo apt-get install nginx

   # Run setup script
   curl -fsSL https://raw.githubusercontent.com/Jakes1987/drmscript/main/setup-nginx-remote.sh | bash
   ```

3. **Start application on Windows:**
   ```powershell
   # In PowerShell, run your application
   python launcher.py
   ```

4. **Access:**
   ```
   https://your-windows-ip
   ```

---

## Comparison Table

| Option | Setup | HTTPS | Security | Cost | Reliability |
|--------|-------|-------|----------|------|-------------|
| Port Forward | ⭐ Easy | ❌ No | ⚠️ Poor | Free | 🟡 OK |
| Ngrok | ⭐⭐ Easy | ✅ Yes | ✅ Good | Free* | ✅ Good |
| IIS | ⭐⭐⭐ Medium | ⭐ Manual | ✅ Good | Free | ✅ Good |
| SSH Tunnel | ⭐⭐⭐ Hard | ✅ Yes | ✅ Excellent | Free | ✅ Good |
| CloudFlare | ⭐⭐ Easy | ✅ Yes | ✅ Excellent | Free* | ✅ Excellent |
| WSL Nginx | ⭐⭐⭐ Hard | ✅ Yes | ✅ Excellent | Free | ✅ Good |

*Free tier has limitations

---

## Recommendation

### For Quick Testing
👉 **Use Ngrok** - Fastest to set up, secure by default

### For Personal Use
👉 **Use CloudFlare Tunnel** - Free, secure, reliable

### For Home Server
👉 **Use Port Forwarding + DuckDNS** - Simple, permanent access

### For Production
👉 **Use CloudFlare or IIS** - Enterprise-ready

---

## Security Considerations

### ALWAYS
- ✅ Use HTTPS/TLS encryption
- ✅ Don't expose on default ports when possible
- ✅ Use strong authentication on your app
- ✅ Monitor access logs
- ✅ Keep Windows and Python updated

### NEVER
- ❌ Use HTTP for sensitive data
- ❌ Expose directly without firewall
- ❌ Share your public IP widely
- ❌ Use weak passwords
- ❌ Ignore security warnings

---

## Firewall Configuration

### Allow through Windows Firewall

```powershell
# From PowerShell (Admin)

# Allow Python application
New-NetFirewallRule -DisplayName "Kayo Script Gen" -Direction Inbound -Program "C:\Path\To\python.exe" -Action Allow

# Allow port 5000
New-NetFirewallRule -DisplayName "Kayo - Port 5000" -Direction Inbound -LocalPort 5000 -Protocol TCP -Action Allow
```

---

## Testing Remote Access

### Check if port is open
```powershell
# PowerShell method
Test-NetConnection -ComputerName your-ip -Port 5000

# Or use online tool
# https://www.canyouseeme.org/
```

### Test from another device
1. Connect to same network
2. Try: `http://192.168.x.x:5000`
3. If it works, port forwarding should work from outside

---

## Troubleshooting

### Can't Access Locally
- [ ] Application is running: `http://localhost:5000`
- [ ] Firewall allows port 5000
- [ ] No other app on port 5000

### Can't Access Remotely
- [ ] Port forwarding configured on router
- [ ] Router's WAN IP matches your public IP
- [ ] No CGNAT (carrier-grade NAT)
- [ ] Dynamic IP needs DDNS

### HTTPS Errors
- [ ] Certificate is valid for your domain
- [ ] Browser isn't caching old cert
- [ ] System date/time correct

---

## Next Steps

1. **Choose an option** based on your needs
2. **Follow the setup steps**
3. **Test locally first**
4. **Test remotely**
5. **Monitor logs**

---

## Related Documentation

- **Linux Nginx Setup**: `NGINX_SETUP_GUIDE.md`
- **Quick Start**: `GITHUB_QUICK_START.txt`
- **Installation Guide**: `install-ubuntu.sh`
