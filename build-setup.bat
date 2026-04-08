@echo off
REM Build script for setup.exe
REM Requirements: Python with PyInstaller installed

setlocal enabledelayedexpansion

cd /d "%~dp0"

echo.
echo ========================================================
echo.
echo   Kayo Script Generator - Setup.exe Build
echo.
echo ========================================================
echo.

REM Check if Python is available
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed or not in PATH
    echo Please install Python from https://www.python.org
    echo And make sure to check "Add Python to PATH" during installation
    pause
    exit /b 1
)

REM Check if PyInstaller is installed
python -m PyInstaller --version >nul 2>&1
if errorlevel 1 (
    echo WARNING: PyInstaller not found
    echo Installing PyInstaller...
    python -m pip install pyinstaller
    if errorlevel 1 (
        echo ERROR: Could not install PyInstaller
        pause
        exit /b 1
    )
)

echo.
echo Step 1: Cleaning previous builds...
echo.
rmdir /s /q dist_setup 2>nul
rmdir /s /q build_setup 2>nul
del /q setup.exe 2>nul

echo.
echo Step 2: Building setup_installer.py...
echo.
python -m PyInstaller setup.spec --distpath dist_setup --workpath build_setup -y

echo.
echo Step 3: Verifying build...
echo.
if exist "dist_setup\setup.exe" (
    echo ✓ Build successful!
    echo.
    echo Copying to main directory...
    copy "dist_setup\setup.exe" "setup.exe" /Y >nul
    
    if exist "setup.exe" (
        for /f "tokens=*" %%A in ('powershell -Command "[math]::Round((Get-Item setup.exe).Length/1MB, 2)"') do set SIZE=%%A
        echo ✓ setup.exe ready! (Size: !SIZE! MB)
        echo.
        echo Location: setup.exe
        echo Ready to distribute to users!
    ) else (
        echo ERROR: Could not copy setup.exe
        pause
        exit /b 1
    )
) else (
    echo ERROR: Build failed - setup.exe not found
    pause
    exit /b 1
)

echo.
echo ========================================================
echo Build Complete!
echo ========================================================
echo.
echo You can now share setup.exe with users.
echo.
pause

endlocal
exit /b 0
