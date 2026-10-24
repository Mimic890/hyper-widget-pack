-- Magnet between widgets. Rainmeter only glues edges a few px apart and never lines widgets up,
-- so after a drag a widget closer than PULL px to another one moves right against it and takes
-- its top / bottom (side by side) or left / right edge (stacked) when that is close too.
-- Each widget shares its window rect with the others in a group variable Snap<NAME> = "x,y,w,h".

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

-- The shift closest to 0 among the given ones, if it is at most PULL px.
local function near(...)
	local m
	for _, d in ipairs({ ... }) do
		if math.abs(d) <= PULL and (not m or math.abs(d) < math.abs(m)) then m = d end
	end
	return m
end

-- Where widget a should go: against the nearest other widget closer than PULL px (gap or
-- overlap; Rainmeter's own snap only catches a few px), lined up with its edge when that is
-- close too. nil = stay (already in place or nothing near).
function Pull(a, others)
	local best, bx, by
	local function try(dx, dy)
		if dx and (not best or math.abs(dx) + math.abs(dy) < best) then
			best, bx, by = math.abs(dx) + math.abs(dy), a.x + dx, a.y + dy
		end
	end
	for _, b in ipairs(others) do
		if a.y < b.y + b.h and b.y < a.y + a.h then -- beside: snap x, line up top / bottom
			local dx = near(b.x + b.w - a.x, b.x - a.w - a.x)
			try(dx, dx and (near(b.y - a.y, b.y + b.h - a.h - a.y) or 0))
		end
		if a.x < b.x + b.w and b.x < a.x + a.w then -- above / below: snap y, line up left / right
			local dy = near(b.y + b.h - a.y, b.y - a.h - a.y)
			if dy then try(near(b.x - a.x, b.x + b.w - a.w - a.x) or 0, dy) end
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
