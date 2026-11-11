param(
    [switch]$PackageOnly,
    [Parameter(Mandatory=$true)][string]$SigningDirectory,
    [string]$SdkPath = 'E:/android/sdk',
    [string]$NdkPath = "$env:USERPROFILE/.codex/android-tooling/ndk/android-ndk-r28c",
    [string]$JavaPath = 'C:/Program Files/Eclipse Adoptium/jdk-21.0.6.7-hotspot'
)
$ErrorActionPreference = 'Stop'
# A Play Games-enabled testing release must never silently use blank resources.
& "$PSScriptRoot/Validate-PlayGamesConfig.ps1"
$projectRoot = (Resolve-Path (Split-Path -Parent $PSScriptRoot)).Path
$keyPath = (Resolve-Path (Join-Path $SigningDirectory 'upload-keystore.p12')).Path
$passwordPath = (Resolve-Path (Join-Path $SigningDirectory 'upload-password.dpapi')).Path
foreach ($path in @($keyPath, $passwordPath)) {
    if ($path.StartsWith($projectRoot + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) { throw 'Signing secrets must be outside the repository.' }
}
$initScript = (Resolve-Path "$PSScriptRoot/release-signing.init.gradle").Path.Replace('\','/')
if ($initScript -match '\s') { throw 'Lime splits Gradle arguments on spaces; use a checkout path without spaces for this release script.' }
if (Test-Path "$projectRoot/export/android/bin/app/signing.properties") { throw 'Remove or migrate the existing generated signing.properties configuration before using environment-based signing.' }
$secure = (Get-Content -LiteralPath $passwordPath -Raw).Trim() | ConvertTo-SecureString
$bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
$names = @('MM_UPLOAD_KEYSTORE','MM_UPLOAD_PASSWORD','ANDROID_GRADLE_TASK','ANDROID_SETUP','ANDROID_SDK','ANDROID_NDK_ROOT','ANDROID_HOST','JAVA_HOME','GRADLE_USER_HOME','HXCPP_COMPILE_THREADS','PATH')
$previous = @{}
foreach ($name in $names) { $previous[$name] = [Environment]::GetEnvironmentVariable($name, 'Process') }
Push-Location $projectRoot
try {
    $env:MM_UPLOAD_KEYSTORE = $keyPath
    $env:MM_UPLOAD_PASSWORD = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
    $env:ANDROID_GRADLE_TASK = "bundleRelease assembleRelease --init-script $initScript"
    $env:ANDROID_SETUP = 'true'
    $env:ANDROID_SDK = $SdkPath
    $env:ANDROID_NDK_ROOT = $NdkPath
    $env:ANDROID_HOST = 'windows-x86_64'
    $env:JAVA_HOME = $JavaPath
    $env:GRADLE_USER_HOME = 'E:/android/gradle-cache'
    $env:HXCPP_COMPILE_THREADS = '4'
    $env:PATH = "$PSScriptRoot/ndk-compat;$env:PATH"
    if ($PackageOnly) {
        Push-Location "$projectRoot/export/android/bin"
        try { & ./gradlew.bat bundleRelease assembleRelease --init-script $initScript }
        finally { Pop-Location }
    } else {
        & lime build android
    }
    if ($LASTEXITCODE -ne 0) { throw "Release bundle build failed: $LASTEXITCODE" }
    $bundle = Join-Path $projectRoot 'export/android/bin/app/build/outputs/bundle/release/app-release.aab'
    if (!(Test-Path -LiteralPath $bundle)) { throw 'Expected release AAB was not produced.' }
    $verification = & "$JavaPath/bin/jarsigner.exe" -verify $bundle 2>&1
    if ($LASTEXITCODE -ne 0 -or ($verification -join "`n") -notmatch 'jar verified\.') { throw 'AAB signature verification failed or bundle is unsigned.' }
    Write-Output $verification
    Get-FileHash -LiteralPath $bundle -Algorithm SHA256
} finally {
    foreach ($name in $names) { [Environment]::SetEnvironmentVariable($name, $previous[$name], 'Process') }
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
    $secure.Dispose()
    Pop-Location
}
