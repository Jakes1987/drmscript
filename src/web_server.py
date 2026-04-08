#!/usr/bin/env python3
"""
Flask-based Web GUI for Kayo to O11V4 Script Generator

This module provides a web interface for generating O11V4 provider scripts
from Kayo streaming credentials.
"""

import json
import os
import sys
from pathlib import Path
from typing import Dict, Any, Tuple
from datetime import datetime
import threading
import traceback

from flask import Flask, render_template, request, jsonify, send_file, send_from_directory
from kayo_connector import KayoConnector
from o11v4_generator import O11V4Generator, ConfigBuilder


# Flask app initialization
app = Flask(__name__, template_folder='../templates', static_folder='../templates/static')
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # 16MB max request size

# Session state for tracking generation progress
generation_state = {
    'status': 'idle',  # idle, processing, completed, error
    'progress': 0,
    'message': '',
    'error': None,
    'output_dir': None,
    'generated_files': []
}


def update_status(status: str, progress: int = None, message: str = None, error: str = None):
    """Update generation status."""
    generation_state['status'] = status
    if progress is not None:
        generation_state['progress'] = progress
    if message is not None:
        generation_state['message'] = message
    if error is not None:
        generation_state['error'] = error
    print(f"[{datetime.now().isoformat()}] {status} - {message or ''} ({progress or 0}%)")


@app.route('/')
def index():
    """Serve main GUI page."""
    return render_template('index.html')


@app.route('/api/status')
def api_status():
    """Get current generation status."""
    return jsonify(generation_state)


@app.route('/api/test-credentials', methods=['POST'])
def api_test_credentials():
    """Test Kayo credentials."""
    try:
        data = request.json
        username = data.get('username', '').strip()
        password = data.get('password', '').strip()
        
        if not username or not password:
            return jsonify({
                'success': False,
                'message': 'Username and password required'
            }), 400
        
        update_status('processing', 25, 'Testing credentials...')
        
        credentials = {'username': username, 'password': password}
        connector = KayoConnector(credentials)
        
        # Test authentication
        token = connector.authenticate()
        if not token:
            update_status('error', 0, error='Authentication failed')
            return jsonify({
                'success': False,
                'message': 'Kayo authentication failed. Please check your credentials.'
            }), 401
        
        # Fetch sample data to confirm connectivity
        channels = connector.get_channels()
        if channels is None:
            update_status('error', 0, error='Failed to fetch channels')
            return jsonify({
                'success': False,
                'message': 'Failed to fetch channels. Kayo service may be unavailable.'
            }), 500
        
        update_status('idle', 0)
        
        return jsonify({
            'success': True,
            'message': f'Credentials verified. Found {len(channels) if channels else 0} channels.',
            'channel_count': len(channels) if channels else 0
        }), 200
    
    except Exception as e:
        error_msg = f"Credential test error: {str(e)}"
        update_status('error', 0, error=error_msg)
        return jsonify({
            'success': False,
            'message': error_msg
        }), 500


