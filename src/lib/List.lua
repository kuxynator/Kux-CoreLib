if List then
    if List.__guid == "{C8A1AC2B-DAF8-4A2C-8C4E-A20B500EE576}" then return List end
    error("A global List class already exist.")
    --TODO combine
end

---Provides a true List 
---@class List
---@field length integer Gets the number if items in this List (including nil)
List = {
	__class  = "List",
	__guid   = "{C8A1AC2B-DAF8-4A2C-8C4E-A20B500EE576}",
	__origin = "Kux-CoreLib/lib/List.lua",

    ---@type integer The number of entries in the list
    count = 0
}

-- to avoid circular references, the class is defined before require other modules
KuxCoreLib = KuxCoreLib or require("__Kux_CoreLib__/init")
require(KuxCoreLib.Assert)
require(KuxCoreLib.String)
require(KuxCoreLib.Table)

local function createMetatable(t)
	local mt = {
		__index = function(table, key)
			if key == "count" then
				return table.count
			else
				return List[key]
			end
	  	end,
		__newindex = function(table, key, value)
			if key == "count" then
				error("Cannot modify read-only property 'count'", 2)
			else
				-- self[key]=value
				-- rawset(table, key, value)
				error("List can not be modified!")
			end
		end,
		count = 0
	}
	setmetatable(t, mt)
end

---Creates a new list
---@param data table?
---@param ownsData boolean?
---@return List
function List:new(data, ownsData)
	local instance = {}
	local mt = {}
	if(ownsData == false and data) then
		data=Table.shallowCopy(data)
	else
		mt.data = data or {}
	end
	mt.length=Table.getMaxIndex(mt.data)

	function mt.isInteger(v)
		return type(v)=="number" and v == math.floor(v)
	end

	function mt.__index(table, key)
		if(mt.isInteger(key)) then return mt.data[key]
		elseif key=="length" then return mt.length
		elseif(List[key]) then return List[key]
		else error("Invalid argument. Name: 'index'. Integer expected got "..type(key))
		end
	end

	function mt.__newindex(table, key, value)
		if(mt.isInteger(key)) then
			mt.data[key] = value
			if(key>mt.length) then mt.length = key end
		else
			error("Invalid argument. Name: 'index'. Integer expected got "..type(key))
		end
	end

	function mt.__len(table)
		return mt.length
	end

	function mt.__pairs(t)
		return function(table, lastIndex)
			lastIndex = lastIndex or 0
			local index = lastIndex + 1
			while index <= mt.length do
				local value = table[index]
				if(value~=nil) then return index, value end
				index = index + 1
			end
		end, t, nil
	end

	function mt.__ipairs(t)
		return function(table, lastIndex)
			lastIndex = lastIndex or 0
			local index = lastIndex + 1
			if index <= mt.length then
				local value = table[index]
				return index, value
			end
		end, t, nil
	end

	function mt.__call(_,_,lastIndex)
		local index = lastIndex or 0
		index = index + 1
		if index <= mt.length then
			local value = mt.data[index]
			return index, value
		end
	end

	-- function mt:__call(...)
	-- 	local additionalParams = {...} -- zusätzliche Parameter erhalten als Tabelle
	-- 	local startIndex = additionalParams[1] -- Beispiel: erster zusätzlicher Parameter als Startindex
	-- 	local function iterator(_,_,lastIndex)
	-- 		local index = lastIndex or 0
	-- 		index = index + 1
	-- 		if index <= mt.length then
	-- 			local value = data[index]
	-- 			return index, value
	-- 		end
	-- 	end
	-- 	return iterator, nil, startIndex
	-- end

	setmetatable(instance, mt)
	return instance
end

function List:add(item)
	local mt=getmetatable(self)
	mt.length = mt.length + 1
	mt.data[mt.length] = item;
end

function List:addRange(t)
	local mt=getmetatable(self)
	for _, v in ipairs(t) do
		mt.length = mt.length + 1
		mt.data[mt.length]=v;
	end
end

function List:insert(index, v)
	local mt=getmetatable(self)
	mt.length = mt.length + 1
	for i = mt.length, index+1, -1 do
		mt.data[i]=mt.data[i-1];
	end
end

---Removes the specified item
---@param item any
---@return boolean #true if the item has been found and removed; elsewhere false
function List:remove(item)
	local mt=getmetatable(self)
	local index = Table.indexOf(self,item)
	if index == 0 then return false end
	mt.length = mt.length - 1
	for i = index, mt.length, 1 do
		mt.data[i]=mt.data[i+1];
	end
	return true
end

---Remove an item at the specified index
---@param index integer
function List:removeAt(index)
	local mt=getmetatable(self)
	mt.length = mt.length - 1
	for i = index, mt.length, 1 do
		mt.data[i]=mt.data[i+1];
	end
end

---Clears the the list
function List:clear()
	local mt=getmetatable(self)
	for i = 1, mt.length, 1 do
		mt.data[i] = nil
	end
	mt.length = 0
end

---Gets the index of the item
---@param item any
---@return integer # The index or 0
function List:indexOf(item)
	for i, v in self do
		if v == item then return i end
	end
	return 0
end

---Removes all nil items
function List:compress()
	local mt=getmetatable(self)
	local shift=0
	for i = 1, mt.length do
		if(mt.data[i]) == nil then
			shift = shift + 1
		elseif(shift > 0) then
			mt.data[i-shift] = mt.data[i]
			mt.data[i]=nil
		end
	end
	mt.length = mt.length - shift
	return self
end

function List.isNilOrEmpty(t) return not t or #t==0 end

return List