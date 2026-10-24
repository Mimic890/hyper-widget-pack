; GPU measures, shared by GPU.ini (list view) and Rings.ini (rings view).
; Data from nvidia-smi (part of the NVIDIA driver). The driver doesn't report power for this card.

; ---------- Measures ----------
; Parses nvidia-smi output when it finishes.
[MeasureGpu]
Measure=Script
ScriptFile=#@#Scripts\Gpu.lua
Source=MeasureSmi
UpdateDivider=-1

[MeasureSmi]
Measure=Plugin
Plugin=RunCommand
Program=nvidia-smi
Parameter=--query-gpu=utilization.gpu,memory.used,memory.total,temperature.gpu --format=csv,noheader,nounits
State=Hide
OutputType=ANSI
Timeout=5000
FinishAction=[!UpdateMeasure MeasureGpu]

; Runs nvidia-smi on load and then every GpuRate seconds.
[MeasureSmiTimer]
Measure=Calc
Formula=1
UpdateDivider=#GpuRate#
OnUpdateAction=[!CommandMeasure MeasureSmi "Run"]

; Load as a number 0..100 for the bar and ring.
[MeasureGpuLoad]
Measure=Calc
Formula=[&MeasureGpu:GetNum('load')]
MinValue=0
MaxValue=100
DynamicVariables=1
