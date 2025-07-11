@echo off
rem Add FlutterFire CLI to PATH for current session
rem Run this if you want to use 'flutterfire' command directly

set PATH=%PATH%;C:\Users\douvle\AppData\Local\Pub\Cache\bin

echo FlutterFire CLI added to PATH for this session
echo You can now use: flutterfire configure
echo.
echo To make this permanent, add the following to your system PATH:
echo C:\Users\douvle\AppData\Local\Pub\Cache\bin
echo.
echo Opening new PowerShell with flutterfire available...
powershell
