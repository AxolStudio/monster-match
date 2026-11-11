# Read-only checks for the historical build26 launcher. No generation or Android build.
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
$root=Split-Path -Parent $PSScriptRoot
$res=Join-Path $root 'extensions/play-games/android/src/main/res'
$ns='http://schemas.android.com/apk/res/android'
$original=[Drawing.Bitmap]::new((Join-Path $root 'assets/icons/icon.png'))
try {
 if($original.Width -ne 8 -or $original.Height -ne 8){throw 'Expected original 8x8 source'}
 [xml]$fg=Get-Content (Join-Path $res 'drawable/monster_icon_foreground.xml')
 [xml]$mono=Get-Content (Join-Path $res 'drawable/monster_icon_monochrome.xml')
 if(@($fg.vector.path).Count -ne 64 -or @($mono.vector.path).Count -ne 64){throw 'Historical build26 requires all 64 framed pixels'}
 foreach($vector in @($fg.vector,$mono.vector)) {
  foreach($attr in @('width','height')) { if($vector.GetAttribute($attr,$ns) -ne '108dp'){throw 'Wrong vector dimensions'} }
  foreach($attr in @('viewportWidth','viewportHeight')) { if($vector.GetAttribute($attr,$ns) -ne '108'){throw 'Wrong viewport'} }
 }
 for($y=0;$y -lt 8;$y++){for($x=0;$x -lt 8;$x++){
  $i=$y*8+$x; $px=34+$x*5; $py=34+$y*5
  $expected="M$px,$py h5 v5 h-5 z"
  $color='#{0:X8}' -f $original.GetPixel($x,$y).ToArgb()
  if($fg.vector.path[$i].GetAttribute('fillColor',$ns) -ne $color){throw 'Historical source color changed'}
  if($mono.vector.path[$i].GetAttribute('fillColor',$ns) -ne '#FFFFFFFF'){throw 'Monochrome color changed'}
  foreach($vector in @($fg.vector,$mono.vector)) {
   if($vector.path[$i].GetAttribute('pathData',$ns) -ne $expected){throw 'Historical framed geometry changed'}
  }
  foreach($dx in @(0,5)){foreach($dy in @(0,5)){
   if([Math]::Pow($px+$dx-54,2)+[Math]::Pow($py+$dy-54,2) -gt 1089){throw 'Outside guaranteed safe circle'}
  }}
 }}
} finally {$original.Dispose()}
Write-Output 'PASS: historical build26 full 8x8 frame, 64 exact colors/paths, monochrome geometry, and safe circle. Listing references are intentionally excluded.'
