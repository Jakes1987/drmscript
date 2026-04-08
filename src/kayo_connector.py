"""
Kayo Streaming Service Connector
Handles authentication and content retrieval from Kayo streaming service

API Integration based on: https://github.com/etopiei/kayo and wrxtasy/plugin.video.kayo.sports
"""

import requests
import json
import time
from typing import Dict, List, Optional, Any
from datetime import datetime, timedelta
import logging

logger = logging.getLogger(__name__)


class KayoConnector:
    """Manages connection to Kayo streaming service and content retrieval"""
    
    # Real Kayo API Endpoints (from GitHub repo analysis)
    AUTH_URL = "https://auth.kayosports.com.au/oauth/token"
    PROFILES_URL = "https://profileapi.kayosports.com.au/user/profile"
    CONTENT_URL = "https://vccapi.kayosports.com.au/content/types/landing/names"
    CAROUSEL_URL = "https://vccapi.kayosports.com.au/content/types/carousel/keys"
    STREAM_URL = "https://vmndplay.kayosports.com.au/api/v1/asset/{}/play"
    SPORTS_MENU_URL = "https://resources.kayosports.com.au/production/sport-menu/lists/{}.json"
    IMAGES_URL = "https://vmndims.kayosports.com.au/api/v2/img/{}"
    
    # Client ID from official Kayo app
    CLIENT_ID = "qjmv9ZvaMDS9jGvHOxVfImLgQ3G5NrT2"
    
    def __init__(self, credentials: Dict[str, str]):
        """
        Initialize Kayo connector with user credentials
        
        Args:
            credentials: Dict with 'email'/'username' and 'password' keys
        """
        self.credentials = credentials
        self.session = requests.Session()
        self.access_token = None
        self.refresh_token = None
        self.token_expiry = None
        self.profile_id = None
        self.channels = []
        self.epg_data = {}
        
        # Official Kayo app user agent (critical for API compatibility)
        self.user_agent = "au.com.foxsports.core.App/1.1.5 (Linux;Android 8.1.0) ExoPlayerLib/2.7.3"
        
        self.headers = {
            "User-Agent": self.user_agent,
            "Content-Type": "application/json",
            "Origin": "https://kayosports.com.au"
        }
        
    def authenticate(self) -> bool:
        """
        Authenticate with Kayo using OAuth2 password-realm flow
        
        Returns:
            bool: True if authentication successful, False otherwise
        """
        try:
            logger.info("Authenticating with Kayo using OAuth2...")
            
            # OAuth2 password realm login
            payload = {
                "audience": "kayosports.com.au",
                "grant_type": "http://auth0.com/oauth/grant-type/password-realm",
                "scope": "openid offline_access",
                "realm": "prod-martian-database",
                "client_id": self.CLIENT_ID,
                "username": self.credentials.get("email") or self.credentials.get("username"),
                "password": self.credentials.get("password"),
            }
            
            response = self.session.post(self.AUTH_URL, json=payload, headers=self.headers, timeout=10)
            response.raise_for_status()
            
            auth_data = response.json()
            
            if "error" in auth_data:
                logger.error(f"OAuth error: {auth_data.get('error_description')}")
                return False
            
            self.access_token = auth_data.get("access_token")
            self.refresh_token = auth_data.get("refresh_token")
            
            # Token expires in typically 86400s (24h), subtract 15s for safety
            expires_in = auth_data.get("expires_in", 86400)
            self.token_expiry = int(time.time() + expires_in - 15)
            
            # Update headers with auth token
            self.headers["Authorization"] = f"Bearer {self.access_token}"
            
            # Auto-fetch profiles after authentication
            if not self._get_profiles():
                logger.warning("Could not fetch user profiles")
                return False
            
            logger.info(f"Authentication successful, profile: {self.profile_id}")
            return True
            
        except Exception as e:
            logger.error(f"Authentication failed: {str(e)}")
            return False
    
    def refresh_access_token(self) -> bool:
        """
        Refresh access token using refresh token
        
        Returns:
            bool: True if refresh successful, False otherwise
        """
        try:
            # Check if token still valid
            if time.time() < self.token_expiry:
                return True  # Token still valid
            
            if not self.refresh_token:
                logger.warning("No refresh token available")
                return False
                
            logger.info("Refreshing access token...")
            
            payload = {
                "grant_type": "refresh_token",
                "refresh_token": self.refresh_token,
                "client_id": self.CLIENT_ID,
            }
            
            response = self.session.post(self.AUTH_URL, json=payload, headers=self.headers, timeout=10)
            response.raise_for_status()
            
            auth_data = response.json()
            self.access_token = auth_data.get("access_token")
            expires_in = auth_data.get("expires_in", 86400)
            self.token_expiry = int(time.time() + expires_in - 15)
            
            logger.info("Token refresh successful")
            return True
            
        except Exception as e:
            logger.error(f"Token refresh failed: {str(e)}")
            return False
    
    def _get_profiles(self) -> bool:
        """
        Fetch user profiles and select first one
        
        Returns:
            bool: True if profile selected successfully
        """
        try:
            if not self.access_token:
                return False
            
            logger.info("Fetching user profiles...")
            response = self.session.get(self.PROFILES_URL, headers=self.headers, timeout=10)
            response.raise_for_status()
            
            profiles = response.json()
            if isinstance(profiles, list) and len(profiles) > 0:
                self.profile_id = profiles[0].get("id")
                logger.info(f"Selected profile: {profiles[0].get('name')}")
                return True
            
            logger.warning("No profiles available")
            return False
        except Exception as e:
            logger.warning(f"Could not fetch profiles: {str(e)}")
            return False
    
    def is_token_valid(self) -> bool:
        """Check if current token is still valid"""
        if not self.access_token or not self.token_expiry:
            return False
        return time.time() < self.token_expiry
    
    def ensure_token_valid(self) -> bool:
        """Ensure token is valid, refresh if needed"""
        if not self.is_token_valid():
            return self.refresh_access_token()
        return True
    
    def get_landing_content(self, name: str = "home") -> Dict[str, Any]:
        """
        Get landing page content (home, shows, sports, event, etc.)
        
        Args:
            name: Content name (home, shows, sports, event)
            
        Returns:
            Dict with content data or empty dict if failed
        """
        try:
            if not self.ensure_token_valid():
                logger.error("Cannot fetch content: token invalid")
                return {}
            
            if not self.profile_id:
                logger.error("No profile selected")
                return {}
            
            logger.info(f"Fetching landing content: {name}")
            
            params = {
                "evaluate": 99,
                "profile": self.profile_id,
            }
            
            url = f"{self.CONTENT_URL}/{name}"
            response = self.session.get(url, params=params, headers=self.headers, timeout=10)
            response.raise_for_status()
            
            return response.json()
            
        except Exception as e:
            logger.error(f"Failed to fetch content ({name}): {str(e)}")
            return {}
    
    def get_carousel(self, carousel_id: str) -> Dict[str, Any]:
        """
        Get carousel/show/episode content from Kayo
        
        Args:
            carousel_id: Carousel identifier
            
        Returns:
            Dict with carousel content
        """
        try:
            if not self.ensure_token_valid():
                return {}
            
            if not self.profile_id:
                return {}
            
            logger.info(f"Fetching carousel: {carousel_id}")
            
            params = {"profile": self.profile_id}
            url = f"{self.CAROUSEL_URL}/{carousel_id}"
            response = self.session.get(url, params=params, headers=self.headers, timeout=10)
            response.raise_for_status()
            
            data = response.json()
            return data[0] if data else {}
            
        except Exception as e:
            logger.error(f"Failed to fetch carousel: {str(e)}")
            return {}
    
    def get_stream(self, asset_id: str) -> Dict[str, Any]:
        """
        Get playable stream with manifest URI
        
        Args:
            asset_id: Content asset ID
            
        Returns:
            Dict with stream details including manifest URI
        """
        try:
            if not self.ensure_token_valid():
                logger.error("Cannot fetch stream: token invalid")
                return {}
            
            logger.info(f"Fetching stream for asset: {asset_id}")
            
            params = {
                "fields": "alternativeStreams,assetType,markers,metadata.isStreaming",
            }
            
            url = self.STREAM_URL.format(asset_id)
            response = self.session.post(url, params=params, json={}, headers=self.headers, timeout=10)
            response.raise_for_status()
            
            data = response.json()
            
            if "errors" in data:
                logger.error(f"Stream error: {data['errors'][0].get('detail')}")
                return {}
            
            stream = data.get("data", [{}])[0]
            
            # Select best stream (prefer HLS over DASH, Akamai as fallback)
            if "alternativeStreams" in stream:
                streams = [stream["recommendedStream"]] + stream["alternativeStreams"]
                playable = [s for s in streams if s.get("mediaFormat") in ["hls-ts", "dash"]]
                playable.sort(
                    key=lambda s: (s.get("mediaFormat") == "hls-ts", s.get("provider") == "AKAMAI"),
                    reverse=True
                )
                return playable[0] if playable else stream.get("recommendedStream", stream)
            
            return stream.get("recommendedStream", stream)
            
        except Exception as e:
            logger.error(f"Failed to fetch stream: {str(e)}")
            return {}
    
    def get_stream_url(self, asset_id: str) -> Optional[str]:
        """
        Get the actual HLS/DASH manifest URL ready to play
        
        Args:
            asset_id: Content asset ID
            
        Returns:
            Stream manifest URL or None if failed
        """
        try:
            stream = self.get_stream(asset_id)
            if stream and "manifest" in stream:
                manifest_url = stream["manifest"].get("uri")
                logger.info(f"Got stream URL: {manifest_url[:50]}...")
                return manifest_url
            return None
        except Exception as e:
            logger.error(f"Failed to get stream URL: {str(e)}")
            return None
    
    def get_channels(self) -> List[Dict[str, Any]]:
        """
        Fetch available channels - extracts from carousel content
        
        Returns:
            List of channel dictionaries
        """
        try:
            content = self.get_landing_content("shows")
            self.channels = []
            
            # Extract channels from content structure
            if isinstance(content, list):
                for item in content:
                    if item.get("type") == "carousel":
                        channel_data = {
                            "id": item.get("id"),
                            "name": item.get("name"),
                            "asset_id": item.get("asset_id")
                        }
                        self.channels.append(channel_data)
            
            logger.info(f"Retrieved {len(self.channels)} channels")
            return self.channels
            
        except Exception as e:
            logger.error(f"Failed to fetch channels: {str(e)}")
            return []
    
    def get_events(self, limit: int = 50) -> List[Dict[str, Any]]:
        """
        Fetch upcoming events from Kayo
        
        Args:
            limit: Maximum number of events to retrieve
            
        Returns:
            List of event dictionaries
        """
        try:
            content = self.get_landing_content("event")
            events = []
            
            # Extract events from landing content
            if isinstance(content, list) and len(content) > 0:
                for item in content:
                    if "contents" in item:
                        for content_item in item["contents"][:limit]:
                            event_data = {
                                "id": content_item.get("id"),
                                "title": content_item.get("title"),
                                "asset_id": content_item.get("asset_id"),
                                "start": content_item.get("start"),
                                "end": content_item.get("end")
                            }
                            events.append(event_data)
            
            logger.info(f"Retrieved {len(events)} events")
            return events
            
        except Exception as e:
            logger.error(f"Failed to fetch events: {str(e)}")
            return []
    
    def get_manifest(self) -> Dict[str, Any]:
        """
        Get provider manifest/metadata
        
        Returns:
            Dictionary containing provider metadata
        """
        try:
            manifest = {
                "provider": "kayo",
                "version": "1.0",
                "channels_count": len(self.channels or []),
                "authenticated": bool(self.access_token),
                "profile_id": self.profile_id,
                "last_updated": datetime.now().isoformat()
            }
            logger.info(f"Retrieved manifest: {manifest.get('provider')}")
            return manifest
            
        except Exception as e:
            logger.error(f"Failed to get manifest: {str(e)}")
            return {}
    
    def test_login(self) -> bool:
        """Test if login credentials are valid"""
        return self.authenticate()
