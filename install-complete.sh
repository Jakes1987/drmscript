#!/bin/bash

# Kayo Script Generator - Complete Remote Server Installer (Fixed)
# This is the master installer for Ubuntu/Debian servers
# Downloads and runs the full installation with line ending fixes
# Usage: bash install-complete.sh

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

# Download installers with retry logic
download_with_retry() {
    local url=$1
    local output=$2
    local max_attempts=3
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        echo "  Attempt $attempt of $max_attempts: $url"
        
        if curl -fsSL --connect-timeout 10 "$url" -o "$output"; then
            # Remove Windows line endings (CRLF) and convert to Unix (LF)
            dos2unix "$output" 2>/dev/null || sed -i 's/\r$//' "$output"
            echo "  ✓ Downloaded successfully"
            return 0
        else
            echo "  ✗ Download failed"
            attempt=$((attempt + 1))
            if [ $attempt -le $max_attempts ]; then
                echo "  Retrying in 3 seconds..."
                sleep 3
            fi
        fi
    done
    
    return 1
}

# Download main installer
if ! download_with_retry \
    "https://raw.githubusercontent.com/Jakes1987/drmscript/main/install-ubuntu.sh" \
    "$TEMP_DIR/install-ubuntu.sh"; then
    echo -e "${RED}✗ Failed to download install-ubuntu.sh${NC}"
    exit 1
fi

# Download nginx setup
if ! download_with_retry \
    "https://raw.githubusercontent.com/Jakes1987/drmscript/main/setup-nginx-remote.sh" \
    "$TEMP_DIR/setup-nginx-remote.sh"; then
    echo -e "${RED}✗ Failed to download setup-nginx-remote.sh${NC}"
    exit 1
fi

chmod +x "$TEMP_DIR/install-ubuntu.sh"
chmod +x "$TEMP_DIR/setup-nginx-remote.sh"

echo -e "${GREEN}✓ Scripts downloaded and fixed${NC}"
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

# Run Nginx setup with detected IP and port 8080
sudo bash "$TEMP_DIR/setup-nginx-remote.sh" "$PRIMARY_IP" 8080

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✓ Installation Complete!                        ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${BLUE}NEXT STEPS:${NC}"
echo ""
echo "1. Start the application:"
echo "   kayo-script-gen"
echo ""
echo "2. Access your application:"
echo ""
echo "   Local (same machine):"
echo "   → http://localhost:5000"
echo ""
echo "   Remote (from other machines):"
echo "   → http://$PRIMARY_IP:8080"
echo ""
echo "3. Access O11V4 Panel:"
echo "   → http://$PRIMARY_IP:80"
echo ""

echo -e "${BLUE}PORT SUMMARY:${NC}"
echo ""
echo "  Port 80:   O11V4 Panel"
echo "  Port 5000: Kayo Script Generator (local)"
echo "  Port 8080: Kayo Script Generator (remote via Nginx)"
echo ""

echo -e "${BLUE}FIREWALL:${NC}"
echo ""
echo "If ports don't work, allow them:"
echo "  sudo ufw allow 80/tcp"
echo "  sudo ufw allow 8080/tcp"
echo ""

echo -e "${BLUE}LOGS & DEBUGGING:${NC}"
echo ""
echo "  Check app: ps aux | grep kayo-script-gen"
echo "  Nginx logs: sudo tail -f /var/log/nginx/kayo-script-gen.error.log"
echo "  App logs: cd ~/.local/kayo-script-gen && tail -f app.log"
echo ""

echo "Installation files saved to: ~/.local/kayo-script-gen/"
echo ""
