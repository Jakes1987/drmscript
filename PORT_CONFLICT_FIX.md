# Nginx Port Conflict Troubleshooting

## Problem: `Address already in use`

```
nginx: [emerg] bind() to 0.0.0.0:8080 failed (98: Address already in use)
```

This means something else is already listening on port 8080.

---

## Quick Fix

### Option 1: Use the Automatic Fixer (Easiest)

```bash
# Download and run the port conflict resolver
sudo bash <(curl -fsSL https://raw.githubusercontent.com/Jakes1987/drmscript/main/fix-port-conflict.sh)

# Or specify a custom port
sudo bash <(curl -fsSL https://raw.githubusercontent.com/Jakes1987/drmscript/main/fix-port-conflict.sh) 8080
```

The script will:
- ✅ Identify what's using port 8080
- ✅ Offer to kill the process, change port, or stop a service
- ✅ Automatically reconfigure Nginx
- ✅ Start Nginx

---

## Option 2: Manual Fixes

### 2A. Find What's Using Port 8080

```bash
# See what's listening on port 8080
sudo netstat -tlnp | grep 8080

# Or use ss (more modern)
sudo ss -tlnp | grep 8080

# Output example:
# tcp  0  0 0.0.0.0:8080  0.0.0.0:*  LISTEN  40824/nginx
```

The output shows the process ID and name using the port.

### 2B. Kill the Process

```bash
# Get the PID from command above (example: 40824)
sudo kill -9 40824

# Or kill by name
sudo pkill -f nginx
sudo pkill -f java  # if Java app is using it
sudo pkill -f node  # if Node.js app is using it

# Then start Nginx
sudo systemctl start nginx
```

### 2C. Use a Different Port

If you want to change Nginx to port 8081 instead:

```bash
# Edit the configuration
sudo nano /etc/nginx/sites-available/kayo-script-gen

# Find these lines and change 8080 to 8081:
# listen 8081;
# listen [::]:8081;

# Save and exit (Ctrl+X, then Y, then Enter)

# Test the configuration
sudo nginx -t

# If OK, restart Nginx
sudo systemctl restart nginx

# Access your app at:
# http://your-ip:8081
```

### 2D. Check Why Nginx Crashed

```bash
# View Nginx error log
sudo tail -20 /var/log/nginx/error.log

# View detailed status
sudo systemctl status nginx -l

# Try to start manually to see errors
sudo nginx -g 'daemon on;'
```

---

## Common Causes

### 1. Port Already In Use (Most Common)

```bash
# find what's using it
sudo lsof -i :8080

# Kill the process
sudo kill -9 <PID>
```

### 2. Nginx Already Running

```bash
# Check if nginx is running
sudo systemctl is-active nginx

# List all nginx processes
ps aux | grep nginx

# Stop and restart
sudo systemctl stop nginx
sudo systemctl start nginx
```

### 3. Previous Nginx Process Didn't Stop

```bash
# Kill all nginx processes
sudo pkill -9 nginx

# Wait a moment
sleep 2

# Start fresh
sudo systemctl start nginx
```

### 4. Docker Container or Other Service Using Port

```bash
# Find what's listening
sudo lsof -i:8080

# Common culprits:
docker ps  # Check Docker containers
sudo systemctl list-units --type=service  # List all services
```

---

## Port Management

### Check All Listening Ports

```bash
# See everything listening
sudo ss -tlnp

# Or with netstat
sudo netstat -tlnp
```

### Available Ports to Use

Instead of 8080, try:
- **8081** - next logical choice
- **9000** - common alternative
- **3000** - Node.js default
- **5001** - if 5000 is taken
- **9090** - Web admin common port

### Change Nginx Port Permanently

```bash
# Edit config
sudo nano /etc/nginx/sites-available/kayo-script-gen

# Change:
# listen 8080;
# listen [::]:8080;

# To:
# listen 9000;
# listen [::]:9000;

# Test
sudo nginx -t

# Reload
sudo systemctl reload nginx
```

---

## Step-by-Step: Port Conflict Resolution

