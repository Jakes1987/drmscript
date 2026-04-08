# Nginx Remote Access Guide

## What This Script Does

The `setup-nginx-remote.sh` script configures Nginx as a reverse proxy to allow remote access to your Kayo Script Generator web GUI.

**Key Features:**
- ✅ Runs on **port 8080** (leaves port 80 free for O11V4 panel)
- ✅ Proxies local application running on **port 5000**
- ✅ WebSocket support for real-time updates
- ✅ Automatic caching of static files
- ✅ Security headers and protections
- ✅ No SSL/HTTPS needed (HTTP on port 8080)

**Port Configuration:**
- **Port 80**: Available for O11V4 panel
- **Port 5000**: Local Kayo application
- **Port 8080**: Nginx reverse proxy (remote access)

---

## Quick Setup

### On Ubuntu/Debian Server:

```bash
# Download and run the setup script (port 8080 is default)
sudo bash <(curl -fsSL https://raw.githubusercontent.com/Jakes1987/drmscript/main/setup-nginx-remote.sh)

# Or specify a different port if needed
sudo bash <(curl -fsSL https://raw.githubusercontent.com/Jakes1987/drmscript/main/setup-nginx-remote.sh) your-ip-or-domain 8080
```

**Note:** The script automatically uses port **8080** to avoid conflicts with O11V4 panel on port 80.

### Manual Installation:

```bash
# Copy the script
curl -fsSL https://raw.githubusercontent.com/Jakes1987/drmscript/main/setup-nginx-remote.sh -o setup-nginx-remote.sh

# Make it executable
chmod +x setup-nginx-remote.sh

# Run with sudo
sudo ./setup-nginx-remote.sh
```

---

## Prerequisites

- **Ubuntu 18.04+** or **Debian 10+** system
- Root/sudo access
- Static IP address or domain name (for SSL certificate)
- Application running on localhost:5000 (default port)

---

## Step-by-Step Setup

### 1. Run the Nginx Setup Script

```bash
sudo bash setup-nginx-remote.sh
```

Or with a specific IP/domain:
```bash
sudo bash setup-nginx-remote.sh 192.168.1.100
```

Or with custom port:
```bash
sudo bash setup-nginx-remote.sh 192.168.1.100 8080
```

### 2. Start Your Application

The application should be running on port 5000:
```bash
kayo-script-gen
```

### 3. Access Your Application

**Local Access:**
```
http://localhost:5000
```

**Remote Access (via Nginx on port 8080):**
```
http://your-ip-or-domain:8080
```

**O11V4 Panel (still on port 80):**
```
http://your-ip-or-domain:80
```

---

## Configuration

### Nginx Config File Location
```
/etc/nginx/sites-available/kayo-script-gen
```

### Port Configuration

The script uses these ports by default:

| Port | Service | Notes |
|------|---------|-------|
| 5000 | Kayo Script Generator (local) | Application runs here |
| 8080 | Nginx Reverse Proxy | External/remote access |
| 80 | O11V4 Panel / Other Services | Kept free for other applications |

### Change External Port

If you want to use a different port instead of 8080:

```bash
sudo bash setup-nginx-remote.sh your-domain.com 9000
```

This will use port 9000 instead of 8080.

### Edit Configuration
```bash
sudo nano /etc/nginx/sites-available/kayo-script-gen
```

### View Current Port Settings

Look for these lines in the nginx config:
```nginx
upstream kayo_app {
    server localhost:5000;
    keepalive 32;
}

server {
    listen 8080;        # External port
    listen [::]:8080;
    server_name $DOMAIN_OR_IP;
}
```

### Common Customizations

**Change the local port (if app runs on different port):**
```nginx
upstream kayo_app {
    server localhost:5001;  # Change to your port
    keepalive 32;
}
```

**Allow only specific IPs:**
```nginx
location / {
    allow 192.168.1.0/24;
    deny all;
    proxy_pass http://kayo_app;
    # ... rest of config
}
```

**Add rate limiting:**
```nginx
limit_req_zone $binary_remote_addr zone=general:10m rate=10r/s;

location / {
    limit_req zone=general burst=20 nodelay;
    proxy_pass http://kayo_app;
    # ... rest of config
}
```

---

## Useful Commands

### Status and Control
```bash
# Check if running
sudo systemctl status nginx

# Start Nginx
sudo systemctl start nginx

# Stop Nginx
sudo systemctl stop nginx

# Restart Nginx
sudo systemctl restart nginx

# Reload (graceful - no dropped connections)
sudo systemctl reload nginx

# Enable on boot
sudo systemctl enable nginx

# Disable on boot
sudo systemctl disable nginx
```

