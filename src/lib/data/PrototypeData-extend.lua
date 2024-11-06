---@class KuxCorelib.PrototypeData.Extend.Arguments

---@class KuxCorelib.PrototypeData.Extend
---@field prefix string
local extend = {
	---@type string
	prefix = nil,
	---@type table
	common = {}
}

---Creates a new Extend object
---@param t KuxCorelib.PrototypeData.Extend.Arguments | table ExtendArguments | {setting_type, order}
---@return KuxCorelib.PrototypeData.Extend
local function call_extend(self, t)
	local new = {common = t or {}, count = 0}
	setmetatable(new, {
		__index = extend
	})
	return new
end

setmetatable(extend,{
	__call = call_extend
})

---Returns the prefix
---@param self KuxCorelib.PrototypeData.Extend
---@return string
local function getPrefix(self)
	return (self.common.prefix or extend.prefix
		or (_G["mod"] and _G["mod"].prefix or nil)) -- assumnig the mod defines a global "mod" variable
		or error("No prefix defined. use extend.common.prefix, extend.prefix, or _G.mod.prefix")
end

---Returns the name with prefix
---@param self KuxCorelib.PrototypeData.Extend
---@param name string
---@return string
local function getName(self, name)
	return getPrefix(self)..name
end

local function merge(common, data, final_fixes)
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

---@class extend.CustomInputPrototype : data.CustomInputPrototype
---@field name string?
---@field key_sequence string?
---@field [1] string name
---@field [2] string key_sequence

---Adds a custom-input
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaCustomInputPrototype.html)
---@param t extend.CustomInputPrototype CustomInputPrototype | {name, key_sequence}
function extend:custom_input(t)
	local d = merge(self.common, t, {
		type          = "custom-input",
		name          = getName(self, t.name or t[1]),
		key_sequence  = t.key_sequence or t[2] or "",
		consuming     = t.consuming or "none",
		-- forced_value -- Only loaded if hidden = true
	})
	data:extend{d}
end

return extend