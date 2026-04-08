@echo off
REM Kayo Script Generator - Easy Launcher with Browser Fix
REM Use this if setup.exe doesn't open the GUI automatically

setlocal enabledelayedexpansion

cls
echo.
echo ========================================================
echo.
echo   Kayo to O11V4 Script Generator - Launcher
echo.
echo ========================================================
echo.

REM Find the installed executable
set "exe_path=%LOCALAPPDATA%\Kayo Script Gen\KayoScriptGen.exe"

REM If not found, check dist folder (developer mode)
if not exist "!exe_path!" (
    set "exe_path=%~dp0dist\KayoScriptGen.exe"
)

if not exist "!exe_path!" (
    echo ERROR: Cannot find KayoScriptGen.exe
    echo.
    echo Expected location: !exe_path!
    echo.
    echo Please run setup.exe to install first.
    echo.
    pause
    exit /b 1
)

echo Starting application...
echo.

REM Launch the application
start "" "!exe_path!"

REM Give it time to start
timeout /t 3 /nobreak >nul

echo.
echo Opening web browser...
echo.

REM Open the web interface
start http://localhost:5000

echo.
echo ========================================================
echo.
echo If browser doesn't open:
echo   1. Open http://localhost:5000 in your browser manually
echo   2. Or try a different port (e.g., http://localhost:5001)
echo.
echo The application should already be running in the background.
echo.
echo ========================================================
echo.

timeout /t 2 /nobreak >nul
exit /b 0
