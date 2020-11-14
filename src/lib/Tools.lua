Tools = {
	tableName = "Tools",
	guid      = "{2852E802-BC5B-442F-87E4-881623FD2E42}",
	origin    = "Kux-CoreLib/lib/Tools.lua",
}

--- OBSOLETE use Table.migrate
Tools.migrateTable = function (t, prototype)
	log("Warning Tools.migrateTable() is obsolete. use Table.migrate()")
	Table.migrate(t, prototype)
end

--- Splits a string.
--@param inputString  The string to split
--@param separator    The separator (string or pattern)
--@return A table with the parts
--example: stringSplit("Foo, Bar, Boo", ",%s*") returns the table {"Foo", "Bar", "Boo"}
Tools.stringSplit = function (inputString, separator)
	if separator == nil then separator = "%s" end
	local t={}
	local i=1
	for str in string.gmatch(inputString, "([^"..separator.."]+)") do
		t[i] = str
		i = i + 1
	end
	return t
end

return Tools