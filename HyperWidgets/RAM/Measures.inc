; RAM measures, shared by RAM.ini (list view) and Rings.ini (rings view).

; ---------- Measures (bytes) ----------
[MeasureUsed]
Measure=PhysicalMemory

[MeasureTotal]
Measure=PhysicalMemory
Total=1

; Swap = pagefile.sys. SwapMemory total is RAM + pagefile, so pagefile size = that minus RAM.
[MeasureCommitTotal]
Measure=SwapMemory
Total=1

[MeasureSwapTotal]
Measure=Calc
Formula=Max(MeasureCommitTotal - MeasureTotal, 0)

; Pagefile usage in percent (English counter names work on any Windows language).
[MeasureSwapPercent]
Measure=Plugin
Plugin=UsageMonitor
Category=Paging File
Counter=% Usage
Index=0
MinValue=0
MaxValue=100

[MeasureSwapUsed]
Measure=Calc
Formula=MeasureSwapPercent / 100 * MeasureSwapTotal


; Swap percent as a plain number: the plugin's own text value is the counter instance name ("Total").
[MeasureSwapPct]
Measure=Calc
Formula=MeasureSwapPercent
