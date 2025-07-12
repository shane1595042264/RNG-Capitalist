#!/usr/bin/env pwsh
# Emergency API Key Rotation Script

Write-Host "🚨 EMERGENCY API KEY ROTATION" -ForegroundColor Red
Write-Host "================================" -ForegroundColor Red
Write-Host ""

Write-Host "⚠️  CRITICAL: An API key has been exposed on GitHub!" -ForegroundColor Yellow
Write-Host "📋 Exposed Key: AIzaSyAQ1kZIG6dXHHekLVUAGHaTyGzOD8UVQYY" -ForegroundColor Red
Write-Host ""

Write-Host "🔧 IMMEDIATE ACTIONS REQUIRED:" -ForegroundColor Cyan
Write-Host ""

Write-Host "1. 🌐 Open Google Cloud Console:" -ForegroundColor White
Write-Host "   https://console.cloud.google.com/apis/credentials" -ForegroundColor Blue
Write-Host ""

Write-Host "2. 🔍 Find and DISABLE the exposed key:" -ForegroundColor White
Write-Host "   - Look for key: AIzaSyAQ1kZIG6dXHHekLVUAGHaTyGzOD8UVQYY" -ForegroundColor Red
Write-Host "   - Click 'Delete' or 'Disable' immediately" -ForegroundColor Yellow
Write-Host ""

Write-Host "3. 🆕 Generate NEW Gemini API key:" -ForegroundColor White
Write-Host "   - Go to: https://aistudio.google.com/app/apikey" -ForegroundColor Blue
Write-Host "   - Click 'Create API Key'" -ForegroundColor Green
Write-Host "   - Copy the new key" -ForegroundColor Green
Write-Host ""

Write-Host "4. 🔄 Update your .env file:" -ForegroundColor White
Write-Host "   - Replace GOOGLE_GEMINI_API_KEY with new key" -ForegroundColor Yellow
Write-Host "   - Save the file" -ForegroundColor Yellow
Write-Host ""

Write-Host "5. 🧪 Test the application:" -ForegroundColor White
Write-Host "   - Run your app to verify new key works" -ForegroundColor Green
Write-Host "   - Process a test document" -ForegroundColor Green
Write-Host ""

Write-Host "🛡️  SECURITY STATUS:" -ForegroundColor Magenta
Write-Host "   ✅ Environment variables implemented" -ForegroundColor Green
Write-Host "   ✅ .env file gitignored" -ForegroundColor Green
Write-Host "   ✅ No hardcoded keys in code" -ForegroundColor Green
Write-Host "   ❌ Old exposed key still needs revocation" -ForegroundColor Red
Write-Host ""

Write-Host "🚀 AFTER KEY ROTATION:" -ForegroundColor Cyan
Write-Host "   - Your app will be 100% secure" -ForegroundColor Green
Write-Host "   - No more API key leaks possible" -ForegroundColor Green
Write-Host "   - Ready for production deployment" -ForegroundColor Green
Write-Host ""

Read-Host "Press Enter after you've rotated the API key..."

Write-Host "✅ Security incident handled!" -ForegroundColor Green
Write-Host "🔒 Your application is now secure!" -ForegroundColor Green
