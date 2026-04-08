#!/usr/bin/env python3
"""
Kayo Script Generator - Setup Installer
Creates a professional Windows installer executable
"""

import os
import sys
import shutil
import subprocess
from pathlib import Path
from ctypes import windll, Structure, POINTER, byref, c_int, c_wchar_p

class POINT(Structure):
    _fields_ = [("x", c_int), ("y", c_int)]

def get_source_dir():
    """Get the directory where this script is running from"""
    if getattr(sys, 'frozen', False):
        return os.path.dirname(sys.executable)
    return os.path.dirname(os.path.abspath(__file__))

def get_install_dir():
    """Get the installation directory (user's Local AppData)"""
    local_appdata = os.path.expandvars(r'%LOCALAPPDATA%')
    return os.path.join(local_appdata, 'Kayo Script Gen')

def create_vbscript_shortcut(shortcut_path, target_path, working_dir, description):
    """Create a Windows shortcut using VBScript"""
    vbscript_code = f'''
Set oWS = WScript.CreateObject("WScript.Shell")
sLinkFile = "{shortcut_path}"
Set oLink = oWS.CreateShortcut(sLinkFile)
oLink.TargetPath = "{target_path}"
oLink.WorkingDirectory = "{working_dir}"
oLink.Description = "{description}"
oLink.Save
'''
    
    temp_vbs = os.path.join(os.environ.get('TEMP', '.'), 'createlink.vbs')
    try:
        with open(temp_vbs, 'w') as f:
            f.write(vbscript_code)
        subprocess.run(['cscript.exe', temp_vbs], 
                      capture_output=True, timeout=5)
    finally:
        try:
            os.remove(temp_vbs)
        except:
            pass

