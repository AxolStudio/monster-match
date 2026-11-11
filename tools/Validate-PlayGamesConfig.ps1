param(
    [string]$ConfigPath = "$PSScriptRoot/../extensions/play-games/android/src/main/res/values/pgs_ids.xml",
    [switch]$AllowUnconfigured
)
$ErrorActionPreference='Stop'
[xml]$config=Get-Content -LiteralPath $ConfigPath -Raw
$names=@('pgs_project_id','leaderboard_high_scores','achievement_gardens','achievement_dungeons','achievement_catacomb','achievement_viaduct','achievement_ruins','achievement_ramparts','achievement_sanctum','achievement_victory','achievement_drinkme','achievement_spellshuffle','achievement_spellpurge','achievement_spellmeteor')
$values=@{}
foreach($name in $names){
    $nodes=@($config.resources.string | Where-Object name -eq $name)
    if($nodes.Count -ne 1){throw "Missing or duplicate Play Games resource: $name"}
    $values[$name]=$nodes[0].InnerText.Trim()
}
$filled=@($values.Values | Where-Object {$_ -ne ''})
if($filled.Count -eq 0 -and $AllowUnconfigured){Write-Output 'Play Games intentionally unconfigured; offline test build.';return}
if($filled.Count -ne $names.Count){throw 'Real Play Games project, leaderboard and all 12 achievement IDs are required.'}
if($values['pgs_project_id'] -notmatch '^[1-9][0-9]*$'){throw 'Use the numeric Play Games app/project ID from the Console export.'}
$ids=@($names | Where-Object {$_ -ne 'pgs_project_id'} | ForEach-Object {$values[$_]})
if(@($ids | Select-Object -Unique).Count -ne $ids.Count){throw 'Achievement and leaderboard IDs must be unique.'}
Write-Output 'Play Games resource configuration is complete; Console credentials/testers still require live verification.'
