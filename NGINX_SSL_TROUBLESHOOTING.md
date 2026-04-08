# Nginx SSL Certificate Troubleshooting Guide

## Problem: "Cannot load certificate... No such file or directory"

This error means Nginx is configured to use an SSL certificate that doesn't exist yet.

### Quick Fix

```bash
# Download and run the SSL fix script
sudo bash <(curl -fsSL https://raw.githubusercontent.com/Jakes1987/drmscript/main/fix-nginx-ssl.sh)

# Or specify your domain
sudo bash <(curl -fsSL https://raw.githubusercontent.com/Jakes1987/drmscript/main/fix-nginx-ssl.sh) your-domain.com
```

The script will:
1. Check if certificates exist
2. Offer to get a free Let's Encrypt certificate
3. Or create a self-signed certificate for testing
4. Or temporarily use HTTP only

---

## Option 1: Get Free Let's Encrypt Certificate (Recommended)

```bash
# Run the fix script
sudo bash fix-nginx-ssl.sh

# Choose option 1 when prompted
```

**Requirements:**
- Domain name (not IP address)
- Port 80 must be open
- Email for Let's Encrypt

**Result:**
- Certificate at: `/etc/letsencrypt/live/your-domain.com/`
- Auto-renewal enabled
- Valid for 90 days

---

## Option 2: Self-Signed Certificate (Testing Only)

```bash
# Run the fix script
sudo bash fix-nginx-ssl.sh

# Choose option 2 when prompted
```

**What it does:**
- Creates certificate at: `/etc/nginx/ssl/kayo-cert.crt`
- Updates Nginx config automatically
- Browser will show warning (normal for self-signed)

**Use only for:**
- Testing
- Internal networks
- Development

---

## Option 3: Temporary HTTP Only (Not Recommended)

```bash
# Run the fix script
sudo bash fix-nginx-ssl.sh

# Choose option 3 when prompted
```

**What it does:**
- Disables HTTPS temporarily
- Site accessible on port 80 (HTTP)
- Not secure! ⚠️

**When to use:**
- Quickly test installation
- Will add HTTPS later

---

## Manual Certificate Setup

### If Let's Encrypt Failed

```bash
# Install certbot
sudo apt-get install -y certbot python3-certbot-nginx

# Try again - this will prompt you
sudo certbot certonly --webroot -w /var/www/certbot -d your-domain.com
```

### If using IP address (not domain)

Let's Encrypt doesn't work with IP addresses. Use self-signed:

```bash
sudo bash fix-nginx-ssl.sh your-ip-address
# Choose option 2 (self-signed)
```

### Manual Self-Signed Certificate

```bash
# Create directory
sudo mkdir -p /etc/nginx/ssl

# Generate certificate (replace example.com with your domain)
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/kayo-key.key \
  -out /etc/nginx/ssl/kayo-cert.crt \
  -subj "/C=US/ST=State/L=City/O=Organization/CN=example.com"

# Update nginx config
sudo nano /etc/nginx/sites-available/kayo-script-gen
```

Find and update these lines:
```nginx
ssl_certificate /etc/nginx/ssl/kayo-cert.crt;
ssl_certificate_key /etc/nginx/ssl/kayo-key.key;
```

Then restart Nginx:
```bash
sudo systemctl restart nginx
```

---

## After Getting a Certificate

### Test Nginx Configuration

```bash
sudo nginx -t
```

Should show: `configuration file test is successful`

### Restart Nginx

```bash
sudo systemctl restart nginx
```

### Verify Certificate is Working

```bash
# Check certificate details
sudo openssl x509 -text -noout -in /path/to/cert.pem

# Check expiry date
sudo openssl x509 -enddate -noout -in /path/to/cert.pem

# Test HTTPS connection
curl -k https://your-domain.com  # -k ignores certificate warnings
```

---

## Certificate Renewal

### Let's Encrypt Certificates (Auto-Renewal)

```bash
# Check renewal is working
sudo certbot renew --dry-run

# Manual renewal if needed
sudo certbot renew
```

### Check When Certificates Expire

```bash
# Check all certificates
sudo certbot certificates

# Check specific certificate
sudo openssl x509 -enddate -noout -in /etc/letsencrypt/live/your-domain.com/fullchain.pem
```

---

## Common Issues & Fixes

### Issue: Port 80/443 Already in Use

```bash
# Find what's using the port
sudo lsof -i :80
sudo lsof -i :443

# Kill the process
sudo kill -9 <PID>

# Try certbot again
sudo certbot certonly --webroot -w /var/www/certbot -d your-domain.com
```

### Issue: Domain Not Found

```bash
# Verify DNS is pointing to your server
nslookup your-domain.com

# Should show your server IP
```

### Issue: Cannot Verify Ownership

```bash
# Make sure .well-known directory is writable
sudo mkdir -p /var/www/certbot/.well-known/acme-challenge
sudo chmod -R 755 /var/www/certbot

# Try again
sudo certbot certonly --webroot -w /var/www/certbot -d your-domain.com
```

### Issue: "Renewal Impossible" Error

```bash
# Force renewal
sudo certbot renew --force-renewal

# Or get new certificate
sudo certbot certonly --webroot -w /var/www/certbot -d your-domain.com --force-renewal
```

---

## Troubleshooting Commands

```bash
# View Nginx error log
sudo tail -20 /var/log/nginx/kayo-script-gen.error.log

# Full error details
sudo journalctl -u nginx -n 50

# Test configuration
sudo nginx -t

# Full configuration test
sudo nginx -T

# Restart Nginx
sudo systemctl restart nginx

# Stop Nginx
sudo systemctl stop nginx

# Start Nginx
sudo systemctl start nginx

# View services status
sudo systemctl status nginx

# View Nginx version
nginx -v

# List certificates
sudo ls -la /etc/letsencrypt/live/

# View certificate details
sudo cat /etc/nginx/sites-available/kayo-script-gen
```

---

## Getting Help

### Collect Information

When asking for help, provide:

```bash
# Nginx version and config
nginx -v
sudo nginx -T

# Error logs
sudo tail -30 /var/log/nginx/kayo-script-gen.error.log

# Certificate info (if using Let's Encrypt)
sudo certbot certificates

# Nginx config status
sudo systemctl status nginx
```

### Common Support URLs

- Let's Encrypt Troubleshooting: https://certbot.eff.org/docs/
- Nginx Documentation: http://nginx.org/en/docs/
- Certbot Help: https://certbot.eff.org/faq/

---

## Quick Decision Tree

```
Do you have a domain name?
├─ YES
│  ├─ Get Let's Encrypt (FREE, recommended)
│  │  └─ sudo bash fix-nginx-ssl.sh your-domain.com
│  │     Choose option 1
│  │
│  └─ Use self-signed (testing)
│     └─ sudo bash fix-nginx-ssl.sh your-domain.com
│        Choose option 2
│
└─ NO (using IP address)
   ├─ Use self-signed certificate
   │  └─ sudo bash fix-nginx-ssl.sh your-ip
   │     Choose option 2
   │
   └─ Use HTTP temporarily (NOT secure)
      └─ sudo bash fix-nginx-ssl.sh
         Choose option 3
```

---

## Next Steps

1. Run the SSL fix script
2. Choose your certificate option
3. Restart Nginx: `sudo systemctl restart nginx`
4. Start app: `kayo-script-gen`
5. Access: `https://your-domain.com`

For production, always use Let's Encrypt or another trusted certificate authority.
