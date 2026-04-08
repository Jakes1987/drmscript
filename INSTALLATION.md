# Installation & Setup Guide

## Quick Start (Windows)

1. **Install Python 3.7+** from https://www.python.org
   - ✓ Check "Add Python to PATH" during installation
   
2. **Install Dependencies:**
   ```bash
   # From project root directory
   pip install -r requirements.txt
   ```
   
3. **Launch the Web GUI:**
   ```bash
   # Option A: Double-click the launcher
   launcher.bat
   
   # Option B: Command line with custom port
   python launcher.py --port 8080
   ```

4. **Browser opens automatically** to `http://127.0.0.1:5000`

## Quick Start (macOS/Linux)

1. **Install Python 3.7+:**
   ```bash
   # macOS
   brew install python3
   
   # Ubuntu/Debian
   sudo apt-get install python3 python3-pip
   ```

2. **Install Dependencies:**
   ```bash
   pip3 install -r requirements.txt
   ```

3. **Launch the Web GUI:**
   ```bash
   # Make script executable (first time only)
   chmod +x launcher.sh
   
   # Run launcher
   ./launcher.sh
   
   # Or with custom options
   ./launcher.sh --port 8080
   ```

4. **Browser opens automatically** to `http://127.0.0.1:5000`

## CLI Launcher Options

All platforms support the same Python launcher:

```bash
# Launch with defaults (port 5000)
python launcher.py

# Launch on custom port
python launcher.py --port 8080
python launcher.py -p 8080

# Make accessible from other machines
python launcher.py --host 0.0.0.0

# Combine options
python launcher.py --host 0.0.0.0 --port 8080

# Don't auto-open browser
python launcher.py --no-browser

# Enable Flask debug mode (development only)
python launcher.py --debug

# Show help
python launcher.py --help
```

## Troubleshooting

### "Python is not installed or not found"
- Install Python 3.7+ from https://www.python.org
- **Windows**: Check "Add Python to PATH" during installation
- **macOS**: Use `brew install python3`
- **Linux**: Use package manager (`apt-get`, `yum`, etc.)

### "ModuleNotFoundError: No module named 'flask'"
```bash
# Reinstall dependencies
pip install -r requirements.txt --force-reinstall
```

### "Port 5000 already in use"
- Use a different port: `python launcher.py --port 8080`
- Or let the launcher auto-detect (if on default port)

### "Cannot open browser"
- Use `--no-browser` flag and manually open the URL
- Example: `python launcher.py --no-browser`
- Then visit `http://localhost:5000` in your browser

### "Connection refused" or "Cannot connect"
- Ensure server is running (check terminal window)
- Try `http://127.0.0.1:5000` instead of `localhost`
- Check firewall isn't blocking port 5000
- Try different port: `python launcher.py --port 8080`

### "Credentials test fails but are correct"
- Check Kayo account status (not locked/suspended)
- Test credentials via CLI first:
  ```bash
  python src/main.py --username user@example.com --password pass
  ```

### "Files not generating"
- Check browser console for JavaScript errors (F12)
- Verify output directory permissions
- Ensure disk space is available
- Check terminal for server errors

## Running Both CLI and GUI

Both versions work independently:

```bash
# Original CLI version
python src/main.py --help

# New Web GUI version
python launcher.py
```

You can use either version based on preference:
- **Web GUI**: Easier for non-technical users, real-time progress
- **CLI**: Better for automation, scripting, batch operations

## Accessing from Other Machines

To access the GUI from another machine on your network:

```bash
# Start server on all interfaces
python launcher.py --host 0.0.0.0

# Note the IP address from the console output
# Then visit: http://<your-ip>:5000
```

⚠️ Warning: Embedded credentials in web requests. Only use on trusted networks!

## Deployment

### Docker (Optional)

For containerized deployment:

```bash
# Build image
docker build -t kayo-generator .

# Run container
docker run -p 5000:5000 -v /path/to/output:/app/output kayo-generator
```

### systemd Service (Linux)

Create `/etc/systemd/system/kayo-generator.service`:

```ini
[Unit]
Description=Kayo to O11V4 Script Generator
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/path/to/Kayo Script Gen
ExecStart=/usr/bin/python3 launcher.py --host 0.0.0.0 --port 5000
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

Enable and start:
```bash
sudo systemctl enable kayo-generator
sudo systemctl start kayo-generator
```

## File Structure

```
Kayo Script Gen/
├── launcher.py              # Python launcher (all platforms)
├── launcher.bat             # Windows batch launcher
├── launcher.sh              # macOS/Linux shell launcher
├── requirements.txt         # Python dependencies
├── src/
│   ├── main.py             # Original CLI application
│   ├── web_server.py       # Flask web server
│   ├── kayo_connector.py   # Kayo API integration
│   └── o11v4_generator.py  # Script generator
├── templates/
│   ├── index.html          # Web interface
│   ├── app.js              # Frontend logic
│   └── style.css           # Styling
├── output/                 # Generated files (default)
└── config/                 # Configuration examples
```

## Next Steps

1. ✅ Install Python and dependencies
2. ✅ Start launcher (`launcher.py` / `launcher.bat` / `launcher.sh`)
3. ✅ Enter Kayo credentials and generate script
4. ✅ Download generated files
5. ✅ Copy to O11V4 installation:
   - `kayo.py` → `<O11V4_PATH>/scripts/`
   - `kayo.json` → `<O11V4_PATH>/providers/`
6. ✅ Restart O11V4

## Support

For issues:
- Check browser console (F12) for JavaScript errors
- Check terminal output for server errors
- Review WEB_GUI_GUIDE.md for detailed documentation
- Try the CLI version: `python src/main.py`

## Security Notes

⚠️ **Important:**
- Generated scripts contain embedded Kayo credentials
- Store files securely on trusted machines only
- Don't share scripts with untrusted parties
- Consider using environment variables for credentials in production
- Web interface transmits credentials over HTTP (use HTTPS in production)
