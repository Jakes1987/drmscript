# Uploading to GitHub & Ubuntu Installation Guide

## Step 1: Create GitHub Repository

### On GitHub Website:
1. Go to https://github.com/new
2. Fill in:
   - **Repository name**: `kayo-script-gen` (or your preference)
   - **Description**: "Kayo to O11V4 Script Generator - Generate provider scripts with real Kayo API integration"
   - **Public** ✓ (selected)
   - **Add a README file** ✓ (check this)
   - **Add .gitignore**: Python
   - Click **Create repository**

3. Copy the repository URL (will look like): `https://github.com/Jakes1987/drmscript`

---

## Step 2: Upload Project to GitHub

### In PowerShell (from project directory):

```powershell
# Navigate to project
cd "C:\Users\Jaco\Documents\Kayo Script Gen"

# Add GitHub as remote (replace with YOUR repo URL)
git remote add origin https://github.com/Jakes1987/drmscript

# Verify remote
git remote -v

# Add all files
git add .

# Create initial commit
git commit -m "Initial commit: Kayo Script Generator project"

# Push to GitHub
git branch -M main
git push -u origin main
```

Done! Your project is now on GitHub.

---

## Step 3: Update Installer Scripts with Your GitHub URL

The installer scripts need to know your GitHub repository URL.

### Edit `install-ubuntu.sh`:
Find the line:
```bash
REPO_URL="https://github.com/Jakes1987/drmscript"
```

Already updated with your GitHub username.

### Edit `install-one-liner.sh`:
Already updated with your GitHub username.

Then push these changes:
```powershell
git add install-ubuntu.sh install-one-liner.sh
git commit -m "Update installer URLs"
git push
```

---

## Step 4: Test the Installers

### Full Ubuntu Installer

On an Ubuntu/Debian system, run:
```bash
curl -fsSL https://raw.githubusercontent.com/Jakes1987/drmscript/main/install-ubuntu.sh | bash
```

Or download and run locally:
```bash
bash install-ubuntu.sh
```

### One-Liner Installation

On Ubuntu/Debian, users can simply run:
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Jakes1987/drmscript/main/install-one-liner.sh)
```

---

## What the Ubuntu Installer Does

1. ✅ Checks for Python 3 and Git (installs if missing)
2. ✅ Creates installation directory: `~/.local/kayo-script-gen`
3. ✅ Clones the GitHub repository
4. ✅ Installs Python dependencies: `pip3 install -r requirements.txt`
5. ✅ Creates a launcher script: `~/.local/bin/kayo-script-gen`
6. ✅ Creates a desktop application entry
7. ✅ Sets up everything for easy launching

---

## How Users Launch the Application

After installation, users can run the application in three ways:

### Method 1: Terminal Command (Easiest)
```bash
kayo-script-gen
```

### Method 2: Application Menu
Search for "Kayo Script Generator" in their application menu and click it.

### Method 3: Manual Path
```bash
~/.local/bin/kayo-script-gen
```

Then open: **http://localhost:5000** in their web browser

---

## Files in Your GitHub Repository

```
kayo-script-gen/
├── src/
│   ├── main.py
│   ├── kayo_connector.py
│   ├── o11v4_generator.py
│   ├── web_server.py
│   └── __init__.py
├── templates/
│   ├── index.html
│   ├── app.js
│   └── style.css
├── config/
│   └── kayo_config_example.json
├── launcher.py
├── install-ubuntu.sh (Ubuntu installer)
├── install-one-liner.sh (One-liner installer)
├── requirements.txt
├── README.md
├── .gitignore
└── [other documentation files]
```

---

## Quick Reference: Commands Your Users Will Use

### Ubuntu Installation (One Line)
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Jakes1987/drmscript/main/install-one-liner.sh)
```

### Launch Application
```bash
kayo-script-gen
```

### Open in Browser
```
http://localhost:5000
```

### Uninstall
```bash
rm -rf ~/.local/kayo-script-gen ~/.local/bin/kayo-script-gen
```

---

## GitHub Badges (Optional)

You can add these to your README.md:

```markdown
![Python 3.14+](https://img.shields.io/badge/python-3.14%2B-blue)
![License: MIT](https://img.shields.io/badge/license-MIT-green)
![Status: Production](https://img.shields.io/badge/status-production-brightgreen)
![Platform: Ubuntu/Debian](https://img.shields.io/badge/platform-ubuntu%2Fdebian-orange)
[![GitHub Release](https://img.shields.io/github/v/release/Jakes1987/drmscript)](https://github.com/Jakes1987/drmscript/releases)
```

---

## Troubleshooting Ubuntu Installation

### curl not found?
```bash
sudo apt-get install curl
```

### Python not installed?
```bash
sudo apt-get install python3 python3-pip
```

### Permission denied when running installer?
```bash
chmod +x install-ubuntu.sh
./install-ubuntu.sh
```

### Can't find kayo-script-gen command?
Add to your PATH:
```bash
export PATH="$HOME/.local/bin:$PATH"
```

Or add this line to `~/.bashrc` for permanent setup:
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

---

## For Windows Users (Different Method)

Windows users should use the `setup.exe` installer instead. See SETUP_EXE_READY.md

---

## Testing Your GitHub Setup

### Test Push
```powershell
git status  # Should show working tree clean
```

### Test Clone (from another directory)
```bash
cd /tmp
git clone https://github.com/yourusername/kayo-script-gen
cd kayo-script-gen
```

### Test One-Liner (on Linux/Mac)
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/yourusername/kayo-script-gen/main/install-one-liner.sh)
```

---

## Summary

1. ✅ Create GitHub repository
2. ✅ Push your code: `git push`
3. ✅ Update installer URLs with your GitHub username
4. ✅ Users can now install with one command
5. ✅ Users launch with: `kayo-script-gen`
6. ✅ Application opens at: `http://localhost:5000`

**Complete! Your project is now on GitHub with easy Ubuntu installation.**
