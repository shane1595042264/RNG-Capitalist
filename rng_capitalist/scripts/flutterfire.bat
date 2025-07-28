@echo off
rem Convenience script to run FlutterFire CLI commands
rem This script sets up the full path to the FlutterFire CLI executable

set FLUTTERFIRE_PATH=C:\Users\douvle\AppData\Local\Pub\Cache\bin\flutterfire.bat

echo FlutterFire CLI Helper Script
echo ============================
echo.

if "%1"=="" (
    echo Usage: %0 ^<command^> [arguments...]
    echo.
    echo Examples:
    echo   %0 configure
    echo   %0 configure --project=my-project
    echo   %0 --help
    echo.
    goto :end
)

echo Running: %FLUTTERFIRE_PATH% %*
echo.
%FLUTTERFIRE_PATH% %*

:end
