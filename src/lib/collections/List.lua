require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")
local collection_util = require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/collections/_collection_util") --[[@as collection_util]]

---Provides array functions
---@class KuxCoreLib.List : KuxCoreLib.Class
---@field asGlobal fun():KuxCoreLib.List
local List = {
	__class  = "List",
	__guid   = "{aeb0658f-4c33-4a61-a689-49741a5e8fff}",
	__origin = "Kux-CoreLib/lib/List.lua",

    ---@type integer The length of the list
    length = 0
}
if not KuxCoreLib.__classUtils.ctor(List) then return self end
-----------------------------------------------------------------------------------------------------------------------

local that = KuxCoreLib.require.That
local table = collection_util.table_o--original lua table


---@class KuxCoreLib.List.Instance
---@field length integer
local impl = {
	__class="KuxCoreLib.List.Instance"
}

local mt = {
	__class = "KuxCoreLib.List.Metatable",
	__guid = "{c765029f-1961-447e-b747-e894bfca1479}"
}

local function set_length(t, new_length)
	if new_length<0 then error("new_length must be positive") end
	local len = rawget(t,"__len") or 0

	rawset(t,"__len",new_length)

	if new_length < len then
		for i = new_length+1, len, 1 do rawset(t,i,nil) end
	elseif new_length > len then
		;
	else
	end
end

---Creates a new List
---@param values any[]?
---@param length integer?
---@return KuxCoreLib.List.Instance
function List.new(values, length)
	local t = values and collection_util.shallowCopy(values) or {}
	length = length or #t
	rawset(t, "__len", length)
	setmetatable(t, mt)
	set_length(t, length)
	return t
end

---Converts into List
---@param t any[]
---@param length integer?
---@return KuxCoreLib.List.Instance
function List.convert(t, length)
	length = length or #t
	setmetatable(t, mt) ---@cast t KuxCoreLib.List.Instance
	set_length(t, length)
	return t
end

---Returns true if the list is nil or empty
function List.isNilOrEmpty(t) return not t or #t==0 end

function List.get_length(list)
	return rawget(list, "__len") or 0
end

--[ implementation ]---------------------------------------------------------------------------------------------------

---Adds a value to the end of the list
---@param self KuxCoreLib.List.Instance
---@param value any The value to add
function impl.add(self, value)
	local len = rawget(self, "__len") or 0
	rawset(self, "__len", len+1)
	table.insert(self, len+1, value)
end
List.add = impl.add

function impl.addRange(self, t)
	local len = rawget(self, "__len")
	if rawlen(self) == len then
		for _, v in ipairs(t) do
			table.insert(self, v)
			len = len + 1
		end
	else
		for _, v in ipairs(t) do
			rawset(self, len+1, v);
			len = len + 1
		end
	end
	rawset(self, "__len", len)
end
List.addRange = impl.addRange


function impl.insert(self, index, v)
	local len = rawget(self, "__len")
	if index < 1 then error("index out of range") end
	if index > len then self[index] = v return end
	table.insert(self, index, v)
	rawset(self, "__len", len+1)
end
List.insert = impl.insert


function impl.remove(self, index)
	local len = rawget(self, "__len") or 0
	if index < 1 or index > len then error("index out of range") end
	table.remove(self, index)
	rawset(self, "__len", len - 1)
end
List.remove = impl.remove


---Removes the specified value
---@param item any
---@return integer? #The index of the value if has been found and removed; elsewhere nil
function impl.removeValue(self, item)
	local index = impl.indexOf(self, item)
	if not index then return nil end
	impl.remove(self, index)
	return index
end
List.removeValue = impl.removeValue


---Gets the index of the specified item
---@param item any
---@return integer #the index of the item; 0 if the item is not found
function impl.indexOf(self, item)
	for i = 1, rawget(self, "__len"), 1 do
		if self[i] == item then return i end
	end
	return 0
end
List.indexOf = impl.indexOf


function impl.compact(self)
	local write = 1
	for read = 1, self.length do
		local v = rawget(self, read)
		if v ~= nil then
			rawset(self, write, v)
			write = write + 1
		end
	end
	for i = write, self.length do rawset(self, i, nil) end
	self.length = write - 1
	return self
