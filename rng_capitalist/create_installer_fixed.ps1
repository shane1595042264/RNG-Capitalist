# Fixed Installer Creator for RNG Capitalist
# Handles proper directory structure and launch paths

param(
    [string]$OutputPath = "RNG-Capitalist-v2.1-Installer-FIXED.exe"
)

Write-Host "🔧 Creating FIXED RNG Capitalist Installer..." -ForegroundColor Green
Write-Host ""

# Check if 7-Zip is available
$sevenZipPath = ""
$possiblePaths = @(
    "${env:ProgramFiles}\7-Zip\7z.exe",
    "${env:ProgramFiles(x86)}\7-Zip\7z.exe",
    "C:\Program Files\7-Zip\7z.exe",
    "C:\Program Files (x86)\7-Zip\7z.exe"
)

foreach ($path in $possiblePaths) {
    if (Test-Path $path) {
        $sevenZipPath = $path
        break
    }
}

if ($sevenZipPath -eq "") {
    Write-Host "❌ 7-Zip not found. Please ensure 7-Zip is installed." -ForegroundColor Red
    exit 1
}

Write-Host "✅ Found 7-Zip at: $sevenZipPath" -ForegroundColor Green

# Create improved installer script
$installerScript = @'
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

REM Get the working directory (directory containing the exe)
for %%F in ("%EXE_PATH%") do set "WORK_DIR=%%~dpF"

REM Create desktop shortcut
echo Creating desktop shortcut...
powershell -Command "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%USERPROFILE%\Desktop\RNG Capitalist.lnk'); $Shortcut.TargetPath = '%EXE_PATH%'; $Shortcut.IconLocation = '%EXE_PATH%'; $Shortcut.WorkingDirectory = '%WORK_DIR%'; $Shortcut.Save()"

REM Create start menu shortcut  
echo Creating start menu shortcut...
if not exist "%ProgramData%\Microsoft\Windows\Start Menu\Programs\RNG Capitalist" mkdir "%ProgramData%\Microsoft\Windows\Start Menu\Programs\RNG Capitalist"
powershell -Command "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%ProgramData%\Microsoft\Windows\Start Menu\Programs\RNG Capitalist\RNG Capitalist.lnk'); $Shortcut.TargetPath = '%EXE_PATH%'; $Shortcut.IconLocation = '%EXE_PATH%'; $Shortcut.WorkingDirectory = '%WORK_DIR%'; $Shortcut.Save()"

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
echo Working directory:
echo %WORK_DIR%
echo.
echo Desktop shortcut created
echo Start menu shortcut created
echo.
echo Testing application launch...
echo.

REM Test the application
if exist "%EXE_PATH%" (
    echo ✅ Executable found - launching application...
    cd /d "%WORK_DIR%"
    start "" "%EXE_PATH%"
) else (
    echo ❌ ERROR: Executable not found at %EXE_PATH%
    echo Please check the installation manually.
    pause
)

echo.
echo Installation completed successfully!
echo You can now run RNG Capitalist from:
echo - Desktop shortcut
echo - Start menu
echo - Or directly from: %EXE_PATH%
echo.
pause
'@

# Save improved installer script
$installerScript | Out-File -FilePath "installer_improved.bat" -Encoding ASCII

Write-Host "✅ Improved installer script created" -ForegroundColor Green

# Create the self-extracting archive with improved script
Write-Host "📦 Creating improved self-extracting installer..." -ForegroundColor Cyan

$arguments = @(
    "a", "-sfx7z.sfx", 
    $OutputPath,
    "RNG-Capitalist-v2.1-Secure\*",
    "installer_improved.bat"
)

& $sevenZipPath $arguments

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ FIXED Installer created successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📦 Fixed Installer file: $OutputPath" -ForegroundColor Cyan
    
    # Get file size
    $fileSize = (Get-Item $OutputPath).Length
    $fileSizeMB = [math]::Round($fileSize / 1MB, 2)
    Write-Host "💾 Size: $fileSizeMB MB" -ForegroundColor Yellow
    
    Write-Host ""
    Write-Host "🔧 FIXES APPLIED:" -ForegroundColor Green
    Write-Host "   ✅ Proper executable path detection" -ForegroundColor White
    Write-Host "   ✅ Correct working directory setup" -ForegroundColor White
    Write-Host "   ✅ Improved error handling" -ForegroundColor White
    Write-Host "   ✅ Launch path verification" -ForegroundColor White
    
    Write-Host ""
    Write-Host "🚀 Ready for deployment!" -ForegroundColor Green
    
    # Clean up
    Remove-Item "installer_improved.bat" -Force
} else {
    Write-Host "❌ Failed to create fixed installer" -ForegroundColor Red
    exit 1
}
