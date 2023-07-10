require((KuxCoreLibPath or "__Kux-CoreLib__/").."init")
if(KuxCoreLib.__modules.Dictionary) then return KuxCoreLib.__modules.Dictionary end

---DRAFT Provides Dictionary functions
---@class KuxCoreLib.Dictionary
local Dictionary = {
	__class  = "Dictionary",
	__guid   = "{114989BE-8900-4ABF-91F4-BC5D19537396}",
	__origin = "Kux-CoreLib/lib/Dictionary.lua",

    ---@type integer The number of entries in the list
    count = 0
}
KuxCoreLib.__modules.Dictionary = Dictionary
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

function Dictionary.asGlobal() return KuxCoreLib.utils.asGlobal(Dictionary) end

return Dictionary