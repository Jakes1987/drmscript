# Nginx Remote Access Guide

## What This Script Does

The `setup-nginx-remote.sh` script configures Nginx as a reverse proxy to allow remote access to your Kayo Script Generator web GUI.

**Benefits:**
- ✅ Access your GUI from anywhere on the network or internet
- ✅ Automatic HTTP to HTTPS redirection
- ✅ SSL/TLS encryption for security
- ✅ WebSocket support for real-time updates
- ✅ Automatic caching of static files
- ✅ Security headers and protections

---

## Quick Setup

### On Ubuntu/Debian Server:

```bash
# Download and run the setup script
sudo bash <(curl -fsSL https://raw.githubusercontent.com/Jakes1987/drmscript/main/setup-nginx-remote.sh)

# Or with a domain/IP specified
sudo bash <(curl -fsSL https://raw.githubusercontent.com/Jakes1987/drmscript/main/setup-nginx-remote.sh) example.com
```

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
sudo bash setup-nginx-remote.sh your-domain.com
```

Or let it auto-detect your IP:
```bash
sudo bash setup-nginx-remote.sh
```

### 2. Install SSL Certificate

**Option A: Let's Encrypt (Recommended - FREE)**

```bash
# Install Certbot
sudo apt-get install -y certbot python3-certbot-nginx

# Get a certificate
sudo certbot certonly --webroot -w /var/www/certbot -d your-domain.com
```

**Option B: Self-Signed (Testing Only)**

```bash
# Create certificate directory
sudo mkdir -p /etc/nginx/ssl

# Generate self-signed certificate
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/kayo-key.key \
  -out /etc/nginx/ssl/kayo-cert.crt
```

Then update `/etc/nginx/sites-available/kayo-script-gen`:
```nginx
ssl_certificate /etc/nginx/ssl/kayo-cert.crt;
ssl_certificate_key /etc/nginx/ssl/kayo-key.key;
```

### 3. Reload Nginx

```bash
sudo systemctl reload nginx
```

### 4. Start Your Application

```bash
# Make sure the app is running on port 5000
kayo-script-gen
```

---

## Accessing Your GUI Remotely

Once everything is set up:

1. **Locally (same network):**
   ```
   https://your-ip-or-domain
   ```

2. **Remotely (from anywhere):**
   ```
   https://your-ip-or-domain
   ```

3. **From another machine on network:**
   ```
   https://192.168.x.x:443
   ```

---

## Configuration

### Nginx Config File Location
```
/etc/nginx/sites-available/kayo-script-gen
```

### Edit Configuration
```bash
sudo nano /etc/nginx/sites-available/kayo-script-gen
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
