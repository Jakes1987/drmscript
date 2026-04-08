# GUI Not Opening - Troubleshooting Guide

## What's Happening

✓ The **application is running** (you see it in your taskbar)  
✗ The **web browser is not opening** automatically  

This is a common issue with Python applications on Windows. The web server is working fine - the browser just isn't opening automatically.

---

## Quick Fix (Try This First)

### Option 1: Manual Browser Launch
1. Open your web browser (Chrome, Edge, Firefox, etc.)
2. Go to: **http://localhost:5000**
3. The application should open!

**That's it!** The application was running the whole time.

---

### Option 2: Use the Launcher Batch File
1. In the installation folder, find: **LAUNCH_APP.bat**
2. Double-click it
3. This will launch the app AND open the browser

---

## Permanent Fix

### For All Windows Versions

We've updated the application to use a more reliable browser opening method. Here's what to do:

**Step 1: Reinstall**
1. Uninstall the current version (if installed)
   - Control Panel → Programs → Uninstall Kayo Script Generator
   - Or find Uninstall.bat in the installation folder and run it

2. Download the latest **setup.exe** (11 MB)

3. Run setup.exe and reinstall

**Step 2: Test**
- Double-click the desktop shortcut
- Browser should now open automatically
- If it still doesn't, use Option 1 above

---

## What Port Is It Using?

By default: **http://localhost:5000**

If port 5000 is busy, it automatically tries:
- 5001
- 5002
- 5003
- etc.

If you get a "connection refused" error, try these in your browser:
```
http://localhost:5000  (default)
http://localhost:5001  (if 5000 is busy)
http://localhost:5002  (if 5001 is busy)
```

---

## Browser Support

Tested with:
- ✅ Google Chrome
- ✅ Microsoft Edge
- ✅ Firefox
- ✅ Safari (Mac/Windows)
- ✅ Internet Explorer 11+

Any modern browser should work!

---

## Why Is This Happening?

When the application runs without a visible console window:
1. The server starts correctly (works fine)
2. The Python script tries to open the browser
3. Windows sometimes blocks this or the browser doesn't launch
4. The app keeps running, but you don't see it

**The server is fine - just manually open http://localhost:5000**

---

## Troubleshooting Steps

### Step 1: Verify Application is Running
```
Open Task Manager (Ctrl + Shift + Esc)
Look for: KayoScriptGen.exe or python.exe
```
If you see it → The app IS running ✓

### Step 2: Test the Web Server
```
Open your browser and go to: http://localhost:5000
```
If you see the web interface → It's working! ✓

### Step 3: Check Port Availability
Port 5000 might be in use by another application:
- Skype
- Other Python apps
- Docker
- Node.js servers

Try these alternatives in your browser:
- http://localhost:5001
- http://localhost:5002
- http://localhost:5003

---

## Command Line Launch (For Tech Users)

If you want to see detailed output, launch from command prompt:

```batch
REM From the installation directory:
cd "%LOCALAPPDATA%\Kayo Script Gen"
KayoScriptGen.exe

REM Or with specific port:
cd "%LOCALAPPDATA%\Kayo Script Gen" 
KayoScriptGen.exe --port 8080

REM To see the browser fail or succeed message
REM Run from command prompt (not background)
```

---

## Still Not Working?

### Check These:

1. **Is Windows Firewall blocking it?**
   - Windows Defender → Firewall → Allow an app through firewall
   - Make sure Python/KayoScriptGen is allowed
   - Or temporarily disable firewall to test

2. **Is another app using port 5000?**
   - Open Command Prompt as Admin
   - Type: `netstat -ano | findstr :5000`
   - If something is using it, try port 5001, 5002, etc.

3. **Does your default browser exist?**
   - Make sure you have a browser installed
   - Chrome, Edge, or Firefox (any modern browser)

4. **Is Python installed correctly?**
   - The app includes Python, so this shouldn't be an issue
   - But if you manually launch: `python --version`

---

## Solution Summary

| Issue | Solution |
|-------|----------|
| App runs but no GUI | Open http://localhost:5000 in your browser |
| Browser won't open | Use LAUNCH_APP.bat instead |
| Connection refused | Try http://localhost:5001 or 5002 |
| Multiple instances | Use Task Manager to close duplicates |
| Still frozen | Restart computer and try again |

---

## Quick Workaround

**Create a desktop shortcut that opens the web interface directly:**

1. Right-click desktop → New → Shortcut
2. Location: `http://localhost:5000`
3. Name: "Kayo Script Gen - Web Interface"
4. Click Finish
5. Now you can just click this shortcut to open it!

---

## For Help

See these files for more information:
- **SETUP_GUIDE.txt** - Installation help
- **README.md** - General overview
- **BUILD_INSTRUCTIONS.md** - Technical details

Or: Simply open http://localhost:5000 in your browser!

---

**The application is working - just open http://localhost:5000 in any web browser!**
