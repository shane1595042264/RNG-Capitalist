# PowerShell Installer Creator for RNG Capitalist
# Creates a professional self-extracting installer

param(
    [string]$OutputPath = "RNG-Capitalist-v2.1-Installer.exe"
)

Write-Host "🚀 Creating RNG Capitalist Installer..." -ForegroundColor Green
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
    Write-Host "❌ 7-Zip not found. Installing via winget..." -ForegroundColor Yellow
    try {
        winget install --id 7zip.7zip --silent --accept-package-agreements --accept-source-agreements
        Write-Host "✅ 7-Zip installed successfully!" -ForegroundColor Green
        
        # Re-check for 7-Zip
        foreach ($path in $possiblePaths) {
            if (Test-Path $path) {
                $sevenZipPath = $path
                break
            }
        }
    }
    catch {
        Write-Host "❌ Failed to install 7-Zip automatically" -ForegroundColor Red
        Write-Host "Please install 7-Zip manually from https://7-zip.org/" -ForegroundColor Yellow
        exit 1
    }
}

if ($sevenZipPath -eq "") {
    Write-Host "❌ 7-Zip still not found after installation" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Found 7-Zip at: $sevenZipPath" -ForegroundColor Green

# Create installer script
$installerScript = @'
@echo off
title RNG Capitalist v2.1 Installer
echo.
echo ================================
echo  RNG Capitalist v2.1 Installer
echo ================================
echo.
echo Installing RNG Capitalist...
echo.

REM Create installation directory
set "INSTALL_DIR=%ProgramFiles%\RNG Capitalist"
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

REM Copy files to installation directory
xcopy /E /I /Y "%~dp0\*" "%INSTALL_DIR%\" >nul

REM Create desktop shortcut
echo Creating desktop shortcut...
powershell -Command "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%USERPROFILE%\Desktop\RNG Capitalist.lnk'); $Shortcut.TargetPath = '%INSTALL_DIR%\rng_capitalist.exe'; $Shortcut.IconLocation = '%INSTALL_DIR%\rng_capitalist.exe'; $Shortcut.Save()"

REM Create start menu shortcut
echo Creating start menu shortcut...
if not exist "%ProgramData%\Microsoft\Windows\Start Menu\Programs\RNG Capitalist" mkdir "%ProgramData%\Microsoft\Windows\Start Menu\Programs\RNG Capitalist"
powershell -Command "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%ProgramData%\Microsoft\Windows\Start Menu\Programs\RNG Capitalist\RNG Capitalist.lnk'); $Shortcut.TargetPath = '%INSTALL_DIR%\rng_capitalist.exe'; $Shortcut.IconLocation = '%INSTALL_DIR%\rng_capitalist.exe'; $Shortcut.Save()"

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
echo.
echo Press any key to launch the application...
pause >nul

REM Launch the application
start "" "%INSTALL_DIR%\rng_capitalist.exe"
'@

# Save installer script
$installerScript | Out-File -FilePath "installer.bat" -Encoding ASCII

Write-Host "✅ Installer script created" -ForegroundColor Green

# Create the self-extracting archive
Write-Host "📦 Creating self-extracting installer..." -ForegroundColor Cyan

$arguments = @(
    "a", "-sfx7z.sfx", 
    $OutputPath,
    "RNG-Capitalist-v2.1-Secure\*",
    "installer.bat"
)

& $sevenZipPath $arguments

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Installer created successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📦 Installer file: $OutputPath" -ForegroundColor Cyan
    
    # Get file size
    $fileSize = (Get-Item $OutputPath).Length
    $fileSizeMB = [math]::Round($fileSize / 1MB, 2)
    Write-Host "💾 Size: $fileSizeMB MB" -ForegroundColor Yellow
    
    Write-Host ""
    Write-Host "🚀 Ready for Microsoft Store submission!" -ForegroundColor Green
    
    # Clean up
    Remove-Item "installer.bat" -Force
} else {
    Write-Host "❌ Failed to create installer" -ForegroundColor Red
    exit 1
}
