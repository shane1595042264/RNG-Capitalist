@echo off
echo ========================================
echo RNG Capitalist - API Key Setup Helper
echo ========================================
echo.

REM Check if .env already exists
if exist ".env" (
    echo Found existing .env file.
    echo.
    set /p overwrite="Do you want to update it? (y/n): "
    if /i not "%overwrite%"=="y" (
        echo Setup cancelled.
        pause
        exit /b 0
    )
)

REM Copy from example if .env doesn't exist
if not exist ".env" (
    if exist ".env.example" (
        copy ".env.example" ".env" >nul
        echo Created .env file from template.
    ) else (
        echo Creating new .env file...
        echo # Environment Variables for RNG Capitalist > .env
        echo # DO NOT COMMIT THIS FILE TO VERSION CONTROL! >> .env
        echo. >> .env
        echo # Google Gemini AI API Key >> .env
        echo # Get your free API key from: https://aistudio.google.com/app/apikey >> .env
        echo GOOGLE_GEMINI_API_KEY=your_api_key_here >> .env
        echo. >> .env
        echo # Other configuration >> .env
        echo APP_ENV=production >> .env
        echo DEBUG_MODE=false >> .env
    )
)

echo.
echo ========================================
echo STEP 1: Get Your Free API Key
echo ========================================
echo.
echo 1. Visit: https://aistudio.google.com/app/apikey
echo 2. Sign in with your Google account
echo 3. Click "Create API Key"
echo 4. Copy the generated key
echo.
echo Press any key to open the website...
pause >nul

start https://aistudio.google.com/app/apikey

echo.
echo ========================================
echo STEP 2: Enter Your API Key
echo ========================================
echo.
set /p apikey="Paste your API key here: "

if "%apikey%"=="" (
    echo ERROR: No API key entered!
    pause
    exit /b 1
)

REM Update the .env file
powershell -Command "(Get-Content '.env') -replace 'GOOGLE_GEMINI_API_KEY=.*', 'GOOGLE_GEMINI_API_KEY=%apikey%' | Set-Content '.env'"

echo.
echo ========================================
echo STEP 3: Testing Setup
echo ========================================
echo.
echo API key saved to .env file.
echo Testing Flutter setup...

flutter pub get
if %errorlevel% neq 0 (
    echo ERROR: Flutter pub get failed!
    pause
    exit /b 1
)

echo.
echo ========================================
echo SUCCESS! Setup Complete
echo ========================================
echo.
echo Your API key has been configured successfully!
echo.
echo Next steps:
echo 1. Run: flutter run
echo 2. Test AI upload in the app
echo 3. Look for "✅ Google Gemini AI initialized successfully"
echo.
echo IMPORTANT SECURITY NOTES:
echo - Never share your .env file
echo - The .env file is already in .gitignore
echo - Keep your API key private
echo.
echo Ready to experience AI-powered document analysis!
echo.
pause
