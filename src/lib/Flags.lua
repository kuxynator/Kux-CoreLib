require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")
if(KuxCoreLib.__modules.Flags) then return KuxCoreLib.__modules.Flags end

---@class KuxCoreLib.Flags
local Flags = {
	__class  = "Flags",
	__guid   = "6b3edfc1-861b-4e38-86c3-1272706f1c59",
	__origin = "Kux-CoreLib/lib/Flags.lua",
}
KuxCoreLib.__modules.Flags = Flags

---------------------------------------------------------------------------------------------------

---Creates new Flags
---@param flags string[]
---@return KuxCoreLib.Flags
function Flags:new(flags)
	local instance = {}
	setmetatable(instance, Flags)
	for _, value in ipairs(flags) do
		instance[value]=true
	end
	return instance
end

function Flags:isSet(flag)
	if(self==Flags) then error("Invalid operation.") end
	return self[flag]
end

function Flags:set(flags)
	if(self==Flags) then error("Invalid operation.") end
	if(type(flags)=="table") then
		for _, value in ipairs(flags) do
			self[value]=true
		end
	else
		self[flags]=true
	end
end

function Flags:reset(flags)
	if(self==Flags) then error("Invalid operation.") end
	if(type(flags)=="table") then
		for _, value in ipairs(flags) do
			self[value]=nil
		end
	else
		self[flags]=nil
	end
end

---------------------------------------------------------------------------------------------------

---Provides Flags in the global namespace
---@return KuxCoreLib.Flags
function Flags.asGlobal() return KuxCoreLib.utils.asGlobal(Flags) end

return Flags