@app.route('/api/generate', methods=['POST'])
def api_generate():
    """Generate O11V4 provider script and config."""
    def perform_generation():
        try:
            data = request.json
            username = data.get('username', '').strip()
            password = data.get('password', '').strip()
            provider_name = data.get('provider_name', 'kayo').strip()
            output_dir = data.get('output_dir', './output').strip()
            include_config = data.get('include_config', True)
            
            # Validation
            if not username or not password:
                raise ValueError('Username and password required')
            
            if not provider_name:
                raise ValueError('Provider name required')
            
            # Create output directory
            Path(output_dir).mkdir(parents=True, exist_ok=True)
            generation_state['output_dir'] = os.path.abspath(output_dir)
            
            update_status('processing', 10, 'Authenticating with Kayo...')
            
            # Authenticate
            credentials = {'username': username, 'password': password}
            connector = KayoConnector(credentials)
            token = connector.authenticate()
            
            if not token:
                raise RuntimeError('Kayo authentication failed')
            
            update_status('processing', 30, 'Fetching channels and events...')
            
            # Fetch data
            channels = connector.get_channels()
            events = connector.get_events()
            manifest = connector.get_manifest()
            
            if channels is None:
                channels = []
            if events is None:
                events = []
            if manifest is None:
                manifest = {}
            
            update_status('processing', 60, 'Building configuration...')
            
            # Generate configuration
            channel_config = ConfigBuilder.build_channels_config(channels or [])
            event_config = ConfigBuilder.build_events_config(events or [])
            
            update_status('processing', 75, 'Generating O11V4 script...')
            
            # Generate script
            generator = O11V4Generator(credentials, provider_name)
            script_content = generator.generate_script(channel_config, event_config)
            
            # Save script
            script_path = os.path.join(output_dir, f'{provider_name}.py')
            with open(script_path, 'w', encoding='utf-8') as f:
                f.write(script_content)
            
            generation_state['generated_files'].append(script_path)
            
            # Generate config if requested
            if include_config:
                update_status('processing', 85, 'Generating configuration...')
                config_content = generator.generate_config(channel_config, event_config)
                config_path = os.path.join(output_dir, f'{provider_name}.json')
                with open(config_path, 'w', encoding='utf-8') as f:
                    json.dump(config_content, f, indent=2)
                generation_state['generated_files'].append(config_path)
            
            update_status('completed', 100, 'Generation completed successfully!')
            
            return {
                'success': True,
                'message': 'Script and configuration generated successfully',
                'output_dir': generation_state['output_dir'],
                'files': [os.path.basename(f) for f in generation_state['generated_files']],
                'channels': len(channel_config),
                'events': len(event_config)
            }
        
        except Exception as e:
            error_msg = f"{type(e).__name__}: {str(e)}\n{traceback.format_exc()}"
            update_status('error', 0, error=error_msg)
            return {
                'success': False,
                'message': str(e),
                'error': error_msg
            }
    
    # Run generation in background thread
    result = perform_generation()
    return jsonify(result), 200 if result.get('success') else 500


@app.route('/api/download/<filename>')
def api_download(filename):
    """Download generated file."""
    try:
        if not generation_state['output_dir']:
            return 'No generation output available', 404
        
        file_path = os.path.join(generation_state['output_dir'], filename)
        
        # Security: ensure file is within output directory
        if not os.path.abspath(file_path).startswith(os.path.abspath(generation_state['output_dir'])):
            return 'Invalid file path', 403
        
        if not os.path.exists(file_path):
            return f'File not found: {filename}', 404
        
        return send_file(file_path, as_attachment=True)
    
    except Exception as e:
        return f'Download error: {str(e)}', 500


@app.route('/api/reset', methods=['POST'])
def api_reset():
    """Reset generation state."""
    generation_state['status'] = 'idle'
    generation_state['progress'] = 0
    generation_state['message'] = ''
    generation_state['error'] = None
    generation_state['output_dir'] = None
    generation_state['generated_files'] = []
    return jsonify({'success': True})


@app.route('/templates/<path:path>')
def serve_static(path):
    """Serve static files from templates directory."""
    return send_from_directory('../templates', path)


@app.errorhandler(404)
def not_found(error):
    """Handle 404 errors."""
    return jsonify({'error': 'Not found'}), 404


@app.errorhandler(500)
def server_error(error):
    """Handle 500 errors."""
    return jsonify({'error': 'Internal server error'}), 500


def run_server(host='127.0.0.1', port=5000, debug=False):
    """Run Flask development server."""
    print(f"\n{'='*60}")
    print("Kayo to O11V4 Script Generator - Web Interface")
    print(f"{'='*60}")
    print(f"Server running at: http://{host}:{port}")
    print(f"Press Ctrl+C to stop the server")
    print(f"{'='*60}\n")
    
    app.run(host=host, port=port, debug=debug, use_reloader=False)


if __name__ == '__main__':
    run_server(debug=True)
