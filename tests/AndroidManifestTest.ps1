param([string]$ManifestPath = "$PSScriptRoot/../export/android/bin/app/build/intermediates/merged_manifest/debug/processDebugMainManifest/AndroidManifest.xml")
$ErrorActionPreference='Stop'
$project=Get-Content -LiteralPath "$PSScriptRoot/../Project.xml" -Raw
$app=[regex]::Match($project,'<app\s[^>]+/>', 'Singleline').Value
if($app -notmatch '\bbuild-number="26"' -or $app -match '\sbuild="') { throw 'Use the supported build-number="26" attribute, not build.' }
if(!(Test-Path -LiteralPath $ManifestPath)){throw 'Run lime update android and Gradle processDebugMainManifest before this test.'}
[xml]$xml=Get-Content -LiteralPath $ManifestPath -Raw
$android='http://schemas.android.com/apk/res/android'
$root=$xml.DocumentElement
if($root.GetAttribute('versionCode',$android) -ne '26'){throw 'Merged Android versionCode is not 26'}
if($root.GetAttribute('versionName',$android) -ne '1.0.5'){throw 'Merged versionName is not 1.0.5'}
$appNode=$root.SelectSingleNode('application')
if($appNode.GetAttribute('name',$android) -ne 'com.axolstudio.monstermatch.PlayGamesApplication'){throw 'Play Games Application initializer missing'}
foreach($provider in $appNode.SelectNodes('provider')){
 if($provider.GetAttribute('name',$android) -eq 'com.google.android.gms.games.provider.PlayGamesInitProvider'){throw 'Unconditional SDK init provider was not removed'}
}
$sdk=$root.SelectSingleNode('uses-sdk')
if($sdk.GetAttribute('minSdkVersion',$android) -ne '24' -or $sdk.GetAttribute('targetSdkVersion',$android) -ne '36'){throw 'Unexpected SDK floor or target'}
Write-Output 'Android project version, merged manifest, SDK limits and Application initialization checks passed'
