@echo off
REM Packaroo Windows Build Script (Batch version)
REM This is a simplified version for environments where PowerShell scripts are restricted

setlocal enabledelayedexpansion

REM Configuration
set APP_NAME=Packaroo
set APP_ID=packaroo
set VERSION=2.0.0
set ARCH=x64
set PUBLISHER=Damoiskii
set DESCRIPTION=A modern Java application packaging tool

REM Directories
set SCRIPT_DIR=%~dp0
set BUILD_DIR=%SCRIPT_DIR%windows-package
set PKG_DIR=%BUILD_DIR%\%APP_ID%-%VERSION%-windows-%ARCH%
set FLUTTER_BUILD_DIR=%SCRIPT_DIR%build\windows\%ARCH%\runner\Release

echo Building Flutter application for Windows (%ARCH%)...
flutter build windows --release
if %errorlevel% neq 0 (
    echo Error: Flutter build failed
    pause
    exit /b 1
)

echo Creating package directory structure...
if exist "%BUILD_DIR%" rmdir /s /q "%BUILD_DIR%"
mkdir "%PKG_DIR%"

echo Copying application files...
if not exist "%FLUTTER_BUILD_DIR%" (
    echo Error: Flutter build directory not found: %FLUTTER_BUILD_DIR%
    pause
    exit /b 1
)

xcopy "%FLUTTER_BUILD_DIR%\*" "%PKG_DIR%\" /e /i /y

echo Creating launcher batch file...
echo @echo off > "%PKG_DIR%\%APP_ID%.bat"
echo cd /d "%%~dp0" >> "%PKG_DIR%\%APP_ID%.bat"
echo start "" "packaroo.exe" %%* >> "%PKG_DIR%\%APP_ID%.bat"

echo Creating README.txt...
(
echo %APP_NAME% v%VERSION%
echo %DESCRIPTION%
echo.
echo Installation:
echo 1. Extract all files to a folder of your choice
echo 2. Double-click packaroo.exe to run the application
echo 3. Optionally, create a desktop shortcut to packaroo.exe
echo.
echo System Requirements:
echo - Windows 10 or later
echo - Visual C++ Redistributable ^(usually pre-installed^)
echo.
echo For more information, visit: https://github.com/damoiskii/Packaroo
echo.
echo Publisher: %PUBLISHER%
echo Version: %VERSION%
echo Architecture: %ARCH%
) > "%PKG_DIR%\README.txt"

echo Creating ZIP package...
REM Check if PowerShell is available for compression
powershell -Command "& {if (Get-Command Compress-Archive -ErrorAction SilentlyContinue) { Compress-Archive -Path '%PKG_DIR%' -DestinationPath '%BUILD_DIR%\%APP_ID%-%VERSION%-windows-%ARCH%-portable.zip' -Force; echo 'ZIP created successfully' } else { echo 'PowerShell Compress-Archive not available' }}"

echo.
echo Build completed successfully!
echo Output directory: %BUILD_DIR%
echo.
echo Created packages:
dir /b "%BUILD_DIR%"
echo.
echo To run the application:
echo   1. Navigate to: %PKG_DIR%
echo   2. Double-click packaroo.exe
echo.
pause
