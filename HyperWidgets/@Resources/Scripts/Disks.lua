-- Disk list from the DISK widget's input box -> DiskMain, Disk2..Disk4 in Variables.inc.
-- Accepts "C: G: D:", "c g d", "CGD"...: first letter is the main disk. Option: VarsFile.

function Initialize()
	varsFile = SELF:GetOption('VarsFile')
end

-- Up to 4 unique drive letters as {"C:", "G:", "-", "-"}, or nil if none.
function ParseDisks(s)
	local list, seen = {}, {}
	for l in s:upper():gmatch('%a') do
		if not seen[l] and #list < 4 then
			seen[l] = true
			table.insert(list, l .. ':')
		end
	end
	if #list == 0 then return nil end
	while #list < 4 do table.insert(list, '-') end
	return list
end

function SetDisks(s)
	local list = ParseDisks(s)
	if not list then
		SKIN:Bang('!Log', 'DISK: no drive letters in "' .. s .. '", nothing changed', 'Warning')
		return
	end
	local keys = { 'DiskMain', 'Disk2', 'Disk3', 'Disk4' }
	for i, key in ipairs(keys) do
		SKIN:Bang('!WriteKeyValue', 'Variables', key, list[i], varsFile)
	end
	SKIN:Bang('!Refresh')
end
