# Packaroo Windows Package Builder
# This script builds a Windows installer from your Flutter Windows build

param(
    [string]$Version = "2.0.0",
    [string]$Architecture = "x64",
    [switch]$Help
)

if ($Help) {
    Write-Host @"
Packaroo Windows Build Script

Usage: .\build-windows.ps1 [OPTIONS]

Options:
    -Version      Set the application version (default: 2.0.0)
    -Architecture Set target architecture: x64, x86, arm64 (default: x64)
    -Help         Show this help message

Examples:
    .\build-windows.ps1
    .\build-windows.ps1 -Version "2.1.0" -Architecture "x64"

This script will:
1. Build the Flutter Windows application
2. Create a portable package
3. Generate an NSIS installer (if available)
4. Create a ZIP distribution

Requirements:
- Flutter SDK with Windows desktop support
- Optional: NSIS (Nullsoft Scriptable Install System) for installer creation
"@
    exit 0
}

$ErrorActionPreference = "Stop"

# Configuration
$APP_NAME = "Packaroo"
$APP_ID = "packaroo"
$PUBLISHER = "Damoiskii"
$DESCRIPTION = "A modern Java application packaging tool"
$HOMEPAGE = "https://github.com/damoiskii/Packaroo"

# Directories
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$BUILD_DIR = Join-Path $SCRIPT_DIR "windows-package"
$PKG_DIR = Join-Path $BUILD_DIR "$APP_ID-$Version-windows-$Architecture"
$FLUTTER_BUILD_DIR = Join-Path $SCRIPT_DIR "build\windows\$Architecture\runner\Release"

Write-Host "Building Flutter application for Windows ($Architecture)..." -ForegroundColor Green
try {
    flutter build windows --release
    if ($LASTEXITCODE -ne 0) {
        throw "Flutter build failed"
    }
} catch {
    Write-Error "Failed to build Flutter application: $_"
    exit 1
}

Write-Host "Creating package directory structure..." -ForegroundColor Green
if (Test-Path $BUILD_DIR) {
    Remove-Item -Recurse -Force $BUILD_DIR
}
New-Item -ItemType Directory -Force -Path $PKG_DIR | Out-Null

Write-Host "Copying application files..." -ForegroundColor Green
if (-not (Test-Path $FLUTTER_BUILD_DIR)) {
    Write-Error "Flutter build directory not found: $FLUTTER_BUILD_DIR"
    exit 1
}

Copy-Item -Recurse -Path "$FLUTTER_BUILD_DIR\*" -Destination $PKG_DIR

Write-Host "Creating launcher batch file..." -ForegroundColor Green
$LauncherContent = @"
@echo off
cd /d "%~dp0"
start "" "packaroo.exe" %*
"@
$LauncherContent | Out-File -FilePath (Join-Path $PKG_DIR "$APP_ID.bat") -Encoding ASCII

Write-Host "Creating README.txt..." -ForegroundColor Green
$ReadmeContent = @"
$APP_NAME v$Version
$DESCRIPTION

Installation:
1. Extract all files to a folder of your choice
2. Double-click packaroo.exe to run the application
3. Optionally, create a desktop shortcut to packaroo.exe

System Requirements:
- Windows 10 or later
- Visual C++ Redistributable (usually pre-installed)

For more information, visit: $HOMEPAGE

Publisher: $PUBLISHER
Version: $Version
Architecture: $Architecture
"@
$ReadmeContent | Out-File -FilePath (Join-Path $PKG_DIR "README.txt") -Encoding UTF8

Write-Host "Creating portable ZIP package..." -ForegroundColor Green
$ZipPath = Join-Path $BUILD_DIR "$APP_ID-$Version-windows-$Architecture-portable.zip"
if (Get-Command Compress-Archive -ErrorAction SilentlyContinue) {
    Compress-Archive -Path $PKG_DIR -DestinationPath $ZipPath -Force
    Write-Host "Portable ZIP created: $ZipPath" -ForegroundColor Cyan
} else {
    Write-Warning "Compress-Archive not available. Skipping ZIP creation."
}

# Check for NSIS and create installer
$NSISPath = ""
$PossibleNSISPaths = @(
    "${env:ProgramFiles}\NSIS\makensis.exe",
    "${env:ProgramFiles(x86)}\NSIS\makensis.exe",
    "makensis.exe"
)

foreach ($Path in $PossibleNSISPaths) {
    if (Get-Command $Path -ErrorAction SilentlyContinue) {
        $NSISPath = $Path
        break
    }
}

