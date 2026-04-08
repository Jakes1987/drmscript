#!/usr/bin/env python3
"""
Kayo to O11V4 Script Generator - CLI Launcher

Launches the Flask-based web GUI for the script generator.
"""

import argparse
import sys
import os
import webbrowser
import time
import socket
from pathlib import Path


def find_free_port(start_port=5000, max_attempts=10):
    """Find an available port."""
    for port in range(start_port, start_port + max_attempts):
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(1)
            result = sock.connect_ex(('127.0.0.1', port))
            sock.close()
            if result != 0:
                return port
        except:
            pass
    return start_port


def is_port_open(host, port, timeout=5):
    """Check if port is open and listening."""
    start_time = time.time()
    while time.time() - start_time < timeout:
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(1)
            result = sock.connect_ex((host, port))
            sock.close()
            if result == 0:
                return True
        except:
            pass
        time.sleep(0.5)
    return False


def main():
    """Main launcher function."""
    parser = argparse.ArgumentParser(
        description='Launch Kayo to O11V4 Script Generator Web GUI',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python launcher.py                    # Launch with defaults (port 5000)
  python launcher.py --port 8080        # Launch on port 8080
  python launcher.py --no-browser       # Launch without opening browser
  python launcher.py --host 0.0.0.0     # Make accessible from other machines
        """
    )
    
    parser.add_argument(
        '--port', '-p',
        type=int,
        default=5000,
        help='Port to run web server on (default: 5000)'
    )
    
    parser.add_argument(
        '--host', '-H',
        default='127.0.0.1',
        help='Host to bind to (default: 127.0.0.1, use 0.0.0.0 for network access)'
    )
    
    parser.add_argument(
        '--no-browser', '-nb',
        action='store_true',
        help='Do not automatically open browser'
    )
    
    parser.add_argument(
        '--debug',
        action='store_true',
        help='Run Flask in debug mode (not recommended for production)'
    )
    
    args = parser.parse_args()
    
    # Check if we're in the right directory
    root_dir = Path(__file__).parent
    src_dir = root_dir / 'src'
    if not (src_dir / 'web_server.py').exists():
        print("ERROR: web_server.py not found in src directory")
        print(f"Looked in: {src_dir}")
        sys.exit(1)
    
    # If port is already in use on default, try to find a free port
    if args.host == '127.0.0.1' and args.port == 5000:
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(1)
            result = sock.connect_ex(('127.0.0.1', 5000))
            sock.close()
            if result == 0:
                new_port = find_free_port(5000)
                if new_port != 5000:
                    print(f"[!] Port 5000 is in use, using port {new_port} instead")
                    args.port = new_port
        except:
            pass
    
    # Import Flask app
    try:
        # Add src directory to path for imports
        src_path = root_dir / 'src'
        sys.path.insert(0, str(src_path))
        
        from web_server import run_server
    except ImportError as e:
        print(f"ERROR: Failed to import web_server: {e}")
        print("Make sure dependencies are installed")
        sys.exit(1)
    
    # Display startup information
    print("\n" + "="*70)
    print("Kayo to O11V4 Script Generator - Web GUI Launcher")
    print("="*70)
    print(f"Starting web server on http://{args.host}:{args.port}")
    print(f"Press Ctrl+C to stop the server\n")
    
    # Open browser if requested
    if not args.no_browser:
        print("Waiting for server to start...")
        
        # Wait longer for server to be ready (important for frozen executables)
        time.sleep(2)
        
        if is_port_open(args.host, args.port):
            url = f"http://{args.host}:{args.port}"
            print(f"Opening browser at {url}")
            try:
                # Try multiple methods to open browser
                browser_opened = False
                
                # Method 1: Standard webbrowser module
                try:
                    webbrowser.open(url, new=2, autoraise=True)
                    browser_opened = True
                except:
                    pass
                
                # Method 2: Direct Windows command if Method 1 fails
                if not browser_opened:
                    try:
                        import subprocess
                        subprocess.Popen(['start', url], shell=True)
                        browser_opened = True
                    except:
                        pass
                
                # Method 3: Use os.startfile (Windows-specific, most reliable)
                if not browser_opened:
                    try:
                        import os
                        os.startfile(url)
                        browser_opened = True
                    except:
                        pass
                
                if browser_opened:
                    time.sleep(0.5)
                else:
                    print(f"[!] Could not open browser automatically")
                    print(f"[!] Please open http://{args.host}:{args.port} manually")
            except Exception as e:
                print(f"[!] Error opening browser: {e}")
                print(f"[!] Please open http://{args.host}:{args.port} manually")
        else:
            print("[!] Server did not start in time, browser not opened")
            print(f"[!] Please try opening http://{args.host}:{args.port} manually")
    
    print("="*70 + "\n")
    
    # Start Flask server
    try:
        run_server(host=args.host, port=args.port, debug=args.debug)
    except KeyboardInterrupt:
        print("\n\n[*] Server stopped by user (Ctrl+C)")
        sys.exit(0)
    except Exception as e:
        print(f"\nERROR: {e}")
        sys.exit(1)


if __name__ == '__main__':
    main()
