#!/bin/bash

# Kayo Script Generator - Nginx SSL Certificate Fix
# This script helps resolve SSL certificate issues

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

DOMAIN="${1:-}"

echo -e "${BLUE}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                                                    ║${NC}"
echo -e "${BLUE}║  Nginx SSL Certificate Setup & Fix                ║${NC}"
echo -e "${BLUE}║                                                    ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Error: This script must be run as root (use sudo)${NC}"
    exit 1
fi

# Get domain if not provided
if [ -z "$DOMAIN" ]; then
    echo -e "${YELLOW}Enter your domain or IP address:${NC}"
    read -p "Domain/IP: " DOMAIN
    
    if [ -z "$DOMAIN" ]; then
        echo -e "${RED}Error: Domain/IP cannot be empty${NC}"
        exit 1
    fi
fi

NGINX_CONF="/etc/nginx/sites-available/kayo-script-gen"

echo -e "${BLUE}Current domain: $DOMAIN${NC}"
echo ""

# Check what already exists
if [ -d "/etc/letsencrypt/live/$DOMAIN" ]; then
    echo -e "${GREEN}✓ Let's Encrypt certificate found for $DOMAIN${NC}"
    echo ""
    echo "Certificate details:"
    openssl x509 -text -noout -in "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" | grep -A 2 "Not Before\|Not After" | grep -v "^--"
    echo ""
    echo "The certificate path in nginx is correct."
    echo "Run: sudo systemctl restart nginx"
    exit 0
fi

if [ -f "/etc/nginx/ssl/kayo-cert.crt" ]; then
    echo -e "${GREEN}✓ Self-signed certificate found${NC}"
    echo ""
    echo "Update nginx config to use self-signed cert:"
    echo "  ssl_certificate /etc/nginx/ssl/kayo-cert.crt;"
    echo "  ssl_certificate_key /etc/nginx/ssl/kayo-key.key;"
    echo ""
    echo "Then run: sudo systemctl restart nginx"
    exit 0
fi

# No certificates found - offer options
echo -e "${YELLOW}No SSL certificate found for $DOMAIN${NC}"
echo ""
echo "Choose an option:"
echo ""
echo "1) Get FREE certificate from Let's Encrypt"
echo "2) Create self-signed certificate (testing only)"
echo "3) Temporarily use HTTP only (no HTTPS)"
echo ""
read -p "Option (1/2/3): " choice

case $choice in
    1)
        echo ""
        echo -e "${BLUE}Installing Certbot for Let's Encrypt...${NC}"
        
        # Install certbot
        if ! command -v certbot &> /dev/null; then
            apt-get update
            apt-get install -y certbot python3-certbot-nginx
            echo -e "${GREEN}✓ Certbot installed${NC}"
        fi
        
        echo ""
        echo -e "${BLUE}Creating certificate for $DOMAIN...${NC}"
        echo ""
        echo "You will need to:"
        echo "1. Verify you own the domain (email confirmation)"
        echo "2. Make sure port 80 is open"
        echo ""
        echo "For IP addresses without a domain, use certbot with manual mode:"
        echo ""
        echo "  sudo certbot certonly --manual -d $DOMAIN"
        echo ""
        
        read -p "Continue? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Cancelled"
            exit 1
        fi
        
        # Try to get certificate
        if certbot certonly --webroot -w /var/www/certbot -d "$DOMAIN" 2>/dev/null; then
            echo -e "${GREEN}✓ Certificate obtained successfully!${NC}"
            echo ""
            echo "Certificate location:"
            echo "  /etc/letsencrypt/live/$DOMAIN/fullchain.pem"
            echo "  /etc/letsencrypt/live/$DOMAIN/privkey.pem"
            echo ""
            echo "Nginx config will use: /etc/letsencrypt/live/$DOMAIN/"
            echo ""
            echo -e "${BLUE}Testing nginx configuration...${NC}"
            if nginx -t; then
                echo -e "${GREEN}✓ Configuration test passed${NC}"
                echo ""
                echo "Restart nginx:"
                echo "  sudo systemctl restart nginx"
            else
                echo -e "${RED}✗ Configuration test failed${NC}"
                echo "Check: sudo nginx -t"
                exit 1
            fi
        else
            echo -e "${YELLOW}! Certbot failed. Try manual mode:${NC}"
            echo ""
            echo "  sudo certbot certonly --manual -d $DOMAIN"
            exit 1
        fi
        ;;
        
    2)
        echo ""
        echo -e "${BLUE}Creating self-signed certificate...${NC}"
        
        # Create directory
        mkdir -p /etc/nginx/ssl
        
        # Generate certificate
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
            -keyout /etc/nginx/ssl/kayo-key.key \
            -out /etc/nginx/ssl/kayo-cert.crt \
            -subj "/C=US/ST=State/L=City/O=Organization/CN=$DOMAIN"
        
        echo -e "${GREEN}✓ Self-signed certificate created${NC}"
        echo ""
        echo -e "${YELLOW}WARNING: Self-signed certificates will show browser warnings!${NC}"
        echo "Use only for testing. For production, get a free Let's Encrypt certificate."
        echo ""
        
        # Backup current config
        if [ -f "$NGINX_CONF" ]; then
            cp "$NGINX_CONF" "$NGINX_CONF.backup.$(date +%s)"
        fi
        
        # Update nginx config
        echo -e "${BLUE}Updating nginx configuration...${NC}"
        
        sed -i "s|ssl_certificate /etc/letsencrypt/live/.*fullchain.pem;|ssl_certificate /etc/nginx/ssl/kayo-cert.crt;|g" "$NGINX_CONF"
        sed -i "s|ssl_certificate_key /etc/letsencrypt/live/.*privkey.pem;|ssl_certificate_key /etc/nginx/ssl/kayo-key.key;|g" "$NGINX_CONF"
        
        echo -e "${GREEN}✓ Configuration updated${NC}"
        echo ""
        
        echo -e "${BLUE}Testing nginx configuration...${NC}"
        if nginx -t; then
            echo -e "${GREEN}✓ Configuration test passed${NC}"
            echo ""
            echo "Restart nginx:"
            echo "  sudo systemctl restart nginx"
        else
            echo -e "${RED}✗ Configuration test failed${NC}"
            echo "Restore backup:"
            echo "  sudo cp $NGINX_CONF.backup.* $NGINX_CONF"
            exit 1
        fi
        ;;
        
    3)
        echo ""
        echo -e "${BLUE}Disabling HTTPS (HTTP only)...${NC}"
        echo -e "${YELLOW}WARNING: This is insecure! Only for testing.${NC}"
        echo ""
        
        # Backup config
        cp "$NGINX_CONF" "$NGINX_CONF.backup.$(date +%s)"
        
        # Create temporary HTTP-only config
        cat > "$NGINX_CONF" << 'EOF'