### If Nginx won't start:

```bash
# 1. Check if port is free
sudo netstat -tlnp | grep 8080

# 2. If something is using it, identify it
sudo lsof -i:8080

# 3. Option A: Kill the process
sudo kill -9 <PID>

# 3. Option B: Use different port
sudo sed -i 's/:8080/:8081/g' /etc/nginx/sites-available/kayo-script-gen

# 4. Test nginx
sudo nginx -t

# 5. Start nginx
sudo systemctl start nginx

# 6. Verify
sudo systemctl status nginx
```

---

## Full Debug Checklist

```bash
# 1. Check port status
sudo ss -tlnp | grep 8080

# 2. Check nginx config
sudo nginx -t

# 3. View all nginx processes
ps aux | grep nginx

# 4. Check nginx error log
sudo tail -50 /var/log/nginx/error.log

# 5. Check system logs
sudo journalctl -u nginx -n 30

# 6. Check firewall
sudo ufw status

# 7. Check if nginx is enabled
sudo systemctl is-enabled nginx

# 8. Full nginx status
sudo systemctl status nginx -l

# 9. Start with verbose output
sudo nginx -g 'daemon off;'  # Run in foreground (Ctrl+C to stop)

# 10. Check all listening ports
sudo netstat -tlnp
```

---

## Nginx Service Commands

```bash
# Start
sudo systemctl start nginx

# Stop
sudo systemctl stop nginx

# Restart (full stop/start)
sudo systemctl restart nginx

# Reload (graceful restart, no dropped connections)
sudo systemctl reload nginx

# Status
sudo systemctl status nginx

# Enable on boot
sudo systemctl enable nginx

# Disable on boot
sudo systemctl disable nginx

# Check if active
sudo systemctl is-active nginx

# Check if enabled
sudo systemctl is-enabled nginx
```

---

## Testing After Fix

Once you fix the port conflict:

```bash
# 1. Verify Nginx is running
sudo systemctl status nginx

# 2. Check it's listening on the port
sudo ss -tlnp | grep nginx

# 3. Test locally
curl http://localhost:8080  # or your port

# 4. Test from another machine
curl http://your-ip:8080

# 5. Check in browser
http://your-ip:8080
```

---

## If Still Not Working

### Run the automatic fixer:

```bash
sudo bash fix-port-conflict.sh
```

### Or collect debug info:

```bash
# Create log file
{
  echo "=== System Info ==="
  uname -a
  
  echo "=== Nginx Version ==="
  nginx -v
  
  echo "=== Port Status ==="
  sudo ss -tlnp
  
  echo "=== Nginx Config Test ==="
  sudo nginx -t
  
  echo "=== Nginx Error Log ==="
  sudo tail -30 /var/log/nginx/error.log
  
  echo "=== Systemd Journal ==="
  sudo journalctl -u nginx -n 30
  
  echo "=== Nginx Processes ==="
  ps aux | grep nginx
  
} > nginx-debug.log

# Share debug.log for support
cat nginx-debug.log
```

---

## Prevention

### Check port before new installs:

```bash
# Before installing Nginx, check port
sudo ss -tlnp | grep 8080

# If free, proceed with installation
sudo bash setup-nginx-remote.sh
```

### Use different ports for different services:

```
Service              Port
===================  =====
O11V4 Panel          80
Kayo App (local)     5000
Kayo App (remote)    8080 or 8081
Other Web App        9000
```

---

## Recommended Solution

For your setup at 157.180.122.129:

```bash
# 1. Stop whatever is using port 8080
sudo pkill -9 <process_name>

# OR 2. Change Nginx to port 8081
sudo sed -i 's/listen 8080;/listen 8081;/g' /etc/nginx/sites-available/kayo-script-gen

# 3. Test and restart
sudo nginx -t
sudo systemctl restart nginx

# 4. Access at:
# http://157.180.122.129:8080 (original)
# OR
# http://157.180.122.129:8081 (if changed)
```

Run the automatic fixer - it handles all of this! 🚀
