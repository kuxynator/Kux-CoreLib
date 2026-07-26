local table_util = require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/_table_util") --[[@as table_util]]

---@class collection_util
local collection_util = {}

collection_util.table_o = {
	remove = table.remove,
	insert = table.insert,
	sort   = table.sort
}

---@alias TableKind
---| "empty"      # no entries at all
---| "array"      # numeric keys (may have gaps), default for numeric tables
---| "sequence"   # dense numeric keys 1..n, no gaps
---| "dictionary" # no numeric keys
---| "mixed"      # numeric + non-numeric keys

---@alias TableKind.nil TableKind|nil

---@class analyzeTable.result
---       ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
---@field count integer
---@field max_index integer
---@field has_gaps boolean
---@field has_integer boolean
---@field has_noninteger boolean
---@field kind TableKind


---
---@param t table
---@return analyzeTable.result
function collection_util.analyzeTable(t)
	local result = { ---@type analyzeTable.result
		count = 0,
		max_index = 0,
		has_gaps = false,
		has_integer = false,
		has_noninteger = false,
		kind = "mixed"
	}

	for k, _ in pairs(t) do
		if type(k) == "number" and k % 1 == 0 then
			result.has_integer = true
			if k > result.max_index then result.max_index = k end
			result.count = result.count + 1
		else
			result.has_noninteger = true
		end
	end

	for i = 1, result.max_index do
		if t[i] == nil then
			result.has_gaps = true
			break
		end
	end

	if result.has_integer and result.has_noninteger then
		result.kind = "mixed"
	elseif result.has_integer then
		result.kind = result.has_gaps and "array" or "sequence"
	elseif result.has_noninteger then
		result.kind = "dictionary"
	else
		result.kind = "empty"
	end

	return result
end

function collection_util.hasGaps(t)
	local max = 0
	for k, _ in pairs(t) do
		if type(k) == "number" and k > max then
			max = k
		end
	end
	for i = 1, max do
		if t[i] == nil then return true end
	end
	return false
end

function collection_util.isDense(t)
	return collection_util.analyzeTable(t).kind == "sequence"
end

---Creates an unordered shallow copy of the table (no key order guaranteed)
---@param t table The table to copy.
---@return table # The shallow copy.
---<p>slightly faster than shallowCopy</p>
function collection_util.unordered_shallowCopy(t)
	local copy = {}
	for k,v in pairs(t) do copy[k] = v end
	return copy
end

