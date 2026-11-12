$ErrorActionPreference='Stop'
Push-Location (Split-Path -Parent $PSScriptRoot)
try {
 python tools/Prepare-ArcadeTests.py
 if($LASTEXITCODE -ne 0){throw 'Test project preparation failed'}
 # Hosted runner only. Debug enables real bitmap-log assertions; no production telemetry.
 haxelib run lime build ArcadeTest.xml windows -debug -D arcade_regression -D HXCPP_CHECK_POINTER -D HXCPP_STACK_TRACE -nolaunch
 if($LASTEXITCODE -ne 0){throw 'Isolated native regression build failed'}
 python tools/Run-ArcadeTests.py
 if($LASTEXITCODE -ne 0){throw 'Native regressions failed'}
} finally {Pop-Location}