end
List.compact = impl.compact


function impl.sort(self, comparator)
	collection_util.table_o.sort(self,comparator)
	return self
end
List.sort = impl.sort

--[ metatable ]----------------------------------------------------------------

function mt.__len(t)
	return rawget(t,"__len") or 0
end

function mt.__index(t,k)
	local f = impl[k]; if f then return f end
	--if type(k)=="string" and impl[k] then rawset(t,"__action", k) return t end
	if k=="length" then return rawget(t,"__len") or 0 end
	--if type(k)~="number" then error("only numeric indexes are allowed") end
end

function mt.__newindex(t,k,v)
	if k=="length" then
		set_length(t,v)
	elseif type(k) == "number" and k%1==0 then
		if k < 1 then error("index out of range. value must be >= 1, but was "..k) end
		len = rawget(t,"__len") or 0
		if k == len+1 then impl.add(t,v)
		elseif k > len+1 then set_length(t,k) rawset(t,k,v)
		else rawset(t, k, v)
		end
	else
		error("only integer indexes >= 1 are allowed")
	end
end

function mt.__call(t,...)
	local action = impl[rawget(t,"__action")] or error("attempt to call a table value", 2)
	rawset(t,"__action",nil)
	if select(1, ...) == t then return action(...)
	else return action(t, ...) end
end

mt.__ipairs = collection_util.allpairs

--mt.__pairs = collection_util.notnilpairs

collection_util.register_metatable_and_guard(mt)

--[ unit test ]--------------------------------------------------------------------------------------------------------

if mods["debugadapter"] then --test removeAt
	local that = KuxCoreLib.require.That

	do --test [x]=nil
		local list = List.new({1,nil,3,4,5})
		assert(that.IsEqual(#list, 5))
		assert(that.IsEqual(list.length, 5))
		assert(that.IsEqual(serpent.line(list),"{1, nil, 3, 4, 5, __len = 5}"))
		list[4]=nil
		assert(that.IsEqual(#list, 5))
		assert(that.IsEqual(list.length, 5))
		assert(that.IsEqual(serpent.line(list),"{1, nil, 3, nil, 5, __len = 5}"))
		list[5]=nil
		assert(that.IsEqual(#list, 5))
		assert(that.IsEqual(list.length, 5))
		assert(that.IsEqual(serpent.line(list),"{1, nil, 3, nil, nil, __len = 5}"))

		local s=""; for _, v in ipairs(list) do s = s .. tostring(v).." " end
		assert(that.IsEqual(s,"1 nil 3 nil nil "))
		list:sort(function (a,b)
			--ascending, nil last
			if a == nil then return false end
			if b == nil then return true end
			return a < b
		end)
		s=""; for _, v in ipairs(list) do s = s .. tostring(v).." " end
		assert(that.IsEqual(s,"1 3 nil nil nil "))
	end

	do --test insert
		local list = List.new()
		for i = 1, 5, 1 do list:add(nil) end
		assert(that.IsEqual(list.length, 5))
		list[3] = "3"
		list:insert(3, "insert")
		assert(that.IsEqual(#list, 6))
		assert(that.IsEqual(list[3], "insert"))
		assert(that.IsEqual(list[4], "3"))
		assert(that.IsEqual(list[5], nil))
		assert(that.IsEqual(list[6], nil))
		assert(that.IsEqual(list[7], nil))
	end

	do --test removeAt
		local list = List.new()
		for i = 1, 5, 1 do list:add(i) end
		list[1] = nil list[5] = nil
		list:remove(3)
		assert(that.IsEqual(#list, 4))
		assert(that.IsEqual(list[3], 4))
		assert(that.IsEqual(list[4], nil))
		assert(that.IsEqual(list[5], nil))
	end

	do --test compact
		local list = List.new()
		for i = 1, 5, 1 do list:add(i) end
		list[2] = nil list[4] = nil
		list:compact()
		assert(#list == 3)
		assert(list[1] == 1)
		assert(list[2] == 3)
		assert(list[3] == 5)
		assert(rawlen(list) == 3)
	end
end
---------------------------------------------------------------------------------------------------
return List