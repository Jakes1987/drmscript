#!/usr/bin/env python3
"""
Verification script to check if all components are in place
"""

import sys
import os
from pathlib import Path

def check_file(path, description):
    """Check if a file exists"""
    if os.path.exists(path):
        size = os.path.getsize(path)
        print(f"✓ {description:50s} {size:>10,} bytes")
        return True
    else:
        print(f"✗ {description:50s} MISSING")
        return False

def check_directory(path, description):
    """Check if a directory exists"""
    if os.path.isdir(path):
        files = len(os.listdir(path))
        print(f"✓ {description:50s} ({files} items)")
        return True
    else:
        print(f"✗ {description:50s} MISSING")
        return False

def main():
    project_root = Path(__file__).parent
    os.chdir(project_root)
    
    print("\n" + "="*70)
    print("Kayo to O11V4 Script Generator - Component Verification")
    print("="*70 + "\n")
    
    results = []
    
    # Check directories
    print("Checking directories...")
    results.append(check_directory("src", "Source directory (src/)"))
    results.append(check_directory("templates", "Templates directory (templates/)"))
    results.append(check_directory("output", "Output directory (output/)"))
    results.append(check_directory("config", "Config directory (config/)"))
    print()
    
    # Check source files
    print("Checking source files...")
    results.append(check_file("src/main.py", "CLI application (main.py)"))
    results.append(check_file("src/web_server.py", "Web server (web_server.py)"))
    results.append(check_file("src/kayo_connector.py", "Kayo connector (kayo_connector.py)"))
    results.append(check_file("src/o11v4_generator.py", "O11V4 generator (o11v4_generator.py)"))
    results.append(check_file("src/__init__.py", "Package init (__init__.py)"))
    print()
    
    # Check web GUI files
    print("Checking web GUI files...")
    results.append(check_file("templates/index.html", "Web interface (index.html)"))
    results.append(check_file("templates/app.js", "Frontend logic (app.js)"))
    results.append(check_file("templates/style.css", "Styling (style.css)"))
    print()
    
    # Check launcher scripts
    print("Checking launcher scripts...")
    results.append(check_file("launcher.py", "Python launcher (launcher.py)"))
    results.append(check_file("launcher.bat", "Windows launcher (launcher.bat)"))
    results.append(check_file("launcher.sh", "Unix launcher (launcher.sh)"))
    print()
    
    # Check documentation
    print("Checking documentation...")
    results.append(check_file("README.md", "Main README"))
    results.append(check_file("INSTALLATION.md", "Installation guide"))
    results.append(check_file("WEB_GUI_GUIDE.md", "Web GUI guide"))
    results.append(check_file("GUI_IMPLEMENTATION.md", "Implementation summary"))
    results.append(check_file("TESTING_CHECKLIST.md", "Testing checklist"))
    results.append(check_file("requirements.txt", "Python requirements"))
    print()
    
    # Check generated files
    print("Checking generated files...")
    results.append(check_file("output/kayo.py", "Generated script"))
    results.append(check_file("output/kayo.json", "Generated config"))
    print()
    
    # Summary
    total = len(results)
    passed = sum(results)
    failed = total - passed
    
    print("="*70)
    print(f"Verification Results: {passed}/{total} components present")
    print("="*70)
    
    if failed == 0:
        print("\n✓ All components verified successfully!")
        print("\nYou can now launch the application:")
        print("  Windows: launcher.bat")
        print("  macOS/Linux: ./launcher.sh")
        print("  All platforms: python launcher.py")
        return 0
    else:
        print(f"\n✗ {failed} component(s) missing!")
        return 1

if __name__ == "__main__":
    sys.exit(main())
