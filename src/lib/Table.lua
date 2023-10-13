require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")
if(KuxCoreLib.__modules.Table) then return KuxCoreLib.__modules.Table end

---Provides table functions
---@class KuxCoreLib.Table
local Table = {
	__class  = "Table",
	__guid   = "{0a7a6b17-1d2a-4001-a105-2897c4d7f4e6}",
	__origin = "Kux-CoreLib/lib/Table.lua",

	__isInitialized = false,
	__on_initialized = {}
}
KuxCoreLib.__modules.Table = Table
---------------------------------------------------------------------------------------------------
-- to avoid circular references, the class MUST be defined before require other modules
local That = KuxCoreLib.That
local String = KuxCoreLib.String

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

--#region count, length, size
--[[
table
  - array(unspecified)
    - continuous-array 
    - gap-array, 
  - dictionary, 
  - mixed
LuaCustomTable

§  arrays: does not contins non numeric keys. (numeric keys, if present, are ignored)
! gap-array: ipairs loop ends after first nil!
! table.remove: does not allways shift subsequent values!

count 		Returns the number of elements that are not nil. (including numeric and non numeric key) using Factorio's table_size()
countAll		counts entries including nil
length
size
lastIndex
]]

---Returns the number of elements that are not nil.  
---Supports non-continuous arrays: nil is not counted.   
---Supports dictionaries: key are counted.  
---Supports LuaCustomTable: (simple using #t)
---@param t table
---@return integer
---
---See also List.count() which ist optimized for arrays.  
---See also Dictionary.count()  
--- 
--- WARNING entries in a mixed dictionar/gap arrays are not counted correctly.
function Table.count(t) -- alias 'countNonNil'
	--[[ from original table_size docu:
		>>Returns the size of a table with non-continuous keys.
		Factorio provides the table_size() function as a simple way to determine 
		the size of tables with non-continuous keys, as the standard # operator 
		does not work correctly for these. The function is a C++ implementation, 
		which is faster than doing the same in Lua<<
		--
		NOTE The # operator works correctly! The difference is: It counts also nil elements but no keys.
	]]

	if t.object_name=="LuaCustomTable" then return #t end
	--return table_size(t) --does not seem to count dictionary keys!
	local c = #t
	for k,_ in pairs(t) do
		if(type(k)~="number" or (not math.ceil(k)==k and k>c) ) then c=c+1 end
	end
	return c
end

function Table.countPairs(t)
	local c = 0
	for k,_ in pairs(t) do c=c+1 end
	return c
end

function Table.countNonNumericKeys(t)
	local c = 0
	for k,_ in pairs(t) do
		if(type(k)~="number") then c=c+1 end
	end
	return c
end

---Counts all entries for mixed tables (keys and indicies)
function Table.countAll(t)
	local nnk = Table.countNonNumericKeys(t)
	local l =  #t --TODO: does not work with gap array
	return nnk + l-- number of key + length of array
end

---Gets the length of the array. (same as #t)  
---If table is a mixed array/dictionary it returns only the length of the array part including nil elements.  
---A pure dictionary will returns always 0.  
---If you want the number of elemets, see Table.count() or Table.countAll()
---@param t table
---@return integer
function Table.length(t) return #t end

function Table.maxIndex(t)
	local key, value = next(t)
	local max = 0
	while key do
		key, value = next(t, key)
		if(type(key)=="number" and value>max) then max = value end
	end
	return max
end

function Table.stats(t)
	local key, value = next(t)
	local info = {
		max_index = 0,
		num_numeric_keys=0,
		num_nonNumeric_keys=0,
		numericKeys_num_nil=0,
		numerikKeys_num_nonNil=0,
		nonNumericKeys_num_nil=0,
		nonNumerikKeys_num_nonNil=0,
		is_continuous_array = false,
		is_true_continuous_array = false,
		is_gap_array = false,
		is_true_gap_array = false,
		is_dictionary = false,
		is_true_dictionary = false,
		has_mixed_keys = false
	}
	while key do
		if(type(key)=="number") then
			if (value>info.max_index) then info.max_index = value end

			if (value == nil) then
				info.numericKeys_num_nil = info.numericKeys_num_nil + 1
			else
				info.numerikKeys_num_nonNil = info.numerikKeys_num_nonNil + 1
			end
		else
			if (value == nil) then
				info.nonNumericKeys_num_nil = info.nonNumericKeys_num_nil + 1
			else
				info.nonNumerikKeys_num_nonNil = info.nonNumerikKeys_num_nonNil + 1
			end
		end

		key, value = next(t, key)
	end

	info.info.numericKeys = info.numericKeys_num_nil + info.numerikKeys_num_nonNil
	info.info.nonNumericKeys = info.nonNumericKeys_num_nil + info.nonNumerikKeys_num_nonNil
	
	info.is_continuous_array=info.numericKeys_num_nil==0
	info.is_true_continuous_array=info.numericKeys_num_nil==0 and info.num_nonNumeric_keys==0
	info.is_gap_array=info.numericKeys_num_nil>0
	info.is_true_gap_array=info.numericKeys_num_nil>0 and info.num_nonNumeric_keys==0
	info.is_dictionary=info.num_nonNumeric_keys>0
	info.is_true_dictionary=info.num_nonNumeric_keys>0 -- pure dictionary | associativ table
	info.has_mixed_keys = info.num_numeric_keys>0 and info.num_nonNumeric_keys>0
	return info
end

---What 'size' is expected? Numer of elements, length of array, 'size' is not unique and will always throw an error.<br>
---See Table.length()<br>
---See Table.count()<br>
---See Table.countAll()
---@param t any
---@return integer
---@deprecated
function Table.size(t) error("Size() is not unique in function.") end

---Removes a value from the table
---@param t table The table
---@param value any the Value to remove
---@return boolean # True if the values has been removed; else false
function Table.remove(t, value)
	--print("Table.remove")
	if(not table or value==nil) then return false end
    for key, v in pairs(t) do
        if v == value then
			--print("  remove '"..value.."'")
            table.remove(t, key)
			--print("  > "..serpent.line(t))
            return true
        end
    end
	return false
end

function Table.removeAt(t, index)
	-- BUGFIX subsequent entries will not be moved if next entry is nil
	local w = t[index+1]==nil
	if(w) then t[index+1]="dummy" end
	table.remove(t, index)
	if(w) then t[index+1]=nil end
end

---Moves entries
---@param source table
---@param startIdx integer
---@param endIdx integer?
---@param targetIdx integer
---@param destination table? not implemented
---@return table #destination
---@deprecated DRAFT. subject to change.
function Table.move(source, startIdx, endIdx, targetIdx, destination)
	if(destination~=source) then error("Not implemented.") end
	destination = destination or source
	if(endIdx==nil) then endIdx = Table.maxIndex(source) end

	if(startIdx > targetIdx) then
		local length = endIdx - startIdx + 1
		for i = 0, length - 1 do
			destination[targetIdx + i] = source[startIdx + i]
		end
		if destination == source then
			for i = targetIdx + length, endIdx do
				destination[i] = nil
			end
		end
	elseif(targetIdx>startIdx) then
		error("Not implemented.")
	else
		error("Argument out of range.")
	end

	return destination
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
---@param t table The table to update
---@param prototype table The prototype
---@param versionField string? name of version field. default = "dataVersion"
---@return table
function Table.migrate(t, prototype, versionField)
	assert(That.Argument.IsNotNil(t,"t"))
	assert(t~=prototype, "Argument 'prototype' must not be the same value as 't'!")
	versionField = "dataVersion"
	if(not prototype.dataVersion and prototype.version) then versionField = "version" end -- for compatibility
	if t[versionField] == prototype[versionField] then return t end

	-- remove orphaned members
	for n, v in pairs(t) do if prototype[n] == nil then t[n] = nil end end

	for n, v in pairs(prototype) do
		if string.find(n,"_migrationUpdate$") then goto next end
		if v == nil and t[n] ~=nil then t[n] = nil
		elseif t[n] == nil or prototype[n.."_migrationUpdate"] then t[n] = prototype[n] -- create or update
		end
		::next::
	end
	t[versionField] = prototype[versionField]
	return t
end

---Compares the content of the tables
---@param t1 table
---@param t2 table
---@return boolean # true if the content is equal; elsewhere false
---TODO: may be does not work as expected for sparse arrays
---see also List.isEqual or Dictionary.isEqual
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
	-- ⌧ ✕ 🗑️
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
	return json
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

---isNilOrEmpty
function Table.isNilOrEmpty(t) return t==nil or Table.isEmpty(t) end

---Appends a value
---@param t any[]|KuxCoreLib.List
---@param value any
function Table.append(t, value)
	table.insert(t, value)
end

---Appends a sequence of values
---@param t any[]|KuxCoreLib.List
---@param list any[]|KuxCoreLib.List the valies to append
function Table.appendRange(t, list)
	for index, value in ipairs(list) do
		Table.append(t, value)
	end
end

---Gets the highest numeric index
---@param t table
---@param assumeInteger boolean? assumes that all keys are integers. thist is faster.
---@return integer
function Table.getMaxIndex(t, assumeInteger)
	local function isInteger(v)	return math.floor(v) == v end
	local maxIndex = 0
	if(assumeInteger) then
		for k, _ in pairs(t) do
			if k > maxIndex then
				maxIndex = k
			end
		end
	else
		for k, _ in pairs(t) do
			if type(k) == "number" and isInteger(k) and k > maxIndex then
				maxIndex = k
			end
		end
	end	
	return maxIndex
end

function Table.removeGaps(t, length)
	if(length==nil) then length = Table.getMaxIndex(t) end
	local shift=0
	for i = 1, length do
		if(t[i]) == nil then
			shift = shift + 1
		elseif(shift > 0) then
			t[i-shift] = t[i]
			t[i]=nil
		end
	end
	return t
end

function Table.removeRange(t, itemsToRemove)
	for _, item in ipairs(itemsToRemove) do
		Table.remove(t, item)
	end
end

function Table.sub(t,startpos,endpos)
	local subTable = {}
    local length = #t

	if(endpos==nil) then endpos = length end

    -- Wenn die Startposition negativ ist, wird sie an den richtigen Index angepasst
    if startpos < 0 then
        startpos = length + startpos + 1
    end

    -- Wenn die Endposition negativ ist, wird sie an den richtigen Index angepasst
    if endpos < 0 then
        endpos = length + endpos + 1
    end

    -- Überprüfung, ob die Start- und Endpositionen innerhalb der Grenzen des Tisches liegen
    if startpos <= endpos and startpos >= 1 and endpos <= length then
        for i = startpos, endpos do
            subTable[#subTable + 1] = t[i]
        end
    end

    return subTable
end

function Table.overlaps(a,b)
	-- abcde
	--    def
	--> 4, 2
	local aStart, aEnd , bStart, bEnd
	
	for i = 1, math.min(#a, #b) do
		if String.join("//",Table.sub(a, -i)) == String.join("//",Table.sub(b, 1, i)) then
			aStart = #a - i + 1
			aEnd = #a
			bStart = 1
			bEnd = i
			break
		end
	end
	
	if aStart and aEnd and bStart and bEnd then
		return aStart, aEnd, bStart, bEnd
	else
		return nil
	end

	-- abc   abc   abc   abc   ab     bc   abc     bce   abc
	-- abc   ab     bc    b    abc   abc    bce   abc       def 
end

function Table.toFlagsDictionary(t)
	local flags = {}
	for _, v in ipairs(t) do
		flags[v] = true
	end
	return flags
end

---------------------------------------------------------------------------------------------------

---Provides Table in the global namespace
---@return KuxCoreLib.Table
function Table.asGlobal() return KuxCoreLib.utils.asGlobal(Table) end

Table.__isInitialized = true
for _, fnc in ipairs(Table.__on_initialized) do fnc() end

return Table