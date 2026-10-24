; Right-click > View (list or rings) and Title (show / hide). Not used by WEATHER.
; Each view is its own .ini in the widget folder; activating the other one swaps it in place (same position).
; Title is saved into the widget's own .ini (no file path), so only that widget changes.

[Rainmeter]
ContextTitle15=---
ContextTitle16=View: list
ContextAction16=[!ActivateConfig "#CURRENTCONFIG#" "#ListFile#"]
ContextTitle17=View: rings
ContextAction17=[!ActivateConfig "#CURRENTCONFIG#" "Rings.ini"]
ContextTitle18=---
ContextTitle19=Title: show
ContextAction19=[!WriteKeyValue Variables ShowTitle 1][!Refresh]
ContextTitle20=Title: hide
ContextAction20=[!WriteKeyValue Variables ShowTitle 0][!Refresh]
; Widgets may add ContextTitle21.
