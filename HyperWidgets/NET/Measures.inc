; NET measures, shared by NET.ini (list view) and Rings.ini (rings view).

; ---------- Measures (bytes per second) ----------
[MeasureIn]
Measure=NetIn
Interface=#NetInterface#
; needed so Interface=Best follows adapter changes
DynamicVariables=1

[MeasureOut]
Measure=NetOut
Interface=#NetInterface#
DynamicVariables=1

