-- Open-Meteo forecast parser + city search (geocoding) for the WEATHER widget.
-- Options: Source (forecast WebParser), GeoSource (geocoding WebParser), VarsFile (Variables.inc path).

values = {}
hourly = {}
days = {}
status = nil
geoPending = false

-- Hourly chart: the URL asks past_hours=4, so hourly[NOW] is the current hour.
-- BARS bars, one per 2 hours starting at hourly[1]; bar NOWBAR is the current hour.
NOW, BARS, NOWBAR = 5, 12, 3

-- WMO weather codes -> short text (ASCII only).
DESC = {
	[0] = 'Clear', [1] = 'Mostly clear', [2] = 'Partly cloudy', [3] = 'Overcast',
	[45] = 'Fog', [48] = 'Rime fog',
	[51] = 'Light drizzle', [53] = 'Drizzle', [55] = 'Dense drizzle',
	[56] = 'Freezing drizzle', [57] = 'Freezing drizzle',
	[61] = 'Light rain', [63] = 'Rain', [65] = 'Heavy rain',
	[66] = 'Freezing rain', [67] = 'Freezing rain',
	[71] = 'Light snow', [73] = 'Snow', [75] = 'Heavy snow', [77] = 'Snow grains',
	[80] = 'Showers', [81] = 'Showers', [82] = 'Heavy showers',
	[85] = 'Snow showers', [86] = 'Snow showers',
	[95] = 'Thunderstorm', [96] = 'Storm, hail', [99] = 'Storm, hail',
}

function Initialize()
	source = SKIN:GetMeasure(SELF:GetOption('Source'))
	geoSource = SKIN:GetMeasure(SELF:GetOption('GeoSource'))
	varsFile = SELF:GetOption('VarsFile')
end

-- current.* -> values['temperature_2m'], daily first day -> values['daily.temperature_2m_max'],
-- hourly arrays -> hourly.time / hourly.temperature_2m / hourly.weather_code (strings).
function Parse(raw)
	values, hourly = {}, {}
	local cur = raw:match('"current"%s*:%s*(%b{})')
	if cur then
		for k, v in cur:gmatch('"([%w_]+)"%s*:%s*(%-?[%d.]+)') do values[k] = tonumber(v) end
	end
	local daily = raw:match('"daily"%s*:%s*(%b{})')
	if daily then
		for k, v in daily:gmatch('"([%w_]+)"%s*:%s*%[%s*(%-?[%d.]+)') do values['daily.' .. k] = tonumber(v) end
	end
	hourly = ParseArrays(raw:match('"hourly"%s*:%s*(%b{})'))
	days = ParseArrays(daily)
	return cur and 1 or 0
end

-- {"time":["a","b"],"x":[1,2]} -> { time = {"a","b"}, x = {"1","2"} }
function ParseArrays(block)
	local t = {}
	if not block then return t end
	for k, arr in block:gmatch('"([%w_]+)"%s*:%s*(%b[])') do
		local list = {}
		for v in arr:gmatch('[^,%[%]]+') do table.insert(list, (v:gsub('"', ''))) end
		t[k] = list
	end
	return t
end

-- Called after every forecast download (FinishAction).
function Update()
	return Parse(source:GetStringValue())
end

function Clear()
	values, hourly, days = {}, {}, {}
end

-- Inline use: [&MeasureWeather:Get('temperature_2m', 1)] -> "5.8" or "--"
function Get(key, decimals)
	local v = values[key]
	if not v then return '--' end
	return string.format('%.' .. (decimals or 0) .. 'f', v)
end

function Desc()
	local code = values['weather_code']
	if not code then return '' end
	return DESC[code] or ('Code ' .. code)
end

-- 'Rain', 'Snow' or nil for a WMO code.
function Kind(code)
	code = tonumber(code)
	if not code or code < 51 then return nil end
	if (code >= 71 and code <= 77) or code == 85 or code == 86 then return 'Snow' end
	return 'Rain'
end

local function hourAt(i, key) return (hourly[key] or {})[i] end
local function barTemp(i) return tonumber(hourAt(2 * i - 1, 'temperature_2m')) end

-- Bar height in base px (8..48), scaled between the coldest and warmest bar.
function BarH(i)
	local t = barTemp(i)
	if not t then return 1 end
	local lo, hi = t, t
	for b = 1, BARS do
		local v = barTemp(b)
		if v then lo, hi = math.min(lo, v), math.max(hi, v) end
	end
	if hi == lo then return 28 end
	return 8 + (t - lo) / (hi - lo) * 40
end

-- Hovered bar (set by the hit areas), otherwise the current hour.
sel = nil
function Selected() return sel or NOWBAR end
-- Hover animation: grow[i] eases 0 -> 1 for the hovered bar and back to 0 for the others.
-- MeasureAnim (ActionTimer) calls Tick() ~60 times a second for a short burst after each hover change.
GROW_H, GROW_W, EASE = 6, 3, 0.3
grow = {}
function G(i) return grow[i] or 0 end

function Tick()
	for i = 1, BARS do
		local target = (i == sel) and 1 or 0
		local g = G(i) + (target - G(i)) * EASE
		if math.abs(target - g) < 0.01 then g = target end
		grow[i] = g
	end
end

-- Animated bar geometry (base px): taller and wider, growing from its center.
function DrawH(i) return BarH(i) + GROW_H * G(i) end
function DrawW(i) return BARW + GROW_W * G(i) end
function DrawX(i) return BarX(i) - GROW_W / 2 * G(i) end