def setup_gui():
    """Run the installer with a nice GUI"""
    import tkinter as tk
    from tkinter import ttk, messagebox
    
    root = tk.Tk()
    root.title("Kayo Script Generator Setup")
    root.geometry("500x400")
    root.resizable(False, False)
    
    # Center window
    root.update_idletasks()
    x = (root.winfo_screenwidth() // 2) - (root.winfo_width() // 2)
    y = (root.winfo_screenheight() // 2) - (root.winfo_height() // 2)
    root.geometry(f"+{x}+{y}")
    
    # Style
    style = ttk.Style()
    style.theme_use('clam')
    
    # Header
    header_frame = tk.Frame(root, bg='#2c3e50', height=80)
    header_frame.pack(fill=tk.X)
    
    title_label = tk.Label(header_frame, 
                           text="Kayo to O11V4 Script Generator",
                           font=('Arial', 16, 'bold'),
                           bg='#2c3e50', fg='white')
    title_label.pack(pady=15)
    
    subtitle_label = tk.Label(header_frame,
                             text="Setup Installer",
                             font=('Arial', 10),
                             bg='#2c3e50', fg='#ecf0f1')
    subtitle_label.pack()
    
    # Content frame
    content_frame = tk.Frame(root)
    content_frame.pack(fill=tk.BOTH, expand=True, padx=20, pady=20)
    
    info_text = tk.Label(content_frame,
                        text="This installer will:\n\n"
                             "✓ Install the application\n"
                             "✓ Create Start Menu shortcut\n"
                             "✓ Create Desktop shortcut\n"
                             "✓ Set up configuration\n\n"
                             "Your Kayo credentials are NEVER stored.\n"
                             "Installation requires ~200 MB disk space.\n\n"
                             f"Install location:\n{get_install_dir()}",
                        font=('Arial', 10),
                        justify=tk.LEFT)
    info_text.pack(fill=tk.BOTH, expand=True)
    
    # Progress frame (initially hidden)
    progress_frame = tk.Frame(root)
    progress_label = tk.Label(progress_frame, text="Installing...", font=('Arial', 10))
    progress_label.pack(pady=10)
    progress_bar = ttk.Progressbar(progress_frame, mode='indeterminate', length=300)
    progress_bar.pack(pady=10, fill=tk.X)
    
    # Status frame
    status_frame = tk.Frame(root)
    status_label = tk.Label(status_frame, text="", font=('Arial', 9))
    status_label.pack()
    
    # Button frame
    button_frame = tk.Frame(root)
    button_frame.pack(fill=tk.X, padx=20, pady=20)
    
    def run_installation():
        # Hide info, show progress
        content_frame.pack_forget()
        progress_frame.pack(fill=tk.BOTH, expand=True, padx=20, pady=20)
        status_frame.pack(fill=tk.X, padx=20)
        button_frame.pack_forget()
        
        progress_bar.start()
        root.update()
        
        try:
            source_dir = get_source_dir()
            install_dir = get_install_dir()
            
            # Step 1: Create directories
            status_label.config(text="Step 1/4: Creating directories...")
            root.update()
            os.makedirs(install_dir, exist_ok=True)
            os.makedirs(os.path.join(install_dir, 'templates'), exist_ok=True)
            os.makedirs(os.path.join(install_dir, 'config'), exist_ok=True)
            
            # Step 2: Copy files
            status_label.config(text="Step 2/4: Copying files...")
            root.update()
            
            exe_src = os.path.join(source_dir, 'dist', 'KayoScriptGen.exe')
            if not os.path.exists(exe_src):
                raise FileNotFoundError(f"KayoScriptGen.exe not found at {exe_src}")
            
            shutil.copy2(exe_src, os.path.join(install_dir, 'KayoScriptGen.exe'))
            
            # Copy templates if they exist
            templates_src = os.path.join(source_dir, 'templates')
            if os.path.exists(templates_src):
                for file in os.listdir(templates_src):
                    shutil.copy2(os.path.join(templates_src, file),
                               os.path.join(install_dir, 'templates', file))
            
            # Copy config if it exists
            config_src = os.path.join(source_dir, 'config')
            if os.path.exists(config_src):
                for file in os.listdir(config_src):
                    shutil.copy2(os.path.join(config_src, file),
                               os.path.join(install_dir, 'config', file))
            
            # Step 3: Create shortcuts
            status_label.config(text="Step 3/4: Creating shortcuts...")
            root.update()
            
            # Desktop shortcut
            desktop = os.path.expandvars(r'%USERPROFILE%\Desktop')
            shortcut_path = os.path.join(desktop, 'Kayo Script Gen.lnk')
            target = os.path.join(install_dir, 'KayoScriptGen.exe')
            description = "Generate O11V4 provider scripts with real Kayo integration"
            
            create_vbscript_shortcut(shortcut_path, target, install_dir, description)
            
            # Start Menu shortcut
            start_menu = os.path.expandvars(r'%APPDATA%\Microsoft\Windows\Start Menu\Programs\Kayo Script Gen')
            os.makedirs(start_menu, exist_ok=True)
            shortcut_path = os.path.join(start_menu, 'Kayo Script Gen.lnk')
            create_vbscript_shortcut(shortcut_path, target, install_dir, description)
            
            # Step 4: Create uninstaller
            status_label.config(text="Step 4/4: Creating uninstaller...")
            root.update()
            
            uninstall_bat = os.path.join(install_dir, 'Uninstall.bat')
            with open(uninstall_bat, 'w') as f:
                f.write(f'''@echo off
echo.
echo    Uninstalling Kayo Script Gen...
echo.
rmdir /s /q "{install_dir}" 2>nul
del "%USERPROFILE%\\Desktop\\Kayo Script Gen.lnk" 2>nul
rmdir /s /q "%APPDATA%\\Microsoft\\Windows\\Start Menu\\Programs\\Kayo Script Gen" 2>nul
echo.
echo    Uninstall complete!
echo.
pause
''')
            
            progress_bar.stop()
            progress_frame.pack_forget()
            status_frame.pack_forget()
            button_frame.pack(fill=tk.X, padx=20, pady=20)
            
            # Show completion message
            content_frame.pack(fill=tk.BOTH, expand=True, padx=20, pady=20)
            content_frame.pack_forget()
            
            completion_frame = tk.Frame(root)
            completion_frame.pack(fill=tk.BOTH, expand=True, padx=20, pady=20)
            
            completion_text = tk.Label(completion_frame,
                                      text="✓ Installation Complete!\n\n"
                                           "Quick Start:\n"
                                           "1. Find 'Kayo Script Gen' in Start Menu\n"
                                           "   OR use the Desktop shortcut\n"
                                           "2. Enter your Kayo credentials\n"
                                           "3. Generate your O11V4 provider\n"
                                           "4. Deploy to O11V4\n\n"
                                           "Documentation:\n"
                                           "See QUICK_DEPLOUMENT_GUIDE.txt",
                                      font=('Arial', 10),
                                      justify=tk.LEFT)
            completion_text.pack(fill=tk.BOTH, expand=True)
            
            button_frame.pack(fill=tk.X, padx=20, pady=20)
            
        except Exception as e:
            progress_bar.stop()
            messagebox.showerror("Installation Error", f"Installation failed:\n\n{str(e)}")
            root.destroy()
            sys.exit(1)
    
    def start_installation():
        root.after(100, run_installation)
    
    def close_window():
        root.destroy()
        sys.exit(0)
    
    install_btn = ttk.Button(button_frame, text="Install", command=start_installation)
    install_btn.pack(side=tk.LEFT, padx=5)
    
    cancel_btn = ttk.Button(button_frame, text="Cancel", command=close_window)
    cancel_btn.pack(side=tk.RIGHT, padx=5)
    
    # Show completion button after installation
    def show_completion():
        completion_btn = ttk.Button(button_frame, text="Close", command=close_window)
        completion_btn.pack(side=tk.RIGHT, padx=5)
        install_btn.pack_forget()
        cancel_btn.pack_forget()
    
    root.mainloop()

if __name__ == '__main__':
    try:
        setup_gui()
    except Exception as e:
        import tkinter.messagebox as messagebox
        messagebox.showerror("Setup Error", f"An error occurred:\n\n{str(e)}")
        sys.exit(1)
