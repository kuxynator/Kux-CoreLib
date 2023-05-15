if Tools then
    if Tools.guid == "{2852E802-BC5B-442F-87E4-881623FD2E42}" then return Tools end
    error("A global Tools class already exist.")
end

require(KuxCoreLibPath.."Table")
require(KuxCoreLibPath.."String")

---@class Tools
Tools = {
	tableName = "Tools",
	guid      = "{2852E802-BC5B-442F-87E4-881623FD2E42}",
	origin    = "Kux-CoreLib/lib/Tools.lua",
}

---@deprecated OBSOLETE use Table.migrate
Tools.migrateTable = function (t, prototype)
	log("Warning Tools.migrateTable() is obsolete. use Table.migrate()")
	Table.migrate(t, prototype)
end

---Splits a string.
---@deprecated OBSOLETE use String.split
Tools.stringSplit = function (inputString, separator)
	log("Warning Tools.stringSplit() is obsolete. use String.split()")
	String.split(inputString, separator)
end

return Tools