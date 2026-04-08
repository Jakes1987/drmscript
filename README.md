# Kayo to O11V4 Script Generator

A professional streaming integration tool that connects to Kayo streaming service and generates production-ready O11V4 provider scripts and configuration files for seamless IPTV panel integration.

## Features

✅ **Automated Authentication** - Smart token caching with automatic refresh  
✅ **Live Channel Delivery** - Complete channel listing with instant manifest generation  
✅ **DRM Support** - External CDM integration for Widevine, PlayReady, and Verimatrix  
✅ **Session Intelligence** - Automatic playback cleanup and heartbeat maintenance  
✅ **Production Reliability** - Built-in error handling and graceful degradation  
✅ **Flexible Deployment** - Full proxy, DoH, and worker support via O11 framework  

## Installation

### Prerequisites

- Python 3.7 or higher
- pip (Python package manager)

### Setup

1. Clone or download this repository
2. Install dependencies:

```bash
pip install -r requirements.txt
```

## Usage

### 🌐 Web GUI (Easiest)

Launch the beautiful web interface:

**Windows:**
```bash
launcher.bat
```

**macOS/Linux:**
```bash
./launcher.sh
# or
python launcher.py
```

Browser opens automatically to `http://localhost:5000`

**Features:**
- ✅ User-friendly web interface
- ✅ Real-time progress monitoring
- ✅ Direct file downloads
- ✅ Credential testing before generation
- ✅ Responsive design for desktop and tablet

See [WEB_GUI_GUIDE.md](WEB_GUI_GUIDE.md) for detailed web interface documentation.

### 🖥️ CLI - Interactive Mode (Recommended)

Run the application without arguments for an interactive setup:

```bash
python src/main.py
```

The application will prompt you for:
- Kayo username/email
- Kayo password
- Provider name
- Output directory
- Options to fetch channels and events

### 💻 CLI - Command Line Mode

```bash
python src/main.py --username your_email@example.com --password your_password \
  --output ./my_provider --provider-name kayo --fetch-channels --fetch-events
```

### Command Line Options

```
--username, -u              Kayo username/email
--password, -p              Kayo password
--provider-name             Name for the provider (default: kayo)
--output, -o                Output directory for generated files
--fetch-channels            Fetch channels from Kayo and include in config
--fetch-events              Fetch events from Kayo and include in config
--include-all               Fetch both channels and events
--max-items                 Maximum number of channels/events to fetch (default: 50)
--script-only               Generate only the script file, skip config
--config-only               Generate only the config file, skip script
--force, -f                 Overwrite existing files
--verbose, -v               Enable verbose output
```

## Output Files

The tool generates two files:

### 1. Provider Script (`provider_name.py`)

A standalone Python script that handles:
- **Authentication** - Automatic token caching and refresh
- **Channel listing** - Retrieves available channels
- **Event listing** - Fetches upcoming events and VOD content
- **Manifest retrieval** - Gets streaming URLs with headers and CDN info
- **DRM handling** - Integrates with CDM services for protected content
- **Session management** - Keeps sessions alive with heartbeat

Supports all O11V4 actions:
- `channels` - Get list of available channels
- `events` - Get list of upcoming events
- `manifest` - Get streaming manifest with headers
- `cdm` - Get DRM keys for protected content
- `login` - Test account credentials
- `heartbeat` - Keep session alive

### 2. Configuration File (`provider_name.json`)

A comprehensive configuration that includes:
- Provider metadata (name, version, description)
- Account credentials
- Network configuration (timeouts, retries)
- DRM settings (type, CDM integration)
- Channel and event listings (if fetched)

## Integration with O11V4

After generation, integrate the files into your O11V4 installation:

### Step 1: Copy Files

```bash
# Copy the generated script to O11V4 scripts directory
cp -r provider_name.py /path/to/o11v4/scripts/

# Copy the generated config to O11V4 providers directory
cp provider_name.json /path/to/o11v4/providers/
```

### Step 2: Configure O11V4

