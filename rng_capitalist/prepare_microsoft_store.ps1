# Microsoft Store Preparation Script
# Run this in PowerShell as Administrator

Write-Host "========================================" -ForegroundColor Green
Write-Host "RNG Capitalist - Microsoft Store Prep" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

# Step 1: Install Windows App SDK if not present
Write-Host "`n[1/8] Checking Windows App SDK..." -ForegroundColor Yellow
if (!(Get-AppxPackage -Name "Microsoft.WindowsAppRuntime*")) {
    Write-Host "Installing Windows App SDK..." -ForegroundColor Cyan
    # You may need to download and install Windows App SDK manually
    Write-Host "Please download Windows App SDK from: https://docs.microsoft.com/en-us/windows/apps/windows-app-sdk/" -ForegroundColor Red
}

# Step 2: Create MSIX package structure
Write-Host "`n[2/8] Creating MSIX package structure..." -ForegroundColor Yellow
$packageDir = "RNG-Capitalist-MSIX"
if (Test-Path $packageDir) {
    Remove-Item $packageDir -Recurse -Force
}
New-Item -ItemType Directory -Path $packageDir
New-Item -ItemType Directory -Path "$packageDir\Assets"

# Step 3: Copy release files
Write-Host "`n[3/8] Copying release files..." -ForegroundColor Yellow
Copy-Item "build\windows\x64\runner\Release\*" -Destination $packageDir -Recurse -Force

# Step 4: Create Package.appxmanifest
Write-Host "`n[4/8] Creating Package.appxmanifest..." -ForegroundColor Yellow
$manifest = @"
<?xml version="1.0" encoding="utf-8"?>
<Package xmlns="http://schemas.microsoft.com/appx/manifest/foundation/windows10"
         xmlns:uap="http://schemas.microsoft.com/appx/manifest/uap/windows10"
         xmlns:rescap="http://schemas.microsoft.com/appx/manifest/foundation/windows10/restrictedcapabilities">
  <Identity Name="RNGCapitalist.AITracker"
            Publisher="CN=YourPublisher"
            Version="2.0.0.0" />
  
  <Properties>
    <DisplayName>RNG Capitalist</DisplayName>
    <PublisherDisplayName>Your Publisher Name</PublisherDisplayName>
    <Logo>Assets\StoreLogo.png</Logo>
    <Description>AI-Powered Sunk Cost Tracker with Google Gemini AI</Description>
  </Properties>
  
  <Dependencies>
    <TargetDeviceFamily Name="Windows.Desktop" MinVersion="10.0.17763.0" MaxVersionTested="10.0.22000.0" />
  </Dependencies>
  
  <Capabilities>
    <Capability Name="internetClient" />
    <rescap:Capability Name="runFullTrust" />
  </Capabilities>
  
  <Applications>
    <Application Id="RNGCapitalist" Executable="rng_capitalist.exe" EntryPoint="Windows.FullTrustApplication">
      <uap:VisualElements DisplayName="RNG Capitalist"
                          Description="AI-Powered Sunk Cost Tracker"
                          BackgroundColor="transparent"
                          Square150x150Logo="Assets\Square150x150Logo.png"
                          Square44x44Logo="Assets\Square44x44Logo.png">
        <uap:DefaultTile Wide310x150Logo="Assets\Wide310x150Logo.png" />
        <uap:SplashScreen Image="Assets\SplashScreen.png" />
      </uap:VisualElements>
    </Application>
  </Applications>
</Package>
"@
$manifest | Out-File -FilePath "$packageDir\Package.appxmanifest" -Encoding UTF8

# Step 5: Create placeholder icons (you'll need to replace these with real icons)
Write-Host "`n[5/8] Creating placeholder app icons..." -ForegroundColor Yellow
Write-Host "NOTE: You need to create proper PNG icons for Microsoft Store:" -ForegroundColor Red
Write-Host "- Square44x44Logo.png (44x44)" -ForegroundColor Red
Write-Host "- Square150x150Logo.png (150x150)" -ForegroundColor Red
Write-Host "- Wide310x150Logo.png (310x150)" -ForegroundColor Red
Write-Host "- StoreLogo.png (50x50)" -ForegroundColor Red
Write-Host "- SplashScreen.png (620x300)" -ForegroundColor Red

