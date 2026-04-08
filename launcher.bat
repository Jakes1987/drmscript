@echo off
REM Kayo to O11V4 Script Generator - Windows Launcher
REM This batch file launches the web GUI

setlocal enabledelayedexpansion

echo.
echo ============================================
echo Kayo to O11V4 Script Generator - Launcher
echo ============================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed or not in PATH
    echo Please install Python 3.7+ from https://www.python.org
    echo Make sure to check "Add Python to PATH" during installation
    pause
    exit /b 1
)

REM Get Python version for info
for /f "tokens=2" %%i in ('python --version 2^>^&1') do set PYTHON_VERSION=%%i
echo Using Python: !PYTHON_VERSION!
echo.

REM Check if requirements are installed
python -c "import flask" >nul 2>&1
if errorlevel 1 (
    echo.
    echo Installing dependencies... this may take a minute
    echo.
    python -m pip install -r requirements.txt
    if errorlevel 1 (
        echo ERROR: Failed to install dependencies
        pause
        exit /b 1
    )
)

REM Parse command line arguments
set PORT=5000
set HOST=127.0.0.1
set NO_BROWSER=0
set DEBUG=0

:parse_args
if "%~1"=="" goto start_app
if "%~1"=="--port" (
    set PORT=%~2
    shift
    shift
    goto parse_args
)
if "%~1"=="-p" (
    set PORT=%~2
    shift
    shift
    goto parse_args
)
if "%~1"=="--host" (
    set HOST=%~2
    shift
    shift
    goto parse_args
)
if "%~1"=="-H" (
    set HOST=%~2
    shift
    shift
    goto parse_args
)
if "%~1"=="--no-browser" (
    set NO_BROWSER=1
    shift
    goto parse_args
)
if "%~1"=="-nb" (
    set NO_BROWSER=1
    shift
    goto parse_args
)
if "%~1"=="--debug" (
    set DEBUG=1
    shift
    goto parse_args
)
if "%~1"=="--help" (
    echo Usage: launcher.bat [options]
    echo.
    echo Options:
    echo   --port PORT, -p PORT       Port to run on (default: 5000)
    echo   --host HOST, -H HOST       Host to bind to (default: 127.0.0.1)
    echo   --no-browser, -nb          Don't open browser
    echo   --debug                    Run in debug mode
    echo   --help                     Show this help message
    echo.
    exit /b 0
)
shift
goto parse_args

:start_app
cd /d "%~dp0"

echo Starting web server...
echo Host: !HOST!
echo Port: !PORT!
echo URL: http://!HOST!:!PORT!
echo.
echo Press Ctrl+C to stop the server
echo.

REM Start the server
if "%DEBUG%"=="1" (
    python launcher.py --host !HOST! --port !PORT! --debug
) else if "%NO_BROWSER%"=="1" (
    python launcher.py --host !HOST! --port !PORT! --no-browser
) else (
    python launcher.py --host !HOST! --port !PORT!
)

pause
