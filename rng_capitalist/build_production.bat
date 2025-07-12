@echo off
echo ========================================
echo RNG Capitalist - Production Build Script
echo ========================================

echo.
echo [0/7] Checking environment setup...
if not exist ".env" (
    echo ERROR: .env file not found!
    echo Please copy .env.example to .env and add your API key
    echo Visit: https://aistudio.google.com/app/apikey
    pause
    exit /b 1
)

echo.
echo [1/7] Cleaning previous builds...
flutter clean
if %errorlevel% neq 0 (
    echo ERROR: Flutter clean failed
    exit /b 1
)

echo.
echo [2/7] Getting dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo ERROR: Flutter pub get failed
    exit /b 1
)

echo.
echo [3/7] Building release version...
flutter build windows --release --verbose
if %errorlevel% neq 0 (
    echo ERROR: Flutter build failed
    exit /b 1
)

echo.
echo [4/6] Creating distribution directory...
if exist "RNG-Capitalist-Release" rmdir /s /q "RNG-Capitalist-Release"
mkdir "RNG-Capitalist-Release"

echo.
echo [5/6] Copying release files...
xcopy "build\windows\x64\runner\Release\*" "RNG-Capitalist-Release\" /s /e /y
if %errorlevel% neq 0 (
    echo ERROR: Failed to copy release files
    exit /b 1
)

echo.
echo [6/6] Creating distributable package...
powershell -Command "Compress-Archive -Path 'RNG-Capitalist-Release\*' -DestinationPath 'RNG-Capitalist-v2.0-Windows-x64.zip' -Force"
if %errorlevel% neq 0 (
    echo ERROR: Failed to create zip package
    exit /b 1
)

echo.
echo ========================================
echo BUILD COMPLETE!
echo ========================================
echo.
echo Release executable: RNG-Capitalist-Release\rng_capitalist.exe
echo Distribution package: RNG-Capitalist-v2.0-Windows-x64.zip
echo.
echo File sizes:
dir "RNG-Capitalist-Release\rng_capitalist.exe" | findstr ".exe"
dir "RNG-Capitalist-v2.0-Windows-x64.zip" | findstr ".zip"
echo.
echo Ready for distribution!
echo ========================================
pause
