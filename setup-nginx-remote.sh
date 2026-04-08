#!/bin/bash

# Kayo Script Generator - Nginx Remote Access Setup
# This script configures Nginx as a reverse proxy for remote GUI access
# Compatible with Ubuntu/Debian systems

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
LOCAL_PORT=5000
NGINX_CONF="/etc/nginx/sites-available/kayo-script-gen"
NGINX_ENABLED="/etc/nginx/sites-enabled/kayo-script-gen"
DOMAIN_OR_IP="${1:-}"

echo -e "${BLUE}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                                                    ║${NC}"
echo -e "${BLUE}║  Kayo Script Gen - Nginx Remote Access Setup      ║${NC}"
echo -e "${BLUE}║                                                    ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Error: This script must be run as root (use sudo)${NC}"
    exit 1
fi

# Check OS compatibility
if ! [ -f /etc/os-release ]; then
    echo -e "${RED}Error: This installer requires a Debian/Ubuntu-based Linux distribution${NC}"
    exit 1
fi

# Get IP address if not provided
if [ -z "$DOMAIN_OR_IP" ]; then
    echo -e "${BLUE}Step 1: Detecting network configuration...${NC}"
    echo ""
    
    # Try to get primary IP
    PRIMARY_IP=$(hostname -I | awk '{print $1}')
    
    if [ -z "$PRIMARY_IP" ]; then
        PRIMARY_IP="127.0.0.1"
    fi
    
    echo -e "${YELLOW}Detected IP: $PRIMARY_IP${NC}"
    echo ""
    echo -e "${YELLOW}Enter your domain name or IP address for remote access:${NC}"
    echo -e "${YELLOW}(Examples: example.com, 192.168.1.100, server.example.com)${NC}"
    read -p "Domain/IP: " DOMAIN_OR_IP
    
    if [ -z "$DOMAIN_OR_IP" ]; then
        DOMAIN_OR_IP="$PRIMARY_IP"
        echo -e "${YELLOW}Using detected IP: $DOMAIN_OR_IP${NC}"
    fi
fi

echo -e "${BLUE}Step 2: Checking dependencies...${NC}"

# Check and install Nginx
if ! command -v nginx &> /dev/null; then
    echo -e "${YELLOW}  ! Nginx not found, installing...${NC}"
    apt-get update
    apt-get install -y nginx
    echo -e "${GREEN}  ✓ Nginx installed${NC}"
else
    echo -e "${GREEN}  ✓ Nginx found${NC}"
fi

echo ""
echo -e "${BLUE}Step 3: Configuring Nginx reverse proxy...${NC}"

# Backup existing config if it exists
if [ -f "$NGINX_CONF" ]; then
    cp "$NGINX_CONF" "$NGINX_CONF.backup.$(date +%s)"
    echo -e "${GREEN}  ✓ Backup created${NC}"
fi

# Create Nginx configuration
cat > "$NGINX_CONF" << EOF
# Nginx Reverse Proxy Configuration for Kayo Script Generator
# Auto-generated on $(date)

upstream kayo_app {
    server localhost:$LOCAL_PORT;
    keepalive 32;
}

# Redirect HTTP to HTTPS (if SSL is enabled)
server {
    listen 80;
    listen [::]:80;
    server_name $DOMAIN_OR_IP;

    # Allow Let's Encrypt verification
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    # Redirect everything else to HTTPS
    location / {
        return 301 https://\$server_name\$request_uri;
    }
}

# Main HTTPS configuration
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name $DOMAIN_OR_IP;

    # SSL Certificate paths (update after obtaining certificate)
    ssl_certificate /etc/letsencrypt/live/$DOMAIN_OR_IP/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN_OR_IP/privkey.pem;

    # SSL Security
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;

    # Logging
    access_log /var/log/nginx/kayo-script-gen.access.log;
    error_log /var/log/nginx/kayo-script-gen.error.log;

    # Proxy configuration
    location / {
        proxy_pass http://kayo_app;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_buffering off;
    }

    # WebSocket support
    location /socket.io {
        proxy_pass http://kayo_app/socket.io;
        proxy_http_version 1.1;
        proxy_buffering off;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }

    # Static files caching
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    # Disable access to hidden files
    location ~ /\. {
        deny all;
    }
}
EOF

