# Reproduce the existing 8x8 icon as Android vector paths and a 512px Play export.
# Existing pixels only: remove gray frame and black backdrop; never modify source PNG.
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
$repoRoot=Split-Path -Parent $PSScriptRoot
$originalIcon=[Drawing.Bitmap]::new((Join-Path $repoRoot 'assets/icons/icon.png'))
if($originalIcon.Width -ne 8 -or $originalIcon.Height -ne 8){throw 'Expected original 8x8 icon'}
$sourceIcon=[Drawing.Bitmap]::new(6,6,[Drawing.Imaging.PixelFormat]::Format32bppArgb)
for($y=0;$y -lt 6;$y++){for($x=0;$x -lt 6;$x++){
    $c=$originalIcon.GetPixel($x+1,$y+1)
    if($c.ToArgb() -ne [Drawing.Color]::Black.ToArgb()){$sourceIcon.SetPixel($x,$y,$c)}
}}
$originalIcon.Dispose()
$resRoot=Join-Path $repoRoot 'extensions/play-games/android/src/main/res'
$artRoot=Join-Path $repoRoot 'artwork/launcher'
foreach($dir in @('drawable','drawable-anydpi-v26','drawable-anydpi-v33')) { New-Item -ItemType Directory -Force (Join-Path $resRoot $dir) | Out-Null }
New-Item -ItemType Directory -Force $artRoot | Out-Null
$step=[int][Math]::Floor(66/[Math]::Max($sourceIcon.Width,$sourceIcon.Height))
do {
    $safe=$true
    $ox=54-$sourceIcon.Width*$step/2
    $oy=54-$sourceIcon.Height*$step/2
    for($y=0;$y -lt $sourceIcon.Height;$y++){ for($x=0;$x -lt $sourceIcon.Width;$x++){
        if($sourceIcon.GetPixel($x,$y).A -eq 0){continue}
        foreach($dx in @(0,1)){foreach($dy in @(0,1)){
            $cx=$ox+($x+$dx)*$step-54; $cy=$oy+($y+$dy)*$step-54
            if($cx*$cx+$cy*$cy -gt 33*33){$safe=$false}
        }}
    }}
    if(!$safe){$step--}
} while(!$safe -and $step -gt 0)
if($step -lt 1){throw 'Icon cannot fit Android safe zone'}
$paths=@(); $mono=@(); $svg=@()
$listing=[Drawing.Bitmap]::new(512,512,[Drawing.Imaging.PixelFormat]::Format32bppArgb)
$graphics=[Drawing.Graphics]::FromImage($listing)
$graphics.Clear([Drawing.Color]::FromArgb(255,23,23,23))
$listingStep=64; $listingOffset=64
if($listingStep -ne [Math]::Floor($listingStep) -or $sourceIcon.Width -ne $sourceIcon.Height){throw 'Listing requires an exact integer square enlargement'}
for($y=0;$y -lt $sourceIcon.Height;$y++){for($x=0;$x -lt $sourceIcon.Width;$x++){
    $color=$sourceIcon.GetPixel($x,$y)
    if($color.A -eq 0){continue}
    $hex='{0:X8}' -f $color.ToArgb()
    $px=$ox+$x*$step; $py=$oy+$y*$step
    $pathData="M$px,$py h$step v$step h-$step z"
    $paths += "<path android:fillColor=`"#$hex`" android:pathData=`"$pathData`" />"
    $mono += "<path android:fillColor=`"#FFFFFFFF`" android:pathData=`"$pathData`" />"
    $sx=$listingOffset+$x*$listingStep; $sy=$listingOffset+$y*$listingStep
    $rgb=$hex.Substring(2)
    $svg += "<rect x=`"$sx`" y=`"$sy`" width=`"$listingStep`" height=`"$listingStep`" fill=`"#$rgb`" />"
    $brush=[Drawing.SolidBrush]::new($color)
    $graphics.FillRectangle($brush,[int]$sx,[int]$sy,[int]$listingStep,[int]$listingStep)
    $brush.Dispose()
}}
$header='<vector xmlns:android="http://schemas.android.com/apk/res/android" android:width="108dp" android:height="108dp" android:viewportWidth="108" android:viewportHeight="108">'
($header+[Environment]::NewLine+($paths -join [Environment]::NewLine)+[Environment]::NewLine+'</vector>') | Set-Content (Join-Path $resRoot 'drawable/monster_icon_foreground.xml')
($header+[Environment]::NewLine+($mono -join [Environment]::NewLine)+[Environment]::NewLine+'</vector>') | Set-Content (Join-Path $resRoot 'drawable/monster_icon_monochrome.xml')
'<layer-list xmlns:android="http://schemas.android.com/apk/res/android"><item><shape><solid android:color="#171717" /></shape></item><item android:drawable="@drawable/monster_icon_foreground" /></layer-list>' | Set-Content (Join-Path $resRoot 'drawable/monster_launcher.xml')
'<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android"><background android:drawable="@color/monster_icon_background"/><foreground android:drawable="@drawable/monster_icon_foreground"/></adaptive-icon>' | Set-Content (Join-Path $resRoot 'drawable-anydpi-v26/monster_launcher.xml')
'<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android"><background android:drawable="@color/monster_icon_background"/><foreground android:drawable="@drawable/monster_icon_foreground"/><monochrome android:drawable="@drawable/monster_icon_monochrome"/></adaptive-icon>' | Set-Content (Join-Path $resRoot 'drawable-anydpi-v33/monster_launcher.xml')
'<resources><color name="monster_icon_background">#171717</color></resources>' | Set-Content (Join-Path $resRoot 'values/launcher_colors.xml')
('<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512" shape-rendering="crispEdges"><rect width="512" height="512" fill="#171717"/>'+($svg -join '')+'</svg>') | Set-Content (Join-Path $artRoot 'play-icon-512.svg')
$listing.Save((Join-Path $artRoot 'play-icon-512.png'),[Drawing.Imaging.ImageFormat]::Png)
$graphics.Dispose(); $listing.Dispose(); $sourceIcon.Dispose()
Write-Output "Original character isolated without repainting; launcher source pixels = ${step}dp; all opaque corners fit the 66dp safe circle. Play export is 512x512 RGBA, exact ${listingStep}x pixels."
