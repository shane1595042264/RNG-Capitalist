@echo off
title RNG Capitalist - Manual Launch
echo.
echo ========================================
echo  RNG Capitalist v2.1 - Manual Launch
echo ========================================
echo.

REM Check where we are
echo Current directory: %cd%
echo.

REM Look for the executable
set "EXE_PATH="
if exist "rng_capitalist.exe" (
    set "EXE_PATH=%cd%\rng_capitalist.exe"
    echo Found executable in current directory
) else (
    echo Looking for executable in subdirectories...
    for /r . %%f in (rng_capitalist.exe) do (
        if exist "%%f" (
            set "EXE_PATH=%%f"
            echo Found executable at: %%f
            goto :found
        )
    )
    echo ERROR: Could not find rng_capitalist.exe
    pause
    exit /b 1
)

:found
echo.
echo Executable location: %EXE_PATH%
echo.

REM Get the directory containing the exe
for %%F in ("%EXE_PATH%") do set "WORK_DIR=%%~dpF"
echo Working directory: %WORK_DIR%
echo.

REM Change to the correct directory and launch
echo Launching RNG Capitalist...
cd /d "%WORK_DIR%"
start "" "%EXE_PATH%"

if %ERRORLEVEL% EQU 0 (
    echo ✅ Application launched successfully!
) else (
    echo ❌ Failed to launch application
    echo.
    echo Troubleshooting:
    echo 1. Make sure all DLL files are in the same directory as the exe
    echo 2. Check that your .env file is in the data/flutter_assets/ folder
    echo 3. Verify internet connection for AI features
    echo.
    pause
)

echo.
pause
