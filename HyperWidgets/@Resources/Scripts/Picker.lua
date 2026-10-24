-- Theme picker: swatch colors read straight from the theme files, plus selection state.
-- Options: ThemesDir, Theme, Appearance (Light/Dark/Auto), Mode (Light/Dark in use).

-- Themes that have -Dark / -Light files; the rest are single files.
FAMILIES = { Graphite = true, Warm = true, GitHub = true, Kanagawa = true }
cache = {}

function Initialize()
	dir = SELF:GetOption('ThemesDir')
	theme = SELF:GetOption('Theme')
	appearance = SELF:GetOption('Appearance')
	mode = SELF:GetOption('Mode')
end

-- "Key=R,G,B" lines -> table
function ReadTheme(text)
	local t = {}
	for k, v in text:gmatch('(%w+)%s*=%s*(%d+%s*,%s*%d+%s*,%s*%d+)') do t[k] = v end
	return t
end

function FileFor(name)
	return FAMILIES[name] and (name .. '-' .. mode) or name
end

-- Inline: [&MeasurePicker:Color('Graphite', 'Bg')] -> "23,23,26"
function Color(name, key)
	local file = FileFor(name)
	if not cache[file] then
		local f = io.open(dir .. file .. '.inc', 'r')
		cache[file] = f and ReadTheme(f:read('*a')) or {}
		if f then f:close() end
	end
	return cache[file][key] or '128,128,128'
end

-- Decimal char code for [\N]: check mark for the current theme, space otherwise.
function Check(name)
	return name == theme and 10003 or 32
end

function Fg(name)
	return SKIN:GetVariable(name == theme and 'Text' or 'Dim')
end

function Weight(name)
	return name == theme and 700 or 400
end

-- Appearance toggle: 1 for the active button.
function Sel(value)
	return appearance == value and 1 or 0
end

function AppFg(value)
	return SKIN:GetVariable(appearance == value and 'Text' or 'Dim')
end