echo -e "${GREEN}  ✓ Nginx configuration created${NC}"

echo ""
echo -e "${BLUE}Step 4: Enabling Nginx site...${NC}"

# Enable the site
if [ ! -L "$NGINX_ENABLED" ]; then
    ln -s "$NGINX_CONF" "$NGINX_ENABLED"
    echo -e "${GREEN}  ✓ Site enabled${NC}"
else
    echo -e "${GREEN}  ✓ Site already enabled${NC}"
fi

echo ""
echo -e "${BLUE}Step 5: Testing Nginx configuration...${NC}"

# Test configuration
if nginx -t 2>&1 | grep -q "successful"; then
    echo -e "${GREEN}  ✓ Configuration test passed${NC}"
else
    echo -e "${RED}  ✗ Configuration test failed${NC}"
    nginx -t
    exit 1
fi

echo ""
echo -e "${BLUE}Step 6: Reloading Nginx...${NC}"

# Reload Nginx
systemctl reload nginx

echo -e "${GREEN}  ✓ Nginx reloaded${NC}"

# Check if running
if systemctl is-active --quiet nginx; then
    echo -e "${GREEN}  ✓ Nginx is running${NC}"
else
    echo -e "${YELLOW}  ! Starting Nginx...${NC}"
    systemctl start nginx
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║         ✓ Nginx Setup Complete!                  ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${BLUE}IMPORTANT - SSL Certificate Setup:${NC}"
echo ""
echo "Your Nginx proxy is configured but needs an SSL certificate."
echo "Choose one of the following options:"
echo ""
echo -e "${YELLOW}Option 1: Use Let's Encrypt (FREE - Recommended)${NC}"
echo "Run:"
echo "  sudo apt-get install -y certbot python3-certbot-nginx"
echo "  sudo certbot certonly --webroot -w /var/www/certbot -d $DOMAIN_OR_IP"
echo ""
echo "Then update the SSL paths in: $NGINX_CONF"
echo ""

echo -e "${YELLOW}Option 2: Use Self-Signed Certificate (Testing Only)${NC}"
echo "Run:"
echo "  sudo mkdir -p /etc/nginx/ssl"
echo "  sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \\"
echo "    -keyout /etc/nginx/ssl/kayo-key.key \\"
echo "    -out /etc/nginx/ssl/kayo-cert.crt"
echo ""
echo "Then update $NGINX_CONF with:"
echo "  ssl_certificate /etc/nginx/ssl/kayo-cert.crt;"
echo "  ssl_certificate_key /etc/nginx/ssl/kayo-key.key;"
echo ""
echo "Then reload: sudo systemctl reload nginx"
echo ""

echo -e "${BLUE}Remote Access URLs:${NC}"
echo ""
echo -e "${YELLOW}After SSL is set up:${NC}"
echo "  https://$DOMAIN_OR_IP"
echo ""

echo -e "${BLUE}Useful Commands:${NC}"
echo ""
echo "  Check Nginx status:        sudo systemctl status nginx"
echo "  Restart Nginx:             sudo systemctl restart nginx"
echo "  Reload Nginx:              sudo systemctl reload nginx"
echo "  Stop Nginx:                sudo systemctl stop nginx"
echo "  View access logs:          sudo tail -f /var/log/nginx/kayo-script-gen.access.log"
echo "  View error logs:           sudo tail -f /var/log/nginx/kayo-script-gen.error.log"
echo "  Test configuration:        sudo nginx -t"
echo "  Edit configuration:        sudo nano $NGINX_CONF"
echo ""

echo -e "${BLUE}Ensure Application is Running:${NC}"
echo ""
echo "The local web server must be running on port $LOCAL_PORT"
echo "Start with: kayo-script-gen"
echo ""

echo "════════════════════════════════════════════════════════════"
