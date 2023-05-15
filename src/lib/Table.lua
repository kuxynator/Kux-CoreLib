if Table then
    if Table.guid == "{0a7a6b17-1d2a-4001-a105-2897c4d7f4e6}" then return Table end
    error("A global Table class already exist.")
    --TODO combine
end

---Provides table functions
---@class Table
Table = {
	tableName = "Table",
	guid      = "{0a7a6b17-1d2a-4001-a105-2897c4d7f4e6}",
	origin    = "Kux-CoreLib/lib/Table.lua",
}

-- to avoid circular references, the class is defined before require other modules
require(KuxCoreLibPath.."Assert")
require(KuxCoreLibPath.."String")


---Gets all values.
---@param t table
---@return any[]
function Table.getValues(t)
	local values = {}
	for _,v in pairs(t) do
		table.insert(values, v)
	end
	return values
end

---Gets all keys
---@param t table
---@return table
function Table.getKeys(t)
	local keys = {}
	for k, _ in pairs(t) do
		table.insert(keys, k)
	end
	return keys
end

---Gets the index of the value
---@param t any[] The array
---@param value any
---@return integer # The index or 0
function Table.indexOf(t, value)
	for i, v in ipairs(t) do
		if v == value then return i end
	end
	return 0
end

---Gets the first key which has the value
---@param t table 
---@param value any
---@return integer|string|nil # The key or nil
function Table.keyOf(t, value)
	for k, v in pairs(t) do
		if v == value then return k end
	end
	return nil
end

---Gets the keys which have the value
---@param t table
---@param value any
---@return any[]
function Table.keysOf(t,value)
	local n = {}
	for k,v in pairs(t) do
		if v == value then
			table.insert(n,k)
		end
	end
	return n
end

--[[ 
Table.indexOfF = function (t,f)
	for i, v in ipairs(t) do
		if f(v) then return i end
	end
	return 0
end
]]

-- TODO nextIndexOf(t,value,start)
-- TODO lastIndexOf(t,value)

---Gets a value indicating the table has a specific element.
---@param t table
---@param value any
---@return boolean
function Table.hasValue(t, value)
    for _, v in pairs(t) do
        if v == value then return true end
    end
    return false
end

---Gets a value indicating the table contains a specific element.
---@param t table
---@param element any
---@return boolean
function Table.contains(t, element)
    for _, v in pairs(t) do
        if v == element then return true end
    end
    return false
end

---Checks if a table is empty
---@param t table
---@return boolean
function Table.isEmpty(t)
	return next(t) == nil
	-- TODO check this with LuaObject
end

---Returns the number of elements that are not nil. <br>
---Supports non-continuous arrays: nil is not counted. 
---Supports dictionaries: key are counted.
---@param t table
---@return integer
function Table.count(t) -- alias 'countNoNil'
	--[[ from original table_size docu:
		Returns the size of a table with non-continuous keys.
		Factorio provides the table_size() function as a simple way to determine 
		the size of tables with non-continuous keys, as the standard # operator 
		does not work correctly for these. The function is a C++ implementation, 
		which is faster than doing the same in Lua
	]]
	-- The # operator works correctly! The difference is: It counts also nil elements but no keys.

	if t.object_name=="LuaCustomTable" then return #t end
	return table_size(t)
end

function Table.countAll(t)
	local c = 0
	for k,v in pairs(t) do
		if(type(k)~="number") then c=c+1 end -- count only the keys
	end
	return c + #t -- number of key + length of array
end

