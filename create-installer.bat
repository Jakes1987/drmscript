@echo off
REM Kayo to O11V4 Script Generator - Simple Installer Creator
REM Creates a self-contained installer exe

setlocal enabledelayedexpansion
cd /d "%~dp0"

echo.
echo ============================================================
echo Kayo Script Gen - Installer Creation
echo ============================================================
echo.

REM Check if executable exists
if not exist "dist\KayoScriptGen.exe" (
    echo [ERROR] Executable not found
    echo [*] Please run build.bat first
    pause
    exit /b 1
)

echo [*] Packaging application...

REM Create installer directory
if exist "installer_temp" rmdir /s /q installer_temp
mkdir installer_temp

REM Copy executable
copy "dist\KayoScriptGen.exe" "installer_temp\"

REM Create install batch script
(
    echo @echo off
    echo title Kayo to O11V4 Script Generator - Installation
    echo echo.
    echo echo ============================================================
    echo echo Kayo to O11V4 Script Generator - Installer
    echo echo ============================================================
    echo echo.
    echo echo Choose installation location:
    echo echo.
    echo set "INSTALL_DIR=%PROGRAMFILES%\Kayo Script Gen"
    echo echo [*] Default location: !INSTALL_DIR!
    echo echo.
    echo set /p CONFIRM="Install to this location? (Y/n): "
    echo if /i "!CONFIRM!"=="n" (
    echo     set /p INSTALL_DIR="Enter custom path: "
    echo ^)
    echo.
    echo if not exist "!INSTALL_DIR!" mkdir "!INSTALL_DIR!"
    echo.
    echo echo [*] Installing files...
    echo copy "KayoScriptGen.exe" "!INSTALL_DIR!\"
    echo.
    echo echo [*] Creating shortcuts...
    echo if not exist "%%USERPROFILE%%\Desktop" mkdir "%%USERPROFILE%%\Desktop"
    echo powershell -Command "^$WshShell = New-Object -ComObject WScript.Shell; ^$Shortcut = ^$WshShell.CreateShortcut('%%USERPROFILE%%\Desktop\Kayo Script Gen.lnk'); ^$Shortcut.TargetPath = '!INSTALL_DIR!\KayoScriptGen.exe'; ^$Shortcut.Save(^)"
    echo.
    echo echo [OK] Installation complete!
    echo echo.
    echo echo You can now run: !INSTALL_DIR!\KayoScriptGen.exe
    echo echo Or use the shortcut on your Desktop
    echo echo.
    echo pause
) > "installer_temp\Install.bat"

REM Create uninstall batch script
(
    echo @echo off
    echo title Kayo Script Gen - Uninstall
    echo echo.
    echo set /p INSTALL_DIR="Enter installation path (default: %PROGRAMFILES%\Kayo Script Gen): "
    echo if "!INSTALL_DIR!"=="" set "INSTALL_DIR=%PROGRAMFILES%\Kayo Script Gen"
    echo.
    echo echo [*] Removing files...
    echo if exist "!INSTALL_DIR!" rmdir /s /q "!INSTALL_DIR!"
    echo.
    echo echo [*] Removing shortcuts...
    echo if exist "%%USERPROFILE%%\Desktop\Kayo Script Gen.lnk" del "%%USERPROFILE%%\Desktop\Kayo Script Gen.lnk"
    echo echo [OK] Uninstall complete!
    echo pause
) > "installer_temp\Uninstall.bat"

REM Create README
(
    echo Kayo to O11V4 Script Generator - Installation Package
    echo.
    echo Contents:
    echo - KayoScriptGen.exe: Main application
    echo - Install.bat: Installation script
    echo - Uninstall.bat: Uninstall script
    echo - README.txt: This file
    echo.
    echo Installation:
    echo 1. Extract this archive
    echo 2. Run Install.bat
    echo 3. Follow the installation wizard
    echo.
    echo Usage:
    echo Run KayoScriptGen.exe or use the Desktop shortcut
    echo.
    echo Uninstallation:
    echo Run Uninstall.bat from the installation directory
    echo.
) > "installer_temp\README.txt"

echo [OK] Packaged files

REM Note: For a true .exe installer, NSIS or similar is needed
REM For now, we create a zip package that acts as installer
echo.
echo [*] Creating installer package...
echo.
echo To create a full .exe installer, you can:
echo 1. Install NSIS from https://nsis.sourceforge.io
echo 2. Run: makensis.exe installer.nsi
echo.
echo For portable use, zip the contents of installer_temp\
echo.

REM Show directory structure
echo ============================================================
echo Installer Contents:
echo ============================================================
dir /b "installer_temp\"

echo.
echo ============================================================
echo Installer creation options:
echo ============================================================
echo.
echo Option 1: Use the installer_temp folder as-is
echo   - Portable (no installation required)
echo   - Run Install.bat to set up shortcuts
echo.
echo Option 2: Create NSIS installer (requires NSIS)
echo   - Professional .exe installer
echo   - Run: makensis.exe installer.nsi
echo.
echo Option 3: Create self-extracting archive (requires 7-Zip)
echo   - Single .exe file with built-in extraction
echo   - Run: 7z a -sfx KayoScriptGen-Setup.exe installer_temp\
echo.

pause
