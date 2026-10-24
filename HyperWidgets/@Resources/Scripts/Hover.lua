-- Smooth hover highlight. A hit meter named H1..H4 calls Go('H1', 1) on mouse over and
-- Go('H1', 0) on leave; Step() (every 16 ms from [MeasureHoverTimer]) eases variable #H1#
-- toward that goal and redraws. Meters use #H1# (0..1) in formulas: size, stroke, brightness.

local cur, goal = {}, {}

-- One animation step: 20 % of the way, snapped when close (about 0.35 s in total).
function Ease(v, g)
	v = v + (g - v) * 0.2
	if math.abs(g - v) < 0.005 then v = g end
	return v
end

function Go(name, on)
	goal[name] = on
	cur[name] = cur[name] or 0
	SKIN:Bang('!CommandMeasure', 'MeasureHoverTimer', 'Stop 1')
	SKIN:Bang('!CommandMeasure', 'MeasureHoverTimer', 'Execute 1')
end

function Step()
	local moved = false
	for name, g in pairs(goal) do
		if cur[name] ~= g then
			cur[name] = Ease(cur[name], g)
			SKIN:Bang('!SetVariable', name, string.format('%.3f', cur[name]))
			moved = true
		end
	end
	if moved then
		SKIN:Bang('!UpdateMeter', '*')
		SKIN:Bang('!Redraw')
	end
end

-- Color between two theme colors (names of R,G,B variables), h = 0..1.
-- FontColor=[&MeasureHover:Mix('Dim', 'Text', #H1#)]
function Mix(a, b, h)
	h = tonumber(h) or 0
	local ca, cb = {}, {}
	for n in (SKIN:GetVariable(a) or ''):gmatch('%d+') do ca[#ca + 1] = tonumber(n) end
	for n in (SKIN:GetVariable(b) or ''):gmatch('%d+') do cb[#cb + 1] = tonumber(n) end
	local out = {}
	for i = 1, 3 do
		local x, y = ca[i] or 0, cb[i] or 0
		out[i] = math.floor(x + (y - x) * h + 0.5)
	end
	return table.concat(out, ',') .. ',255'
end

-- Theme color with alpha going from a (h = 0) to b (h = 1, default 255).
-- BarColor=[&MeasureHover:Color('AccentRam', 140, #H2#)]
function Color(name, a, h, b)
	h = tonumber(h) or 0
	b = b or 255
	return (SKIN:GetVariable(name) or '0,0,0') .. ',' .. math.floor(a + (b - a) * h + 0.5)
end