### Logs and Debugging
```bash
# View access logs (real-time)
sudo tail -f /var/log/nginx/kayo-script-gen.access.log

# View error logs (real-time)
sudo tail -f /var/log/nginx/kayo-script-gen.error.log

# View all access logs
sudo cat /var/log/nginx/kayo-script-gen.access.log

# Test configuration
sudo nginx -t

# Full config syntax test
sudo nginx -T
```

### Managing Certificates
```bash
# List certificates
sudo ls -la /etc/letsencrypt/live/

# Renew certificate manually
sudo certbot renew

# Auto-renew check
sudo certbot renew --dry-run

# View certificate info
sudo openssl x509 -text -noout -in /etc/letsencrypt/live/your-domain.com/fullchain.pem
```

---

## Troubleshooting

### Port Already in Use
```bash
# Find what's using port 80/443
sudo lsof -i :80
sudo lsof -i :443

# Kill the process
sudo kill -9 <PID>
```

### Nginx Won't Start
```bash
# Test configuration
sudo nginx -t

# View detailed errors
sudo journalctl -u nginx -n 50

# Check error logs
sudo tail -20 /var/log/nginx/kayo-script-gen.error.log
```

### Can't Connect Remotely
```bash
# Check firewall
sudo ufw status
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Check if app is running
ps aux | grep kayo-script-gen

# Check if app is listening on port 5000
sudo netstat -tlnp | grep 5000
```

### SSL Certificate Issues
```bash
# View certificate details
sudo openssl x509 -text -noout -in /path/to/cert.pem

# Check certificate expiry
sudo openssl x509 -enddate -noout -in /path/to/cert.pem

# Renew Let's Encrypt certificate
sudo certbot renew
```

### Proxy Not Working
```bash
# Verify upstream is accessible
curl http://localhost:5000

# Check Nginx configuration
sudo nginx -T

# Verify socket permissions
sudo ls -la /var/run/nginx.sock
```

---

## Security Best Practices

1. **Always use HTTPS**
   - Use Let's Encrypt for valid certificates
   - Never disable SSL in production

2. **Keep Nginx Updated**
   ```bash
   sudo apt-get update
   sudo apt-get upgrade nginx
   ```

3. **Use Strong Passwords**
   - For any authentication in your app

4. **Enable Firewalls**
   ```bash
   sudo ufw default deny incoming
   sudo ufw allow ssh
   sudo ufw allow http
   sudo ufw allow https
   sudo ufw enable
   ```

5. **Monitor Logs**
   ```bash
   sudo tail -f /var/log/nginx/kayo-script-gen.access.log
   sudo tail -f /var/log/nginx/kayo-script-gen.error.log
   ```

6. **Rate Limiting**
   - Already configured in the script for DDoS protection

---

## Advanced: Multiple Domains

To serve on multiple domains:

```bash
# Create another config
sudo nano /etc/nginx/sites-available/kayo-script-gen-alt

# Enable it
sudo ln -s /etc/nginx/sites-available/kayo-script-gen-alt /etc/nginx/sites-enabled/

# Test and reload
sudo nginx -t
sudo systemctl reload nginx
```

---

## Advanced: Docker Container

If running in Docker:

```nginx
upstream kayo_app {
    server kayo-app-container:5000;  # Docker service name
    keepalive 32;
}
```

Then restart Nginx:
```bash
sudo systemctl reload nginx
```

---

## Uninstalling

To remove Nginx:

```bash
# Stop Nginx
sudo systemctl stop nginx

# Remove Nginx
sudo apt-get remove nginx

# Remove Nginx configs
sudo apt-get purge nginx

# Remove dependencies
sudo apt-get autoremove
```

---

## Support & Logs

**When getting help, provide:**

1. Output of `sudo nginx -t`
2. Contents of `/var/log/nginx/kayo-script-gen.error.log`
3. Your OS and Nginx version
4. Network/firewall setup details

**Check version:**
```bash
nginx -v
```

---

## Next Steps

1. ✅ Run the setup script
2. ✅ Install SSL certificate
3. ✅ Start your application
4. ✅ Access remotely via HTTPS
5. ✅ Monitor logs regularly

---

## Related Files

- **Setup Script**: `setup-nginx-remote.sh`
- **Installation Guide**: `install-ubuntu.sh`
- **Quick Start**: `GITHUB_QUICK_START.txt`
- **Main README**: `README.md`
