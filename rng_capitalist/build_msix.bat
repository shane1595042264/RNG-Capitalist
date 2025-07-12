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
