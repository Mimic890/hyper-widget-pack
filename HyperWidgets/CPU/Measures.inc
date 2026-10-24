; CPU measures, shared by CPU.ini (list view) and Rings.ini (rings view).

; ---------- Measures ----------
[MeasureCPU]
Measure=CPU

[MeasureQueue]
Measure=Plugin
Plugin=UsageMonitor
Category=System
Counter=Processor Queue Length
Index=0

; Must stay below MeasureCPU and MeasureQueue so they update first.
[MeasureLoad]
Measure=Script
ScriptFile=#@#Scripts\LoadAvg.lua
CpuMeasure=MeasureCPU
QueueMeasure=MeasureQueue
Interval=1

