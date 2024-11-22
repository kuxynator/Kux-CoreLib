loc = {}

---@class LocUtil
LocUtil = {}

function LocUtil.mod_setting(key, name, description)
	loc["mod-setting-name"][key] = name
	loc["mod-setting-description"][key] = description
end

function LocUtil.controls(key, name, description)
	loc["controls"][key] = name
	loc["controls-description"][key] = description
end

function LocUtil.item(key, name, description)
	loc["item-name"][key] = name
	loc["item-description"][key] = description
end

--[[loc = {
	["mod-setting-name"] = {
		["Kux-ZoomRunning-GlobalCheatMode"] = "Allow cheat mode for all players.",
		["Kux-ZoomRunning-DefaultCharacterRunningSpeedModifier"] = "Default character running speed modifier",
		["Kux-ZoomRunning-ZoomSpeedModificator"] = "Zoom: Speed Modificator"
	},
	["mod-setting-description"] = {
		["Kux-ZoomRunning-GlobalCheatMode"] = "Allow cheat mode for all players. For admins it is always alowed.",
		["Kux-ZoomRunning-DefaultCharacterRunningSpeedModifier"] = "If this mod does not need the LuaPlayer.character_running_speed_modifier the value is set to this value.",
		["Kux-ZoomRunning-ZoomSpeedModificator"] = "For faster walking speed in zoom mode increase this value."
	}
}]]

function load_loc_files(directory)
	local handle = io.popen('dir /B "' .. directory .. '"') -- Für Linux/macOS, ersetze durch "dir /B" für Windows
	local files = handle:lines()

	-- Jede Datei im Verzeichnis laden
	for file in files do
		if file:match("%.loc%.lua$") then
			print("Loading: " .. file)
			dofile(directory .. "/" .. file) -- Lade jede Datei
		end
	end

	handle:close()
end

function generate_compiled_cfg(directory)
	-- Datei öffnen, um zu schreiben
	local file = io.open(directory.."/compiled.cfg", "w")

	-- Durchlaufe jede Gruppe in der `loc`-Tabelle
	for group, group_data in pairs(loc) do
		if group~="" then file:write("[" .. group .. "]\n") end
		for key, value in pairs(group_data) do
			file:write(key .. "=" .. value .. "\n")
		end
		file:write("\n")
	end

	file:close()
	print("compiled.")
end

local directory = arg[1]
--local directory = "mod/src/locale/en"
load_loc_files(directory)
generate_compiled_cfg(directory)

--USAGE: lua52 compile.lua mod/src/locale/en