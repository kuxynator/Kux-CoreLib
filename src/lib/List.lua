require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---Provides array functions
---@class KuxCoreLib.List : KuxCoreLib.Class
---@field asGlobal fun():KuxCoreLib.List
local List = {
	__class  = "List",
	__guid   = "aeb0658f-4c33-4a61-a689-49741a5e8fff",
	__origin = "Kux-CoreLib/lib/List.lua",

    ---@type integer The length of the list
    length = 0
}
if not KuxCoreLib.__classUtils.ctor(List) then return self end
-----------------------------------------------------------------------------------------------------------------------
local Table= KuxCoreLib.require.Table
local Array = KuxCoreLib.require.Array
local Assert= KuxCoreLib.require.That
local String = KuxCoreLib.require.String

local table_o = {
	remove = table.remove,
	insert = table.insert,
	sort = table.sort
}

---@class KuxCoreLib.List.Instance
---@field length integer
local impl = {}

local function set_length(t, new_length)
	if new_length<0 then error("new_length mast be positive") end
	local len = rawget(t,"__len")
	for i = new_length+1, len, 1 do t[i]=nil end
	rawset(t,"__len",new_length)
end

local mt = {__class="KuxCoreLib.List.Metatable"}


---Creates a new array
---@param values any[]?
---@param maxlength integer?
---@return KuxCoreLib.List.Instance
function List.new(values, maxlength)
	local t = values and Table.shallowCopy(values) or {}
	setmetatable(t, mt)
	t.length = math.min(#t, maxlength)
	return t
end

---Converts into array
---@param t any[]
---@param length integer?
---@return KuxCoreLib.List.Instance
function List.convert(t, length)
	setmetatable(t, mt) ---@cast t KuxCoreLib.List.Instance
	t.length = length or #t
	return t
end

function impl:add(value)
	local len = rawget(self, "__length")
	if rawlen(self) == len then
		table.insert(self, value)
	else
		rawset(self, len+1, value)
	end
	rawset(self, "__length", len+1)
end

function impl:addRange(t)
	local len = rawget(self, "__length")
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
	rawset(self, "__length", len)
end

function impl:insert(index, v)
	local len = rawget(self, "__length")
	if index < 1 then error("index out of range") end
	if index > len then self[index] = v return end

	if rawlen(self) == len then
		table.insert(self, index, v)
	else
		for i = len, index, -1 do rawset(self, i+1, rawget(self, i)) end
		rawset(self, index, v)
	end
	rawset(self, "__length", len+1)
end

function impl:removeAt(index)
	local len = rawget(self, "__length")
	if index < 1 or index > len then error("index out of range") end
	if rawlen(self) == len then table.remove(self, index)
	else
		for i = index+1, len, 1 do rawset(self, i-1, rawget(self, i)) end
		rawset(self, len, nil)
	end
	rawset(self, "__length", len - 1)
end

---Removes the specified item
---@param item any
---@return boolean #true if the item has been found and removed; elsewhere false
function impl:remove(item)
	local index = impl.indexOf(self, item)
	if index then return false end
	impl.removeAt(self, index)
	return true
end

---Gets the index of the specified item
---@param item any
---@return integer #the index of the item; 0 if the item is not found
function impl:indexOf(item)
	for i = 1, rawget(self, "__length"), 1 do
		if self[i] == item then return i end
	end
	return 0
end

function impl:compact()
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

function impl:sort(comparator)
	local nilfirst = comparator(nil,"")
	local nillast = comparator("",nil)
	if not ((nilfirst and not nillast) or (not nilfirst and nillast)) then
		error("This comparator cannot be used for nil order", 2)
	end

	local len = self.length
	impl.compact(self)
	local new_len = self.length
	table_o.sort(self, comparator)
	if nilfirst then
		local num_nil = len - new_len
		for i = new_len, 1, -1 do self[i + num_nil] = self[i] end
		for i = 1, num_nil do self[i] = nil end
	end
	self.length = len
	return self
end


---Returns true if the list is nil or empty
function List.isNilOrEmpty(t) return not t or #t==0 end


--[ metatable ]----------------------------------------------------------------

function mt.__len(t)
	return rawget(t,"__len")
end

function mt.__index(t,k)
	if k=="length" then return rawget(t,"__len") end
	--if type(k)==string and impl[k] then return function(...) return impl[k].insert(t, ...) end end
	if type(k)==string and impl[k] then rawset(t,"__action", k) return t end
	if type(k)~="number" then error("only numeric indexes are allowed") end
end

function mt.__newindex(t,k,v)
	if rawget(t,"length") then set_length(t,v) end
	if type(k)~="number" then error("only numeric indexes are allowed") end
end

function mt.__call(t,...)
	local action = impl[rawget(t["__action]"])] or error("attempt to call a table value", 2)
	rawset(t,"__action",nil)
	return action(t,...)
end

mt.__ipairs = allpairs

mt.__pairs = Array.notnilpairs

if script then script.register_metatable(mt.__class, mt) end

--[ global ]----------------------------------------------------------------


--[ guard ]--------------------------------------------------------------------

table["remove"] = function(t, ...) ---@diagnostic disable-line: duplicate-set-field
	if getmetatable(t) == mt then error("table.remove is not supported for list. use myMyList:removeAt") end
	--if rawget(t,"__len") then error("table.remove is not supported for arrays") end
	table_o.remove(t, ...)
end

table["insert"] = function(t, ...) ---@diagnostic disable-line: duplicate-set-field
	if getmetatable(t) == mt then error("table.insert is not supported for list. use myMyList:insert") end
	--if rawget(t,"__len") then error("table.insert is not supported for arrays") end
	table_o.insert(t, ...)
end

table["sort"] = function(t, ...) ---@diagnostic disable-line: duplicate-set-field
	if getmetatable(t) == mt then error("table.sort is not supported for list. use myMyList:sort") end
	--if rawget(t,"__len") then error("table.sort is not supported for arrays") end
	table_o.sort(t, ...)
end

-----------------------------------------------------------------------------------------------------------------------
if mods["debugadapter"] then --test removeAt
	local list = List.new()
	for i = 1, 5, 1 do list:add(i) end
	list[2] = nil list[4] = nil
	list:removeAt(3)
	assert(#list == 4)
	assert(list[3] == nil)
	assert(list[4] == 5)
	assert(list[5] == nil)
end

if mods["debugadapter"] then --test compress
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
---------------------------------------------------------------------------------------------------
return List