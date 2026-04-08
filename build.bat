@echo off
REM Kayo to O11V4 Script Generator - Build Script
REM Creates a standalone executable installer

setlocal enabledelayedexpansion
cd /d "%~dp0"

echo.
echo ============================================================
echo Kayo to O11V4 Script Generator - Build System
echo ============================================================
echo.

REM Check Python installation
echo [*] Checking Python installation...
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python is not installed or not in PATH
    pause
    exit /b 1
)
echo [OK] Python found

REM Check PyInstaller
echo [*] Checking PyInstaller...
python -m pip list | find "pyinstaller" >nul
if errorlevel 1 (
    echo [*] Installing PyInstaller...
    python -m pip install pyinstaller
)
echo [OK] PyInstaller available

REM Clean previous builds
if exist "build" (
    echo [*] Cleaning previous build artifacts...
    rmdir /s /q build
)
if exist "dist" (
    rmdir /s /q dist
)

REM Build executable
echo.
echo [*] Building standalone executable...
echo [*] This may take a few minutes...
echo.

python -m PyInstaller KayoScriptGen.spec --onefile --windowed

if errorlevel 1 (
    echo [ERROR] Build failed!
    pause
    exit /b 1
)

echo.
echo [OK] Build successful!
echo.

REM Check output
if exist "dist\KayoScriptGen.exe" (
    for /f "%%A in ('dir /b "dist\KayoScriptGen.exe"') do set "SIZE=%%~zA"
    echo [OK] Executable created: dist\KayoScriptGen.exe
    echo [*] File size: !SIZE! bytes
) else (
    echo [ERROR] Executable not found in dist folder
    pause
    exit /b 1
)

echo.
echo ============================================================
echo Build Complete!
echo ============================================================
echo.
echo The standalone executable is ready:
echo   Location: dist\KayoScriptGen.exe
echo.
echo You can now:
echo   1. Run it directly: dist\KayoScriptGen.exe
echo   2. Create an installer (optional)
echo   3. Distribute to other machines
echo.
echo Note: This executable includes all dependencies and will
echo work on any Windows system with .NET Framework 4.5+
echo.
pause
