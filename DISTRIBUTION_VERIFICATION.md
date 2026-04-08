# KayoScriptGen.exe - Distribution Verification

**File**: dist/KayoScriptGen.exe
**Size**: 12.63 MB
**Built**: April 8, 2026
**Version**: 1.0 - Production Release

## Integrity Hashes

**MD5**: BE00DDA7B0E865DF51802458C3B5D2A1
**SHA256**: 41A3E1FB400049A75A52D4584F09576A74BEACAF5BAF2346B48004BA0EDB2570

## Verification Steps

1. **Download** KayoScriptGen.exe
2. **Calculate** MD5 hash of downloaded file:
   - Windows PowerShell: (Get-FileHash -Path KayoScriptGen.exe -Algorithm MD5).Hash
   - Command Prompt: certutil -hashfile KayoScriptGen.exe MD5
3. **Compare** with hash above
4. **If matches**: File is verified authentic ?
5. **If different**: File may be corrupted or modified ?

## Calculate SHA256 Hash

Command:
\\\powershell
(Get-FileHash -Path KayoScriptGen.exe -Algorithm SHA256).Hash
\\\

Expected: 41A3E1FB400049A75A52D4584F09576A74BEACAF5BAF2346B48004BA0EDB2570

## System Requirements

- **OS**: Windows 7, 8, 10, 11 (64-bit)
- **RAM**: 2 GB minimum, 4 GB recommended
- **Disk**: 200 MB free space
- **Network**: Internet connection required
- **Admin**: No administrator rights needed

## Installation

1. Download KayoScriptGen.exe
2. Verify integrity using hashes above (optional but recommended)
3. Run: \KayoScriptGen.exe\
4. Web GUI will open automatically in default browser
5. Follow on-screen instructions

## Support

For issues or questions:
- See QUICK_DEPLOUMENT_GUIDE.txt for quick start
- See BUILD_INSTRUCTIONS.md for technical details
- See KAYO_API_REFERENCE.md for API information

---

**Built with PyInstaller 6.19.0 | Python 3.14.3**
**Production Ready | April 8, 2026**
