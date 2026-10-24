-- Magnet between widgets. Rainmeter only glues touching edges and never lines widgets up, so
-- after a drag: a widget touching another side by side takes its top (or bottom) edge, a stacked
-- one its left (or right) edge, if that is at most PULL px away. Each widget shares its window
-- rect with the others in a group variable Snap<NAME> = "x,y,w,h".

local PULL = 30
local NAMES = { 'CPU', 'RAM', 'NET', 'GPU', 'DISK', 'WEATHER', 'RECYCLE' }
local me, last, still, n

function Initialize()
	me = SKIN:GetVariable('CURRENTCONFIG'):match('[^\\]+$')
	still, n = 0, 0
end

local function rect()
	return SKIN:ReplaceVariables('#CURRENTCONFIGX#,#CURRENTCONFIGY#,#CURRENTCONFIGWIDTH#,#CURRENTCONFIGHEIGHT#')
end

local function parse(s)
	local x, y, w, h = (s or ''):match('^(-?[%d.]+),(-?[%d.]+),([%d.]+),([%d.]+)$')
	if x then return { x = tonumber(x), y = tonumber(y), w = tonumber(w), h = tonumber(h) } end
end

local function share(r)
	SKIN:Bang('!SetVariableGroup', 'Snap' .. me, r, 'HyperWidgets')
end

-- Where widget a should go to line up with one of the others; nil = stay (already lined up,
-- nothing close, or not touching anyone).
function Pull(a, others)
	local best, bx, by
	local function try(d, x, y)
		if math.abs(d) <= PULL and (not best or math.abs(d) < best) then best, bx, by = math.abs(d), x, y end
	end
	for _, b in ipairs(others) do
		local side = math.abs(a.x - (b.x + b.w)) <= 1 or math.abs(a.x + a.w - b.x) <= 1
		local stack = math.abs(a.y - (b.y + b.h)) <= 1 or math.abs(a.y + a.h - b.y) <= 1
		if side and a.y < b.y + b.h and b.y < a.y + a.h then
			try(b.y - a.y, a.x, b.y)
			try(b.y + b.h - (a.y + a.h), a.x, b.y + b.h - a.h)
		elseif stack and a.x < b.x + b.w and b.x < a.x + a.w then
			try(b.x - a.x, b.x, a.y)
			try(b.x + b.w - (a.x + a.w), b.x + b.w - a.w, a.y)
		end
	end
	if best and best > 0 then return bx, by end
end

-- Every second: a moved widget starts the fast check; the rect is re-shared every 5 s,
-- because a refreshed widget forgets the others' variables.
function Update()
	local r = rect()
	n = n + 1
	if r ~= last then
		if last then
			still = 0
			SKIN:Bang('!CommandMeasure', 'MeasureSnapTimer', 'Stop 1')
			SKIN:Bang('!CommandMeasure', 'MeasureSnapTimer', 'Execute 1')
		end
		last = r
		share(r)
	elseif n % 5 == 0 then
		share(r)
	end
	return 0
end

-- Every 200 ms while a drag may be going on: 2 ticks without moving = dropped, line up.
function Tick()
	local r = rect()
	if r ~= last then
		last, still = r, 0
		share(r)
		return
	end
	still = still + 1
	if still ~= 2 then return end
	SKIN:Bang('!CommandMeasure', 'MeasureSnapTimer', 'Stop 1')
	local others = {}
	for _, name in ipairs(NAMES) do
		local b = name ~= me and parse(SKIN:GetVariable('Snap' .. name))
		if b then table.insert(others, b) end
	end
	local x, y = Pull(parse(r), others)
	if x then SKIN:Bang('!Move', x, y) end
end
