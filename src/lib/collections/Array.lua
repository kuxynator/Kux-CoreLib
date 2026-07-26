require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")
local collection_util = require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/collections/_collection_util") --[[@as collection_util]]

---Provides array functions
---@class KuxCoreLib.Array : KuxCoreLib.Class
---@field length integer The length of the array
---@field asGlobal fun():KuxCoreLib.Array
local Array = {
	__class  = "Array",
	__guid   = "{57811545-A9BF-42D3-9AD5-DDEF82BB9C40}",
	__origin = "Kux-CoreLib/lib/Array.lua",
}
if not KuxCoreLib.__classUtils.ctor(Array) then return self end
-----------------------------------------------------------------------------------------------------------------------
local table = collection_util.table_o

---@class KuxCoreLib.Array.Instance
---@field length integer
local impl = {}

local mt = {
	__class = "KuxCoreLib.Array.Metatable",
	__guid = "{9df08220-7cad-41ec-9a28-57dc0c30df5a}"
}

---Creates a new array
---@param values any[]?
---@param length integer?
---@return KuxCoreLib.Array.Instance
function Array.new(values, length)
	local t = values and collection_util.shallowCopy(values) or {}
	length = length or #t
	setmetatable(t, mt)
	rawset(t, "__len", length)
	return t
end

---Converts into array
---@param t any[]
---@param length integer?
---@return KuxCoreLib.Array.Instance
function Array.convert(t, length)
	length = length or #t
	setmetatable(t, mt) ---@cast t KuxCoreLib.Array.Instance
	rawset(t, "__len", length)
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
	collection_util.table_o.sort(self, comparator)
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
	return rawget(t,"__len") or 0
end

function mt.__index(t,k)
	if k=="length" then return rawget(t,"__len") or 0 end
	--if type(k)==string and impl[k] then return function(...) return impl[k].insert(t, ...) end end
	if type(k)=="string" and impl[k] then rawset(t,"__action", k) return t end
	if type(k)~="number" then error("only numeric indexes are allowed") end
end

function mt.__newindex(t,k,v)
	if rawget(t,"length") then error("length is read-only") end
	if type(k)~="number" then error("only numeric indexes are allowed") end
end

function mt.__call(t,...)
	local action = impl[rawget(t,"__action")] or error("attempt to call a table value", 2)
	rawset(t,"__action",nil)
	return action(t,...)
end

mt.__ipairs = collection_util.allpairs

--mt.__pairs = collection_util.notnilpairs

collection_util.register_metatable_and_guard(mt)

---------------------------------------------------------------------------------------------------
return Array