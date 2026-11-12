$ErrorActionPreference='Stop'
Push-Location (Split-Path -Parent $PSScriptRoot)
try {
 foreach($test in @('DesktopOnlineSessionTest','DesktopOnlineDispatcherTest','DesktopOnlineConcurrencyTest','DesktopOnlineBudgetTest','DesktopOnlineClientTest','DesktopOnlineInitialsTest','DesktopOnlineFacadeTest')) {
  haxe -cp source -cp tests/desktop-online -cp tests/desktop-online/stubs -main $test -D desktop -D desktop_input_test --interp
  if($LASTEXITCODE -ne 0){throw "$test failed"}
 }
 haxe -cp source -cp tests/desktop-online -cp tests/desktop-online/stubs -cp tests/desktop-online/http-stubs -main DesktopOnlineTransportTest -D desktop --interp
 if($LASTEXITCODE -ne 0){throw 'Online transport tests failed'}
 haxe -cp source -cp tests/desktop-online -cp tests/desktop-online/stubs -main DesktopOnlineRegressionTest -D desktop -D arcade_regression --interp
 if($LASTEXITCODE -ne 0){throw 'Online regression isolation failed'}
} finally {Pop-Location}
