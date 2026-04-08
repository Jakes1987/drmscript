#!/bin/bash

# Kayo to O11V4 Script Generator - Ubuntu/Linux Installer
# This script downloads and installs the application on Ubuntu/Debian-based systems

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REPO_URL="https://github.com/Jakes1987/drmscript"
INSTALL_DIR="$HOME/.local/kayo-script-gen"
BIN_DIR="$HOME/.local/bin"

echo -e "${BLUE}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                                                    ║${NC}"
echo -e "${BLUE}║  Kayo to O11V4 Script Generator - Ubuntu Installer ║${NC}"
echo -e "${BLUE}║                                                    ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if running on supported OS
if ! [ -f /etc/os-release ]; then
    echo -e "${RED}Error: This installer requires a Debian/Ubuntu-based Linux distribution${NC}"
    exit 1
fi

# Source the OS release info
. /etc/os-release

if [[ "$ID" != "ubuntu" && "$ID" != "debian" && "$ID_LIKE" != *"ubuntu"* ]]; then
    echo -e "${YELLOW}Warning: This installer is for Ubuntu/Debian. Your system is: $ID${NC}"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo -e "${BLUE}Step 1: Checking dependencies...${NC}"

# Check for required tools
check_command() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${YELLOW}  ! $1 not found${NC}"
        return 1
    else
        echo -e "${GREEN}  ✓ $1 found${NC}"
        return 0
    fi
}

MISSING=0

check_command "python3" || MISSING=1
check_command "git" || MISSING=1

if [ $MISSING -eq 1 ]; then
    echo ""
    echo -e "${YELLOW}Installing missing dependencies...${NC}"
    sudo apt-get update
    sudo apt-get install -y python3 python3-pip git
fi

echo ""
echo -e "${BLUE}Step 2: Creating installation directory...${NC}"

if [ ! -d "$INSTALL_DIR" ]; then
    mkdir -p "$INSTALL_DIR"
    echo -e "${GREEN}  ✓ Created: $INSTALL_DIR${NC}"
else
    echo -e "${GREEN}  ✓ Directory exists: $INSTALL_DIR${NC}"
fi

echo ""
echo -e "${BLUE}Step 3: Downloading application...${NC}"

cd /tmp
if [ -d "kayo-script-gen" ]; then
    rm -rf kayo-script-gen
fi

git clone "$REPO_URL" kayo-script-gen
cd kayo-script-gen

echo -e "${GREEN}  ✓ Downloaded${NC}"

echo ""
echo -e "${BLUE}Step 4: Installing dependencies...${NC}"

pip3 install -r requirements.txt --user
echo -e "${GREEN}  ✓ Dependencies installed${NC}"

echo ""
echo -e "${BLUE}Step 5: Setting up application...${NC}"

# Copy application files
cp -r . "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/launcher.py"

echo -e "${GREEN}  ✓ Application files copied${NC}"

# Create launcher script
mkdir -p "$BIN_DIR"
cat > "$BIN_DIR/kayo-script-gen" << 'LAUNCHER'
#!/bin/bash
cd "$HOME/.local/kayo-script-gen"
python3 launcher.py "$@"
LAUNCHER

chmod +x "$BIN_DIR/kayo-script-gen"
echo -e "${GREEN}  ✓ Launcher script created${NC}"

echo ""
echo -e "${BLUE}Step 6: Creating desktop entry...${NC}"

DESKTOP_DIR="$HOME/.local/share/applications"
mkdir -p "$DESKTOP_DIR"

cat > "$DESKTOP_DIR/kayo-script-gen.desktop" << 'DESKTOP'
[Desktop Entry]
Type=Application
Name=Kayo Script Generator
Comment=Generate O11V4 provider scripts with Kayo integration
Exec=kayo-script-gen
Icon=application-x-python
Terminal=false
Categories=Development;Utility;
Keywords=Kayo;O11V4;Script;Generator;
DESKTOP

echo -e "${GREEN}  ✓ Desktop entry created${NC}"

# Clean up
cd ~
rm -rf /tmp/kayo-script-gen

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║         ✓ Installation Complete!                  ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${BLUE}Quick Start:${NC}"
echo ""
echo -e "  ${YELLOW}Option 1: From Terminal${NC}"
echo -e "    ${BLUE}$ kayo-script-gen${NC}"
echo ""
echo -e "  ${YELLOW}Option 2: From Applications${NC}"
echo -e "    ${BLUE}Search for 'Kayo Script Generator' in your application menu${NC}"
echo ""
echo -e "  ${YELLOW}Option 3: Direct Path${NC}"
echo -e "    ${BLUE}$ ~/.local/bin/kayo-script-gen${NC}"
echo ""
echo -e "  ${YELLOW}Then open:${NC}"
echo -e "    ${BLUE}http://localhost:5000${NC}"
echo ""

echo -e "${BLUE}Location:${NC}"
echo -e "  Application: ${YELLOW}$INSTALL_DIR${NC}"
echo -e "  Launcher: ${YELLOW}$BIN_DIR/kayo-script-gen${NC}"
echo ""

echo -e "${BLUE}To uninstall:${NC}"
echo -e "  ${YELLOW}$ rm -rf $INSTALL_DIR${NC}"
echo -e "  ${YELLOW}$ rm $BIN_DIR/kayo-script-gen${NC}"
echo ""

echo -e "${GREEN}Ready to use! Run 'kayo-script-gen' to start.${NC}"
