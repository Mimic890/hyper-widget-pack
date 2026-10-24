-- Donut ring geometry for the "rings" view.
-- Inline use: Shape2=[&MeasureRing:Arc((value 0..1), #Scale#, diameter, thickness)] | StrokeStartCap Round | ...
-- Returns an open Arc path from 12 o'clock, clockwise; the round caps come from the meter.

-- Arc from fraction a to b of the circle (0 = 12 o'clock, clockwise).
local function Span(a, b, scale, d, t)
	-- equal start and end would draw nothing; nearly equal ones (a full ring) leave the arc's
	-- center ill-defined, so the ring drew shifted sideways (full value arc, or the empty track
	-- of a 0% ring): stop 1% short, the gap hides under the value arc's round cap
	a = math.min(math.max(a, 0), 0.99)
	b = math.max(math.min(b, 0.99), a + 0.0001)
	local c, r = d / 2, (d - t) / 2
	local function x(p) return (c + r * math.sin(2 * math.pi * p)) * scale end
	local function y(p) return (c - r * math.cos(2 * math.pi * p)) * scale end
	return string.format('Arc %.4f,%.4f,%.4f,%.4f,%.4f,%.4f,0,0,%d',
		x(a), y(a), x(b), y(b), r * scale, r * scale, b - a > 0.5 and 1 or 0)
end

local function value(name, max)
	local m = SKIN:GetMeasure(name)
	if not m then return 0 end
	return max and m:GetValue() / max or m:GetRelativeValue()
end

function Arc(p, scale, d, t)
	return Span(0, tonumber(p) or 0, scale, d, t)
end

-- Grey track: only the part the value arc doesn't cover, so the two never overlap
-- (a track under the arc shows as a grey fringe around it). Shape=[&MeasureRing:Rest(...)]
function Rest(p, scale, d, t)
	return Span(tonumber(p) or 0, 1, scale, d, t)
end

-- Same, value read from a measure here: section variables like [MeasureCPU:] are not
-- resolved inside inline Lua arguments. Without max: the measure's own 0..1 range
-- (Min/MaxValue, disk or memory size); with max: value / max.
function ArcOf(name, scale, d, t, max)
	return Arc(value(name, max), scale, d, t)
end

function RestOf(name, scale, d, t, max)
	return Rest(value(name, max), scale, d, t)
end
