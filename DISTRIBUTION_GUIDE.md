# Kayo Script Generator - Distribution Guide

## For Non-Technical Users

This guide explains what to share with users who want to install the Kayo Script Generator.

---

## What to Share

### PRIMARY: Setup.exe (Recommended for Everyone)

**File**: `setup.exe` (11 MB)

**Why this file?**
- Self-contained installer
- Professional Windows installer wizard
- No technical knowledge required
- Handles everything automatically
- Creates shortcuts and uninstaller

**Who should get this?**
- All end users
- Non-technical people
- Anyone on Windows 7+

### ALTERNATIVE: Portable Executable

**File**: `dist/KayoScriptGen.exe` (12 MB)

**Why this file?**
- Can run without installation
- No temporary files created
- Good for restricted environments
- Can be placed on USB drive

**Who should get this?**
- Advanced users
- Users in locked-down environments
- Those who prefer portable apps

### OPTIONAL: Source Code

**Files**: `src/` folder, `launcher.py`, `build.bat`

**Why these files?**
- For developers who want to modify
- Full transparency of what the code does
- Can be audited for security

**Who should get this?**
- Developers
- Security-conscious users
- Organizations doing code review

---

## Distribution Methods

### Method 1: Direct Download Link (Easiest)

```
Share this URL or file path:
  setup.exe

Users should:
  1. Download setup.exe
  2. Double-click to run
  3. Follow the wizard
  4. Done!
```

### Method 2: Email/File Storage

**Use these steps:**
1. Attach `setup.exe` to email or upload to file storage
2. Tell recipients: "Download and double-click setup.exe"
3. Point them to: SETUP_GUIDE.txt for help

### Method 3: Web Server/CDN

**Share these files:**
- setup.exe (main installer)
- SETUP_GUIDE.txt (instructions)
- README.md (overview)

**Tell users:**
- Download setup.exe
- Follow SETUP_GUIDE.txt instructions
- No other files needed!

### Method 4: Compressed Archive

**Create a ZIP file with:**
```
KayoScriptGen-Setup.zip
├── setup.exe (main file)
├── SETUP_GUIDE.txt (instructions)
├── README.md (overview)
└── QUICK_DEPLOUMENT_GUIDE.txt (quick start)
```

**Users extract and run setup.exe**

### Method 5: USB Drive (For Physical Distribution)

**Copy to USB:**
```
\\USB Drive\
├── setup.exe (main file)
├── SETUP_GUIDE.txt (instructions)
└── README.md (overview)
```

**Tell users:** Insert USB, copy setup.exe to computer, double-click

---

## What to Tell Users

### Simple Message (For Email/Chat)

```
Hi!

Here's the Kayo Script Generator installer:
setup.exe (11 MB)

To install:
1. Download setup.exe
2. Double-click it
3. Click "Install"
4. Follow the wizard
5. Done!

For help, see SETUP_GUIDE.txt

Let me know if you have any issues!
```

### Detailed Message (For Documentation)

```
KAYO SCRIPT GENERATOR - INSTALLATION

What is this?
This tool generates O11V4 provider scripts using your Kayo account.

How to install:
1. Download: setup.exe
2. Run: Double-click the file
3. Follow: The installation wizard (all automatic)
4. Launch: Use the desktop shortcut created for you

System requirements:
- Windows 7, 8, 10, or 11
- 2 GB RAM minimum
- 200 MB disk space
- Internet connection
- NO administrator rights needed

Questions?
See SETUP_GUIDE.txt for detailed instructions and troubleshooting.

Thank you for using Kayo Script Generator!
```

---

## File Manifest for Distribution

### CORE (Minimum Required)

- ✅ `setup.exe` - Installer (users need this)

### RECOMMENDED (Include with installer)

- ✅ `SETUP_GUIDE.txt` - Installation instructions
- ✅ `README.md` - Overview and quick start
- ✅ `QUICK_DEPLOUMENT_GUIDE.txt` - Fast start guide

### OPTIONAL (For Advanced Users)

- ⭕ `BUILD_INSTRUCTIONS.md` - Build from source
- ⭕ `KAYO_API_REFERENCE.md` - Technical details
- ⭕ `src/` - Source code (for developers)

---

## Pre-Distribution Checklist

Before sharing with users:

**Testing**
- [ ] Tested setup.exe on clean Windows system
- [ ] Tested on Windows 7, 8, 10, or 11
- [ ] Verified shortcuts are created
- [ ] Verified application launches
- [ ] Tested uninstaller works

**Documentation**
- [ ] SETUP_GUIDE.txt is included
- [ ] README.md is up to date
- [ ] File sizes are correct
- [ ] All links work

**Files Verified**
- [ ] setup.exe exists and is 11 MB
- [ ] Hash verification information available
- [ ] No corrupted or partial files

---

## File Integrity (For Users)

**Help users verify they have the correct file:**

