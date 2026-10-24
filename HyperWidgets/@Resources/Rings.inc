; Shared parts of the "rings" view (each widget's Rings.ini).

[MeasureRing]
Measure=Script
ScriptFile=#@#Scripts\Ring.lua
UpdateDivider=-1

; Value in the middle of a ring.
[StyleRingValue]
StringAlign=CenterCenter
FontFace=#FontFace#
FontSize=(11*#Scale#)
FontWeight=700
FontColor=#Text#,255
AntiAlias=1
DynamicVariables=1

; Caption under a ring.
[StyleRingLabel]
StringAlign=CenterTop
FontFace=#FontFace#
FontSize=(8*#Scale#)
FontColor=#Dim#,255
AntiAlias=1
DynamicVariables=1
