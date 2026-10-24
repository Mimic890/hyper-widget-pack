-- Self-check for LoadAvg, Ring, Gpu, Weather, Disks, Picker, AutoMode scripts and theme files. Writes result.txt next to this file, then unloads itself.

function Initialize()
	-- not 'dir': Picker.lua uses a global with that name
	local outDir = SKIN:GetVariable('CURRENTPATH')
	local scripts = SKIN:GetVariable('SKINSPATH') .. 'HyperWidgets\\@Resources\\'
	dofile(scripts .. 'Scripts\\LoadAvg.lua')

	local fails = {}
	local function check(name, got, want)
		if got ~= want then table.insert(fails, name .. ': got ' .. tostring(got) .. ', want ' .. tostring(want)) end
	end

	-- Load average: steady 2.0, then 60 s of idle -> 1-min avg = 2*e^-1.
	dt = 1
	check('no data yet', Avg(1), '--')
	Step(2)
	check('seeded', Avg(3), '2.00')
	for _ = 1, 60 do Step(0) end
	check('1 min decay', Avg(1), string.format('%.2f', 2 * math.exp(-1)))
	check('15 min decay', Avg(3), string.format('%.2f', 2 * math.exp(-60 / 900)))
	check('threads env', tonumber(os.getenv('NUMBER_OF_PROCESSORS')) ~= nil, true)
	threads = 4
	check('load pct', LoadPct(), avg[1] / 4)
	avg[1] = 10
	check('load pct capped', LoadPct(), 1)

	-- Rings view: arc from 12 o'clock, clockwise; d=64, t=7 -> center 32, radius 28.5.
	dofile(scripts .. 'Scripts\\Ring.lua')
	check('arc quarter', Arc(0.25, 1, 64, 7), 'Arc 32.0000,3.5000,60.5000,32.0000,28.5000,28.5000,0,0,0')
	check('arc three quarters', Arc(0.75, 1, 64, 7), 'Arc 32.0000,3.5000,3.5000,32.0000,28.5000,28.5000,0,0,1')
	check('arc scaled', Arc(0.25, 2, 64, 7), 'Arc 64.0000,7.0000,121.0000,64.0000,57.0000,57.0000,0,0,0')
	check('arc empty clamps', Arc(0, 1, 64, 7):sub(-1), '0')
	check('arc full clamps', Arc(1.5, 1, 64, 7):sub(-1), '1')
	check('arc junk', Arc('x', 1, 64, 7) ~= nil, true)
	check('arcof missing measure', ArcOf('NoSuchMeasure', 1, 64, 7), Arc(0, 1, 64, 7))
	check('rest starts where arc ends', Rest(0.25, 1, 64, 7):sub(1, 19), 'Arc 60.5000,32.0000')
	check('rest ends at 12', Rest(0.25, 1, 64, 7):match('Arc [^,]+,[^,]+,([^,]+)'), '30.2105')
	check('full ring ends clearly left of its start', Arc(1, 1, 64, 7):match('Arc [^,]+,[^,]+,([^,]+)'), '30.2105')
	check('rest of empty is almost full', Rest(0, 1, 64, 7):sub(-1), '1')
	check('rest of full draws', Rest(1, 1, 64, 7) ~= nil, true)

	-- Hover easing and colors (SKIN here is the self-test skin; theme vars come from a stub).
	dofile(scripts .. 'Scripts\\Hover.lua')
	check('ease step', Ease(0, 1), 0.2)
	check('ease snaps', Ease(0.997, 1), 1)
	local v, n = 0, 0
	while v ~= 1 and n < 100 do v, n = Ease(v, 1), n + 1 end
	check('ease settles within timer', n <= 40, true)
	local realSkin = SKIN
	SKIN = { GetVariable = function(_, k) return ({ Dim = '100,100,100', Text = '200,0,50' })[k] end }
	check('mix half', Mix('Dim', 'Text', 0.5), '150,50,75,255')
	check('mix junk h', Mix('Dim', 'Text', 'x'), '100,100,100,255')
	check('color alpha', Color('Dim', 140, 0.5), '100,100,100,198')
	check('color to b', Color('Text', 255, 1, 70), '200,0,50,70')
	SKIN = realSkin

	-- GPU from nvidia-smi.
	dofile(scripts .. 'Scripts\\Gpu.lua')
	check('smi parsed', Parse('38, 1909, 8188, 54\r\n'), 1)
	check('smi load', Get('load'), '38')
	check('smi vram gb', Get('vramUsed', 1, 1024), '1.9')
	check('smi vram pct', VramPct(), 1909 / 8188)
	check('smi temp', GetNum('temp'), 54)
	check('smi n/a field', Parse('[N/A], 1909, 8188, 54'), 0)
	check('smi n/a shows dashes', Get('load'), '--')
	check('smi error text', Parse('NVIDIA-SMI has failed because it could not communicate'), 0)
	check('smi no vram', VramPct(), 0)

	-- Weather.lua redefines Get/Parse (also in Gpu.lua), so its checks run after the GPU ones.
	dofile(scripts .. 'Scripts\\Weather.lua')
	local forecast = '{"latitude":57.76,"current_units":{"time":"iso8601","temperature_2m":"\194\176C"},' ..
		'"current":{"time":"2026-10-23T18:15","interval":900,"temperature_2m":-5.8,"relative_humidity_2m":71,"weather_code":3,"wind_speed_10m":2.02},' ..
		'"daily_units":{"time":"iso8601"},"daily":{"time":["2026-10-23"],"temperature_2m_max":[9.0],"temperature_2m_min":[-4.0]}}'
	check('forecast parsed', Parse(forecast), 1)
	check('negative temp', Get('temperature_2m', 1), '-5.8')
	check('humidity', Get('relative_humidity_2m'), '71')
	check('daily min', Get('daily.temperature_2m_min'), '-4')
	check('desc', Desc(), 'Overcast')
	-- Hourly: 24 entries from now-4h; bars use every 2nd hour.
	local t, c, temps, codes = {}, {}, {}, {}
	for i = 1, 24 do
		table.insert(t, string.format('"2026-10-23T%02d:00"', (13 + i) % 24))
		table.insert(temps, tostring(i)) -- 1..24, warmest last
		table.insert(codes, i == 9 and '61' or (i == 15 and '73' or '3'))
	end
	Parse('{"current":{"temperature_2m":5},"hourly":{"time":[' .. table.concat(t, ',') .. '],"temperature_2m":[' ..
		table.concat(temps, ',') .. '],"weather_code":[' .. table.concat(codes, ',') .. ']},' ..
		'"daily":{"time":["2026-10-23"],"sunrise":["2026-10-23T07:00"],"sunset":["2026-10-23T16:30"]}}')
	-- Bars are 14,16,18,...,12 h (same date in this sample): daylight = bars 1-2 and 10-12.
	check('day block 1', DayRect(1, 1), '0,0,39,72')
	check('day block 2', DayRect(2, 1), '178,0,58,72')
	check('no day block 3', DayRect(3, 1), '0,0,1,1')
	check('sel default now', SelX(), 60.5)
	Hover(5)
	check('hover temp', SelTemp(), '9')
	check('hover hour', SelHour(), '22:00')
	-- Animation: 16 frames bring the hovered bar to full size, others stay put.
	for _ = 1, 16 do Tick() end
	check('grown height', DrawH(5), BarH(5) + GROW_H)
	check('grown width', DrawW(5), BARW + GROW_W)
	check('grown centered', DrawX(5), BarX(5) - GROW_W / 2)
	check('other bar same', DrawW(4), BARW)
	Hover(nil)
	for _ = 1, 16 do Tick() end
	check('shrunk back', DrawH(5), BarH(5))
	check('unhover temp', SelTemp(), '5')
	check('bar coldest', BarH(1), 8)
	check('bar warmest', BarH(12), 48)
	check('hour now', Hour(3), '18:00')
	check('kind rain', Kind('61'), 'Rain')
	check('kind snow', Kind(85), 'Snow')
	check('kind cloud', Kind('3'), nil)
	check('summary rain', Summary(), 'Rain from 22:00')
	hourly.weather_code[5] = '71'
	check('summary now', Summary(), 'Snow now')
	check('city country', City('Kostroma', 'Russia'), 'Kostroma, Russia')

	check('no current', Parse('{"error":true}'), 0)
	check('desc empty', Desc(), '')
	local lat, lon, name = ParseGeo('{"results":[{"id":1,"name":"Z\195\188rich","latitude":47.36667,"longitude":8.55,"admin1_id":2}]}')
	check('geo lat', lat, '47.36667')
	check('geo lon', lon, '8.55')
	check('geo ascii name', name, 'Zrich')
	check('geo not found', ParseGeo('{"generationtime_ms":0.16}'), nil)
	check('city saved', City('Moscow'), 'Moscow')
	StartGeo()
	check('city searching', City('Moscow'), 'searching...')

	-- Magnet: window rects like the real ones (CPU / RAM 205x112, bin 158x74).
	dofile(scripts .. 'Scripts\\Snap.lua')
	local cpu = { x = 487, y = 190, w = 205, h = 112 }
	local x, y = Pull({ x = 692, y = 214, w = 205, h = 112 }, { cpu })
	check('side by side takes top', x .. ',' .. y, '692,190')
	check('side by side aligned stays', Pull({ x = 692, y = 190, w = 205, h = 112 }, { cpu }), nil)
	check('side by side too far stays', Pull({ x = 692, y = 240, w = 205, h = 112 }, { cpu }), nil)
	check('not touching stays', Pull({ x = 700, y = 200, w = 205, h = 112 }, { cpu }), nil)
	x, y = Pull({ x = 282, y = 200, w = 205, h = 112 }, { cpu })
	check('left neighbour too', x .. ',' .. y, '282,190')
	x, y = Pull({ x = 500, y = 302, w = 158, h = 74 }, { cpu })
	check('stacked takes left edge', x .. ',' .. y, '487,302')
	x, y = Pull({ x = 530, y = 302, w = 158, h = 74 }, { cpu })
	check('stacked takes right edge', x .. ',' .. y, '534,302')
	x, y = Pull({ x = 692, y = 200, w = 158, h = 74 }, { cpu, { x = 850, y = 196, w = 205, h = 171 } })
	check('nearest of two neighbours', x .. ',' .. y, '692,196')

	dofile(scripts .. 'Scripts\\Disks.lua')
	check('disks colon list', table.concat(ParseDisks('C: G: - -'), ' '), 'C: G: - -')
	check('disks loose', table.concat(ParseDisks('c g,d'), ' '), 'C: G: D: -')
	check('disks dedupe/max 4', table.concat(ParseDisks('CCGDEF'), ' '), 'C: G: D: E:')
	check('disks none', ParseDisks(' - - '), nil)


	-- Theme picker + every theme file has all colors.
	dofile(scripts .. 'Scripts\\Picker.lua')
	dir, theme, appearance, mode = scripts .. 'Themes\\', 'Graphite', 'Auto', 'Light'
	check('family light file', Color('Graphite', 'Bg'), '250,250,250')
	check('single file', Color('Mocha', 'AccentCpu'), '166,227,161')
	check('missing theme', Color('Nope', 'Bg'), '128,128,128')
	check('check mark', Check('Graphite'), 10003)
	check('no check mark', Check('Mocha'), 32)
	check('appearance sel', Sel('Auto') + Sel('Light') + Sel('Dark'), 1)

	dofile(scripts .. 'Scripts\\AutoMode.lua')
	check('auto switch', Decide('Light\r\n', 'Dark'), 'Light')
	check('auto same', Decide('Dark\r\n', 'Dark'), nil)
	check('auto junk', Decide('Get-ItemPropertyValue : error', 'Dark'), nil)
	check('auto empty', Decide('', 'Dark'), nil)
	local keys = { 'Bg', 'Text', 'Dim', 'Grid', 'AccentNet', 'AccentNetAlt', 'AccentCpu', 'AccentRam', 'AccentGpu', 'AccentDisk', 'AccentWeather' }
	for _, file in ipairs({ 'Graphite-Dark', 'Graphite-Light', 'Warm-Dark', 'Warm-Light', 'Latte', 'Frappe', 'Macchiato', 'Mocha', 'GitHub-Dark', 'GitHub-Light', 'Kanagawa-Dark', 'Kanagawa-Light' }) do
		local f = io.open(dir .. file .. '.inc', 'r')
		local t = f and ReadTheme(f:read('*a')) or {}
		if f then f:close() end
		for _, k in ipairs(keys) do check(file .. ' has ' .. k, t[k] ~= nil, true) end
	end

	local f = io.open(outDir .. 'result.txt', 'w')
	f:write(#fails == 0 and 'OK\n' or table.concat(fails, '\n') .. '\n')
	f:close()
	SKIN:Bang('!DeactivateConfig')
end
