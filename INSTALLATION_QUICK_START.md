# Quick Installation Decision Flowchart

```
START: Choose your installation method
│
├─→ Do you have git installed?
│   ├─ YES → USE METHOD 1: git clone (Recommended)
│   │       git clone https://github.com/Jakes1987/drmscript.git
│   │       cd drmscript && bash install-one-liner.sh
│   │
│   └─ NO  → Continue below...
│
├─→ Have you seen curl download errors like:
│   │     "curl: (23) Failed writing body"?
│   │
│   ├─ YES → USE METHOD 2: setup-download.sh (Robust)
│   │       curl -fsSL https://raw.githubusercontent.com/Jakes1987/drmscript/main/setup-download.sh -o setup.sh
│   │       bash setup.sh
│   │
│   └─ NO  → Continue below...
│
├─→ Do you use a restrictive shell (sh, dash, busybox)?
│   │     (Or got error: "bash: /dev/fd/63: No such file"?)
│   │
│   ├─ YES → USE METHOD 2: setup-download.sh
│   │       (Same as above - handles restricted shells)
│   │
│   └─ NO  → Continue below...
│
├─→ Do you prefer automatic retries and error recovery?
│   │
│   ├─ YES → USE METHOD 3: install-complete.sh (Balanced)
│   │       curl -fsSL https://raw.githubusercontent.com/Jakes1987/drmscript/main/install-complete.sh -o install.sh
│   │       bash install.sh
│   │
│   └─ NO  → USE METHOD 4: install-one-liner.sh (Quick)
│           bash <(curl -fsSL https://raw.githubusercontent.com/Jakes1987/drmscript/main/install-one-liner.sh)
│
END
```

---

## Quick Start (Copy & Paste)

### For most users (recommended):
```bash
git clone https://github.com/Jakes1987/drmscript.git && cd drmscript && bash install-one-liner.sh
```

### If git is not available:
```bash
curl -fsSL https://raw.githubusercontent.com/Jakes1987/drmscript/main/setup-download.sh -o setup.sh && bash setup.sh
```

### If you've had download errors before:
```bash
curl -fsSL https://raw.githubusercontent.com/Jakes1987/drmscript/main/setup-download.sh -o setup.sh && bash setup.sh
```

---

## After Installation

The installation will:
1. ✅ Install Python 3.14+ dependencies
2. ✅ Configure Flask web server on port 5000
3. ✅ Set up Nginx reverse proxy on port 8080
4. ✅ Create `kayo-script-gen` command

**Test it:**
```bash
# Start the application
kayo-script-gen

# Open web browser (local access)
http://localhost:5000

# Remote access (from other machines, replace YOUR_SERVER_IP)
http://YOUR_SERVER_IP:8080
```

---

## Where to Find Help

- **Interactive Installation**: See [INSTALLATION_GUIDE.md](INSTALLATION_GUIDE.md) for detailed methods and troubleshooting
- **Nginx Setup**: See [NGINX_SETUP_GUIDE.md](NGINX_SETUP_GUIDE.md) for remote access configuration
- **Common Issues**: See section "Troubleshooting Installation Issues" in INSTALLATION_GUIDE.md
- **Port Conflicts**: Run `bash fix-port-conflict.sh`
- **SSL Issues**: Run `bash fix-nginx-ssl.sh`

