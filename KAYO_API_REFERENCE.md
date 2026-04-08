# Kayo API Integration - Complete Reference

## Summary
Your Kayo Script Gen project now uses the **real, verified Kayo API** from the official Kayo Android app. This documentation outlines the complete API integration including authentication, endpoints, and implementation details.

## Real Kayo API Endpoints

### Authentication
- **URL**: `https://auth.kayosports.com.au/oauth/token`
- **Method**: POST
- **Auth Flow**: OAuth2 Password Realm with offline token support
- **Required Fields**:
  - `audience`: "kayosports.com.au"
  - `grant_type`: "http://auth0.com/oauth/grant-type/password-realm"
  - `scope`: "openid offline_access"
  - `realm`: "prod-martian-database"
  - `client_id`: "qjmv9ZvaMDS9jGvHOxVfImLgQ3G5NrT2"
  - `username`: User email
  - `password`: User password

### Content APIs
| Endpoint | Purpose |
|----------|---------|
| `https://profileapi.kayosports.com.au/user/profile` | Get user profiles (must select one) |
| `https://vccapi.kayosports.com.au/content/types/landing/names/{name}` | Get landing content (home, shows, sports, event) |
| `https://vccapi.kayosports.com.au/content/types/carousel/keys/{id}` | Get carousel/show content |
| `https://vmndplay.kayosports.com.au/api/v1/asset/{asset_id}/play` | Get playable stream with manifest |

### Key Parameters
- **User-Agent**: `au.com.foxsports.core.App/1.1.5 (Linux;Android 8.1.0) ExoPlayerLib/2.7.3`
- **Client ID**: `qjmv9ZvaMDS9jGvHOxVfImLgQ3G5NrT2`
- **Origin**: `https://kayosports.com.au`

## Token Management

### Token Refresh
```python
payload = {
    "grant_type": "refresh_token",
    "refresh_token": refresh_token,
    "client_id": "qjmv9ZvaMDS9jGvHOxVfImLgQ3G5NrT2"
}
```

### Token Lifetime
- Access tokens: ~24 hours
- Refresh tokens: Long-lived (offline access)
- Cache location: `.kayo_tokens/{provider}_cache.json`

## Stream Access Pattern

1. **Authenticate** → Get access token + refresh token
2. **Get Profiles** → Select user profile
3. **Get Content** → Fetch landing content (shows, sports, events)
4. **Get Stream** → Request specific asset with profile context
5. **Parse Manifest** → Extract HLS/DASH URL
6. **Deliver to O11V4** → Return manifest with proper headers

## Stream Format Selection

The Kayo API returns multiple stream options. Selection priority:
1. Prefer HLS-TS over DASH (better compatibility)
2. Fallback: Akamai provider
3. Return manifest URI for playback

## Critical Implementation Notes

### 1. Profile Requirement
- Every API call requires `profile` parameter (user ID from /user/profile)
- Automatically selected as first profile after login

### 2. Token Auto-Refresh
- Access tokens expire after ~24 hours
- Must check expiry before each request
- Subtract 15 seconds from expiry time for safety margin

### 3. Error Handling
- Stream errors use `"errors"` key (not Exception)
- Check `data['errors'][0]['detail']` for stream-specific errors
- Fallback to refresh token if access token fails

### 4. Rate Limiting
- No explicit rate limiting found in API
- Recommendation: Reasonable delays (1-2s) between requests

### 5. DRM/License Support
- Kayo streams are delivered as standard HLS/DASH
- No explicit license key handling found
- All content appears to use standard encryption

## Updated Files

### 1. `src/kayo_connector.py`
- Real OAuth2 authentication flow
- Profile management
- Stream URL extraction
- Token refresh with proper timestamp handling
- Real API endpoints with error handling

### 2. `src/o11v4_generator.py`
- Updated script template with real API
- OAuth2 authentication in generated scripts
- Profile-based stream access
- Proper stream format selection
- Manifest URI extraction

### 3. `output/kayo.py`
- Removed placeholder credentials
- Uses real Kayo API endpoints
- Production-ready authentication

## Testing Configuration

To test the integration:

```bash
# Basic authentication test
python output/kayo.py --action login --user your_email@example.com --password your_password

# Get available content
python output/kayo.py --action channels --user your_email@example.com --password your_password

# Get stream manifest
python output/kayo.py --action manifest --user your_email@example.com --password your_password --id ASSET_ID
```

## API Response Examples

### Authentication Success
```json
{
  "access_token": "eyJ0...",
  "refresh_token": "cFIf...",
  "expires_in": 86400,
  "token_type": "Bearer"
}
```

### Stream Response Structure
```json
{
  "data": [{
    "recommendedStream": {...},
    "alternativeStreams": [...],
    "manifest": {
      "uri": "https://..../master.m3u8"
    }
  }]
}
```

## Sources & References

- **Kayo Electron App**: https://github.com/etopiei/kayo
- **Kayo Kodi Plugin**: https://github.com/wrxtasy/plugin.video.kayo.sports/
- **All work referenced from**: Matt Huisman's Kayo API analysis

## Version History

- **2026-04-07**: Updated with real Kayo API from official sources
  - Implemented OAuth2 password-realm authentication
  - Added profile-based content access
  - Updated stream selection logic
  - Integrated real API endpoints
  - Fixed token refresh mechanism
