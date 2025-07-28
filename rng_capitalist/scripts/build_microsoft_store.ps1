# MSIX Build Configuration for Microsoft Store

$ErrorActionPreference = "Stop"

Write-Host "Building RNG Capitalist v2.2 for Microsoft Store..." -ForegroundColor Cyan

# Clean previous builds
Write-Host "Cleaning previous builds..." -ForegroundColor Yellow
if (Test-Path "build\windows\x64\runner\Release") {
    Remove-Item "build\windows\x64\runner\Release" -Recurse -Force -ErrorAction SilentlyContinue
}

# Build Flutter app for release
Write-Host "Building Flutter release..." -ForegroundColor Yellow
flutter clean
flutter pub get
flutter build windows --release

# Install MSIX tool if not available
Write-Host "Checking MSIX packaging tool..." -ForegroundColor Yellow
try {
    $msixExists = Get-Command "makeappx.exe" -ErrorAction SilentlyContinue
    if (-not $msixExists) {
        Write-Host "Installing Windows SDK for MSIX packaging..." -ForegroundColor Yellow
        # Note: User needs to install Windows SDK manually
        Write-Host "Please install Windows 10/11 SDK from https://developer.microsoft.com/en-us/windows/downloads/windows-sdk/" -ForegroundColor Red
        Write-Host "After installation, makeappx.exe should be available in PATH" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "Windows SDK not found. Please install it first." -ForegroundColor Red
    exit 1
}

# Add Flutter MSIX support
Write-Host "Adding MSIX support to pubspec.yaml..." -ForegroundColor Yellow
$pubspecPath = "pubspec.yaml"
$pubspecContent = Get-Content $pubspecPath -Raw

if ($pubspecContent -notmatch "msix:") {
    $msixConfig = @"

# MSIX configuration for Microsoft Store
msix:
  display_name: RNG Capitalist - D&D Budget Tracker
  publisher_display_name: Shane Software
  identity_name: ShaneSoftware.RNGCapitalist
  msix_version: 2.2.0.0
  description: AI-Powered D&D Budget Tracker with smart analytics and cloud sync. Track your tabletop gaming expenses with intelligent categorization and real-time collaboration.
  publisher: CN=Shane Software
  logo_path: assets/logo/app_icon.png
  start_menu_icon_path: assets/logo/app_icon.png
  tile_icon_path: assets/logo/app_icon.png
  vs_generated_images_folder_path: assets/logo/
  icons_background_color: '#663399'
  architecture: x64
  capabilities: |
    <Capability Name="internetClient" />
    <Capability Name="internetClientServer" />
    <Capability Name="privateNetworkClientServer" />
    <rescap:Capability Name="runFullTrust" xmlns:rescap="http://schemas.microsoft.com/appx/manifest/foundation/windows10/restrictedcapabilities" />
"@
    
    Add-Content -Path $pubspecPath -Value $msixConfig
    Write-Host "Added MSIX configuration to pubspec.yaml" -ForegroundColor Green
}

# Install msix package
Write-Host "Installing Flutter MSIX package..." -ForegroundColor Yellow
flutter pub add msix
flutter pub get

# Create app icons directory
Write-Host "Creating app icons..." -ForegroundColor Yellow
$iconDir = "assets/logo"
if (-not (Test-Path $iconDir)) {
    New-Item -ItemType Directory -Path $iconDir -Force | Out-Null
}

# Create a simple app icon (placeholder - user should replace with actual icon)
$iconScript = @"
Add-Type -AssemblyName System.Drawing

# Create a simple purple icon as placeholder
`$bitmap = New-Object System.Drawing.Bitmap(256, 256)
`$graphics = [System.Drawing.Graphics]::FromImage(`$bitmap)
`$graphics.Clear([System.Drawing.Color]::FromArgb(102, 51, 153))

# Add text
`$font = New-Object System.Drawing.Font("Arial", 32, [System.Drawing.FontStyle]::Bold)
`$brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
`$graphics.DrawString("RNG", `$font, `$brush, 50, 80)
`$graphics.DrawString("CAP", `$font, `$brush, 40, 120)

`$bitmap.Save("assets/logo/app_icon.png", [System.Drawing.Imaging.ImageFormat]::Png)
`$graphics.Dispose()
`$bitmap.Dispose()
Write-Host "Created placeholder app icon at assets/logo/app_icon.png" -ForegroundColor Green
"@

try {
    Invoke-Expression $iconScript
} catch {
    Write-Host "Could not create icon automatically. Please add app_icon.png to assets/logo/" -ForegroundColor Yellow
}

# Build MSIX package
Write-Host "Building MSIX package for Microsoft Store..." -ForegroundColor Yellow
try {
    flutter pub run msix:create
    Write-Host "MSIX package created successfully!" -ForegroundColor Green
    
    # Find the created MSIX file
    $msixFile = Get-ChildItem -Path "build\windows\x64\runner\Release" -Filter "*.msix" -Recurse | Select-Object -First 1
    if ($msixFile) {
        $finalPath = "RNG-Capitalist-v2.2-Microsoft-Store.msix"
        Copy-Item $msixFile.FullName $finalPath
        Write-Host "MSIX package copied to: $finalPath" -ForegroundColor Green
        
        # Show file info
        $fileInfo = Get-Item $finalPath
        Write-Host "Package size: $([math]::Round($fileInfo.Length/1MB,2)) MB" -ForegroundColor Cyan
    }
    
} catch {
    Write-Host "Error creating MSIX package: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Trying alternative method..." -ForegroundColor Yellow
    
    # Alternative: Manual MSIX creation
    Write-Host "Please follow these steps for manual MSIX creation:" -ForegroundColor Yellow
    Write-Host "1. Open Visual Studio 2022" -ForegroundColor White
    Write-Host "2. Create new 'Windows Application Packaging Project'" -ForegroundColor White
    Write-Host "3. Add your Flutter build output as reference" -ForegroundColor White
    Write-Host "4. Configure manifest and build MSIX" -ForegroundColor White
}

Write-Host "`nBuild process completed!" -ForegroundColor Green
Write-Host "Next steps for Microsoft Store submission:" -ForegroundColor Cyan
Write-Host "1. Code sign the MSIX with a trusted certificate" -ForegroundColor White
Write-Host "2. Test installation on clean Windows machine" -ForegroundColor White
Write-Host "3. Submit to Microsoft Partner Center" -ForegroundColor White
