#!/bin/bash
# Kayo Script Generator - Simple Download & Setup
# Minimal version without fancy formatting (avoids encoding issues)

set -e

# Configuration
BASE_URL="https://raw.githubusercontent.com/Jakes1987/drmscript/main"
WORK_DIR="/tmp/kayo-install-$$"

# Create temp directory
mkdir -p "$WORK_DIR"
trap "rm -rf $WORK_DIR" EXIT

echo "Starting Kayo Script Generator installation..."
echo ""

# Download files with 5 attempts
download_file() {
    local url=$1
    local output=$2
    local attempt=1
    
    while [ $attempt -le 5 ]; do
        echo "Downloading $(basename $url) (attempt $attempt/5)..."
        if curl --connect-timeout 30 --max-time 120 -fSL "$url" -o "$output" 2>/dev/null; then
            if [ -s "$output" ]; then
                echo "  Success"
                return 0
            fi
        fi
        attempt=$((attempt + 1))
        if [ $attempt -le 5 ]; then
            sleep 2
        fi
    done
    
    echo "ERROR: Failed to download $(basename $url)" >&2
    return 1
}

# Download required scripts
echo "Downloading installation scripts..."
download_file "$BASE_URL/install-ubuntu.sh" "$WORK_DIR/install-ubuntu.sh"
download_file "$BASE_URL/setup-nginx-remote.sh" "$WORK_DIR/setup-nginx-remote.sh"

echo ""
echo "Fixing line endings..."

# Fix line endings and permissions
for script in "$WORK_DIR"/*.sh; do
    if [ -f "$script" ]; then
        sed -i 's/\r$//' "$script"
        chmod +x "$script"
        echo "  Fixed: $(basename $script)"
    fi
done

echo ""
echo "Running installer..."
echo ""

# Run main installer
bash "$WORK_DIR/install-ubuntu.sh"

echo ""
echo "Installation complete!"
echo ""
echo "Next steps:"
echo "1. Run: kayo-script-gen"
echo "2. Open: http://localhost:5000 (local) or http://YOUR_IP:8080 (remote)"
echo ""
