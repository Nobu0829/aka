$sourceDir = (Get-Location).Path
$tempDir = "C:\temp_babydash"

Write-Host "Copying project from $sourceDir to $tempDir to avoid Japanese path issues..."
New-Item -ItemType Directory -Force -Path $tempDir | Out-Null
Copy-Item -Path "$sourceDir\*" -Destination $tempDir -Recurse -Force

Set-Location -Path $tempDir

Write-Host "Cleaning up flutter cache..."
flutter clean

flutter pub get

Write-Host "Building APK..."
flutter build apk

$apkPath = "$tempDir\build\app\outputs\flutter-apk\app-release.apk"
if (Test-Path $apkPath) {
    Write-Host "Build successful! Copying APK to original folder..."
    Copy-Item -Path $apkPath -Destination "$sourceDir\app-release.apk" -Force
} else {
    Write-Host "APK not found, build might have failed."
}

Set-Location -Path $sourceDir
Write-Host "Cleaning up temp directory..."
Remove-Item -Path $tempDir -Recurse -Force

Write-Host "Done!"