---Gets the length of the array. (same as #t)<br>
---If table is a mixed array/dictionary it returns only the length of the array part including nil elements.
---A pure dictionary will returns always 0.<br>
---If you want the number of elemets, see Table.count()
---@param t table
---@return integer
function Table.length(t) return #t end

---What 'size' is expected? Numer of elements, length of array, 'size' is not unique and will always throw an error.<br>
---See Table.length()<br>
---See Table.count()<br>
---See Table.countAll()
---@param t any
---@return integer
---@deprecated
function Table.size(t) error("Size is not unique.") end

---Removes a value from the table
---@param t table The table
---@param value any the Value to remove
---@return boolean # True if the values has been removed; else false
function Table.remove(t, value)
    for key, value in pairs(t) do
        if value == value then
            table.remove(t, key)
            return true
        end
    end
	return false
end

---Gets the unique values.
---@param t any[]
---@return table
function Table.distinct(t)
	local n = {}
	local temp = {}
	for _,value in ipairs(t) do
		if not temp[value] then
			temp[value] = true
			table.insert(n,value)
		end
	end
	return n
end

---Reverses a table in place
---@param table any
function Table.reverse(table)
	for i=1, math.floor(#table / 2) do
		local tmp = table[i]
		table[i] = table[#table - i + 1]
		table[#table - i + 1] = tmp
	end
end

-- TODO getReversed(t)

---Creates a shallow copy of the table
---@param t table The table to copy.
---@return table # The shallow copy.
function Table.shallowCopy(t)
	local copy = {}
	for k,v in pairs(t) do
		copy[k] = v
	end
	return copy
end

function Table.shallowCopyPath(t, props)
    t = Table.shallowCopy(t)
    if props ~= nil then return t end

	local parent = t
	for _, prop in ipairs(props) do
		parent[prop] = Table.shallowCopy(parent[prop])
		parent = parent[prop]
	end

    return t
end

--[[ -- this is only a quick and dirty implementation
function Table.deepCopy(t)	
    local orig_type = type(t)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, t, nil do
            copy[Table.deepCopy(orig_key)] = Table.deepCopy(orig_value)
        end
        setmetatable(copy, Table.deepCopy(getmetatable(t)))
    else -- number, string, boolean, etc
        copy = t
    end
    return copy
end
]]

---Creates a deep copy of the table
---@param object any The table to copy.
---@return table # The deep copy.
---like Factorio's table.deepcopy implementation. references keep referenced
function Table.deepCopy(object)
	local lookup_table = {}
	local function copy(object)
		if type(object) ~= "table" then return object
		-- don't copy factorio rich objects
		elseif object.__self then return object
		elseif lookup_table[object] then return lookup_table[object]
		end
		local new_table = {}
		lookup_table[object] = new_table
		for index, value in pairs(object) do
			new_table[copy(index)] = copy(value)
		end
		return setmetatable(new_table, getmetatable(object))
	end
	return copy(object)
end

-- TODO check older methods


---Migrates values of a prototype with higher version into a (outdated) table
---@param t table
---@param prototype table
---@return table
Table.migrate = function (t, prototype)
	assert(Assert.Argument.IsNotNil(t,"t"))
	assert(t~=prototype, "Argument 'prototype' must not be the same value as 't'!")
	if t.dataVersion == prototype.dataVersion then return t end

	-- remove orphaned members
	for n, v in pairs(t) do if prototype[n] == nil then t[n] = nil end end

	for n, v in pairs(prototype) do
		if string.find(n,"_migrationUpdate$") then goto next end
		if v == nil and t[n] ~=nil then t[n] = nil
		elseif t[n] == nil or prototype[n.."_migrationUpdate"] then t[n] = prototype[n] -- create or update
		end
		::next::
	end
	t.dataVersion = prototype.dataVersion
	return t
end

---Compares the content of the tables
---@param t1 table
---@param t2 table
---@return boolean # true if the content is equal; elsewhere false
--TODO: may be does not work as expected for sparse arrays
function Table.isEqual(t1,t2)
	if t1 == t2 then return true end
	for k,v in pairs(t1) do
	  	if type(v) == "table" and type(t2[k]) == "table" then
			if not Table.isEqual(v, t2[k]) then return false end
		elseif type(v) == "number" and type(t2[k]) == "number" then
			if(math.abs(t2[k] - v) > 1e-15) then return false end
	  	else
			if (v~=t2[k]) then return false end
	  	end
	end
	for k,v in pairs(t2) do
	  	if t1[k] == nil then return false end
	end
	return true
end

---Returns the length of the array.
---@param t any
---@param max? integer The maximum expected length. default is 1024.
---@return integer
local function table_size_mock (t, max)
	if not max then max=1024 end
	local c = 0;
	local i = 1;
	while i<max or t[i]~=nil do
		if t[i]~=nil then c = i end
		i = i + 1
	end
	return c
end
table_size = table_size or table_size_mock

---Cast all elements to strings.
---@param t table
---@param max? integer
---@result table
function Table.castString(t,max)
	if(not max) then max=1024 end
	local result={}
	for i = 1, max, 1 do
		result[i]=String.pretty(t[i])
	end
	return result
end

---Creates a table which contains only the changes. deleted entries are merked as "§DELETED".
---@param t1 table
---@param t2 table
---@return table
function Table.createPatch(t1,t2)
	local function createPatch(t1,t2,parentPatch,key)
		local patch = {}
		local changes = 0
		if not t1 then
			parentPatch[key] = Table.deepCopy(t2)
			return parentPatch
		end
		if not t2 then
			parentPatch[key] ="§DELETED"
			return parentPatch
		end
		for k1, v1 in pairs(t1) do
			local v1t = type(v1)
			if v1t=="userdata" then;
			elseif v1t=="thread" then;
			elseif v1t=="function" then;
			elseif v1t == "table" then
				createPatch(v1,t2[k1],patch,k1)
			else
				if t2[k1] == nil then patch[k1] = "§DELETED"; changes=changes+1
				elseif v1~=t2[k1] then patch[k1] = t2[k1];  changes=changes+1-- changed
				end
			end
		end
		for k2, v2 in pairs(t2) do
			local v2t = type(v2)
			if t1[k2] then; -- already read
			elseif v2t=="userdata" then;
			elseif v2t=="thread" then;
			elseif v2t=="function" then;
			elseif v2t == "table" then
				createPatch(t1[k2],v2, patch,k2)
			else
				patch[k2] = t1[k2]; changes=changes+1-- added
			end
		end
		if changes>0 and key then
			parentPatch[key]=patch
		end
		return patch
	end
	return createPatch (t1,t2,{},nil)
end

---Applies a patch to the specified table. (see Table.createPatch())
---@param t table The table to patch.
---@param patch table The patch.
function Table.applyPatch(t,patch)
	for k, v in pairs(patch) do
		if v=="§DELETED" then
			t[k]=nil
		elseif type(v)=="table" and type(t[k])=="table" then
			Table.applyPatch(t[k],v)
		else
			t[k]=v
		end
	end
end

---Removes properties with empty tables
---@param t table
---@param maxLevel integer|nil
function Table.removeEmptyTablesRecursive(t, maxLevel)
	maxLevel = maxLevel or 9999
	for k, v in pairs(t) do
		if type(v) == "table" then
			if(maxLevel>1) then Table.removeEmptyTablesRecursive(v, maxLevel-1) end
			if Table.isEmpty(v) then t[k] = nil end
		end
	end
end

---Gets a table whre the values are in reverse order
---@param t table
---@return table
---applicable only for continuous arrays
function Table.getReversed(t)
	--TODO: this will lost all non numeric keys!
	--TODO: write tests
	local reversed = {}
	local length = #t
	for i = length, 1, -1 do
	  	table.insert(reversed, t[i])
	end
	return reversed
end

--function Array.getReversed(a) return Table.getReversed(a) end

---Creates a new compressed table skipping all nil values,
---@param t table The dictionary to comnpress
---@param sort nil|boolean|string if specified and 'true' 'asc' or 'desc' the compressed table will be sorted
---@return table
---usefull afer removing keys
function Table.getCompressed(t,sort)
	--TODO: write tests
	local n = {}
	if(sort) then
		local keys = Table.getKeys(t)
		table.sort(keys)
		if(sort=="desc" or sort == "descent") then Table.reverse(keys) end
		for _, k in ipairs(keys) do
			n[k]=t[k]
		end
	else
		for k,v in pairs(t) do n[k]= v end
	end
	return n
end

---Removes all entries in a table which exists in both (recursive)
---@param t table The table to change
---@param base table The table to compare with
function Table.diff(t, base)
	if t ==nil or base == nil then return end
	for k,v in pairs(t) do
		if type(v) == "table" and base[k] and type(base[k]) == "table" then	-- If both are tables, recursively compare them
			if(Table.hasIndices(v)) then
				if(Table.isEqual(v,base[k]))then t[k] = nil end
			else
				Table.diff(v, base[k])
				if(Table.isEmpty(v)) then
					t[k] = nil
				else
					t[k] = Table.getCompressed(v,"asc")
				end
			end
		elseif base[k] ~= nil and type(v) == "number" and type(base[k]) == "number" and math.abs(base[k] - v) < 1e-15 then
			t[k] = nil -- Remove identical numerical values with tolerance
		elseif base[k] ~= nil and base[k] == v then
			t[k] = nil -- Remove identical values
		end
	end
end

---Converts a table to a json string. 
---@param t table The table to convert
--- - [Not available in data stage. 'game' is required'.]
--- - contains a bugfix for game.table_to_json
function Table.toJson(t)
	if(not game) then error("Function not available in current stage.") end
	local json = game.table_to_json(t)
	--BUGFIX for game.table_to_json
	json=string.gsub(json,"%:inf",":\"#inf\"")
	json=string.gsub(json,"%:%-inf",":\"-#inf\"")
end

function Table.countEntries_DRAFT(t)
	local function isInteger(v)	return math.floor(v) ~= v end
	local maxIndex = 0
	for k, _ in pairs(t) do
		if type(k) == "number" and isInteger(k) and k > maxIndex then
			maxIndex = k
		end
	end
	return maxIndex
end

function Table.getMaxIndex(t)
	local function isInteger(v)	return math.floor(v) == v end
	local maxIndex = 0
	for k, _ in pairs(t) do
		if type(k) == "number" and isInteger(k) and k > maxIndex then
			maxIndex = k
		end
	end
	return maxIndex
end

function Table.isContinuous(t)
	local function isInteger(v)	return math.floor(v) == v end
	local count = 0
	for key, _ in pairs(t) do
		if(type(key) == "number" and isInteger(key)) then
			count = count + 1
			if(key ~= count) then return false end
		end
	end
	return true
end

---Gets a value that indicates whether the table has keys which are non numeric
---@param t table
---@return boolean
function Table.hasKeys(t)
	local function isInteger(v)	return math.floor(v) == v end
	for key,_ in pairs(t) do
		if (type(key) ~= "number" or not isInteger(key)) then return true end
	end
	return false
end

---Gets a value that indicates whether the table has indices
---@param t table
---@return boolean
---only for continuous arrays
function Table.hasIndices(t)
	if(not t) then return false end
	if(type(t)~="table" ) then return false end
	for index, value in ipairs(t) do
		return true
	end
	return false
end

return Table