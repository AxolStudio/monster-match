param(
    [string]$SdkPath = 'E:/android/sdk',
    [string]$NdkPath = "$env:USERPROFILE/.codex/android-tooling/ndk/android-ndk-r28c",
    [string]$JavaPath = 'C:/Program Files/Eclipse Adoptium/jdk-21.0.6.7-hotspot',
    [switch]$RequirePlayGamesConfig
)
$ErrorActionPreference = 'Stop'
if ($RequirePlayGamesConfig) { & "$PSScriptRoot/Validate-PlayGamesConfig.ps1" }
else { & "$PSScriptRoot/Validate-PlayGamesConfig.ps1" -AllowUnconfigured }
foreach ($required in @("$SdkPath/platform-tools/adb.exe", "$NdkPath/source.properties", "$JavaPath/bin/java.exe")) {
    if (!(Test-Path -LiteralPath $required)) { throw "Missing Android build dependency: $required" }
}
$env:ANDROID_SETUP = 'true'
$env:ANDROID_SDK = $SdkPath
$env:ANDROID_NDK_ROOT = $NdkPath
$env:ANDROID_HOST = 'windows-x86_64'
$env:JAVA_HOME = $JavaPath
$env:GRADLE_USER_HOME = 'E:/android/gradle-cache'
$env:HXCPP_COMPILE_THREADS = '4'
$env:PATH = "$PSScriptRoot/ndk-compat;$env:PATH"
Push-Location (Split-Path -Parent $PSScriptRoot)
try {
    & lime build android -debug
    if ($LASTEXITCODE -ne 0) { throw "Android build failed with exit code $LASTEXITCODE" }
} finally { Pop-Location }
