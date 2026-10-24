# Prints Light or Dark for HyperWidgets Auto appearance.
# Widgets match the wallpaper: bright wallpaper -> Light widgets, dark wallpaper -> Dark widgets.
# If the wallpaper can't be read: follow the Windows app mode (Settings > Personalization > Colors).
# -Image <file> overrides the wallpaper (used for testing).
param([string]$Image)
$ErrorActionPreference = 'Stop'

function Get-WindowsMode {
	try { $light = Get-ItemPropertyValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' AppsUseLightTheme }
	catch { $light = 0 }
	if ($light -eq 1) { 'Light' } else { 'Dark' }
}

# Relative luminance 0..1 of an sRGB color (simple weights, no gamma: good enough for a threshold).
function Get-Luma($r, $g, $b) { (0.2126 * $r + 0.7152 * $g + 0.0722 * $b) / 255 }

try {
	if ($Image) {
		$file = $Image
	} else {
		$wp = Get-ItemPropertyValue 'HKCU:\Control Panel\Desktop' WallPaper
		if (-not $wp) {
			# Solid color background: "R G B"
			$c = (Get-ItemPropertyValue 'HKCU:\Control Panel\Colors' Background) -split ' ' | ForEach-Object { [int]$_ }
			if ((Get-Luma $c[0] $c[1] $c[2]) -gt 0.5) { 'Light' } else { 'Dark' }
			exit
		}
		# Windows keeps a copy of the current wallpaper (also for slideshow) here.
		$file = Join-Path $env:APPDATA 'Microsoft\Windows\Themes\TranscodedWallpaper'
		if (-not (Test-Path $file)) { $file = $wp }
	}
	Add-Type -AssemblyName System.Drawing
	$img = [System.Drawing.Image]::FromFile($file)
	try { $bmp = New-Object System.Drawing.Bitmap $img, 32, 32 } finally { $img.Dispose() }
	$sum = 0
	for ($x = 0; $x -lt 32; $x++) {
		for ($y = 0; $y -lt 32; $y++) {
			$p = $bmp.GetPixel($x, $y)
			$sum += Get-Luma $p.R $p.G $p.B
		}
	}
	$bmp.Dispose()
	if ($sum / 1024 -gt 0.5) { 'Light' } else { 'Dark' }
} catch {
	Get-WindowsMode
}
