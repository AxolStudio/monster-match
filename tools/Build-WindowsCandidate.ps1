$ErrorActionPreference = 'Stop'
Push-Location (Split-Path -Parent $PSScriptRoot)
try {
  # Compile only: production telemetry must never run in CI.
  haxelib run lime build windows -nolaunch
  if ($LASTEXITCODE -ne 0) { throw 'Windows candidate compilation failed' }
  $bin = Join-Path (Get-Location) 'export/windows/bin'
  if (!(Test-Path (Join-Path $bin 'MonsterMatch.exe'))) { throw 'Missing Windows executable' }
  New-Item -ItemType Directory -Force candidate | Out-Null
  $sha = (git rev-parse HEAD).Trim()
  $manifest = @{ game='Monster Match'; sourceCommit=$sha; configuration='windows'; startup='fullscreen'; deployment='none'; caveats=@('Physical controller/hotplug and cabinet acceptance pending','Live API delivery not tested'); files=@(Get-ChildItem $bin -File -Recurse | ForEach-Object { @{path=[IO.Path]::GetRelativePath($bin,$_.FullName);sha256=(Get-FileHash $_.FullName -Algorithm SHA256).Hash} }) }
  $manifest | ConvertTo-Json -Depth 6 | Set-Content candidate/manifest.json
  Compress-Archive -Path "$bin/*" -DestinationPath candidate/MonsterMatch-Windows.zip -Force
  Get-FileHash candidate/MonsterMatch-Windows.zip -Algorithm SHA256 | Format-List | Out-File candidate/SHA256.txt
} finally { Pop-Location }