1. Open O11V4 web interface
2. Navigate to **Config** tab
3. Select the new provider from the dropdown
4. Set up network parameters if needed (proxy, DoH, etc.)
5. Configure additional options (recording, autostart, etc.)

### Step 3: Launch

Start O11V4 and the Kayo provider will be available for streaming.

## Generated Script Details

The generated Python script is fully self-contained and includes:

- **Token Management** - Caches tokens locally with automatic refresh
- **Error Handling** - Graceful error handling with detailed logging
- **Network Support** - Proxy and DNS over HTTPS support
- **Flexible Output** - JSON output for O11V4 integration
- **DRM Integration** - Ready for external CDM services

### Example: Using the Generated Script

```bash
# Test authentication
python provider_name.py --action login --user email@example.com --password pass

# Get channels
python provider_name.py --action channels --user email@example.com --password pass

# Get manifest for a channel
python provider_name.py --action manifest --user email@example.com --password pass --id channel_id

# Get DRM keys
python provider_name.py --action cdm --user email@example.com --password pass --pssh pssh_data
```

## Project Structure

```
Kayo Script Gen/
├── src/
│   ├── __init__.py                 # Package initialization
│   ├── main.py                     # CLI application entry point
│   ├── kayo_connector.py           # Kayo API integration
│   └── o11v4_generator.py          # O11V4 script/config generation
├── config/                         # Configuration templates
├── templates/                      # Script templates
├── requirements.txt                # Python dependencies
└── README.md                       # This file
```

## Configuration File Format

The generated configuration file follows O11V4 JSON format:

```json
{
  "Info": {
    "Name": "Kayo",
    "Author": "O11V4 Integration",
    "Version": "1.0.0",
    "Description": "Kayo streaming provider for O11V4"
  },
  "Account": {
    "ScriptAccount": "kayo",
    "Enabled": true,
    "User": "your_email@example.com",
    "Password": "encrypted_password"
  },
  "Script": "kayo",
  "Channels": [...],
  "Events": [...],
  "NetworkConfiguration": {
    "System": "system",
    "Timeout": 30,
    "Retry": 3
  },
  "DRM": {
    "Type": "widevine",
    "UseCdm": false
  }
}
```

## Troubleshooting

### Authentication Failed
- Verify your Kayo username and password
- Check your internet connection
- Ensure your Kayo account is active

### Token Caching Issues
- Delete the `.kayo_tokens` directory to clear cached tokens
- Regenerate the script

### Manifest Retrieval Errors
- Check network connectivity
- Verify the channel ID is correct
- Ensure your Kayo account has access to the channel

### DRM/CDM Issues
- Verify the DRM type matches your content (widevine, playready, verimatrix)
- Ensure external CDM service is configured in O11V4

## Advanced Features

### Proxy Support

Configure proxy in O11V4 panel:
```bash
--proxy http://proxy.example.com:8080
--proxy socks5://user:pass@proxy.example.com:1080
```

### DNS over HTTPS (DoH)

Configure DoH in O11V4 panel:
```bash
--doh https://dns.google/dns-query
```

### Network Overrides

Set network parameters per channel in O11V4 configuration.

## Security Notes

- **Credentials**: Store securely. Generated tokens are cached locally only.
- **Token Refresh**: Tokens refresh automatically before expiry.
- **HTTPS Only**: All communications with Kayo are HTTPS encrypted.
- **No Credential Storage**: Credentials are passed at runtime, not stored in generated config.

## Support & Documentation

- **O11V4 Documentation**: Check O11V4 official docs for provider integration details
- **Kayo API**: This tool uses Kayo's public API endpoints
- **Issues**: Report issues when running the tool

## License

This tool is provided as-is for O11V4 integration purposes.

## Changelog

### Version 1.0.0 (Initial Release)
- Automated script generation from Kayo credentials
- Configuration file creation with channel/event listings
- Support for all O11V4 actions (channels, events, manifest, cdm, login, heartbeat)
- Token caching and automatic refresh
- Network configuration support (proxy, DoH)
- DRM integration ready
- Production-ready error handling
