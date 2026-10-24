-- Auto appearance: takes Light/Dark printed by WallpaperMode.ps1 and saves it as Mode.
-- Options: Source (RunCommand measure), Appearance, Mode, VarsFile.

function Initialize()
	source = SKIN:GetMeasure(SELF:GetOption('Source'))
	mode = SELF:GetOption('Mode')
	varsFile = SELF:GetOption('VarsFile')
	-- Only needed while Appearance=Auto; picking Light/Dark refreshes the group and this unloads.
	if SELF:GetOption('Appearance') ~= 'Auto' then SKIN:Bang('!DeactivateConfig') end
end

-- New mode to save, or nil if output is junk or nothing changed.
function Decide(out, current)
	local m = out:match('%a+')
	if (m == 'Light' or m == 'Dark') and m ~= current then return m end
	return nil
end

-- RunCommand FinishAction.
function Apply()
	local m = Decide(source:GetStringValue(), mode)
	if not m then return end
	SKIN:Bang('!WriteKeyValue', 'Variables', 'Mode', m, varsFile)
	SKIN:Bang('!RefreshGroup', 'HyperWidgets')
end
