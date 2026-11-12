$ErrorActionPreference='Stop'
Push-Location (Split-Path -Parent $PSScriptRoot)
try {
  foreach($test in @('LocalScoresTest','PointerPresentationTest','AchievementCatalogTest','GameEventCatalogTest')) {
    haxe -cp core -cp tests -main $test --interp
    if($LASTEXITCODE -ne 0){throw "Failed $test"}
  }
  foreach($script in @('tools/Test-DesktopNavigation.py','tools/Test-DesktopGameEvents.py')) {
    python $script
    if($LASTEXITCODE -ne 0){throw "Failed $script"}
  }
  & ./tools/Test-DesktopOnline.ps1
  & ./tests/HistoricalAndroidSourceTest.ps1
  & ./tests/LauncherIconTest.ps1
  & ./tests/PlayGamesConfigTest.ps1
  $source='extensions/play-games/android/src/main/java/com/axolstudio/monstermatch'
  $tests='tests/java/com/axolstudio/monstermatch'
  $names=@('AccountProgress','AccountSession','AuthDiagnostics','GameEventRules','InitialsText','UiRequestGate')
  $files=@($names | ForEach-Object {"$source/$_.java"}) + @(Get-ChildItem $tests -Filter '*.java' | ForEach-Object {$_.FullName})
  New-Item -ItemType Directory -Force diagnostics/java | Out-Null
  javac -d diagnostics/java $files
  if($LASTEXITCODE -ne 0){throw 'Pure Java compile failed'}
  foreach($test in @('AccountProgressTest','AuthDiagnosticsTest','GameEventRulesTest','InitialsTextTest','UiRequestGateTest')) {
    java -cp diagnostics/java "com.axolstudio.monstermatch.$test"
    if($LASTEXITCODE -ne 0){throw "Failed $test"}
  }
} finally {Pop-Location}
