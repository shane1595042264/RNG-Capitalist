# Simple ZIP-based Installer Alternative
# For platforms that prefer ZIP downloads

Write-Host "📦 Creating ZIP package for easy distribution..." -ForegroundColor Green

# Create a ZIP file using PowerShell
$source = "RNG-Capitalist-v2.1-Secure"
$destination = "RNG-Capitalist-v2.1-Portable.zip"

if (Test-Path $destination) {
    Remove-Item $destination -Force
}

# Create the ZIP file
Compress-Archive -Path $source -DestinationPath $destination -CompressionLevel Optimal

$zipSize = (Get-Item $destination).Length
$zipSizeMB = [math]::Round($zipSize / 1MB, 2)

Write-Host "✅ ZIP package created!" -ForegroundColor Green
Write-Host "📦 File: $destination" -ForegroundColor Cyan
Write-Host "💾 Size: $zipSizeMB MB" -ForegroundColor Yellow
Write-Host ""
Write-Host "📋 Distribution options:" -ForegroundColor White
Write-Host "   1. 🎯 RNG-Capitalist-v2.1-Installer.exe (Self-extracting installer)" -ForegroundColor Green
Write-Host "   2. 📦 RNG-Capitalist-v2.1-Portable.zip (Portable version)" -ForegroundColor Blue
Write-Host "   3. 🔗 Direct exe link (not recommended for Microsoft Store)" -ForegroundColor Yellow
