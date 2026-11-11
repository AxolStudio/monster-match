$ErrorActionPreference='Stop'
$validator="$PSScriptRoot/../tools/Validate-PlayGamesConfig.ps1"
$source="$PSScriptRoot/../extensions/play-games/android/src/main/res/values/pgs_ids.xml"
$fixture=[IO.Path]::GetTempFileName()
try {
    [xml]$xml=Get-Content -LiteralPath $source -Raw
    foreach($node in $xml.resources.string){$node.InnerText=''}
    $xml.Save($fixture)
    & $validator -ConfigPath $fixture -AllowUnconfigured
    $failed=$false
    try { & $validator -ConfigPath $fixture } catch { $failed=$true }
    if(!$failed){throw 'Unconfigured release was accepted'}
    foreach($node in $xml.resources.string){$node.InnerText="test_$($node.name)"}
    ($xml.resources.string | Where-Object name -eq 'pgs_project_id').InnerText='12345'
    $xml.Save($fixture)
    & $validator -ConfigPath $fixture
    ($xml.resources.string | Where-Object name -eq 'achievement_gardens').InnerText='duplicate'
    ($xml.resources.string | Where-Object name -eq 'achievement_dungeons').InnerText='duplicate'
    $xml.Save($fixture)
    $failed=$false
    try { & $validator -ConfigPath $fixture } catch { $failed=$true }
    if(!$failed){throw 'Duplicate achievements were accepted'}
} finally { Remove-Item -LiteralPath $fixture }
Write-Output 'Play Games configuration gate tests passed'
