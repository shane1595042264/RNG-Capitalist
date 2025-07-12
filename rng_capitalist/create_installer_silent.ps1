# Enhanced Installer with Silent Parameter Support
# Creates a professional installer with explicit silent mode

param(
    [string]$OutputPath = "RNG-Capitalist-v2.1-Installer-SILENT.exe"
)

Write-Host "🔧 Creating SILENT-COMPATIBLE RNG Capitalist Installer..." -ForegroundColor Green
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

# Create enhanced installer script with silent parameter support
$installerScript = @'
@echo off
title RNG Capitalist v2.1 Silent Installer

REM Check for silent parameter
set "SILENT_MODE=0"
if "%1"=="/S" set "SILENT_MODE=1"
if "%1"=="/s" set "SILENT_MODE=1"
if "%1"=="-s" set "SILENT_MODE=1"
if "%1"=="--silent" set "SILENT_MODE=1"

if "%SILENT_MODE%"=="1" (
    REM Silent installation - no output
    goto :silent_install
) else (
    REM Interactive installation
    echo.
    echo =====================================
    echo  RNG Capitalist v2.1 Installer
    echo =====================================
    echo.
    echo Installing RNG Capitalist...
    echo.
)

:silent_install
REM Create installation directory
set "INSTALL_DIR=%ProgramFiles%\RNG Capitalist"
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%" >nul 2>&1

REM Copy all files to installation directory
xcopy /E /I /Y "%~dp0*" "%INSTALL_DIR%\" >nul 2>&1

REM Find the actual executable location
set "EXE_PATH=%INSTALL_DIR%\rng_capitalist.exe"
if not exist "%EXE_PATH%" (
    for /r "%INSTALL_DIR%" %%f in (rng_capitalist.exe) do (
        if exist "%%f" (
            set "EXE_PATH=%%f"
            goto :found_exe_silent
        )
    )
    if "%SILENT_MODE%"=="0" (
        echo ERROR: Could not find rng_capitalist.exe
        pause
    )
    exit /b 1
)
:found_exe_silent

REM Get the working directory
for %%F in ("%EXE_PATH%") do set "WORK_DIR=%%~dpF"

REM Create desktop shortcut
powershell -WindowStyle Hidden -Command "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%USERPROFILE%\Desktop\RNG Capitalist.lnk'); $Shortcut.TargetPath = '%EXE_PATH%'; $Shortcut.IconLocation = '%EXE_PATH%'; $Shortcut.WorkingDirectory = '%WORK_DIR%'; $Shortcut.Save()" >nul 2>&1

REM Create start menu shortcut  
if not exist "%ProgramData%\Microsoft\Windows\Start Menu\Programs\RNG Capitalist" mkdir "%ProgramData%\Microsoft\Windows\Start Menu\Programs\RNG Capitalist" >nul 2>&1
powershell -WindowStyle Hidden -Command "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%ProgramData%\Microsoft\Windows\Start Menu\Programs\RNG Capitalist\RNG Capitalist.lnk'); $Shortcut.TargetPath = '%EXE_PATH%'; $Shortcut.IconLocation = '%EXE_PATH%'; $Shortcut.WorkingDirectory = '%WORK_DIR%'; $Shortcut.Save()" >nul 2>&1

REM Add to Windows Programs list
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall\RNG Capitalist" /v "DisplayName" /t REG_SZ /d "RNG Capitalist v2.1" /f >nul 2>&1
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall\RNG Capitalist" /v "DisplayVersion" /t REG_SZ /d "2.1.0" /f >nul 2>&1
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall\RNG Capitalist" /v "Publisher" /t REG_SZ /d "RNG Capitalist Team" /f >nul 2>&1
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall\RNG Capitalist" /v "InstallLocation" /t REG_SZ /d "%INSTALL_DIR%" /f >nul 2>&1
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall\RNG Capitalist" /v "DisplayIcon" /t REG_SZ /d "%EXE_PATH%" /f >nul 2>&1

if "%SILENT_MODE%"=="0" (
    echo.
    echo ================================
    echo  Installation Complete!
    echo ================================
    echo.
    echo RNG Capitalist has been installed to:
    echo %INSTALL_DIR%
    echo.
    echo Desktop shortcut created
    echo Start menu shortcut created
    echo Added to Windows Programs list
    echo.
    echo Installation completed successfully!
    pause
) else (
    REM Silent mode - exit code 0 for success
    exit /b 0
)
'@

# Save enhanced installer script
$installerScript | Out-File -FilePath "installer_silent.bat" -Encoding ASCII

Write-Host "✅ Silent-compatible installer script created" -ForegroundColor Green

# Create the self-extracting archive with silent support
Write-Host "📦 Creating silent-compatible installer..." -ForegroundColor Cyan

$arguments = @(
    "a", "-sfx7z.sfx", 
    $OutputPath,
    "RNG-Capitalist-v2.1-Secure\*",
    "installer_silent.bat"
)

& $sevenZipPath $arguments

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ SILENT-COMPATIBLE Installer created successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📦 Silent Installer: $OutputPath" -ForegroundColor Cyan
    
    # Get file size
    $fileSize = (Get-Item $OutputPath).Length
    $fileSizeMB = [math]::Round($fileSize / 1MB, 2)
    Write-Host "💾 Size: $fileSizeMB MB" -ForegroundColor Yellow
    
    Write-Host ""
    Write-Host "🔧 SILENT FEATURES:" -ForegroundColor Green
    Write-Host "   ✅ Supports /S parameter for silent installation" -ForegroundColor White
    Write-Host "   ✅ No prompts or dialogs in silent mode" -ForegroundColor White
    Write-Host "   ✅ Automatic registry entries" -ForegroundColor White
    Write-Host "   ✅ Professional deployment ready" -ForegroundColor White
    Write-Host "   ✅ Enterprise compatible" -ForegroundColor White
    
    Write-Host ""
    Write-Host "📋 Microsoft Store Parameters:" -ForegroundColor Cyan
    Write-Host "   Field: /S" -ForegroundColor White
    Write-Host "   Checkbox: ☐ (leave unchecked)" -ForegroundColor White
    
    Write-Host ""
    Write-Host "🚀 Ready for professional deployment!" -ForegroundColor Green
    
    # Clean up
    Remove-Item "installer_silent.bat" -Force
} else {
    Write-Host "❌ Failed to create silent installer" -ForegroundColor Red
    exit 1
}
