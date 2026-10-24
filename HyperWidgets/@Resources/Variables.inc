; ============================================================
;  HyperWidgets - global settings. Edit, save, then right-click
;  any widget > Refresh skin (or tray icon > Refresh all).
;  ASCII only! (or save as UTF-16 LE)
; ============================================================
[Variables]
; Size is per widget: right-click a widget > Size, or Scale= in its own .ini.
; Theme: right-click a widget > Themes... (or type here):
;   Graphite, Warm, GitHub, Kanagawa  - have Light and Dark versions (see Appearance)
;   Latte (light), Frappe, Macchiato, Mocha  - Catppuccin, fixed look
Theme=GitHub
; Light, Dark or Auto (by wallpaper brightness), used by Graphite / Warm / GitHub / Kanagawa
Appearance=Auto
; Light/Dark actually in use. Written automatically (Themes... window and Auto); don't edit.
Mode=Dark
; Auto: re-check the wallpaper every N seconds
AutoCheck=300

; Font. Must be installed in Windows or dropped into @Resources\Fonts
FontFace=JetBrains Mono
; Base sizes in points/pixels (multiplied by Scale)
FontSize=10
TitleSize=8
; Title on (1) or off (0); each widget overrides it (right-click > Title).
ShowTitle=1
; How much shorter a widget gets without its title (base px); set per widget.
TitleCut=0
WidgetW=260
Pad=12
Radius=10
; Empty space left of and above each widget (px): 10 = 10 px between snapped widgets
; and from the left / top / right screen edges (at the right edge the space moves to the right side;
; the bottom edge stays flush).
Margin=10
; Extra background height (base px); DISK sets it for its extra disk rows.
; (Variables are filled in where they are declared, so formulas that use the widget's
; own values live in the styles, not here.)
ExtraH=0
; Set by right-click > Align all here; -1 = nothing to do
AlignX=-1
; Background opacity is per widget: right-click a widget > Opacity, or BgAlpha= in its own .ini.

; ---- NET ----
; Adapter name like Ethernet / Wi-Fi, or Best (auto). Best can pick a VPN tunnel
; (here it took throne-tun) and show wrong speeds, so the real network card is set.
NetInterface=Ethernet
; Rings view: speed (Mbit/s) that fills the ring completely
NetMaxDown=100
NetMaxUp=100

; ---- DISK ----
; Main disk, shown big. Extra disks: letters like D:, fill in order, "-" = unused slot.
DiskMain=C:
Disk2=G:
Disk3=-
Disk4=-

; ---- WEATHER (Open-Meteo, no key) ----
; Easiest: click the city name on the widget and type a new one. These 3 lines are rewritten then.
WeatherCountry=Russia
WeatherCity=Moscow
WeatherLat=55.75
WeatherLon=37.62
; Refresh every N seconds (Open-Meteo current data changes every 15 min)
WeatherRate=900

; ---- GPU (nvidia-smi, comes with the NVIDIA driver) ----
; Read the GPU every N seconds
GpuRate=2

BgAlpha=200
