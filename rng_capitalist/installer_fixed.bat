@echo off
title RNG Capitalist v2.1 Installer - FIXED
echo.
echo =====================================
echo  RNG Capitalist v2.1 Installer FIXED
echo =====================================
echo.
echo Installing RNG Capitalist...
echo.

REM Create installation directory
set "INSTALL_DIR=%ProgramFiles%\RNG Capitalist"
echo Creating directory: %INSTALL_DIR%
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

REM Copy all files to installation directory
echo Copying application files...
xcopy /E /I /Y "%~dp0*" "%INSTALL_DIR%\" >nul

REM Find the actual executable location
set "EXE_PATH=%INSTALL_DIR%\rng_capitalist.exe"
if not exist "%EXE_PATH%" (
    echo Looking for executable in subdirectories...
    for /r "%INSTALL_DIR%" %%f in (rng_capitalist.exe) do (
        if exist "%%f" (
            set "EXE_PATH=%%f"
            echo Found executable at: %%f
            goto :found_exe
        )
    )
    echo ERROR: Could not find rng_capitalist.exe
    pause
    exit /b 1
)
:found_exe

echo Using executable: %EXE_PATH%

REM Create desktop shortcut
echo Creating desktop shortcut...
powershell -Command "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%USERPROFILE%\Desktop\RNG Capitalist.lnk'); $Shortcut.TargetPath = '%EXE_PATH%'; $Shortcut.IconLocation = '%EXE_PATH%'; $Shortcut.WorkingDirectory = Split-Path('%EXE_PATH%'); $Shortcut.Save()"

REM Create start menu shortcut  
echo Creating start menu shortcut...
if not exist "%ProgramData%\Microsoft\Windows\Start Menu\Programs\RNG Capitalist" mkdir "%ProgramData%\Microsoft\Windows\Start Menu\Programs\RNG Capitalist"
powershell -Command "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%ProgramData%\Microsoft\Windows\Start Menu\Programs\RNG Capitalist\RNG Capitalist.lnk'); $Shortcut.TargetPath = '%EXE_PATH%'; $Shortcut.IconLocation = '%EXE_PATH%'; $Shortcut.WorkingDirectory = Split-Path('%EXE_PATH%'); $Shortcut.Save()"

echo.
echo ================================
echo  Installation Complete!
echo ================================
echo.
echo RNG Capitalist has been installed to:
echo %INSTALL_DIR%
echo.
echo Executable location:
echo %EXE_PATH%
echo.
echo Desktop shortcut created
echo Start menu shortcut created
echo.
echo Testing application launch...
echo.

REM Test the application
if exist "%EXE_PATH%" (
    echo ✅ Executable found - launching application...
    start "" "%EXE_PATH%"
) else (
    echo ❌ ERROR: Executable not found at %EXE_PATH%
    echo Please check the installation manually.
    pause
)

echo.
echo Press any key to exit installer...
pause >nul