# Temporary HTTP-only configuration
# This is insecure - add HTTPS before production use!

upstream kayo_app {
    server localhost:5000;
    keepalive 32;
}

server {
    listen 80;
    listen [::]:80;
    server_name _;

    # Logging
    access_log /var/log/nginx/kayo-script-gen.access.log;
    error_log /var/log/nginx/kayo-script-gen.error.log;

    # Proxy configuration
    location / {
        proxy_pass http://kayo_app;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_buffering off;
    }

    # WebSocket support
    location /socket.io {
        proxy_pass http://kayo_app/socket.io;
        proxy_http_version 1.1;
        proxy_buffering off;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF
        
        echo -e "${GREEN}✓ Configuration updated to HTTP only${NC}"
        echo ""
        
        echo -e "${BLUE}Testing nginx configuration...${NC}"
        if nginx -t; then
            echo -e "${GREEN}✓ Configuration test passed${NC}"
            echo ""
            echo "Restart nginx:"
            echo "  sudo systemctl restart nginx"
        else
            echo -e "${RED}✗ Configuration test failed${NC}"
            exit 1
        fi
        
        echo ""
        echo -e "${YELLOW}REMEMBER: Set up HTTPS before using in production!${NC}"
        echo ""
        echo "To add HTTPS later:"
        echo "  sudo bash <(curl -fsSL https://raw.githubusercontent.com/Jakes1987/drmscript/main/fix-nginx-ssl.sh)"
        ;;
        
    *)
        echo "Invalid option"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✓ Setup Complete!                               ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════╝${NC}"
echo ""

if [ $choice -ne 3 ]; then
    echo -e "${BLUE}Next:${NC}"
    echo ""
    echo "1. Restart nginx:"
    echo "   sudo systemctl restart nginx"
    echo ""
    echo "2. Start your application:"
    echo "   kayo-script-gen"
    echo ""
    echo "3. Access:"
    if [ $choice -eq 1 ]; then
        echo "   https://$DOMAIN"
    else
        echo "   https://$DOMAIN (with browser warning)"
    fi
else
    echo -e "${BLUE}Next:${NC}"
    echo ""
    echo "1. Restart nginx:"
    echo "   sudo systemctl restart nginx"
    echo ""
    echo "2. Start your application:"
    echo "   kayo-script-gen"
    echo ""
    echo "3. Access (HTTP only - insecure!):"
    echo "   http://$DOMAIN"
fi

echo ""
