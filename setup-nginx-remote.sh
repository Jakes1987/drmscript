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
EXTERNAL_PORT="${2:-8080}"
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
# Local app is on port $LOCAL_PORT
# External access is on port $EXTERNAL_PORT
# Port 80 remains free for O11V4 panel

upstream kayo_app {
    server localhost:$LOCAL_PORT;
    keepalive 32;
}

# Main HTTP configuration (on port $EXTERNAL_PORT to avoid conflict with O11V4 on port 80)
server {
    listen $EXTERNAL_PORT;
    listen [::]:$EXTERNAL_PORT;
    server_name $DOMAIN_OR_IP;

    # Logging
    access_log /var/log/nginx/kayo-script-gen.access.log;
    error_log /var/log/nginx/kayo-script-gen.error.log;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;

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

echo -e "${BLUE}Remote Access Configuration:${NC}"
echo ""
echo -e "${YELLOW}Port Configuration:${NC}"
echo "  Local Application Port:    $LOCAL_PORT (Kayo Script Generator)"
echo "  External Nginx Port:       $EXTERNAL_PORT (Remote access)"
echo "  Port 80:                   Available for O11V4 panel"
echo ""

echo -e "${BLUE}Remote Access URLs:${NC}"
echo ""
echo -e "${YELLOW}Local Access (same network):${NC}"
echo "  http://localhost:$LOCAL_PORT"
echo ""
echo -e "${YELLOW}Remote Access (via Nginx):${NC}"
echo "  http://$DOMAIN_OR_IP:$EXTERNAL_PORT"
echo ""
echo -e "${YELLOW}O11V4 Panel Access:${NC}"
echo "  http://$DOMAIN_OR_IP:80"
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

echo -e "${BLUE}Port Status:${NC}"
echo ""
echo "  Check which ports are in use:"
echo "    sudo ss -tlnp | grep LISTEN"
echo ""

echo -e "${BLUE}Ensure Application is Running:${NC}"
echo ""
echo "The local web server must be running on port $LOCAL_PORT:"
echo "  kayo-script-gen"
echo ""
echo "Or specify port:"
echo "  kayo-script-gen --port $LOCAL_PORT"
echo ""

echo "════════════════════════════════════════════════════════════"
