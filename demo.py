#!/usr/bin/env python3
"""
Demonstration script showing the O11V4 Generator in action
"""

import sys
import os
import json

# Add src to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

from o11v4_generator import O11V4Generator, ConfigBuilder

def demo():
    """Run a demonstration of the generator."""
    
    print("\n" + "="*70)
    print("KAYO TO O11V4 SCRIPT GENERATOR - DEMONSTRATION")
    print("="*70 + "\n")
    
    # Create generator
    print("[1] Initializing O11V4 Generator...")
    generator = O11V4Generator(
        provider_name="kayo_demo",
        username="demo@example.com",
        password="demo_password"
    )
    print("✓ Generator initialized\n")
    
    # Generate script
    output_dir = "./output"
    script_path = os.path.join(output_dir, "kayo_demo.py")
    config_path = os.path.join(output_dir, "kayo_demo.json")
    
    os.makedirs(output_dir, exist_ok=True)
    
    print("[2] Generating O11V4 Provider Script...")
    if generator.generate_script(script_path):
        print(f"✓ Script generated: {script_path}")
        # Show file size
        size = os.path.getsize(script_path)
        print(f"  File size: {size:,} bytes\n")
    else:
        print(f"✗ Failed to generate script\n")
        return
    
    # Generate config
    print("[3] Building Sample Channel Configuration...")
    
    # Create sample channels
    channels = [
        ConfigBuilder.build_channel(
            name="ESPN Live",
            channel_id="espn_001",
            mode="live",
            on_demand=False,
            speed_up=True
        ),
        ConfigBuilder.build_channel(
            name="Fox Sports",
            channel_id="fox_sports_001",
            mode="live",
            on_demand=False,
            speed_up=True
        ),
        ConfigBuilder.build_channel(
            name="NBA League Pass",
            channel_id="nba_001",
            mode="live",
            on_demand=True,
            speed_up=True
        )
    ]
    
    print(f"✓ Created {len(channels)} sample channels\n")
    
    # Create sample events
    print("[4] Building Sample Event Configuration...")
    import time
    current_time = int(time.time())
    
    events = [
        ConfigBuilder.build_event(
            title="NBA Championship Game",
            event_id="evt_001",
            start_timestamp=current_time + 3600,
            end_timestamp=current_time + 7200,
            mode="vod",
            record_event=True
        ),
        ConfigBuilder.build_event(
            title="Champions League Football",
            event_id="evt_002",
            start_timestamp=current_time + 86400,
            end_timestamp=current_time + 90000,
            mode="vod",
            record_event=False
        )
    ]
    
    print(f"✓ Created {len(events)} sample events\n")
    
    # Generate config
    print("[5] Generating O11V4 Configuration File...")
    if generator.generate_config(config_path, channels=channels, events=events):
        print(f"✓ Config generated: {config_path}")
        size = os.path.getsize(config_path)
        print(f"  File size: {size:,} bytes\n")
    else:
        print(f"✗ Failed to generate config\n")
        return
    
    # Display sample script content
    print("[6] Generated Script Preview (first 30 lines):")
    print("-" * 70)
    with open(script_path, 'r') as f:
        lines = f.readlines()
        for i, line in enumerate(lines[:30], 1):
            print(line.rstrip())
    print("    ...\n    [Script continues with full O11V4 integration code]\n")
    print("-" * 70 + "\n")
    
    # Display config content
    print("[7] Generated Configuration Content:")
    print("-" * 70)
    with open(config_path, 'r') as f:
        config = json.load(f)
        # Pretty print first section
        print(json.dumps({
            "Info": config.get("Info"),
            "Account": config.get("Account"),
            "Script": config.get("Script"),
            "ChannelCount": len(config.get("Channels", [])),
            "EventCount": len(config.get("Events", [])),
            "DRM": config.get("DRM")
        }, indent=2))
    print("\n" + "-" * 70 + "\n")
    
    # Summary
    print("[8] GENERATION SUMMARY:")
    print("-" * 70)
    print(f"✓ Provider Name:        kayo_demo")
    print(f"✓ Script Generated:     {script_path}")
    print(f"✓ Config Generated:     {config_path}")
    print(f"✓ Channels in Config:   {len(channels)}")
    print(f"✓ Events in Config:     {len(events)}")
    print("-" * 70 + "\n")
    
    # Show usage instructions
    print("[9] NEXT STEPS:")
    print("-" * 70)
    print("1. Copy the generated script to O11V4 'scripts/' directory")
    print("   Example: cp kayo_demo.py /path/to/o11v4/scripts/")
    print()
    print("2. Copy the config to O11V4 'providers/' directory")
    print("   Example: cp kayo_demo.json /path/to/o11v4/providers/")
    print()
    print("3. Restart O11V4 to load the new provider")
    print()
    print("4. Access via O11V4 web interface and configure streams")
    print()
    print("5. (Optional) Test the script directly:")
    print("   python kayo_demo.py --action login --user your_email --password pass")
    print("-" * 70 + "\n")
    
    print("="*70)
    print("DEMONSTRATION COMPLETE - Files ready for O11V4 integration!")
    print("="*70 + "\n")

if __name__ == "__main__":
    demo()
