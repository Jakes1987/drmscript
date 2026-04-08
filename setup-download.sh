#!/bin/bash

# Kayo Script Generator - Simple Download & Fix Script
# Use this when <(curl) process substitution doesn't work
# Usage: bash setup-download.sh

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                                                    ║${NC}"
echo -e "${BLUE}║  Kayo Script Generator - Download & Setup         ║${NC}"
echo -e "${BLUE}║                                                    ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════╝${NC}"
echo ""

# Base URL
BASE_URL="https://raw.githubusercontent.com/Jakes1987/drmscript/main"

# Create temp directory
WORK_DIR="/tmp/kayo-install-$$"
mkdir -p "$WORK_DIR"
trap "rm -rf $WORK_DIR" EXIT

echo -e "${BLUE}Step 1: Downloading installation scripts...${NC}"
echo ""

# Download with timeout and verbose error handling
download_file() {
    local url=$1
    local output=$2
    local max_attempts=5
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        echo -e "${YELLOW}  Downloading: $(basename $url) (Attempt $attempt/$max_attempts)${NC}"
        
        if curl --connect-timeout 30 --max-time 120 -fSL "$url" -o "$output" 2>&1; then
            # Check if file is not empty
            if [ -s "$output" ]; then
                echo -e "${GREEN}  ✓ Successfully downloaded$(NC}"
                return 0
            else
                echo -e "${YELLOW}  ! File is empty, retrying...${NC}"
                rm -f "$output"
            fi
        else
            echo -e "${YELLOW}  ! Download failed, retrying...${NC}"
            rm -f "$output"
        fi
        
        attempt=$((attempt + 1))
        if [ $attempt -le $max_attempts ]; then
            sleep 2
        fi
    done
    
    echo -e "${RED}  ✗ Failed to download after $max_attempts attempts${NC}"
    return 1
}

# Download main installer
if ! download_file "$BASE_URL/install-ubuntu.sh" "$WORK_DIR/install-ubuntu.sh"; then
    exit 1
fi

echo ""

# Download nginx setup
if ! download_file "$BASE_URL/setup-nginx-remote.sh" "$WORK_DIR/setup-nginx-remote.sh"; then
    exit 1
fi

echo ""

# Download port conflict resolver
if ! download_file "$BASE_URL/fix-port-conflict.sh" "$WORK_DIR/fix-port-conflict.sh"; then
    echo -e "${YELLOW}  ! Port conflict resolver failed, continuing anyway...${NC}"
fi

echo -e "${BLUE}Step 2: Fixing line endings and permissions...${NC}"
echo ""

# Fix line endings on all bash scripts (CRLF -> LF)
for script in "$WORK_DIR"/*.sh; do
    if [ -f "$script" ]; then
        # Remove carriage returns
        sed -i 's/\r$//' "$script"
        # Make executable
        chmod +x "$script"
        echo -e "${GREEN}  ✓ Fixed: $(basename $script)${NC}"
    fi
done

echo ""
echo -e "${BLUE}Step 3: Running installer...${NC}"
echo ""

# Run main installer
if [ -x "$WORK_DIR/install-ubuntu.sh" ]; then
    bash "$WORK_DIR/install-ubuntu.sh"
else
    echo -e "${RED}✗ Installer script is not executable${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✓ Download and Setup Complete!                  ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════╝${NC}"
echo ""

# Print next steps
PRIMARY_IP=$(hostname -I | awk '{print $1}')
if [ -z "$PRIMARY_IP" ]; then
    PRIMARY_IP="your-ip"
fi

echo -e "${BLUE}NEXT STEPS:${NC}"
echo ""
echo "1. Start the application:"
echo "   kayo-script-gen"
echo ""
echo "2. Access your application:"
echo "   http://localhost:5000 (local)"
echo "   http://$PRIMARY_IP:8080 (remote)"
echo ""
echo "3. If port 8080 is in use, run port conflict resolver:"
echo "   cd $WORK_DIR"
echo "   bash fix-port-conflict.sh"
echo ""