-- Changes only when the selection really changes (no flicker while moving across bars).
function Hover(i)
	if sel == i then return end
	sel = i
	SKIN:Bang('!CommandMeasure', 'MeasureAnim', 'Stop 1')
	SKIN:Bang('!CommandMeasure', 'MeasureAnim', 'Execute 1')
end

-- "R,G,B" + alpha for the top of bar i: selected = text color, rain/snow highlighted, past faded.
function BarRGB(i)
	local kind = Kind(hourAt(2 * i - 1, 'weather_code'))
	if i == Selected() then return SKIN:GetVariable('Text'), 255 end
	if kind == 'Rain' then return SKIN:GetVariable('AccentNet'), 230 end
	if kind == 'Snow' then return '210,230,255', 230 end
	return SKIN:GetVariable('Dim'), (i < NOWBAR and 70 or 150)
end

-- Gradient for bar i: solid at the top, fading out at the bottom (like Glance).
function BarGradient(i)
	local rgb, a = BarRGB(i)
	return '270 | ' .. rgb .. ',' .. a .. ' ; 0.0 | ' .. rgb .. ',' .. math.floor(a / 6) .. ' ; 1.0'
end

-- Bar x (base px, inside the chart box) and layout constants for the meters.
BARX0, BARSTEP, BARW, CHARTX, CHARTY, CHARTW, CHARTH = 5, 20, 7, 12, 64, 236, 72
function BarX(i) return BARX0 + (i - 1) * BARSTEP end

-- Label positions (base px, skin coords) for the selected bar.
function SelX() return CHARTX + BarX(Selected()) + BARW / 2 end
function SelY() return CHARTY + CHARTH - 4 - DrawH(Selected()) end

function SelTemp()
	local s = Selected()
	if s == NOWBAR then return Get('temperature_2m') end
	local t = barTemp(s)
	return t and string.format('%.0f', t) or '--'
end

function SelHour() return Hour(Selected()) end

-- Daylight: bars between sunrise and sunset (ISO strings compare correctly as text).
function IsDay(i)
	local t = hourAt(2 * i - 1, 'time')
	if not (t and days.sunrise and days.sunset) then return false end
	for d = 1, #days.sunrise do
		if t >= days.sunrise[d] and t <= (days.sunset[d] or '') then return true end
	end
	return false
end

-- n-th daylight block as "x,y,w,h" scaled for the Shape meter; a 1 px dot if none.
function DayRect(n, scale)
	local found, i = 0, 1
	while i <= BARS do
		if IsDay(i) then
			local a = i
			while i < BARS and IsDay(i + 1) do i = i + 1 end
			found = found + 1
			if found == n then
				-- 7 px padding around the bars, kept inside the chart box.
				local x = math.max(BarX(a) - 7, 0)
				local w = math.min(BarX(i) + BARW + 7, CHARTW) - x
				return string.format('%g,0,%g,%g', x * scale, w * scale, CHARTH * scale)
			end
		end
		i = i + 1
	end
	return '0,0,1,1' -- tiny instead of empty: zero-size shapes may be rejected
end

-- "14:00" under bar i.
function Hour(i)
	return (hourAt(2 * i - 1, 'time') or ''):match('T(%d%d:%d%d)') or ''
end

-- First rain/snow in the coming hours, e.g. "Rain from 14:00".
function Summary()
	local codes = hourly.weather_code
	if not codes then return '' end
	for i = NOW, #codes do
		local kind = Kind(codes[i])
		if kind then
			if i == NOW then return kind .. ' now' end
			return kind .. ' from ' .. (hourAt(i, 'time'):match('T(%d%d:%d%d)') or '?')
		end
	end
	return 'No rain or snow ahead'
end

-- City label: search status while looking up, otherwise "City, Country".
function City(saved, country)
	if status then return status end
	if country and country ~= '' then return saved .. ', ' .. country end
	return saved
end

-- Variables.inc must stay ASCII: non-ASCII letters (umlauts, accents) are dropped.
local function ascii(s) return (s:gsub('[\128-\255]', '')) end

-- First geocoding result -> lat, lon, name, country (nil if nothing found).
function ParseGeo(raw)
	local lat = raw:match('"latitude"%s*:%s*(%-?[%d.]+)')
	local lon = raw:match('"longitude"%s*:%s*(%-?[%d.]+)')
	if not (lat and lon) then return nil end
	local name = ascii(raw:match('"name"%s*:%s*"([^"]*)"') or 'City')
	local country = ascii(raw:match('"country"%s*:%s*"([^"]*)"') or '')
	return lat, lon, name, country
end

-- Input box sent a city: mark that the next geocoding result should be saved.
function StartGeo()
	geoPending = true
	status = 'searching...'
end

-- Called after every geocoding download (FinishAction). Saves only if user searched.
function ApplyGeo()
	if not geoPending then return end
	geoPending = false
	local lat, lon, name, country = ParseGeo(geoSource:GetStringValue())
	if not lat then
		status = 'not found'
		SKIN:Bang('!UpdateMeter', '*')
		SKIN:Bang('!Redraw')
		return
	end
	SKIN:Bang('!WriteKeyValue', 'Variables', 'WeatherCity', name, varsFile)
	SKIN:Bang('!WriteKeyValue', 'Variables', 'WeatherCountry', country, varsFile)
	SKIN:Bang('!WriteKeyValue', 'Variables', 'WeatherLat', lat, varsFile)
	SKIN:Bang('!WriteKeyValue', 'Variables', 'WeatherLon', lon, varsFile)
	SKIN:Bang('!Refresh')
end
