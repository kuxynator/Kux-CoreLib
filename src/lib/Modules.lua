if Modules~=nil then error("A conflicting global variable 'Modules' is already definied!") end
Modules = {
	tableName = "Modules",
	guid      = "{7DB9693F-91FE-406A-9090-0797F785D8F5}",
	origin    = "Kux-CoreLib/lib/Modules.lua"
}

Modules.call = function (method, ...)
	--log("Kux-Corelib.Modules.call "..method.." ...")
	for name, module in pairs(Modules) do
		if type(module) ~= "table" then goto next end
		if name == "data" then goto next end
		if module[method] then module[method](...) end
		::next::
    end
end

local initGlobals=function()
	global.moduleData = global.moduleData or {
		tableName = "global.moduleData",
		guid      = "{87DB96EF-16E8-4A92-B30C-182C9CEBBCA9}",
		origin    = "Kux-CoreLib/lib/Modules.lua"
	}
end

Modules.on_init = function ()
	initGlobals()
	Modules.call('on_init')
end

Modules.on_load = function ()
	Modules.call('on_load')
end

Modules.on_configuration_changed = function (e)
	initGlobals()
	Modules.call('on_configuration_changed', e)
end

return Modules