; DISK measures, shared by DISK.ini (list view) and Rings.ini (rings view).
[Rainmeter]
ContextTitle21=Set disks...
ContextAction21=[!CommandMeasure MeasureDiskInput "ExecuteBatch 1"]


; ---------- Measures (bytes). Used = InvertMeasure of free space ----------
[MeasureDisk1Used]
Measure=FreeDiskSpace
Drive=#DiskMain#
InvertMeasure=1
UpdateDivider=10

[MeasureDisk1Total]
Measure=FreeDiskSpace
Drive=#DiskMain#
Total=1
UpdateDivider=60

[MeasureDisk2Used]
Measure=FreeDiskSpace
Drive=#Disk2#
InvertMeasure=1
UpdateDivider=10

[MeasureDisk2Total]
Measure=FreeDiskSpace
Drive=#Disk2#
Total=1
UpdateDivider=60

[MeasureDisk3Used]
Measure=FreeDiskSpace
Drive=#Disk3#
InvertMeasure=1
UpdateDivider=10

[MeasureDisk3Total]
Measure=FreeDiskSpace
Drive=#Disk3#
Total=1
UpdateDivider=60

[MeasureDisk4Used]
Measure=FreeDiskSpace
Drive=#Disk4#
InvertMeasure=1
UpdateDivider=10

[MeasureDisk4Total]
Measure=FreeDiskSpace
Drive=#Disk4#
Total=1
UpdateDivider=60

; How many extra disks exist (unused "-" or missing drive has total 0).
[MeasureExtraDisks]
Measure=Calc
Formula=(MeasureDisk2Total > 0) + (MeasureDisk3Total > 0) + (MeasureDisk4Total > 0)

; Writes the typed disk list to Variables.inc.
[MeasureDisks]
Measure=Script
ScriptFile=#@#Scripts\Disks.lua
VarsFile=#@#Variables.inc
UpdateDivider=-1

; Text box over the title row: type letters like "C: G: D:", first = main. Enter = save, Esc = cancel.
[MeasureDiskInput]
Measure=Plugin
Plugin=InputText
X=(#Pad#*#Scale#+[MeasureFrameX])
Y=(#Pad#*#Scale#+#Margin#)
W=((#WidgetW#-2*#Pad#)*#Scale#)
H=(20*#Scale#)
FontFace=#FontFace#
FontSize=(#FontSize#*#Scale#)
FontColor=#Text#
SolidColor=#Bg#,255
DefaultValue=#DiskMain# #Disk2# #Disk3# #Disk4#
; X follows the frame (it moves left at the right screen edge)
DynamicVariables=1
Command1=[!CommandMeasure MeasureDisks "SetDisks('$UserInput$')"]

