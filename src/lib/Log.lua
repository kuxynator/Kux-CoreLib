local this = nil

local getIsEnabled = function ()
	local entry = settings.global[script.mod_name.."_EnableLog"]
	if entry == nil then return false end
	return entry.value
end

--- deterministic data of log module
local data = {
	isEnabled = false
}

--- Log module
-- @module log
Log = {
	tableName = "Log",
	guid      = "{93D539EB-D2F8-41C8-9BAB-44CFDFE67F00}",
	origin    = "Kux-CoreLib/lib/Log.lua",

	on_init = function ()
		--log("Kux-Corelib.Log.on_init")		
		data = global.moduleData.log or data
		data.isEnabled = getIsEnabled()
	end,

	on_load = function ()
		--log("Kux-Corelib.Log.on_load")
		data = global.moduleData.log --[[???]] or data
	end,

	on_configuration_changed = function ()
		--log("Kux-Corelib.Log.on_configuration_changed")
		data = global.moduleData.log or data
	end,

	on_runtime_mod_setting_changed = function (e)
		--log("Kux-Corelib.Log.on_runtime_mod_setting_changed")
		this.onSettingsChanged(e)
	end,

	onSettingsChanged = function()
		data.isEnabled = getIsEnabled()
	end,

	joinArgs = function (...)
		local msg = ""
		for i = 1, select("#",...) do
			local v = select(i,...)
			if v == nil then v = "{nil}"
			else v = tostring(v) end
			msg = msg .. v
		end
	end,

	trace = function(...)
		if not data.isEnabled then return end
		local msg = script.mod_name..": "
		for i = 1, select("#",...) do
			local v = select(i,...)
			if v == nil then v = "{nil}"
			else v = tostring(v) end
			msg = msg .. v
		end
		print(msg)
	end,

	print = function(...)
		if not data.isEnabled then return end

		local msg = ""
		for i = 1, select("#",...) do
			local v = select(i,...)
			if v == nil then v = "{nil}"
			else v = tostring(v) end
			msg = msg .. v
		end
		print(msg)
	end,

	userTrace = function(...)
		if not data.isEnabled then return end

		local msg = ""
		for i = 1, select("#",...) do
			local v = select(i,...)
			if v == nil then v = "{nil}"
			else v = tostring(v) end
			msg = msg .. v
		end
		game.get_player(1).print(msg, {r = 0.7, g = 0.7, b = 0.7, a = 1})
	end,

	userWarning = function(...)
		if not data.isEnabled then return end

		local msg = ""
		for i = 1, select("#",...) do
			local v = select(i,...)
			if v == nil then v = "{nil}"
			else v = tostring(v) end
			msg = msg .. v
		end
		game.get_player(1).print(msg, {r = 1, g = 1, b = 0, a = 1})
	end,

	userError = function(...)
		if not data.isEnabled then return end

		local msg = ""
		for i = 1, select("#",...) do
			local v = select(i,...)
			if v == nil then v = "{nil}"
			else v = tostring(v) end
			msg = msg .. v
		end
		game.get_player(1).print(msg, {r = 1, g = 0, b = 0, a = 1})
	end,
}

this = Log --init local this
Modules.Log = Log -- add to modules
return Log