---Creates a ordered shallow copy of the table
---@param t table The table to copy.
---@param length integer?
---@param nonmixed boolean?
---@return table # The shallow copy.
---<p>pure dictionary: <code> shallowCopy(t, 0, true) </code> <br>
---pure non-sparse array: <code> shallowCopy(t, #t, true) </code> <br>
---pure sparse array: <code> shallowCopy(t, nil, true) </code> <br>
---unknown table: <code> shallowCopy(t) </code> <br>
---</p>
function collection_util.shallowCopy_alt(t, length, nonmixed)
	local copy = {}
	if length then
		if length == 0 and nonmixed then -- pure dictionary
			for k, v in pairs(t) do copy[k] = v end
		elseif length > 0 and nonmixed then -- pure array (maybe sparse)
			for i = 1, length do copy[i] = t[i] end
		else -- mixed
			for i = 1, length do copy[i] = t[i] end
			for k, v in pairs(t) do copy[k] = v end
		end
	else -- auto length
		length = 0
		if nonmixed then
			local k = next(t)
			if type(k) == "number" and k % 1 == 0 and k >= 1 then -- array (maybe sparse)
				for k in pairs(t) do if k > length then length = k end end
				for i = 1, length do copy[i] = t[i] end
			else
				for k, v in pairs(t) do copy[k] = v end
			end
		else
			for k, v in pairs(t) do
				if type(k) == "number" and k % 1 == 0 and k >= 1 then -- find max only
					if k > length then length = k end
				else
					copy[k] = v
				end
			end

			for i = 1, length do
				copy[i] = t[i]
			end
		end
	end
	return copy
end

local function get_max_array_index(t)
	local max
	for k in pairs(t) do if k > max then max = k end end
	return max
end

---Creates a ordered shallow copy of the table
---@param t table The table to copy.
---@param type TableKind.nil
---@param length integer?
---@return table # The shallow copy.
function collection_util.shallowCopy(t, type, length)
	type = type or "mixed" ---@cast type TableKind
	local copy = {}
	if t == nil then
		return nil ---@diagnostic disable-line: return-type-mismatch
	elseif type=="sequence" then
		for i = 1, #t do copy[i] = t[i] end
	elseif type=="array" and length then
		for i = 1, length do copy[i] = t[i] end
	elseif type=="array" and not length then
		for i = 1, get_max_array_index(t) do copy[i] = t[i] end
	elseif type=="dictionary" then
		for k, v in pairs(t) do copy[k] = v end
	elseif type=="mixed" and length then
		for i = 1, length do copy[i] = t[i] end
		for k, v in pairs(t) do copy[k] = v end
	else -- auto length
		length = 0
		for k, v in pairs(t) do
			if _G.type(k) == "number" and k % 1 == 0 and k >= 1 then -- find max only
				if k > length then length = k end
			else
				copy[k] = v
			end
		end
		for i = 1, length do copy[i] = t[i] end
	end
	return copy
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
--- <p>Source: __Kux-CoreLib__\lib\collections\_collection_util.lua</p>
function collection_util.notnilpairs(t)
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
--- <p>Source: __Kux-CoreLib__\lib\collections\_collection_util.lua</p>
function collection_util.allpairs(t)
	if not t["__len"] then error("unsupported table") end
	local i = 0
	return function()
		local len = rawget(t,"__len") or 0
		i = i + 1
		if i <= len then return i, t[i]
		else return nil end
	end, t, 0
end

local mt_dic = {}

function collection_util.register_metatable_and_guard(mt)
	assert(mt.__guid, "Missing field in metatatable. __guid not specified.")
	assert(mt_dic[mt]==nil, "metatable already registered")
	if script then script.register_metatable(mt.__guid, mt) end
	mt_dic[mt]=true
end

--[ global ]----------------------------------------------------------------

_G.apairs = collection_util.allpairs
_G.npairs = collection_util.notnilpairs

--[ table guard ]--------------------------------------------------------------------

table["remove"] = function(list, pos) ---@diagnostic disable-line: duplicate-set-field
	if mt_dic[getmetatable(list)] then error("table.remove is not supported by this collection type") end
	collection_util.table_o.remove(list, pos)
end

---@diagnostic disable-next-line: duplicate-set-field, redundant-parameter
table["insert"] = function(list, ...)
	if mt_dic[getmetatable(list)] then error("table.insert is not supported by this collection type") end
	local n = select("#", ...)
	local a, b = ...
	if n == 1 then
		return collection_util.table_o.insert(list, a)
	elseif n == 2 then
		return collection_util.table_o.insert(list, a, b)
	else
		--ignore
	end
end

do
	local t={0}
	table.insert(t,1,nil)
	assert(t[1]==nil)
	assert(t[2]==0)

	t={0}
	table.insert(t,1)
	assert(t[1]==0)
	assert(t[2]==1)

	t={0}
	table.insert(t,nil)
	assert(t[1]==0)
	assert(#t==1)

	t={0}
	--insert(t)                wrong number of arguments to 'insert'
	--insert(t,"foo","bar")    bad argument #2 of 4 to 'insert' (number expected, got string)
	--insert(t,1,"bar","foo")  wrong number of arguments to 'insert'
	--insert(t,nil)            OK
	--insert(t,nil,nil)        bad argument #2 of 4 to 'insert' (number expected, got nil)

end

table.sort = function(list, comp) ---@diagnostic disable-line: duplicate-set-field
	if mt_dic[getmetatable(list)] then error("table.sort is not supported by this collection type") end
	collection_util.table_o.sort(list, comp)
end
return collection_util