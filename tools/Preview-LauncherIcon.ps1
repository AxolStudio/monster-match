Add-Type -AssemblyName System.Drawing
$root=Split-Path -Parent $PSScriptRoot
$ns='http://schemas.android.com/apk/res/android'
$out=Join-Path $root 'artwork/launcher'
$sheet=[Drawing.Bitmap]::new(864,400)
$g=[Drawing.Graphics]::FromImage($sheet);$g.Clear([Drawing.Color]::FromArgb(255,238,238,238))
$font=[Drawing.Font]::new('Arial',14)
for($i=0;$i -lt 4;$i++){
 $themed=$i -ge 2;$circle=$i%2 -eq 0
 $tile=[Drawing.Bitmap]::new(216,216);$t=[Drawing.Graphics]::FromImage($tile)
 $path=[Drawing.Drawing2D.GraphicsPath]::new()
 if($circle){$path.AddEllipse(0,0,216,216)}else{$r=48;$path.AddArc(0,0,$r,$r,180,90);$path.AddArc(216-$r,0,$r,$r,270,90);$path.AddArc(216-$r,216-$r,$r,$r,0,90);$path.AddArc(0,216-$r,$r,$r,90,90);$path.CloseFigure()}
 $t.SetClip($path)
 $bg=if($themed){[Drawing.Color]::FromArgb(255,210,229,213)}else{[Drawing.Color]::FromArgb(255,23,23,23)}
 $t.Clear($bg)
 [xml]$xml=Get-Content (Join-Path $root 'extensions/play-games/android/src/main/res/drawable/monster_icon_foreground.xml')
 foreach($p in $xml.vector.path){
  $null=$p.GetAttribute('pathData',$ns) -match '^M([\d.]+),([\d.]+) h([\d.]+) v';$x=[double]$Matches[1];$y=[double]$Matches[2];$s=[double]$Matches[3]
  $c=if($themed){[Drawing.Color]::FromArgb(255,32,67,40)}else{[Drawing.ColorTranslator]::FromHtml($p.GetAttribute('fillColor',$ns))}
  $b=[Drawing.SolidBrush]::new($c)
  # Android's 108dp layer is cropped to a 72dp visible mask.
  $t.FillRectangle($b,[single](($x-18)*3),[single](($y-18)*3),[single]($s*3),[single]($s*3));$b.Dispose()
 }
 $t.Dispose();$g.DrawImageUnscaled($tile,$i*216,70);$tile.Dispose();$path.Dispose()
 $label=if($themed){'Themed'}else{'Full color'};$shape=if($circle){'circle'}else{'squircle'}
 $g.DrawString("$label / $shape",$font,[Drawing.Brushes]::Black,$i*216+5,310)
}
$g.DrawString('Monster Match | Existing artwork only',$font,[Drawing.Brushes]::Black,15,20)
$g.DrawString('Mask simulations, not device screenshots',$font,[Drawing.Brushes]::Black,15,360)
$sheet.Save((Join-Path $out 'icon-preview.png'),[Drawing.Imaging.ImageFormat]::Png)
$g.Dispose();$sheet.Dispose();$font.Dispose()
