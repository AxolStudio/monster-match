# Pin the source established by the independent historical local package audit.
# Optional package arguments verify artifact identity, not signatures or Play submission.
param([string]$ApkPath, [string]$AabPath)
$ErrorActionPreference='Stop'
$root=Split-Path -Parent $PSScriptRoot
$expected=@{
 'tools/Build-LauncherIcon.ps1'='A5503A3CF13032B5B8D1E1D69B0D7B357E9A8C25BDB5CF94474E707B0DDD52E5'
 'extensions/play-games/android/src/main/res/drawable/monster_icon_foreground.xml'='2EAFBCEE3FAACE2D6C943769B2C3D82786D118018BDF8B3AEFAA1C7C73CFE660'
 'extensions/play-games/android/src/main/res/drawable/monster_icon_monochrome.xml'='F5A08A5DFBE9AA68C97A3A4251C1618BB759EB0F035CBD74FB4A2841DDC90D27'
 'extensions/play-games/android/src/main/res/drawable/monster_launcher.xml'='A137E5E38909EEB7E6B857AB0196BB62FE3F95BEE639365EF7FB3E6621F80204'
 'extensions/play-games/android/src/main/res/drawable-anydpi-v26/monster_launcher.xml'='07D26FCF51CCEE564D19AE997271479368428CA77DB35D69D9B60285AB113A78'
 'extensions/play-games/android/src/main/res/drawable-anydpi-v33/monster_launcher.xml'='717AEFAD46126500D89C061AC1B27226B7C711EE668807EEE97C1A3409040CD6'
 'extensions/play-games/android/src/main/res/values/launcher_colors.xml'='96E427B754A4B588478127B12161716022C1B725164FF6BB8D7C496300454BA8'
}
$sha=[Security.Cryptography.SHA256]::Create()
try {
 foreach($file in $expected.Keys) {
  # Git checkout line-ending conversion must not change source identity.
  $text=[IO.File]::ReadAllText((Join-Path $root $file)).Replace("`r`n","`n")
  $hash=[BitConverter]::ToString($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($text))).Replace('-','')
  if($hash -ne $expected[$file]){throw "Historical source changed: $file"}
 }
} finally {$sha.Dispose()}
if((Get-FileHash (Join-Path $root 'assets/icons/icon.png')).Hash -ne 'A2F6373EE9CA57844FE2FC6B8C7DFBA0BDB0B45D7A08B2F8156AAE40C9A97C7F'){throw 'Original desktop/icon input changed'}
$project=Get-Content (Join-Path $root 'Project.xml') -Raw
$app=[regex]::Match($project,'<app\s[^>]+/>','Singleline').Value
foreach($attribute in @('package="com.axolstudio.monstermatch"','version="1.0.5"','build-number="26"')) {
 if(!$app.Contains($attribute)){throw "Historical package configuration changed: $attribute"}
}
if($app -match '\sbuild="'){throw 'Ignored build attribute must not replace build-number'}
if($project -notmatch '<config:android[^>]*minimum-sdk-version="24"[^>]*target-sdk-version="36"[^>]*if="android"'){throw 'Android SDK configuration changed'}
if($project -notmatch '<icon path="assets/icons/icon.png" unless="android"\s*/>'){throw 'Desktop icon boundary changed'}
if($ApkPath) {
 if((Get-FileHash -LiteralPath $ApkPath).Hash -ne 'C9523AC8E27F01C0D4C238324D7538203132FAB550B4DEC62EFC62570FA132ED'){throw 'Not the audited local build26 APK'}
 Write-Output 'PASS: audited historical local APK identity'
}
if($AabPath) {
 if((Get-FileHash -LiteralPath $AabPath).Hash -ne '9B56216392663D7A61196CC7E9ED54875D82F5AA126465C48525502EE3515370'){throw 'Not the audited local build26 AAB'}
 Write-Output 'PASS: audited historical local AAB identity'
}
Write-Output 'PASS: historical generator/resources, original desktop icon, effective version/SDK config. No build or generation performed.'
