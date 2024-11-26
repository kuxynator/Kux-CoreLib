
---@class KuxCoreLib.PrototypeData.Extend.Arguments

---@class KuxCoreLib.PrototypeData.Extend
---@field prefix string
---@overload fun(KuxCoreLib.PrototypeData.Extend.Arguments):KuxCoreLib.PrototypeData.ExtendInstance
local extend = {
	---@type string
	prefix = nil,
	---@type table
	common = {}
}

---@class KuxCoreLib.PrototypeData.ExtendInstance : KuxCoreLib.PrototypeData.ExtendInstanceBase
local instanceMembers = {}

---@class KuxCoreLib.PrototypeData.Extend.Utils
local utils = {}

---@type KuxCoreLib.PrototypeData.ExtendInstanceBase
local extendBase = require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/data/PrototypeData-extend-base")

---------------------------------------------------------------------------------------------------

extendBase.setUtils(utils)
setmetatable(instanceMembers, {__index = extendBase}) --instanceMembers inherits from baseClass

---Creates a new Extend object
---@param t KuxCoreLib.PrototypeData.Extend.Arguments | table ExtendArguments | {setting_type, order}
---@return KuxCoreLib.PrototypeData.ExtendInstance
local function call_extend(self, t)
	local new = {
		common = t or {},
		count = 0
	}
	setmetatable(new, {
		__index = instanceMembers
	})
	return new
end

setmetatable(extend--[[@as table]],{
	__call = call_extend
})


---------------------------------------------------------------------------------------------------
--- Utils
---------------------------------------------------------------------------------------------------

---Returns the prefix
---@param obj KuxCoreLib.PrototypeData.ExtendInstance
---@return string
function utils.getPrefix(obj)
	return (obj["common"].prefix or extend.prefix
		or (_G["mod"] and _G["mod"].prefix or nil)) -- assumnig the mod defines a global "mod" variable
		or error("No prefix defined. use extend.common.prefix, extend.prefix, or _G.mod.prefix")
end

---Returns the name with prefix
---@param obj KuxCoreLib.PrototypeData.ExtendInstance
---@param name string
---@return string
function utils.getName(obj, name)
	return utils.getPrefix(obj)..name
end

function utils.merge(common, data, final_fixes)
	--print("merge", order_index, common, data, final_fixes)
	local merged = {}
	--merge common-- << extend(common)
	for k,v in pairs(common) do merged[k] = v end

	--merge data-- << x:int(data)
	for k,v in pairs(data) do merged[k] = type(k)~="number" and v or nil end

	--merge final_fixes--
	for k,v in pairs(final_fixes) do merged[k] = v; end

	--clean up--
	merged.prefix = nil

	return merged
end


---------------------------------------------------------------------------------------------------
--- instanceMembers
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
return extend