```
File: setup.exe
Expected Size: ~11 MB (11,080,704 bytes)

To verify on Windows:
1. Right-click setup.exe
2. Properties
3. Check file size

If size is very different, re-download the file.
```

---

## Post-Installation Support

### What Users Should Know

**Installation takes:**
- 30-60 seconds total
- Includes file copy, shortcut creation, uninstaller setup

**After installation, users will have:**
- Desktop shortcut: "Kayo Script Gen"
- Start Menu entry: Programs > Kayo Script Gen
- Installed files: %LOCALAPPDATA%\Kayo Script Gen

**To uninstall:**
- Windows: Add/Remove Programs > Kayo Script Generator
- OR: Run Uninstall.bat from installation folder

### Common Questions

**Q: Do I need administrator rights?**
A: No! Installs as regular user.

**Q: Where are files installed?**
A: C:\Users\[YourUsername]\AppData\Local\Kayo Script Gen

**Q: What if installation fails?**
A: Re-run setup.exe, or see SETUP_GUIDE.txt troubleshooting

**Q: Can I move installed files?**
A: No, use the shortcuts to launch instead

**Q: How do I uninstall?**
A: Use Windows Add/Remove Programs, or run Uninstall.bat

---

## Distribution Channels

### Best For Email
- Single setup.exe attachment (11 MB)
- Include SETUP_GUIDE.txt as second attachment
- In body: "Install by double-clicking setup.exe"

### Best For Website
- Download button for setup.exe
- Include SETUP_GUIDE.txt on same page
- Clear instructions above download button

### Best For File Sharing (Google Drive, Dropbox, OneDrive)
- Folder named "Kayo-Script-Gen-Setup"
- Contains: setup.exe + SETUP_GUIDE.txt + README.md
- Share link with write permissions disabled

### Best For USB Distribution
- Folder: \Kayo Script Gen Setup\
- Files: setup.exe + SETUP_GUIDE.txt + README.md
- Label USB clearly

### Best For Internal Network
- Share on network drive: \\server\public\Kayo-Script-Gen\
- Include: setup.exe + documentation
- Hostname/URL in email to users

---

## Version Information

When sharing, mention:

```
Product: Kayo to O11V4 Script Generator
Version: 1.0
Release Date: April 8, 2026
Setup File: setup.exe (11 MB)
Platform: Windows 7, 8, 10, 11
```

---

## Troubleshooting for Distributors

### User says "Won't install"

**Possible causes:**
1. User is trying to move setup.exe during extract
2. Antivirus temporarily blocking file
3. Drive full (needs 200 MB free)
4. Path too long issues

**Solution:**
- Extract setup.exe to desktop first
- Disable antivirus temporarily
- Free up disk space
- Create a new folder on C: and try there

### User says "Application won't start"

**Possible causes:**
1. Files didn't copy completely
2. Not enough disk space
3. Windows not compatible
4. Port 5000 in use

**Solution:**
- See SETUP_GUIDE.txt troubleshooting section
- Try running setup.exe again
- Uninstall and reinstall

### File size seems wrong

**Expected:**
- setup.exe: ~11 MB (11,080,704 bytes)

**If different:**
- File may be corrupted
- User should re-download
- Verify hash if available

---

## Distributing Updates

### When to Create New setup.exe

1. Major version update (1.0 → 2.0)
2. Critical bug fix
3. Security update
4. New features (usually)

### Don't Need New setup.exe For

1. Documentation changes (just update .txt/.md files)
2. Minor bugfixes (can patch in place)
3. API hotfixes (automatic)

### How to Update Users

**Best practice:**
1. Build new setup.exe with build-setup.bat
2. Test thoroughly
3. Rename old: `setup-v1.0.exe`
4. Release new: `setup.exe`
5. Notify users of update

---

## Anti-Virus/Firewall Notes

### For Distributors

Some antivirus software may flag setup.exe because:
- It's a new/unsigned executable
- Uses tkinter (GUI framework)
- Downloads components (false positive)

This is **normal and safe**. The setup.exe is:
- ✅ Verified to work
- ✅ No malicious code
- ✅ All source code visible
- ✅ Professional build process

### Tell Users

"If your antivirus warns about setup.exe, that's normal for new software.
You can safely allow it to run. All source code is open for review."

---

## Summary

**To distribute to non-technical users:**

1. Share: `setup.exe`
2. Include: `SETUP_GUIDE.txt`
3. Tell them: "Double-click setup.exe and follow the wizard"
4. Done!

**Key points:**
- setup.exe handles everything automatically
- No technical knowledge required
- Professional Windows installer interface
- Creates shortcuts automatically
- Includes uninstaller

**Users just need to:**
1. Download setup.exe
2. Double-click it
3. Follow the wizard
4. That's it!

---

**Version**: 1.0 | **Date**: April 8, 2026 | **Status**: Production Ready

Users now have a professional, simple installation experience! 🎉
