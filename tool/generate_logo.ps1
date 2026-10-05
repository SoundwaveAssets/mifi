# Génère toutes les images PNG du logo « MiFi » (Windows PowerShell 5.1).
#
#   powershell -ExecutionPolicy Bypass -File tool\generate_logo.ps1
#
# La géométrie (unités de dessin) est identique à celle de
# assets/logo/mifi_logo.svg et des VectorDrawable Android
# (ic_launcher_foreground.xml) : mot-symbole « MiFi » dont le point du dernier
# « i » est remplacé par un signal Wi-Fi.
Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
$black = [System.Drawing.Color]::FromArgb(255, 0, 0, 0)        # #000000
$white = [System.Drawing.Color]::White

# Boîte englobante du mot-symbole en unités de dessin.
$minX = 0.0; $maxX = 110.5; $minY = -14.75; $maxY = 40.0

function New-WordmarkPath {
    $p = New-Object System.Drawing.Drawing2D.GraphicsPath
    $p.FillMode = [System.Drawing.Drawing2D.FillMode]::Winding
    # M
    $m = @(@(0,40), @(0,0), @(10,0), @(20,15), @(30,0), @(40,0), @(40,40), @(31,40), @(31,16), @(20,32), @(9,16), @(9,40))
    $p.AddPolygon([System.Drawing.PointF[]]($m | ForEach-Object { New-Object System.Drawing.PointF($_[0], $_[1]) }))
    # i (tige + point)
    $p.AddRectangle((New-Object System.Drawing.RectangleF(46, 14, 9, 26)))
    $p.AddEllipse((New-Object System.Drawing.RectangleF(46, 0, 9, 9)))
    # F
    $f = @(@(61,0), @(88,0), @(88,9), @(70,9), @(70,17), @(83,17), @(83,26), @(70,26), @(70,40), @(61,40))
    $p.AddPolygon([System.Drawing.PointF[]]($f | ForEach-Object { New-Object System.Drawing.PointF($_[0], $_[1]) }))
    # dernier i : tige + point du signal Wi-Fi
    $p.AddRectangle((New-Object System.Drawing.RectangleF(94, 14, 9, 26)))
    $p.AddEllipse((New-Object System.Drawing.RectangleF(94.5, 0.5, 8, 8)))
    return $p
}

# Dessine le mot-symbole dans [g], ramené à la largeur [width] et centré en ([cx], [cy]).
function Draw-Wordmark($g, [double]$width, [double]$cx, [double]$cy, $color) {
    $scale = $width / ($maxX - $minX)
    $state = $g.Save()
    $g.TranslateTransform([single]($cx - (($minX + $maxX) / 2) * $scale), [single]($cy - (($minY + $maxY) / 2) * $scale))
    $g.ScaleTransform([single]$scale, [single]$scale)
    $brush = New-Object System.Drawing.SolidBrush($color)
    $path = New-WordmarkPath
    $g.FillPath($brush, $path)
    # Arcs du signal Wi-Fi (centre 98.5 ; 4.5), de -125° à -55°.
    $pen = New-Object System.Drawing.Pen($color, 4.5)
    $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    foreach ($r in 10, 17) {
        $g.DrawArc($pen, [single](98.5 - $r), [single](4.5 - $r), [single](2 * $r), [single](2 * $r), -125, 70)
    }
    $g.Restore($state)
    $pen.Dispose(); $brush.Dispose(); $path.Dispose()
}

function New-Canvas([int]$size) {
    $bmp = New-Object System.Drawing.Bitmap($size, $size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    $g.Clear([System.Drawing.Color]::Transparent)
    return @($bmp, $g)
}

function New-RoundedRect([double]$x, [double]$y, [double]$w, [double]$h, [double]$r) {
    $p = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = 2 * $r
    $p.AddArc([single]$x, [single]$y, [single]$d, [single]$d, 180, 90)
    $p.AddArc([single]($x + $w - $d), [single]$y, [single]$d, [single]$d, 270, 90)
    $p.AddArc([single]($x + $w - $d), [single]($y + $h - $d), [single]$d, [single]$d, 0, 90)
    $p.AddArc([single]$x, [single]($y + $h - $d), [single]$d, [single]$d, 90, 90)
    $p.CloseFigure()
    return $p
}

# Icône : fond noir (carré arrondi ou disque) + mot-symbole blanc.
function Save-Icon([int]$size, [bool]$round, [string]$file) {
    $bmp, $g = New-Canvas $size
    $brush = New-Object System.Drawing.SolidBrush($black)
    if ($round) {
        $g.FillEllipse($brush, 0, 0, $size, $size)
        $width = $size * 0.66
    } else {
        $shape = New-RoundedRect 0 0 $size $size ($size * 0.22)
        $g.FillPath($brush, $shape)
        $shape.Dispose()
        $width = $size * 0.72
    }
    Draw-Wordmark $g $width ($size / 2) ($size / 2) $white
    $dir = Split-Path -Parent $file
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force $dir | Out-Null }
    $bmp.Save($file, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose(); $bmp.Dispose(); $brush.Dispose()
}

Save-Icon 1024 $false (Join-Path $root 'assets\logo\mifi_logo.png')
Save-Icon 512 $false (Join-Path $root 'assets\logo\mifi_logo_512.png')

$densities = @{ 'mdpi' = 48; 'hdpi' = 72; 'xhdpi' = 96; 'xxhdpi' = 144; 'xxxhdpi' = 192 }
foreach ($d in $densities.Keys) {
    $res = Join-Path $root "android\app\src\main\res\mipmap-$d"
    Save-Icon $densities[$d] $false (Join-Path $res 'ic_launcher.png')
    Save-Icon $densities[$d] $true (Join-Path $res 'ic_launcher_round.png')
}
Write-Output 'Logo généré.'
