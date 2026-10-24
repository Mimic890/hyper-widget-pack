; Shared [Rainmeter] options and MeterStyles for every widget.
; Colors come from Themes\*.inc as R,G,B (alpha is appended here).

[Rainmeter]
Update=1000
AccurateText=1
Group=HyperWidgets
ContextTitle=Themes...
ContextAction=[!ToggleConfig "HyperWidgets\ThemePicker" "ThemePicker.ini"]
ContextTitle2=Align all here
ContextAction2=[!SetVariableGroup AlignX #CURRENTCONFIGX# HyperWidgets]
ContextTitle3=---
; Size and Opacity: no file path = written into this widget's own .ini, so only this widget changes.
ContextTitle4=Size: 75%
ContextAction4=[!WriteKeyValue Variables Scale 0.75][!Refresh]
ContextTitle5=Size: 100%
ContextAction5=[!WriteKeyValue Variables Scale 1.0][!Refresh]
ContextTitle6=Size: 125%
ContextAction6=[!WriteKeyValue Variables Scale 1.25][!Refresh]
ContextTitle7=Size: 150%
ContextAction7=[!WriteKeyValue Variables Scale 1.5][!Refresh]
ContextTitle8=---
ContextTitle9=Opacity: 40%
ContextAction9=[!WriteKeyValue Variables BgAlpha 100][!Refresh]
ContextTitle10=Opacity: 60%
ContextAction10=[!WriteKeyValue Variables BgAlpha 150][!Refresh]
ContextTitle11=Opacity: 80%
ContextAction11=[!WriteKeyValue Variables BgAlpha 200][!Refresh]
ContextTitle12=Opacity: 100%
ContextAction12=[!WriteKeyValue Variables BgAlpha 255][!Refresh]
ContextTitle13=---
ContextTitle14=Edit settings file
ContextAction14=["#@#Variables.inc"]
; Widgets may add ContextTitle15 (numbers must stay continuous, a gap hides the rest).

; "Align all here": every widget moves to this one's X (keeps its own Y). Rainmeter snapping
; only glues edge to edge, it doesn't line up left edges.
[MeasureAlign]
Measure=Calc
Formula=#AlignX#
DynamicVariables=1
IfCondition=MeasureAlign >= 0
IfTrueAction=[!Move #AlignX# #CURRENTCONFIGY#][!SetVariable AlignX -1]

; Frame X: Margin, or 0 when the window touches the right screen edge, so the empty space moves
; to the right side and the widget keeps a gap there too. Only the content shifts, the window stays put.
[MeasureFrameX]
Measure=Calc
Formula=(#CURRENTCONFIGX# + #CURRENTCONFIGWIDTH# >= #WORKAREAX# + #WORKAREAWIDTH# - 1 ? 0 : #Margin#)
DynamicVariables=1

; ---------- Widget frame ----------
; Every widget: [MeterSpacer] (invisible, sets the window size: Margin of empty space left and above),
; [MeterFrame] (container shifted by [MeasureFrameX] and Margin; all other meters have Container=MeterFrame,
; so their X/Y count from the frame), then [MeterBg] inside the frame.
[StyleSpacer]
Shape=Rectangle 0,0,(#WidgetW#*#Scale#+#Margin#),((#WidgetH#+#ExtraH#-#TitleCut#*(1-#ShowTitle#))*#Scale#+#Margin#) | Fill Color 0,0,0,0 | StrokeWidth 0
DynamicVariables=1

[StyleFrame]
X=[MeasureFrameX]
Y=#Margin#
Shape=Rectangle 0,0,(#WidgetW#*#Scale#),((#WidgetH#+#ExtraH#-#TitleCut#*(1-#ShowTitle#))*#Scale#) | Fill Color 255,255,255,255 | StrokeWidth 0
DynamicVariables=1

; Rounded background with a faint neutral outline (inset 0.5 px so the frame doesn't clip it).
; Without the title (ShowTitle=0) the widget gets TitleCut px shorter (TitleCut, ShowTitle; DISK adds ExtraH).
[StyleBg]
Shape=Rectangle 0.5,0.5,(#WidgetW#*#Scale#-1),((#WidgetH#+#ExtraH#-#TitleCut#*(1-#ShowTitle#))*#Scale#-1),(#Radius#*#Scale#) | Fill Color #Bg#,#BgAlpha# | StrokeWidth 1 | Stroke Color #Grid#,20
DynamicVariables=1

; Quiet centered title; right-click > Title: show / hide (ShowTitle in the widget's own .ini).
; Hidden it keeps its row height 0, so rows positioned with R below it move up.
[StyleTitle]
X=((#WidgetW#/2)*#Scale#)
Y=(#Pad#*#Scale#)
StringAlign=Center
FontFace=#FontFace#
FontSize=(#TitleSize#*#Scale#)
FontColor=#Dim#,200
AntiAlias=1
Hidden=(1-#ShowTitle#)

; Label on the left; put it on a new row under the previous meter.
; Fixed H = the text's natural height, so text growing on hover doesn't push rows below.
[StyleLabel]
X=(#Pad#*#Scale#)
Y=(4*#Scale#)R
H=(#FontSize#*1.8*#Scale#)
FontFace=#FontFace#
FontSize=(#FontSize#*#Scale#)
FontColor=#Dim#,255
AntiAlias=1

; Value on the right, same row as the label before it.
[StyleValue]
X=((#WidgetW#-#Pad#)*#Scale#)
Y=0r
H=(#FontSize#*1.8*#Scale#)
StringAlign=Right
FontFace=#FontFace#
FontSize=(#FontSize#*#Scale#)
FontColor=#Text#,255
AntiAlias=1
