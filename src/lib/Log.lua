if Log then
    if Log.__guid == "{93D539EB-D2F8-41C8-9BAB-44CFDFE67F00}" then return Log end
    error("A global Log class already exist.")
end

--- Log module
---@class Log
Log = {
	__class  = "Log",
	__guid   = "{93D539EB-D2F8-41C8-9BAB-44CFDFE67F00}",
	__origin = "Kux-CoreLib/lib/Log.lua"
}

-- to avoid circular references, the class MUST be defined before require other modules
KuxCoreLib = KuxCoreLib or require("__Kux_CoreLib__/init")
require(KuxCoreLib.Modules)
require(KuxCoreLib.Table)

if log == nil then log = function (s) --[[dummy]] end end -- fallback if not running in Factorio

local this = nil

local getIsLogEnabled = function ()
	local entry = settings.global[script.mod_name.."_EnableLog"]
	if entry == nil then return false end
	return entry.value
end

local getIsConsoleEnabled = function ()
	local entry = settings.global[script.mod_name.."_EnableConsole"]
	if entry == nil then return false end
	return entry.value
end

local update = function (data)
	data.isLogEnabled     = getIsLogEnabled()
	data.isConsoleEnabled = getIsConsoleEnabled()
	data.isEnabled        = data.isLogEnabled and data.isConsoleEnabled
end

local data_prototype = {
	dataVersion      = 2,
	isLogEnabled     = false,
	isConsoleEnabled = false,
	isEnabled        = false,
}

--- deterministic data of Log module
local data = {}

function Log.on_init ()
	--log("Kux-Corelib.Log.on_init")
	global.moduleData = global.moduleData or {}
	data = Table.migrate(global.moduleData.Log or {}, data_prototype)
	update(data)
	global.moduleData.Log = data
end

function Log.on_load ()
	--log("Kux-Corelib.Log.on_load")
	if not global.moduleData or not global.moduleData.Log then
		data = Table.migrate({}, data_prototype)
		update(data)
	else
		data = global.moduleData.Log
	end
end

function Log.on_configuration_changed()
	--log("Kux-Corelib.Log.on_configuration_changed")
	global.moduleData = global.moduleData or {}
	global.moduleData.log = nil -- MIGRATION remove field uded by previous version
	data = Table.migrate(global.moduleData.Log or {}, data_prototype)
	update(data)
	global.moduleData.Log = data
end

function Log.on_runtime_mod_setting_changed(e)
	--log("Kux-Corelib.Log.on_runtime_mod_setting_changed")
	global.moduleData = global.moduleData or {}
	data = Table.migrate(global.moduleData.Log or {}, data_prototype)
	update(data)
	global.moduleData.Log = data
	this.onSettingsChanged(e)
end

function Log.onSettingsChanged()
	update(data)
end

function Log.joinArgs(...)
	local msg = ""
	for i = 1, select("#",...) do
		local v = select(i,...)
		if v == nil then v = "{nil}"
		else v = tostring(v) end
		msg = msg .. v
	end
end

function Log.trace(...)
	if not data or not data.isEnabled then return end

	local msg = script.mod_name..": "
	for i = 1, select("#",...) do
		local v = select(i,...)
		if v == nil then v = "{nil}"
		else v = tostring(v) end
		msg = msg .. v
	end
	if data.isConsoleEnabled then print(msg) end
	if data.isLogEnabled then log(msg) end
end

function Log.print(...)
	if not data or not data.isEnabled then return end

	local msg = ""
	for i = 1, select("#",...) do
		local v = select(i,...)
		if v == nil then v = "{nil}"
		else v = tostring(v) end
		msg = msg .. v
	end
	if data.isConsoleEnabled then print(msg) end
	if data.isLogEnabled then log(msg) end
end

-- TODO use current player and not always player 1
-- userXyz outputs a message to the current user (and if enabled to console and log)

function Log.userTrace(...)
	if not data or not data.isEnabled then return end

	local msg = ""
	for i = 1, select("#",...) do
		local v = select(i,...)
		if v == nil then v = "{nil}"
		else v = tostring(v) end
		msg = msg .. v
	end
	if data.isConsoleEnabled then print(msg) end
	if data.isLogEnabled then log(msg) end
	game.get_player(1).print(msg, {r = 0.7, g = 0.7, b = 0.7, a = 1})
end

function Log.userWarning(...)
	if not data or not data.isEnabled then return end

	local msg = ""
	for i = 1, select("#",...) do
		local v = select(i,...)
		if v == nil then v = "{nil}"
		else v = tostring(v) end
		msg = msg .. v
	end
	if data.isConsoleEnabled then print(msg) end
	if data.isLogEnabled then log(msg) end
	game.get_player(1).print(msg, {r = 1, g = 1, b = 0, a = 1})
end

function Log.userError(...)
	if not data or not data.isEnabled then return end

	local msg = ""
	for i = 1, select("#",...) do
		local v = select(i,...)
		if v == nil then v = "{nil}"
		else v = tostring(v) end
		msg = msg .. v
	end
	if data.isConsoleEnabled then print(msg) end
	if data.isLogEnabled then log(msg) end
	game.get_player(1).print(msg, {r = 1, g = 0, b = 0, a = 1})
end


this = Log --init local this
Modules.Log = Log -- add to modules
return Log