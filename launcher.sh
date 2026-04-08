#!/bin/bash
# Kayo to O11V4 Script Generator - Unix/Linux Launcher

set -e

echo "=========================================="
echo "Kayo to O11V4 Script Generator - Launcher"
echo "=========================================="
echo ""

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "ERROR: Python 3 is not installed"
    exit 1
fi

PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
echo "Using Python: $PYTHON_VERSION"
echo ""

# Check if Flask is installed
if ! python3 -c "import flask" 2>/dev/null; then
    echo "Installing dependencies..."
    python3 -m pip install -r requirements.txt || {
        echo "ERROR: Failed to install dependencies"
        exit 1
    }
fi

# Parse arguments
PORT=5000
HOST="127.0.0.1"
NO_BROWSER=0
DEBUG=0

while [[ $# -gt 0 ]]; do
    case $1 in
        --port|-p)
            PORT="$2"
            shift 2
            ;;
        --host|-H)
            HOST="$2"
            shift 2
            ;;
        --no-browser|-nb)
            NO_BROWSER=1
            shift
            ;;
        --debug)
            DEBUG=1
            shift
            ;;
        --help|-h)
            echo "Usage: ./launcher.sh [options]"
            echo ""
            echo "Options:"
            echo "  --port PORT, -p PORT       Port to run on (default: 5000)"
            echo "  --host HOST, -H HOST       Host to bind to (default: 127.0.0.1)"
            echo "  --no-browser, -nb          Don't open browser"
            echo "  --debug                    Run in debug mode"
            echo "  --help, -h                 Show this help message"
            echo ""
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo "Starting web server..."
echo "Host: $HOST"
echo "Port: $PORT"
echo "URL: http://$HOST:$PORT"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

# Build command
CMD="python3 launcher.py --host $HOST --port $PORT"
if [ $DEBUG -eq 1 ]; then
    CMD="$CMD --debug"
fi
if [ $NO_BROWSER -eq 1 ]; then
    CMD="$CMD --no-browser"
fi

# Run server
cd "$(dirname "$0")"
exec $CMD
