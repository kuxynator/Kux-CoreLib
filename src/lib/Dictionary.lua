require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---DRAFT Provides Dictionary functions
---@class KuxCoreLib.Dictionary
local Dictionary = {
	__class  = "Dictionary",
	__guid   = "{114989BE-8900-4ABF-91F4-BC5D19537396}",
	__origin = "Kux-CoreLib/lib/Dictionary.lua",

    ---@type integer The number of entries in the list
    count = 0
}
if KuxCoreLib.__classUtils.cache(Dictionary) then return KuxCoreLib.__classUtils.cached end
---------------------------------------------------------------------------------------------------
-- to avoid circular references, the class is defined before require other modules
local Table = KuxCoreLib.Table
local Assert = KuxCoreLib.That
local String = KuxCoreLib.String

---Creates a new dictionary
---@param entries {}|nil
---@return KuxCoreLib.Dictionary
function Dictionary:new(entries)
	local t = Table.shallowCopy(entries or {})
	setmetatable(t, self)
    self.__index = self
	self.count = 0
    --setmetatable(t,{maxlength=maxlength})
	return t
end

function Dictionary:add(key, value)
	self[key]=value
end

function Dictionary:remove(key)
	self[key]=nil
end

function Dictionary:clear()
	for key, value in pairs(self) do
		self[key]=nil
	end
end

---------------------------------------------------------------------------------------------------

---Provides Dictionary in the global namespace
---@return KuxCoreLib.Dictionary
function Dictionary.asGlobal() return KuxCoreLib.__classUtils.asGlobal(Dictionary) end

return Dictionary