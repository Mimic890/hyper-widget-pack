-- Load average like Cygwin getloadavg():
--   active = logical_cpus * CPU% / 100 + \System\Processor Queue Length
--   load[i] = load[i] * e + active * (1 - e),  e = exp(-dt / T[i]),  T = 60/300/900 s
-- Options: CpuMeasure, QueueMeasure, Interval (seconds between updates, default 1).

T = { 60, 300, 900 }
avg = nil

function Initialize()
	cpu = SKIN:GetMeasure(SELF:GetOption('CpuMeasure'))
	queue = SKIN:GetMeasure(SELF:GetOption('QueueMeasure'))
	threads = tonumber(os.getenv('NUMBER_OF_PROCESSORS')) or 1
	dt = SELF:GetNumberOption('Interval', 1)
end

function Step(active)
	if not avg then
		-- shortcut: seeded with the first sample instead of 0, so 5/15 min are sane right after start
		avg = { active, active, active }
	else
		for i, t in ipairs(T) do
			local e = math.exp(-dt / t)
			avg[i] = avg[i] * e + active * (1 - e)
		end
	end
	return avg[1]
end

function Update()
	local load = cpu:GetValue()
	-- CPU measure reports 0 on its very first update; don't seed with that.
	if not avg and load == 0 then return 0 end
	return Step(threads * load / 100 + queue:GetValue())
end

-- 1-min load as a share of all threads, 0..1 (rings view).
function LoadPct()
	if not avg then return 0 end
	return math.min(avg[1] / threads, 1)
end

-- Inline use: [&MeasureLoad:Avg(1)] -> "1.23"
function Avg(i)
	if not avg then return '--' end
	return string.format('%.2f', avg[i])
end
