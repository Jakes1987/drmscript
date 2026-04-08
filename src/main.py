#!/usr/bin/env python3
"""
Kayo to O11V4 Script Generator - Main CLI Application

This application connects to Kayo streaming service and generates production-ready
O11V4 provider scripts and configuration files for integration with O11V4 panels.
"""

import argparse
import json
import os
import sys
from pathlib import Path
from typing import Optional

from .kayo_connector import KayoConnector
from .o11v4_generator import O11V4Generator, ConfigBuilder


def create_arg_parser() -> argparse.ArgumentParser:
    """Create and configure argument parser."""
    parser = argparse.ArgumentParser(
        description="Generate O11V4 provider script and config from Kayo credentials",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Generate with interactive prompts
  python main.py

  # Generate with command-line arguments
  python main.py --username user@example.com --password mypass --output ./my_provider --provider-name kayo

  # Generate and fetch channels
  python main.py --username user@example.com --password mypass --fetch-channels --output ./my_provider
        """
    )
    
    parser.add_argument(
        '--username', '-u',
        help='Kayo username/email'
    )
    
    parser.add_argument(
        '--password', '-p',
        help='Kayo password'
    )
    
    parser.add_argument(
        '--provider-name',
        default='kayo',
        help='Name for the provider (default: kayo)'
    )
    
    parser.add_argument(
        '--output', '-o',
        help='Output directory for generated files (user will be prompted if not provided)'
    )
    
    parser.add_argument(
        '--fetch-channels',
        action='store_true',
        help='Fetch channels from Kayo and include in config'
    )
    
    parser.add_argument(
        '--fetch-events',
        action='store_true',
        help='Fetch events from Kayo and include in config'
    )
    
    parser.add_argument(
        '--include-all',
        action='store_true',
        help='Fetch both channels and events'
    )
    
    parser.add_argument(
        '--max-items',
        type=int,
        default=50,
        help='Maximum number of channels/events to fetch (default: 50)'
    )
    
    parser.add_argument(
        '--script-only',
        action='store_true',
        help='Generate only the script file, skip config'
    )
    
    parser.add_argument(
        '--config-only',
        action='store_true',
        help='Generate only the config file, skip script'
    )
    
    parser.add_argument(
        '--force', '-f',
        action='store_true',
        help='Overwrite existing files'
    )
    
    parser.add_argument(
        '--verbose', '-v',
        action='store_true',
        help='Enable verbose output'
    )
    
    return parser


def get_user_input(prompt: str, default: Optional[str] = None, password: bool = False) -> str:
    """
    Get user input from prompt.
    
    Args:
        prompt: Prompt message
        default: Default value if user enters nothing
        password: If True, mask input (for passwords)
        
    Returns:
        User input or default value
    """
    if password:
        import getpass
        return getpass.getpass(prompt)
    else:
        user_input = input(prompt)
        return user_input if user_input else (default or "")


def interactive_setup() -> dict:
    """
    Run interactive setup flow.
    
    Returns:
        Configuration dictionary with user inputs
    """
    print("\n" + "="*60)
    print("Kayo to O11V4 Script Generator - Interactive Setup")
    print("="*60 + "\n")
    
    config = {}
    
    # Get Kayo credentials
    print("Step 1: Kayo Credentials")
    print("-" * 40)
    config['username'] = get_user_input("Enter Kayo username/email: ")
    config['password'] = get_user_input("Enter Kayo password: ", password=True)
    
    # Get provider name
    print("\nStep 2: Provider Configuration")
    print("-" * 40)
    config['provider_name'] = get_user_input("Provider name (default: kayo): ", default="kayo")
    
    # Get output directory
    print("\nStep 3: Output Location")
    print("-" * 40)
    default_output = os.path.join(os.getcwd(), "o11v4_output")
    config['output'] = get_user_input(f"Output directory (default: {default_output}): ", default=default_output)
    
    # Ask about fetching data
    print("\nStep 4: Data Fetching (Optional)")
    print("-" * 40)
    fetch_choice = get_user_input("Fetch channels? (y/n, default: y): ", default="y").lower()
    config['fetch_channels'] = fetch_choice != 'n'
    
    if config['fetch_channels']:
        events_choice = get_user_input("Also fetch events? (y/n, default: y): ", default="y").lower()
        config['fetch_events'] = events_choice != 'n'
    else:
        config['fetch_events'] = False
    
    return config


def fetch_and_build_channels(connector: KayoConnector, max_items: int = 50) -> list:
    """
    Fetch channels from Kayo and build O11V4 config.
    
    Args:
        connector: KayoConnector instance
        max_items: Maximum number of items to fetch
        
    Returns:
        List of O11V4 channel configurations
    """
    print("Fetching channels from Kayo...")
    channels = connector.get_channels()
    
    o11_channels = []
    for i, channel in enumerate(channels[:max_items]):
        o11_channel = ConfigBuilder.build_channel(
            name=channel.get('name', f'Channel {i+1}'),
            channel_id=channel.get('id', f'ch_{i+1}'),
            mode='live',
            on_demand=False,
            speed_up=True,
            autostart=False
        )
        o11_channels.append(o11_channel)
    
    print(f"Successfully fetched {len(o11_channels)} channels")
    return o11_channels


def fetch_and_build_events(connector: KayoConnector, max_items: int = 50) -> list:
    """
    Fetch events from Kayo and build O11V4 config.
    
    Args:
        connector: KayoConnector instance
        max_items: Maximum number of items to fetch
        
    Returns:
        List of O11V4 event configurations
    """
    print("Fetching events from Kayo...")
    events = connector.get_events(limit=max_items)
    
    o11_events = []
    for i, event in enumerate(events[:max_items]):
        # Parse timestamps (assuming ISO format)
        try:
            from datetime import datetime as dt
            start = int(dt.fromisoformat(event.get('start', dt.now().isoformat())).timestamp())
            end = int(dt.fromisoformat(event.get('end', dt.now().isoformat())).timestamp())
        except:
            start = int(dt.now().timestamp())
            end = start + 3600
        
        o11_event = ConfigBuilder.build_event(
            title=event.get('title', f'Event {i+1}'),
            event_id=event.get('id', f'evt_{i+1}'),
            start_timestamp=start,
            end_timestamp=end,
            mode='vod'
        )
        o11_events.append(o11_event)
    
    print(f"Successfully fetched {len(o11_events)} events")
    return o11_events


def main():
    """Main entry point."""
    
    parser = create_arg_parser()
    args = parser.parse_args()
    
    # If no username provided, run interactive setup
    if not args.username:
        config = interactive_setup()
        args.username = config['username']
        args.password = config['password']
        args.provider_name = config['provider_name']
        args.output = config['output']
        args.fetch_channels = config['fetch_channels']
        args.fetch_events = config['fetch_events']
    
    # Validate required inputs
    if not args.username or not args.password:
        print("Error: Username and password are required", file=sys.stderr)
        sys.exit(1)
    
    if not args.output:
        default_output = os.path.join(os.getcwd(), "o11v4_output")
        args.output = input(f"Output directory (default: {default_output}): ") or default_output
    
    # Handle include_all flag
    if args.include_all:
        args.fetch_channels = True
        args.fetch_events = True
    
    # Create output directory
    output_dir = Path(args.output)
    output_dir.mkdir(parents=True, exist_ok=True)
    
    if args.verbose:
        print(f"Output directory: {output_dir}")
        print(f"Provider name: {args.provider_name}")
    
    # Initialize generator
    generator = O11V4Generator(
        provider_name=args.provider_name,
        username=args.username,
        password=args.password
    )
    
    script_path = output_dir / f"{args.provider_name}.py"
    config_path = output_dir / f"{args.provider_name}.json"
    
    # Check for existing files
    if not args.force:
        if script_path.exists() and not args.config_only:
            print(f"Warning: {script_path} already exists. Use --force to overwrite.", file=sys.stderr)
        if config_path.exists() and not args.script_only:
            print(f"Warning: {config_path} already exists. Use --force to overwrite.", file=sys.stderr)
    
    # Generate script
    if not args.config_only:
        print(f"\nGenerating O11V4 provider script: {script_path}")
        if generator.generate_script(str(script_path)):
            print(f"[OK] Script generated successfully")
        else:
            print(f"✗ Failed to generate script", file=sys.stderr)
            sys.exit(1)
    
    # Fetch data and generate config
    channels = []
    events = []
    
    if not args.script_only and (args.fetch_channels or args.fetch_events or not args.username):
        try:
            print("\nConnecting to Kayo...")
            connector = KayoConnector({"email": args.username, "password": args.password})
            
            if not connector.authenticate():
                print("Authentication failed. Check your credentials.", file=sys.stderr)
                sys.exit(1)
            
            print("[OK] Authentication successful")
            
            if args.fetch_channels:
                channels = fetch_and_build_channels(connector, args.max_items)
            
            if args.fetch_events:
                events = fetch_and_build_events(connector, args.max_items)
            
            try:
                connector.session.close()
            except:
                pass
            
        except Exception as e:
            print(f"✗ Error fetching data from Kayo: {e}", file=sys.stderr)
            if args.verbose:
                import traceback
                traceback.print_exc()
    
    # Generate config
    if not args.script_only:
        print(f"\nGenerating O11V4 configuration: {config_path}")
        if generator.generate_config(channels=channels, events=events, output_path=str(config_path)):
            print(f"[OK] Configuration generated successfully")
        else:
            print(f"✗ Failed to generate configuration", file=sys.stderr)
            sys.exit(1)
    
    # Summary
    print("\n" + "="*60)
    print("Generation Complete!")
    print("="*60)
    print(f"Output directory: {output_dir}")
    if not args.config_only:
        print(f"Script file: {script_path}")
    if not args.script_only:
        print(f"Config file: {config_path}")
        if channels:
            print(f"Channels included: {len(channels)}")
        if events:
            print(f"Events included: {len(events)}")
    print("\nNext steps:")
    print("1. Copy the generated files to your O11V4 installation")
    print("2. Place the script in the 'scripts/' directory")
    print("3. Place the config in the 'providers/' directory")
    print("4. Restart O11V4 to load the new provider")
    print("="*60 + "\n")


if __name__ == '__main__':
    main()