if ($NSISPath) {
    Write-Host "Creating NSIS installer script..." -ForegroundColor Green
    
    $NSISScript = @"
!define APP_NAME "$APP_NAME"
!define APP_ID "$APP_ID"
!define VERSION "$Version"
!define PUBLISHER "$PUBLISHER"
!define DESCRIPTION "$DESCRIPTION"
!define HOMEPAGE "$HOMEPAGE"
!define ARCHITECTURE "$Architecture"

!include "MUI2.nsh"

; Installer settings
Name "`${APP_NAME}"
OutFile "$APP_ID-$Version-windows-$Architecture-setup.exe"
InstallDir "`$PROGRAMFILES64\`${APP_NAME}"
InstallDirRegKey HKLM "Software\`${PUBLISHER}\`${APP_NAME}" "InstallDir"
RequestExecutionLevel admin

; Modern UI settings
!define MUI_ABORTWARNING
!define MUI_ICON "`${NSISDIR}\Contrib\Graphics\Icons\modern-install.ico"
!define MUI_UNICON "`${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall.ico"

; Pages
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "README.txt"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

!insertmacro MUI_LANGUAGE "English"

; Version information
VIProductVersion "$Version.0"
VIAddVersionKey "ProductName" "`${APP_NAME}"
VIAddVersionKey "ProductVersion" "`${VERSION}"
VIAddVersionKey "CompanyName" "`${PUBLISHER}"
VIAddVersionKey "FileDescription" "`${DESCRIPTION}"
VIAddVersionKey "FileVersion" "`${VERSION}"
VIAddVersionKey "LegalCopyright" "© `${PUBLISHER}"

Section "Install"
    SetOutPath "`$INSTDIR"
    File /r "$PKG_DIR\*"
    
    ; Create uninstaller
    WriteUninstaller "`$INSTDIR\Uninstall.exe"
    
    ; Registry entries
    WriteRegStr HKLM "Software\`${PUBLISHER}\`${APP_NAME}" "InstallDir" "`$INSTDIR"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\`${APP_ID}" "DisplayName" "`${APP_NAME}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\`${APP_ID}" "UninstallString" "`$INSTDIR\Uninstall.exe"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\`${APP_ID}" "DisplayIcon" "`$INSTDIR\packaroo.exe"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\`${APP_ID}" "Publisher" "`${PUBLISHER}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\`${APP_ID}" "DisplayVersion" "`${VERSION}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\`${APP_ID}" "URLInfoAbout" "`${HOMEPAGE}"
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\`${APP_ID}" "NoModify" 1
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\`${APP_ID}" "NoRepair" 1
    
    ; Start menu shortcut
    CreateDirectory "`$SMPROGRAMS\`${APP_NAME}"
    CreateShortcut "`$SMPROGRAMS\`${APP_NAME}\`${APP_NAME}.lnk" "`$INSTDIR\packaroo.exe"
    CreateShortcut "`$SMPROGRAMS\`${APP_NAME}\Uninstall.lnk" "`$INSTDIR\Uninstall.exe"
    
    ; Desktop shortcut (optional)
    CreateShortcut "`$DESKTOP\`${APP_NAME}.lnk" "`$INSTDIR\packaroo.exe"
SectionEnd

Section "Uninstall"
    Delete "`$INSTDIR\Uninstall.exe"
    RMDir /r "`$INSTDIR"
    
    ; Remove registry entries
    DeleteRegKey HKLM "Software\`${PUBLISHER}\`${APP_NAME}"
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\`${APP_ID}"
    
    ; Remove shortcuts
    RMDir /r "`$SMPROGRAMS\`${APP_NAME}"
    Delete "`$DESKTOP\`${APP_NAME}.lnk"
SectionEnd
"@
    
    $NSISScriptPath = Join-Path $BUILD_DIR "installer.nsi"
    $NSISScript | Out-File -FilePath $NSISScriptPath -Encoding UTF8
    
    Write-Host "Building NSIS installer..." -ForegroundColor Green
    Push-Location $BUILD_DIR
    try {
        & $NSISPath $NSISScriptPath
        if ($LASTEXITCODE -eq 0) {
            Write-Host "NSIS installer created successfully!" -ForegroundColor Cyan
        } else {
            Write-Warning "NSIS installer creation failed with exit code $LASTEXITCODE"
        }
    } finally {
        Pop-Location
    }
} else {
    Write-Warning "NSIS not found. Skipping installer creation."
    Write-Host "To create installers, install NSIS from: https://nsis.sourceforge.io/" -ForegroundColor Yellow
}

Write-Host "`nBuild completed successfully!" -ForegroundColor Green
Write-Host "Output directory: $BUILD_DIR" -ForegroundColor Cyan
Write-Host "`nCreated packages:" -ForegroundColor White
Get-ChildItem $BUILD_DIR -File | ForEach-Object {
    Write-Host "  - $($_.Name)" -ForegroundColor Gray
}

Write-Host "`nTo run the application:" -ForegroundColor White
Write-Host "  1. Navigate to: $PKG_DIR" -ForegroundColor Gray
Write-Host "  2. Double-click packaroo.exe" -ForegroundColor Gray
