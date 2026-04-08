# Kayo to O11V4 Script Generator - Web GUI & Launcher

## Quick Start

### Installation

1. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

2. **Launch the web interface:**
   ```bash
   python launcher.py
   ```

The application will automatically:
- Start a Flask web server on `http://127.0.0.1:5000`
- Open your browser to the web interface
- Display server information in the terminal

## Using the Web GUI

### Step 1: Enter Kayo Credentials
- Enter your Kayo email/username and password
- Click **"Test Credentials"** to verify your account

### Step 2: Configure Output
- **Provider Name**: Name for the O11V4 provider (default: `kayo`)
- **Output Directory**: Where to save generated files (default: `./output`)
- **Include Config**: Generate both script and config, or script only (default: checked)

### Step 3: Generate
- Click **"Generate Script"** to start
- Monitor progress in real-time
- Download files when complete

## CLI Launcher Options

```bash
# Launch with default settings (port 5000)
python launcher.py

# Launch on custom port
python launcher.py --port 8080

# Launch without opening browser
python launcher.py --no-browser

# Make accessible from other machines on your network
python launcher.py --host 0.0.0.0

# Enable Flask debug mode (development only)
python launcher.py --debug

# Combine options
python launcher.py --host 0.0.0.0 --port 8080 --no-browser
```

## Launcher Features

- **Auto Port Detection**: If port 5000 is in use, automatically finds a free port
- **Browser Launch**: Automatically opens your default browser (can be disabled)
- **Credential Testing**: Verify Kayo credentials before generation
- **Progress Monitoring**: Real-time updates during script generation
- **File Download**: Download generated files directly from the UI
- **Session Storage**: Saves your provider settings between sessions

## Generated Files

The web GUI generates the same files as the CLI version:

- **`kayo.py`** (~12 KB)
  - Production-ready O11V4 provider script
  - Embedded authentication
  - Full O11V4 action support
  
- **`kayo.json`** (~600 bytes)
  - O11V4 provider configuration
  - Channel and event metadata
  - Network and DRM settings

## Deployment to O11V4

After generation:

1. **Copy script** to your O11V4 installation:
   ```
   <O11V4_PATH>/scripts/kayo.py
   ```

2. **Copy config** to your O11V4 installation:
   ```
   <O11V4_PATH>/providers/kayo.json
   ```

3. **Restart O11V4** to load the new provider

## Web GUI API Endpoints

The web server exposes several REST API endpoints for advanced usage:

### `GET /api/status`
Get current generation status and progress.

**Response:**
```json
{
  "status": "idle|processing|completed|error",
  "progress": 0-100,
  "message": "Status message",
  "error": null,
  "output_dir": "/path/to/output",
  "generated_files": ["kayo.py", "kayo.json"]
}
```

### `POST /api/test-credentials`
Test Kayo credentials.

**Request:**
```json
{
  "username": "user@example.com",
  "password": "password"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Credentials verified. Found 50 channels.",
  "channel_count": 50
}
```

### `POST /api/generate`
Generate O11V4 provider script and config.

**Request:**
```json
{
  "username": "user@example.com",
  "password": "password",
  "provider_name": "kayo",
  "output_dir": "./output",
  "include_config": true
}
```

**Response:**
```json
{
  "success": true,
  "message": "Script and configuration generated successfully",
  "output_dir": "/path/to/output",
  "files": ["kayo.py", "kayo.json"],
  "channels": 50,
  "events": 120
}
```

### `GET /api/download/<filename>`
Download a generated file.

### `POST /api/reset`
Reset generation state and UI.

## Troubleshooting

### Port Already in Use
The launcher will automatically detect and use another port. Check the console output for the actual URL.

### Browser Not Opening
Use the `--no-browser` flag and manually navigate to the URL shown in the console.

### Connection Refused
Ensure Flask is installed: `pip install Flask`

### Credentials Not Working
- Verify your Kayo credentials are correct
- Use the "Test Credentials" button to diagnose issues
- Check your Kayo account isn't locked or suspended

### Files Not Generating
- Check output directory permissions
- Ensure disk space is available
- Check browser console for JavaScript errors

## Keyboard Shortcuts

- **Enter** in password field: Test credentials
- **Ctrl+C** in terminal: Stop the server

## Security Notes

⚠️ **Important:**
- Generated scripts contain embedded credentials
- Store generated files securely
- Do not share scripts with untrusted parties
- Consider using environment variables or secure vaults for credentials in production

## Development

### Project Structure
```
.
├── launcher.py              # CLI launcher entry point
├── src/
│   ├── main.py             # Original CLI application
│   ├── web_server.py       # Flask web server
│   ├── kayo_connector.py   # Kayo API integration
│   └── o11v4_generator.py  # Script/config generator
├── templates/
│   ├── index.html          # Main GUI page
│   ├── app.js              # Frontend JavaScript
│   └── style.css           # Styling
└── requirements.txt        # Python dependencies
```

### Adding Features

To add new functionality:
1. Add API endpoint in `src/web_server.py`
2. Add HTML elements in `templates/index.html`
3. Add JavaScript handlers in `templates/app.js`
4. Add CSS styling in `templates/style.css`

## Support

For issues or feature requests, check the main project documentation or test the CLI version:
```bash
python src/main.py --help
```
