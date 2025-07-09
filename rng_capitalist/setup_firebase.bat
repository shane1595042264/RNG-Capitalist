@echo off
echo Setting up Firebase CLI for RNG Capitalist...
echo.

:: Check if Firebase CLI is installed
firebase --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Firebase CLI is not installed. Please install it first:
    echo npm install -g firebase-tools
    echo.
    echo After installation, run this script again.
    pause
    exit /b 1
)

echo Firebase CLI is installed. Logging in...
firebase login

echo.
echo Initializing Firebase project...
firebase init

echo.
echo Installing FlutterFire CLI...
dart pub global activate flutterfire_cli

echo.
echo Configuring Firebase for Flutter...
flutterfire configure

echo.
echo Setup complete! 
echo.
echo Next steps:
echo 1. Update your Firestore security rules in the Firebase Console
echo 2. Enable Google Sign-In in Firebase Authentication
echo 3. Replace the placeholder values in firebase_options.dart with your actual config
echo.
pause
