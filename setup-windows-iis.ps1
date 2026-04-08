# Kayo Script Generator - Windows IIS Reverse Proxy Setup
# This script configures IIS as a reverse proxy for remote GUI access
# Run as Administrator

param(
    [string]$ApplicationPort = 5000,
    [string]$SiteName = "KayoScriptGen",
    [string]$SiteBinding = "*:80:"
)

# Colors
$Success = "Green"
$Warning = "Yellow"
$Error = "Red"
$Info = "Cyan"

function Write-Title {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║                                                    ║" -ForegroundColor Cyan
    Write-Host "║  Kayo Script Gen - Windows IIS Setup              ║" -ForegroundColor Cyan
    Write-Host "║                                                    ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

function Check-Admin {
    $admin = [bool]([System.Security.Principal.WindowsIdentity]::GetCurrent().Groups -match "S-1-5-32-544")
    if (-not $admin) {
        Write-Host "ERROR: This script must be run as Administrator" -ForegroundColor $Error
        Exit 1
    }
}

function Check-IIS {
    Write-Host "Checking IIS Installation..." -ForegroundColor $Info
    
    if (-not (Get-WindowsFeature Web-Server -ErrorAction SilentlyContinue)) {
        Write-Host "IIS is not installed. Installing..." -ForegroundColor $Warning
        
        # Install IIS
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole -All -NoRestart
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-UrlRewrite -NoRestart
        
        Write-Host "IIS installed successfully. You may need to restart." -ForegroundColor $Success
    }
    else {
        Write-Host "✓ IIS is installed" -ForegroundColor $Success
    }
}

function Create-IIS-Website {
    Write-Host ""
    Write-Host "Setting up IIS Website..." -ForegroundColor $Info
    
    $AppPoolName = $SiteName + "AppPool"
    
    # Create Application Pool
    if (-not (Get-IISAppPool -Name $AppPoolName -ErrorAction SilentlyContinue)) {
        New-Item -Path "IIS:\AppPools\$AppPoolName" -Force | Out-Null
        Write-Host "✓ Application Pool created: $AppPoolName" -ForegroundColor $Success
    }
    else {
        Write-Host "✓ Application Pool exists: $AppPoolName" -ForegroundColor $Success
    }
    
    # Create Website
    if (-not (Get-IISSite -Name $SiteName -ErrorAction SilentlyContinue)) {
        New-IISSite -Name $SiteName -BindingInformation $SiteBinding -PhysicalPath "C:\inetpub\wwwroot\$SiteName" -ApplicationPool $AppPoolName -Force | Out-Null
        Write-Host "✓ Website created: $SiteName" -ForegroundColor $Success
    }
    else {
        Write-Host "✓ Website already exists: $SiteName" -ForegroundColor $Success
    }
}

function Add-IIS-Modules {
    Write-Host ""
    Write-Host "Installing required IIS modules..." -ForegroundColor $Info
    
    $modules = @(
        "IIS-ApplicationInit",
        "IIS-WebSockets",
        "IIS-UrlRewrite",
        "IIS-ApplicationDevelopment"
    )
    
    foreach ($module in $modules) {
        if (-not (Get-WindowsFeature $module -ErrorAction SilentlyContinue | Where-Object State -eq "Installed")) {
            Write-Host "Installing $module..." -ForegroundColor $Warning
            Enable-WindowsOptionalFeature -Online -FeatureName $module -NoRestart | Out-Null
        }
        else {
            Write-Host "✓ $module is installed" -ForegroundColor $Success
        }
    }
}

function Create-Web-Config {
    Write-Host ""
    Write-Host "Creating web.config with reverse proxy settings..." -ForegroundColor $Info
    
    $webConfigPath = "C:\inetpub\wwwroot\$SiteName\web.config"
    $webConfigDir = "C:\inetpub\wwwroot\$SiteName"
    
    # Create directory if not exists
    if (-not (Test-Path $webConfigDir)) {
        New-Item -ItemType Directory -Path $webConfigDir -Force | Out-Null
    }
    
    $webConfig = @"
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <system.webServer>
        <rewrite>
            <rules>
                <!-- Remove default document requirement -->
                <rule name="ReverseProxyInboundRule1" stopProcessing="true">
                    <match url="(.*)" />
                    <conditions logicalGrouping="MatchAll" trackAllCaptures="false" />
                    <action type="Rewrite" url="http://localhost:$ApplicationPort/{R:1}" />
                </rule>
            </rules>
            <!-- Reverse proxy settings -->
            <outboundRules>
                <rule name="ReverseProxyOutboundRule1" stopProcessing="false">
                    <match filterByTags="A, Form, Img" pattern="^http(s)?://localhost:$ApplicationPort/(.*)" />
                    <conditions logicalGrouping="MatchAll" trackAllCaptures="false" />
                    <action type="Rewrite" value="http{R:1}://{HTTP_HOST}/{R:2}" />
                </rule>
            </outboundRules>
        </rewrite>
        
        <!-- Enable WebSocket support -->
        <webSocket enabled="true" />
        
        <!-- Proxy settings -->
        <proxy enabled="true" />
        
        <!-- Application settings -->
        <applicationSettings>
            <add key="EnableBackendShutdown" value="false" />
        </applicationSettings>
    </system.webServer>
    
    <system.web>
        <httpRuntime maxRequestLength="2147483647" />
        <sessionState mode="InProc" />
    </system.web>
</configuration>
"@
    
    $webConfig | Out-File -FilePath $webConfigPath -Encoding UTF8 -Force
    Write-Host "✓ web.config created at: $webConfigPath" -ForegroundColor $Success
}

function Create-Batch-Launcher {
    Write-Host ""
    Write-Host "Creating IIS launcher script..." -ForegroundColor $Info
    
    $batchPath = "$env:USERPROFILE\Desktop\Launch-Kayo-IIS.bat"
    
    $batch = @"
@echo off
REM Kayo Script Generator - IIS Launch Script
REM This script starts your application and opens the browser

echo.
echo Kayo Script Generator - IIS Remote Access
echo =========================================
echo.
echo Starting application on localhost:$ApplicationPort...
echo.

cd /d "%USERPROFILE%\Documents\Kayo Script Gen"

REM Start the application
start python launcher.py

REM Wait for app to start
timeout /t 3 /nobreak

REM Open browser
echo Opening browser to http://localhost...
start http://localhost

echo.
echo Setup complete! Access locally or remotely:
echo   Local:    http://localhost
echo   Remote:   http://<your-ip-address>
echo.
echo Press Enter to continue...
pause
"@
    
    $batch | Out-File -FilePath $batchPath -Encoding ASCII -Force
    Write-Host "✓ Launcher created at: $batchPath" -ForegroundColor $Success
}

function Enable-Port {
    Write-Host ""
    Write-Host "Configuring Windows Firewall..." -ForegroundColor $Info
    
    # Allow port 80
    netsh advfirewall firewall add rule name="Allow HTTP for $SiteName" `
        dir=in action=allow protocol=tcp localport=80 profile=any | Out-Null
    
    # Allow port 443 (for HTTPS if needed)
    netsh advfirewall firewall add rule name="Allow HTTPS for $SiteName" `
        dir=in action=allow protocol=tcp localport=443 profile=any | Out-Null
    
    Write-Host "✓ Firewall rules configured" -ForegroundColor $Success
}

function Print-Summary {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║  ✓ IIS Setup Complete!                           ║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "NEXT STEPS:" -ForegroundColor $Success
    Write-Host ""
    Write-Host "1. Start your application:" -ForegroundColor $Info
    Write-Host "   python launcher.py" -ForegroundColor "White"
    Write-Host ""
    
    Write-Host "2. Access locally:" -ForegroundColor $Info
    Write-Host "   http://localhost" -ForegroundColor "White"
    Write-Host ""
    
    Write-Host "3. Access remotely:" -ForegroundColor $Info
    Write-Host "   http://<your-computer-ip-or-domain>" -ForegroundColor "White"
    Write-Host ""
    
    Write-Host "USEFUL COMMANDS:" -ForegroundColor $Success
    Write-Host ""
    Write-Host "  Open IIS Manager:          inetmgr" -ForegroundColor "White"
    Write-Host "  Restart IIS:               iisreset" -ForegroundColor "White"
    Write-Host "  Stop IIS:                  iisreset /stop" -ForegroundColor "White"
    Write-Host "  Start IIS:                 iisreset /start" -ForegroundColor "White"
    Write-Host "  View IIS logs:             C:\inetpub\logs\LogFiles" -ForegroundColor "White"
    Write-Host ""
    
    Write-Host "CONFIGURATION DETAILS:" -ForegroundColor $Success
    Write-Host ""
    Write-Host "  Site Name:                 $SiteName" -ForegroundColor "White"
    Write-Host "  Local Application Port:    $ApplicationPort" -ForegroundColor "White"
    Write-Host "  Site Binding:              $SiteBinding" -ForegroundColor "White"
    Write-Host "  Web Config:                C:\inetpub\wwwroot\$SiteName\web.config" -ForegroundColor "White"
    Write-Host ""
    
    Write-Host "TROUBLESHOOTING:" -ForegroundColor $Success
    Write-Host ""
    Write-Host "  - Check app runs on port $ApplicationPort" -ForegroundColor "White"
    Write-Host "  - Open IIS Manager and verify site is 'Running'" -ForegroundColor "White"
    Write-Host "  - Check firewall allows port 80" -ForegroundColor "White"
    Write-Host "  - Try: http://localhost (if local)" -ForegroundColor "White"
    Write-Host "  - View logs at: C:\inetpub\logs\LogFiles\" -ForegroundColor "White"
    Write-Host ""
    
    Write-Host "OPTIONAL: ADD HTTPS/SSL" -ForegroundColor $Success
    Write-Host ""
    Write-Host "  1. Get free certificate: https://letsencrypt.org/" -ForegroundColor "White"
    Write-Host "  2. Or use self-signed cert in IIS Manager" -ForegroundColor "White"
    Write-Host "  3. Add binding in IIS Manager" -ForegroundColor "White"
    Write-Host "  4. Update web.config if needed" -ForegroundColor "White"
    Write-Host ""
    
    Write-Host "=====================================================" -ForegroundColor Green
}

# Main execution
Write-Title
Check-Admin
Check-IIS
Add-IIS-Modules
Create-IIS-Website
Create-Web-Config
Create-Batch-Launcher
Enable-Port
Print-Summary

Write-Host "Setup complete! Launcher created on your Desktop." -ForegroundColor $Success
Write-Host ""
