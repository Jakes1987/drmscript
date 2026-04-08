#!/bin/bash

# Nginx Port Conflict Resolver
# Finds what's using port 8080 and helps resolve the conflict

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PORT="${1:-8080}"

echo -e "${BLUE}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                                                    ║${NC}"
echo -e "${BLUE}║  Nginx Port Conflict Resolver                    ║${NC}"
echo -e "${BLUE}║                                                    ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${BLUE}Checking port $PORT...${NC}"
echo ""

# Check if port is in use
if ! netstat -tlnp 2>/dev/null | grep -q ":$PORT "; then
    echo -e "${GREEN}✓ Port $PORT is available${NC}"
    echo ""
    echo "You can safely start Nginx:"
    echo "  sudo systemctl start nginx"
    echo ""
    exit 0
fi

echo -e "${YELLOW}✗ Port $PORT is already in use${NC}"
echo ""

# Find what's using the port
echo -e "${BLUE}Finding process using port $PORT...${NC}"
echo ""

PROCESS_INFO=$(netstat -tlnp 2>/dev/null | grep ":$PORT " | awk '{print $7}')

if [ -z "$PROCESS_INFO" ]; then
    # Try alternative method
    PROCESS_INFO=$(ss -tlnp 2>/dev/null | grep ":$PORT " | awk '{print $NF}')
fi

if [ -n "$PROCESS_INFO" ]; then
    echo -e "${YELLOW}Process using port $PORT:${NC}"
    echo "  $PROCESS_INFO"
    echo ""
    
    # Extract PID
    PID=$(echo "$PROCESS_INFO" | sed 's/.*(\([0-9]*\)).*/\1/')
    if [ -n "$PID" ]; then
        echo -e "${BLUE}Process details:${NC}"
        ps aux | grep "^" | grep "$PID" | grep -v grep || true
        echo ""
    fi
fi

echo -e "${BLUE}OPTIONS:${NC}"
echo ""
echo "1. Kill the process using port $PORT"
echo "2. Use a different port for Nginx (e.g., 8081, 9000)"
echo "3. Stop the conflicting service"
echo "4. Just show the details (no changes)"
echo ""
read -p "Choose an option (1/2/3/4): " choice

case $choice in
    1)
        if [ -n "$PID" ]; then
            echo ""
            echo -e "${YELLOW}Killing process $PID...${NC}"
            sudo kill -9 "$PID"
            sleep 2
            
            echo -e "${BLUE}Starting Nginx on port $PORT...${NC}"
            sudo systemctl start nginx
            
            if sudo systemctl is-active --quiet nginx; then
                echo -e "${GREEN}✓ Nginx started successfully on port $PORT${NC}"
            else
                echo -e "${RED}✗ Nginx failed to start${NC}"
                sudo systemctl status nginx
                exit 1
            fi
        else
            echo -e "${RED}Could not determine PID${NC}"
            exit 1
        fi
        ;;
        
    2)
        echo ""
        echo -e "${YELLOW}Available ports to use:${NC}"
        echo "  8081 (recommended)"
        echo "  9000"
        echo "  9001"
        echo "  3000"
        echo ""
        read -p "Enter port number (default 8081): " NEW_PORT
        NEW_PORT=${NEW_PORT:-8081}
        
        # Check if new port is available
        if netstat -tlnp 2>/dev/null | grep -q ":$NEW_PORT "; then
            echo -e "${RED}✗ Port $NEW_PORT is also in use${NC}"
            exit 1
        fi
        
        echo ""
        echo -e "${BLUE}Updating Nginx configuration to use port $NEW_PORT...${NC}"
        
        # Update nginx config
        sudo sed -i "s/listen $PORT;/listen $NEW_PORT;/g" /etc/nginx/sites-available/kayo-script-gen
        sudo sed -i "s/listen \[::\]:$PORT;/listen [::]:$NEW_PORT;/g" /etc/nginx/sites-available/kayo-script-gen
        
        echo -e "${GREEN}✓ Configuration updated${NC}"
        echo ""
        
        # Test config
        echo -e "${BLUE}Testing Nginx configuration...${NC}"
        if sudo nginx -t; then
            echo -e "${GREEN}✓ Configuration is valid${NC}"
            echo ""
            
            # Start Nginx
            echo -e "${BLUE}Starting Nginx on port $NEW_PORT...${NC}"
            sudo systemctl start nginx
            
            if sudo systemctl is-active --quiet nginx; then
                echo -e "${GREEN}✓ Nginx started successfully on port $NEW_PORT${NC}"
                echo ""
                echo "Access your application at:"
                echo "  http://your-ip:$NEW_PORT"
            else
                echo -e "${RED}✗ Nginx failed to start${NC}"
                sudo systemctl status nginx
                exit 1
            fi
        else
            echo -e "${RED}✗ Configuration test failed${NC}"
            exit 1
        fi
        ;;
        
    3)
        echo ""
        echo -e "${YELLOW}Common services that might use port 8080:${NC}"
        echo "  - Java applications"
        echo "  - Node.js apps"
        echo "  - Other web servers"
        echo "  - Docker containers"
        echo ""
        
        read -p "Enter service name to stop (e.g., 'apache2', 'nodejs'): " SERVICE_NAME
        
        if [ -n "$SERVICE_NAME" ]; then
            echo ""
            echo -e "${BLUE}Stopping $SERVICE_NAME...${NC}"
            
            if sudo systemctl stop "$SERVICE_NAME" 2>/dev/null; then
                echo -e "${GREEN}✓ $SERVICE_NAME stopped${NC}"
                echo ""
                
                # Start Nginx
                echo -e "${BLUE}Starting Nginx on port $PORT...${NC}"
                sudo systemctl start nginx
                
                if sudo systemctl is-active --quiet nginx; then
                    echo -e "${GREEN}✓ Nginx started successfully on port $PORT${NC}"
                else
                    echo -e "${RED}✗ Nginx failed to start${NC}"
                    sudo systemctl status nginx
                    exit 1
                fi
            else
                echo -e "${RED}✗ Failed to stop $SERVICE_NAME${NC}"
                echo "Try: sudo systemctl stop $SERVICE_NAME"
                exit 1
            fi
        fi
        ;;
        
    4)
        echo ""
        echo -e "${BLUE}Full port status:${NC}"
        echo ""
        echo "All processes listening on all ports:"
        sudo ss -tlnp 2>/dev/null | grep LISTEN
        echo ""
        ;;
        
    *)
        echo "Invalid option"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Operation Complete!                             ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════╝${NC}"
echo ""

# Show final status
echo -e "${BLUE}Nginx Status:${NC}"
sudo systemctl status nginx --no-pager || true
echo ""
