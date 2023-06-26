if Dictionary then
    if Dictionary.__guid == "{114989BE-8900-4ABF-91F4-BC5D19537396}" then return Dictionary end
    error("A global Dictionary class already exist.")
end

---DRAFT Provides Dictionary functions
---@class Dictionary
Dictionary = {
	__class  = "Dictionary",
	__guid   = "{114989BE-8900-4ABF-91F4-BC5D19537396}",
	__origin = "Kux-CoreLib/lib/Dictionary.lua",

    ---@type integer The number of entries in the list
    count = 0
}

-- to avoid circular references, the class is defined before require other modules
KuxCoreLib = KuxCoreLib or require("__Kux_CoreLib__/init")
require(KuxCoreLib.Table)
require(KuxCoreLib.Assert)
require(KuxCoreLib.String)

---Creates a new dictionary
---@param entries {}|nil
---@return Dictionary
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

return Dictionary