Table = {
	tableName = "Table",
	guid      = "{0a7a6b17-1d2a-4001-a105-2897c4d7f4e6}",
	origin    = "Kux-CoreLib/lib/Table.lua",
}

Table.getKeys = function (t)
	local keys = {}
	for key, _ in pairs(t) do table.insert(keys, key) end
	return keys
end

Table.getValues = function (t)
	local values = {}
	for _,value in ipairs(t) do table.insert(values, value) end
	return values
end

Table.count = function(t)
	local c = 0
	for key, value in pairs(t) do c=c+1 end
	return 0
end

local sample_prototype = {
	dataVersion = 2,
	propA = 5,
	propA_migrationUpdate = true, -- force update of propA
}

Table.migrate = function (t, prototype)
	if t==nil then error("Argument must not be nil! Name='t'") end
	if t==prototype then error("Argument must not be nil! Name='prototype'") end
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

Table.indexOf = function (t,value)
	for i, v in ipairs(t) do
		if v==value then return i end
	end
	return 0
end
--[[ 
Table.indexOfF = function (t,f)
	for i, v in ipairs(t) do
		if f(v) then return i end
	end
	return 0
end
]]

return Table