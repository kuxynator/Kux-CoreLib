if List then
    if List.guid == "{C8A1AC2B-DAF8-4A2C-8C4E-A20B500EE576}" then return List end
    error("A global List class already exist.")
    --TODO combine
end

---Provides List functions
---@class List
List = {
	tableName = "List",
	guid      = "{C8A1AC2B-DAF8-4A2C-8C4E-A20B500EE576}",
	origin    = "Kux-CoreLib/lib/List.lua",

    ---@type integer The number of entries in the list
    count = 0
}

-- to avoid circular references, the class is defined before require other modules
require("__Kux-CoreLib__/lib/Assert")
require("__Kux-CoreLib__/lib/String")
require("__Kux-CoreLib__/lib/Table")

---Creates a new list
---@param values any[]
---@param maxlength integer|nil
---@return List
function List:new(values, maxlength)
	local t = Table.shallowCopy(values or {})
	setmetatable(t, self)
    self.__index = self
	self.count = 0
    --setmetatable(t,{maxlength=maxlength})
	return t
end

function List:add(v)
	self.count = self.count + 1
	table.insert(self, v, self.count)
end

function List:insert(v, index)
	table.insert(self, v, index)
	self.count = self.count + 1
end

function List:remove(v)
	local i = Table.indexOf(self,v)
	if i == 0 then return false end
	table.remove(self, i)
	self.count = self.count - 1
end

function List:removeAt(index)
	table.remove(self, index)
	self.count = self.count - 1
end

function List:clear()
	for i = self.count, 1, -1 do
		table.remove(self, i)
	end
	self.count = 0
end

function List.isNilOrEmpty(t) return not t or #t==0 end

return List