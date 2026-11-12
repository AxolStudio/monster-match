$ErrorActionPreference='Stop'
Push-Location (Split-Path -Parent $PSScriptRoot)
try {
  if (!(Test-Path '.haxelib')) { haxelib newrepo; if($LASTEXITCODE -ne 0){throw 'Private library repository failed'} }
  foreach($spec in @(@('lime','8.3.2'),@('openfl','9.5.2'),@('hxp','1.3.1'),@('hxcpp','4.3.2'),@('hscript','2.7.0'),@('flixel','6.2.1'),@('flixel-addons','4.0.1'))) {
    haxelib install $spec[0] $spec[1] --skip-dependencies --always
    if($LASTEXITCODE -ne 0){throw "Install failed: $spec"}
    haxelib set $spec[0] $spec[1]
    if($LASTEXITCODE -ne 0){throw "Select failed: $spec"}
  }
} finally {Pop-Location}
