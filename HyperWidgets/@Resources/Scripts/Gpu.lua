-- NVIDIA GPU stats from nvidia-smi (comes with the driver, no extra program).
-- Source (RunCommand) prints one line: "load, vram used MB, vram total MB, temp C", e.g. "38, 1909, 8188, 54".
-- Option: Source.

KEYS = { 'load', 'vramUsed', 'vramTotal', 'temp' }
values = {}

function Initialize()
	source = SKIN:GetMeasure(SELF:GetOption('Source'))
end

-- Fields that aren't numbers ("[N/A]", error text) stay empty and show as "--".
function Parse(out)
	values = {}
	local line = out:match('[^\r\n]+') or ''
	local i = 0
	for field in (line .. ','):gmatch('([^,]*),') do
		i = i + 1
		if KEYS[i] then values[KEYS[i]] = tonumber(field:match('^%s*(.-)%s*$')) end
	end
	return values.load and 1 or 0
end

-- Called when nvidia-smi finishes (FinishAction).
function Update()
	return Parse(source:GetStringValue())
end

-- Inline use: [&MeasureGpu:Get('vramUsed', 1, 1024)] -> "1.9" or "--"
function Get(key, decimals, divisor)
	local v = values[key]
	if not v then return '--' end
	return string.format('%.' .. (decimals or 0) .. 'f', v / (divisor or 1))
end

-- Number for bars and rings, 0 when missing.
function GetNum(key)
	return values[key] or 0
end

-- VRAM used share 0..1 (rings view).
function VramPct()
	local t = values.vramTotal
	if not (t and t > 0 and values.vramUsed) then return 0 end
	return values.vramUsed / t
end
