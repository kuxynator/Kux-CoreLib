require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---Provides array functions
---@class KuxCoreLib.Array : KuxCoreLib.Class
---@field asGlobal fun():KuxCoreLib.Array
local Array = {
	__class  = "Array",
	__guid   = "{57811545-A9BF-42D3-9AD5-DDEF82BB9C40}",
	__origin = "Kux-CoreLib/lib/Array.lua",

    ---@type integer The length of the array
    length = 0
}
if not KuxCoreLib.__classUtils.ctor(Array) then return self end
-----------------------------------------------------------------------------------------------------------------------
local Table= KuxCoreLib.require.Table
local Assert= KuxCoreLib.require.That
local String = KuxCoreLib.require.String

local table_o = {
	remove = table.remove,
	insert = table.insert,
	sort = table.sort
}

---@class KuxCoreLib.Array.Instance
---@field length integer
local impl = {}

local mt = {__class="KuxCoreLib.Array.Metatable"}

---Creates a new array
---@param values any[]?
---@param maxlength integer?
---@return KuxCoreLib.Array.Instance
function Array.new(values, maxlength)
	local t = values and Table.shallowCopy(values) or {}
	setmetatable(t, mt)
	rawset(t, "__len", math.min(#t, maxlength))
	return t
end

---Converts into array
---@param t any[]
---@param length integer?
---@return KuxCoreLib.Array.Instance
function Array.convert(t, length)
	setmetatable(t, mt) ---@cast t KuxCoreLib.Array.Instance
	rawset(t, "__len", length or #t)
	return t
end

local function compact_inplace()
	local write = 1
	for read = 1, self.length do
		local v = self[read]
		if v ~= nil then
			if write ~= read then self[write] = v end
			write = write + 1
		end
	end
	for i = write, self.length do self[i] = nil end
	return self
end

local function compact_new()
	local new = Array.new(nil, self.length)
	local write = 1
	for read = 1, self.length do
		local v = self[read]
		if v ~= nil then
			new[write] = v
			write = write + 1
		end
	end
	rawset(new, "__len", write - 1)
	return new
end

---Removes all nil values and returns a new array or if inplace=true the same array
---@param inplace boolean? defaults to false
---@return KuxCoreLib.Array.Instance
function impl:compact(inplace)
	return inplace and compact_inplace() or compact_new()
end

function impl:sort(comparator)
	local nilfirst = comparator(nil,"")
	local nillast = comparator("",nil)
	if not ((nilfirst and not nillast) or (not nilfirst and nillast)) then
		error("The specified comparator cannot be used for nil order", 2)
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
	rawset(self, "__len", len)
	return self
end


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
	if rawget(t,"length") then error("length is read-only") end
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

--- allpairs(t)
--- <p>Returns three values: the iterator function, the table t, and the initial index (0).<br>
--- The iterator visits indices 1 through t.length in order, yielding (i, t[i]) even if t[i] is nil.</p>
--- @param t table  An Array-like table with a numeric “length” field.
--- @return function iterator  Function that, each call, returns the next index and value.
--- @return table t             The array being traversed.
--- @return number 0            The initial index for the iterator.
--- <p>Usage: <pre>
--- for i,v in allpairs(t) do
---   -- i = 1..t.length, v = t[i] (may be nil)
--- end
--- </pre>
function _G.allpairs(t)
	if not t["__len"] then error("unsupported table") end
	local i = 0
	return function()
		local len = rawget(t,"__len")
		i = i + 1
		if i <= len then return i, t[i]
		else return nil end
	end, t, 0
end

--- npairs (t)
--- <p>Returns three values: the iterator function, the table t, and the initial index (0).<br>
--- The iterator visits indices 1 through t.length in order, yielding only those (i, t[i]) where t[i] ≠ nil.</p>
--- @param t table  An Array-like table with a numeric “length” field.
--- @return function iterator  Function that returns the next index and non-nil value.
--- @return table t             The array being traversed.
--- @return number 0            The initial index for the iterator.
--- <p>Usage: <pre>
--- for i,v in npairs(t) do
---   -- i = positions with t[i] ≠ nil
--- end
--- </pre>
function Array.notnilpairs(t)
	if not t["__len"] then error("table is not supported") end
	local i = 0
	return function()
		while true do
			local len = rawget(t,"__len")
			i = i + 1
			if i > len then return nil end
			local v = t[i]
			if v ~= nil then return i, v end
		end
	end, t, 0
end

--[ guard ]--------------------------------------------------------------------


table["remove"] = function(t, ...) ---@diagnostic disable-line: duplicate-set-field
	if getmetatable(t) == mt then error("table.remove is not supported for arrays. use myArray:removeAt") end
	--if rawget(t,"__len") then error("table.remove is not supported for arrays") end
	table_o.remove(t, ...)
end

table["insert"] = function(t, ...) ---@diagnostic disable-line: duplicate-set-field
	if getmetatable(t) == mt then error("table.insert is not supported for arrays. use myArray:insert") end
	--if rawget(t,"__len") then error("table.insert is not supported for arrays") end
	table_o.insert(t, ...)
end

table["sort"] = function(t, ...) ---@diagnostic disable-line: duplicate-set-field
	if getmetatable(t) == mt then error("table.sort is not supported for arrays. use myArray:sort") end
	--if rawget(t,"__len") then error("table.sort is not supported for arrays") end
	table_o.sort(t, ...)
end

---------------------------------------------------------------------------------------------------
return Array