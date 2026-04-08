# Kayo to O11V4 Generator - Quick Start Guide

## Installation

1. **Clone the repository**
   ```bash
   cd "C:\Users\Jaco\Documents\Kayo Script Gen"
   ```

2. **Install dependencies**
   ```bash
   python -m pip install -r requirements.txt
   ```

## Quick Start

### Interactive Mode (Recommended)

```bash
python src/main.py
```

This will prompt you for:
- Your Kayo account credentials
- Provider name
- Output directory
- Whether to fetch channels and events

### Command Line Mode

```bash
python src/main.py \
  --username your_email@example.com \
  --password your_password \
  --provider-name kayo \
  --output ./kayo_provider \
  --fetch-channels \
  --fetch-events
```

## Generated Files

After running, you'll get:

1. **kayo.py** - The O11V4 provider script
2. **kayo.json** - The configuration file with channels/events

## Integration with O11V4

### Step 1: Copy Files to O11V4

```bash
# For Windows O11V4 installation
xcopy "kayo.py" "C:\O11V4\scripts\" /Y
xcopy "kayo.json" "C:\O11V4\providers\" /Y
```

### Step 2: Restart O11V4

Restart the O11V4 application to load the new provider.

### Step 3: Configure in Web UI

1. Open O11V4 web interface (usually http://localhost:8000)
2. Go to **Config** tab
3. Select "Kayo" from the providers dropdown
4. Set up network parameters if needed
5. Configure channel streaming options

## Testing the Generated Script

### Test Authentication
```bash
python kayo.py --action login \
  --user your_email@example.com \
  --password your_password
```

Expected output: `logged in`

### Get Channels
```bash
python kayo.py --action channels \
  --user your_email@example.com \
  --password your_password
```

Expected output: JSON with list of channels

### Get Events
```bash
python kayo.py --action events \
  --user your_email@example.com \
  --password your_password
```

Expected output: JSON with list of events

## Project Structure

```
Kayo Script Gen/
├── src/
│   ├── main.py                    # CLI entry point
│   ├── kayo_connector.py          # Kayo API connector
│   └── o11v4_generator.py         # O11V4 script/config generator
├── config/
│   └── kayo_config_example.json   # Example configuration
├── output/                        # Generated files go here
├── requirements.txt               # Python dependencies
├── README.md                      # Full documentation
└── .gitignore                     # Git ignore rules
```

## Troubleshooting

### "Module not found" error
```bash
python -m pip install -r requirements.txt
```

### Authentication fails
- Verify your Kayo credentials
- Check internet connection
- Ensure Kayo account is active

### I want to regenerate files
```bash
python src/main.py --force --fetch-channels --fetch-events
```

## Key Features of Generated Script

✅ **Token Caching** - Tokens cached locally and auto-refreshed  
✅ **Channel Listing** - All available channels extracted  
✅ **Event Support** - Events/VOD content included  
✅ **DRM Ready** - Support for Widevine/PlayReady/Verimatrix  
✅ **Error Handling** - Graceful error handling and logging  
✅ **Network Config** - Proxy and DoH support built-in  

## Command Reference

### Main Application
```bash
python src/main.py [OPTIONS]
```

**Options:**
- `--username, -u` - Kayo username/email
- `--password, -p` - Kayo password
- `--provider-name` - Name for provider (default: kayo)
- `--output, -o` - Output directory
- `--fetch-channels` - Include channels in config
- `--fetch-events` - Include events in config
- `--include-all` - Fetch both channels and events
- `--force, -f` - Overwrite existing files
- `--verbose, -v` - Show detailed output

### Generated Script

```bash
python [provider_name].py --action [ACTION] [OPTIONS]
```

**Actions:**
- `login` - Test credentials
- `channels` - Get channel list
- `events` - Get event list
- `manifest` - Get streaming manifest
- `cdm` - Get DRM keys
- `heartbeat` - Send session heartbeat

## Next Steps

1. ✓ Install requirements
2. ✓ Run the generator to create your provider
3. ✓ Copy files to O11V4 installation
4. ✓ Restart O11V4
5. ✓ Configure streaming in web UI
6. ✓ Start streaming!

## Support

For issues or questions:
1. Check the README.md for detailed documentation
2. Review generated script comments for implementation details
3. Verify O11V4 installation and configuration
