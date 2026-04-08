# Kayo to O11V4 Script Generator - Build Instructions

## Quick Start (Windows)

### Option 1: Direct Build (Easiest)
```batch
build.bat
```
This creates `dist/KayoScriptGen.exe` - a standalone executable.

### Option 2: Build + Create Installer
```batch
build.bat
create-installer.bat
```
This creates an installer package in `installer_temp/`

### Option 3: Full NSIS Installer (Professional)
Requires: NSIS (https://nsis.sourceforge.io)
```batch
build.bat
makensis.exe installer.nsi
```
This creates `KayoScriptGen-Installer.exe` - a proper Windows installer.

---

## Build System Overview

### Scripts Provided

#### 1. **build.bat**
- Installs PyInstaller if needed
- Bundles Python application into standalone .exe
- Clears previous build artifacts
- Creates: `dist/KayoScriptGen.exe`
- Size: ~100-150 MB (includes Python runtime)
- Time: 2-5 minutes

#### 2. **create-installer.bat**
- Creates portable installation package
- Generates Install.bat and Uninstall.bat
- Optionally creates self-extracting archive
- Creates: `installer_temp/` directory

#### 3. **installer.nsi** (Optional)
- NSIS installer script
- Creates professional .exe installer
- Adds Start Menu shortcuts
- Adds uninstall entry to Control Panel
- Requires: NSIS installation

---

## Distribution Options

### Option A: Standalone Executable
**File:** `dist/KayoScriptGen.exe`
- Single executable file
- No installation required
- Works immediately
- Best for: USB drives, shared folders

```
Copy dist/KayoScriptGen.exe → User's machine
Double-click to run
```

### Option B: Portable Package
**File:** `installer_temp/*`
- Pre-configured installation scripts
- Optional shortcuts
- Can be archived as ZIP
- Best for: Email distribution, downloads

```
Extract ZIP
Run Install.bat (optional)
Run KayoScriptGen.exe
```

### Option C: NSIS Installer
**File:** `KayoScriptGen-Installer.exe`
- Professional Windows installer
- Start Menu integration
- Uninstall via Control Panel
- System Registry entries
- Best for: Professional deployment

```
Run KayoScriptGen-Installer.exe
Follow installation wizard
```

---

## Technical Details

### Python Environment Bundling
PyInstaller bundles:
- Python 3.x runtime
- All dependencies (requests, flask, etc.)
- Application code
- Data files (templates, config)

### File Structure in Executable
```
KayoScriptGen.exe
├── Python runtime
├── src/
│   ├── kayo_connector.py
│   ├── o11v4_generator.py
│   ├── web_server.py
│   └── main.py
├── templates/
│   ├── index.html
│   ├── app.js
│   └── style.css
└── config/
    └── kayo_config_example.json
```

### System Requirements
- Windows 7 or later
- 200 MB free disk space (for installation)
- 4 GB RAM recommended
- Internet connection (for Kayo API access)

---

## Troubleshooting

### Build Fails: "PyInstaller not found"
```batch
python -m pip install pyinstaller
build.bat
```

### Build Fails: "Python not in PATH"
- Reinstall Python
- Check "Add Python to PATH" during installation
- Use full path: `C:\Python3.11\python.exe build.bat`

### Executable is Large (100+ MB)
- This is normal - includes full Python runtime
- Cannot be significantly reduced
- Size is acceptable for modern systems

### NSIS Script Fails
- Install NSIS: https://nsis.sourceforge.io
- Ensure makensis.exe is in PATH
- Run from project root directory

---

## Advanced Configuration

### Modifying PyInstaller Spec
Edit `KayoScriptGen.spec` to:
- Change icon: Set `icon='path/to/icon.ico'`
- Add hidden imports: `hiddenimports=['module1', 'module2']`
- Exclude bloat: `excludedimports=['unused_module']`
- Change executable name: Modify `name='NewName'`

### Creating Custom Installer
1. Edit `installer.nsi`
2. Customize company name, copyright, etc.
3. Run `makensis.exe installer.nsi`

---

## Release Checklist

- [ ] Run `build.bat` successfully
- [ ] Test `dist/KayoScriptGen.exe` on clean system
- [ ] Run `create-installer.bat` if packaging
- [ ] Test installer on clean system
- [ ] Version files appropriately
- [ ] Create release notes
- [ ] Archive for distribution

---

## Next Steps

1. **Test the executable:**
   ```batch
   dist\KayoScriptGen.exe
   ```

2. **Create installer (if needed):**
   ```batch
   create-installer.bat
   ```

3. **Distribute to users:**
   - Share `dist/KayoScriptGen.exe` for direct use
   - Or create installer package for installation

---

## Support

For issues or questions:
- Check that all dependencies are installed
- Ensure Python is in system PATH
- Try rebuilding with clean source
- Check build.bat output for specific errors

Last Updated: April 8, 2026