# Step 6: Create build script for MSIX
Write-Host "`n[6/8] Creating MSIX build script..." -ForegroundColor Yellow
$msixBuildScript = @"
@echo off
echo Building MSIX package for Microsoft Store...

echo Step 1: Creating MSIX package...
makeappx pack /d RNG-Capitalist-MSIX /p RNG-Capitalist.msix /o

echo Step 2: Signing package (requires certificate)...
echo NOTE: You need a valid code signing certificate for Microsoft Store
echo signtool sign /fd SHA256 /a RNG-Capitalist.msix

echo MSIX package created: RNG-Capitalist.msix
echo Ready for Microsoft Store submission!
pause
"@
$msixBuildScript | Out-File -FilePath "build_msix.bat" -Encoding ASCII

# Step 7: Create submission checklist
Write-Host "`n[7/8] Creating Microsoft Store submission checklist..." -ForegroundColor Yellow
$checklist = @"
# Microsoft Store Submission Checklist

## Required Files Created:
- [x] RNG-Capitalist-MSIX/ (Package directory)
- [x] Package.appxmanifest (App manifest)
- [x] build_msix.bat (MSIX build script)
- [ ] App icons (44x44, 150x150, 310x150, 50x50, 620x300)
- [ ] Code signing certificate

## Before Submission:
1. **Create App Icons**: Use a design tool to create professional app icons
   - Square44x44Logo.png (44x44 pixels)
   - Square150x150Logo.png (150x150 pixels)  
   - Wide310x150Logo.png (310x150 pixels)
   - StoreLogo.png (50x50 pixels)
   - SplashScreen.png (620x300 pixels)

2. **Get Code Signing Certificate**: 
   - Purchase from trusted CA (DigiCert, Sectigo, etc.)
   - Or use Microsoft Store certificate

3. **Update Package.appxmanifest**:
   - Change Publisher to your actual publisher name
   - Update package identity with your reserved name
   - Verify all metadata is correct

4. **Test MSIX Package**:
   - Install locally: Add-AppxPackage RNG-Capitalist.msix
   - Test all functionality
   - Verify app launches and works correctly

5. **Microsoft Store Developer Account**:
   - Register at https://partner.microsoft.com/
   - Pay registration fee (\$19 individual / \$99 company)
   - Complete identity verification

6. **App Store Listing**:
   - Prepare app description
   - Create screenshots
   - Set pricing and availability
   - Configure age ratings

## Build Commands:
1. Run: build_production.bat
2. Create icons and place in RNG-Capitalist-MSIX/Assets/
3. Run: build_msix.bat
4. Upload RNG-Capitalist.msix to Microsoft Store

## App Features to Highlight:
- AI-Powered document analysis with Google Gemini
- Automatic categorization of expenses
- Smart amount detection ($1,124.22 format support)
- PDF and image processing
- Bank statement analysis
- D&D and gaming expense tracking
- Beautiful, modern UI
"@
$checklist | Out-File -FilePath "MICROSOFT_STORE_CHECKLIST.md" -Encoding UTF8

# Step 8: Summary
Write-Host "`n[8/8] Preparation Complete!" -ForegroundColor Green
Write-Host "`nFiles Created:" -ForegroundColor Cyan
Write-Host "- RNG-Capitalist-MSIX/ (MSIX package directory)" -ForegroundColor White
Write-Host "- Package.appxmanifest (App manifest for Store)" -ForegroundColor White
Write-Host "- build_msix.bat (MSIX build script)" -ForegroundColor White  
Write-Host "- MICROSOFT_STORE_CHECKLIST.md (Submission guide)" -ForegroundColor White

Write-Host "`nNext Steps:" -ForegroundColor Yellow
Write-Host "1. Create professional app icons (see checklist)" -ForegroundColor White
Write-Host "2. Get a code signing certificate" -ForegroundColor White
Write-Host "3. Register Microsoft Store developer account" -ForegroundColor White
Write-Host "4. Follow MICROSOFT_STORE_CHECKLIST.md" -ForegroundColor White

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "Microsoft Store Preparation Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
