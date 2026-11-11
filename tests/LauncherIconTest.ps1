# Verify source fidelity, Android mask safety, and Play listing export.
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
$root=Split-Path -Parent $PSScriptRoot
$res=Join-Path $root 'extensions/play-games/android/src/main/res'
$ns='http://schemas.android.com/apk/res/android'
$original=[Drawing.Bitmap]::new((Join-Path $root 'assets/icons/icon.png'))
$listing=[Drawing.Bitmap]::new((Join-Path $root 'artwork/launcher/play-icon-512.png'))
if($listing.Width -ne 512 -or $listing.Height -ne 512){throw 'Wrong Play dimensions'}
[xml]$fg=Get-Content (Join-Path $res 'drawable/monster_icon_foreground.xml')
[xml]$mono=Get-Content (Join-Path $res 'drawable/monster_icon_monochrome.xml')
$expected=0
for($y=0;$y -lt 6;$y++){for($x=0;$x -lt 6;$x++){
 $c=$original.GetPixel($x+1,$y+1)
 if($c.ToArgb() -eq [Drawing.Color]::Black.ToArgb()){continue}
 $expected++
 if($listing.GetPixel(64+$x*64+32,64+$y*64+32).ToArgb() -ne $c.ToArgb()){throw 'Source color changed'}
}}
if(@($mono.vector.path).Count -ne $expected -or $expected -ge 36){throw 'Themed mask includes backdrop'}
$index=0
foreach($p in $fg.vector.path){
 $d=$p.GetAttribute('pathData',$ns)
 if($d -notmatch '^M([\d.]+),([\d.]+) h([\d.]+) v'){throw 'Unexpected vector path'}
 $x=[double]$Matches[1];$y=[double]$Matches[2];$s=[double]$Matches[3]
 foreach($dx in @(0,$s)){foreach($dy in @(0,$s)){if([Math]::Pow($x+$dx-54,2)+[Math]::Pow($y+$dy-54,2) -gt 1089){throw 'Outside guaranteed safe circle'}}}
 if($mono.vector.path[$index].GetAttribute('pathData',$ns) -ne $d){throw 'Mask geometry mismatch'}
 $index++
}
for($y=0;$y -lt 512;$y++){for($x=0;$x -lt 512;$x++){if($listing.GetPixel($x,$y).A -ne 255){throw 'Listing is not opaque'}}}
$listing.Dispose();$original.Dispose()
Write-Output "PASS: $expected original colored pixels, unchanged colors, non-square themed mask, safe circle, opaque 512px listing."
