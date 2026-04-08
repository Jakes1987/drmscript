; NSIS Installer Script for Kayo to O11V4 Script Generator
; Requires: NSIS (https://nsis.sourceforge.io)
; Usage: makensis.exe installer.nsi

!include "MUI2.nsh"

; Basic configuration
Name "Kayo to O11V4 Script Generator"
OutFile "KayoScriptGen-Installer.exe"
InstallDir "$PROGRAMFILES\Kayo Script Gen"
InstallDirRegKey HKCU "Software\Kayo Script Gen" "InstallDir"

; MUI Settings
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_LANGUAGE "English"

; Installer sections
Section "Install"
    SetOutPath "$INSTDIR"
    
    ; Check if dist folder exists
    IfFileExists "$OUTDIR\..\dist\KayoScriptGen.exe" found notfound
    
    found:
    File "dist\KayoScriptGen.exe"
    
    ; Create shortcuts
    CreateDirectory "$SMPROGRAMS\Kayo Script Gen"
    CreateShortcut "$SMPROGRAMS\Kayo Script Gen\Kayo Script Gen.lnk" "$INSTDIR\KayoScriptGen.exe"
    CreateShortcut "$DESKTOP\Kayo Script Gen.lnk" "$INSTDIR\KayoScriptGen.exe"
    
    ; Write registry
    WriteRegStr HKCU "Software\Kayo Script Gen" "InstallDir" "$INSTDIR"
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\Kayo Script Gen" "DisplayName" "Kayo to O11V4 Script Generator"
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\Kayo Script Gen" "UninstallString" "$INSTDIR\Uninstall.exe"
    
    ; Create uninstaller
    WriteUninstaller "$INSTDIR\Uninstall.exe"
    
    MessageBox MB_OK "Installation complete!$\n$\nYou can run Kayo Script Gen from the Start Menu or Desktop."
    Goto done
    
    notfound:
    MessageBox MB_ICONSTOP "Error: KayoScriptGen.exe not found!$\n$\nPlease run build.bat first to create the executable."
    Abort
    
    done:
SectionEnd

; Uninstaller section
Section "Uninstall"
    Delete "$INSTDIR\KayoScriptGen.exe"
    Delete "$INSTDIR\Uninstall.exe"
    RMDir "$INSTDIR"
    
    Delete "$SMPROGRAMS\Kayo Script Gen\Kayo Script Gen.lnk"
    RMDir "$SMPROGRAMS\Kayo Script Gen"
    
    Delete "$DESKTOP\Kayo Script Gen.lnk"
    
    DeleteRegKey HKCU "Software\Kayo Script Gen"
    DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\Kayo Script Gen"
SectionEnd
