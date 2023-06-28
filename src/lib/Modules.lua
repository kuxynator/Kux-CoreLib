require((KuxCoreLibPath or "__Kux-CoreLib__/").."init")

---@diagnostic disable: deprecated
if Modules then
    if Modules.__guid == "{7DB9693F-91FE-406A-9090-0797F785D8F5}" then return Modules end
    error("A global Modules class already exist.")
end

--- Modules class
---@class Modules
---@deprecated use EventDistributor
Modules = {
	__class  = "Modules",
	__guid   = "{7DB9693F-91FE-406A-9090-0797F785D8F5}",
	__origin = "Kux-CoreLib/lib/Modules.lua",
}

---Calls a mthod in each module
---@param method string Name of the method to call.
---@param ... unknown
function Modules.call(method, ...)
	--log("call "..method.." ...")
	for name, member in pairs(Modules) do
		if type(member) ~= "table" then goto next end
		if name == "data" then goto next end
		local module = member
		if module[method] and type(module[method])=="function" then module[method](...) end
		::next::
    end
end

local function initGlobals()
	global.moduleData = global.moduleData or {
		tableName = "global.moduleData",
		guid      = "{87DB96EF-16E8-4A92-B30C-182C9CEBBCA9}",
		origin    = "Kux-CoreLib/lib/Modules.lua"
	}
end

function Modules.on_init()
	initGlobals()
	Modules.call('on_init')
end

function Modules.on_load()
	Modules.call('on_load')
end

function Modules.on_configuration_changed(e)
	initGlobals()
	Modules.call('on_configuration_changed', e)
end

function Modules.onLoaded ()
	Modules.call('onLoaded')
end

return Modules