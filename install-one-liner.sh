#!/bin/bash

# Kayo Script Generator - Complete Remote Server Installer (One-Liner)
# This is the master installer for Ubuntu/Debian servers
# Downloads and runs the full installation without any manual steps needed
# Usage: bash <(curl -fsSL https://raw.githubusercontent.com/Jakes1987/drmscript/main/install-one-liner.sh)

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                                                    ║${NC}"
echo -e "${BLUE}║  Kayo Script Generator - Complete Installation    ║${NC}"
echo -e "${BLUE}║                                                    ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════╝${NC}"
echo ""

# Create temporary directory for scripts
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

echo -e "${BLUE}Downloading installation scripts...${NC}"

# Download both installers
curl -fsSL https://raw.githubusercontent.com/Jakes1987/drmscript/main/install-ubuntu.sh -o "$TEMP_DIR/install-ubuntu.sh"
curl -fsSL https://raw.githubusercontent.com/Jakes1987/drmscript/main/setup-nginx-remote.sh -o "$TEMP_DIR/setup-nginx-remote.sh"

chmod +x "$TEMP_DIR/install-ubuntu.sh"
chmod +x "$TEMP_DIR/setup-nginx-remote.sh"

echo -e "${GREEN}✓ Scripts downloaded${NC}"
echo ""

# Run the main installer
echo -e "${BLUE}Step 1: Installing application...${NC}"
bash "$TEMP_DIR/install-ubuntu.sh"

echo ""
echo -e "${BLUE}Step 2: Setting up Nginx reverse proxy...${NC}"

# Detect IP for Nginx setup
PRIMARY_IP=$(hostname -I | awk '{print $1}')
if [ -z "$PRIMARY_IP" ]; then
    PRIMARY_IP="127.0.0.1"
fi

echo "Detected IP: $PRIMARY_IP"
echo ""

# Run Nginx setup with detected IP
sudo bash "$TEMP_DIR/setup-nginx-remote.sh" "$PRIMARY_IP"

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✓ Installation Complete!                        ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${BLUE}NEXT STEPS:${NC}"
echo ""
echo "1. Set up SSL Certificate (Required for security):"
echo ""
echo "   Option A: Let's Encrypt (FREE - Recommended)"
echo "   sudo apt-get install -y certbot python3-certbot-nginx"
echo "   sudo certbot certonly --webroot -w /var/www/certbot -d $PRIMARY_IP"
echo ""
echo "   Option B: Self-Signed (Testing Only)"
echo "   sudo mkdir -p /etc/nginx/ssl"
echo "   sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \\"
echo "     -keyout /etc/nginx/ssl/kayo-key.key \\"
echo "     -out /etc/nginx/ssl/kayo-cert.crt"
echo "   Then edit: sudo nano /etc/nginx/sites-available/kayo-script-gen"
echo ""
echo "2. Start the application:"
echo "   kayo-script-gen"
echo ""
echo "3. Access remotely:"
echo "   https://$PRIMARY_IP"
echo ""

echo -e "${BLUE}USEFUL COMMANDS:${NC}"
echo ""
echo "  Check Nginx status:        sudo systemctl status nginx"
echo "  View Nginx logs:           sudo tail -f /var/log/nginx/kayo-script-gen.error.log"
echo "  Restart Nginx:             sudo systemctl restart nginx"
echo "  Stop Kayo app:             pkill -f 'python.*launcher'"
echo ""

echo "Installation files saved to: ~/.local/kayo-script-gen/"
echo ""
