; Smooth hover highlight (Scripts\Hover.lua). Each hoverable object (ring or row) has a
; 0..1 variable H1..H4 and an invisible hit meter with the same name and MeterStyle=StyleHit.
; Meters of that object use #Hn# in formulas: ring / bar grows and gets thicker,
; dim colors brighten, text gets bigger and brighter. Text grows by TransformationMatrix around its
; anchor, not by FontSize: a fractional font size each frame makes the letters jitter.
; The matrix works in window coordinates: pivots add the frame offset ([MeasureFrameX] for x, #Margin# for y), except [Meter:Y],
; which already counts from the window.

[Variables]
H1=0
H2=0
H3=0
H4=0

[MeasureHover]
Measure=Script
ScriptFile=#@#Scripts\Hover.lua
UpdateDivider=-1

; 40 steps of 16 ms; Hover.lua restarts it on every mouse over / leave.
[MeasureHoverTimer]
Measure=Plugin
Plugin=ActionTimer
ActionList1=Repeat Tick,16,40
Tick=[!CommandMeasure MeasureHover "Step()"]

; Invisible hit area (alpha 1 so it catches the mouse); the meter itself sets Meter=Image and
; Container=MeterFrame. Text and shapes over it have no mouse actions, so they don't block it.
[StyleHit]
SolidColor=0,0,0,1
MouseOverAction=[!CommandMeasure MeasureHover "Go('#CURRENTSECTION#', 1)"]
MouseLeaveAction=[!CommandMeasure MeasureHover "Go('#CURRENTSECTION#', 0)"]
DynamicVariables=1
