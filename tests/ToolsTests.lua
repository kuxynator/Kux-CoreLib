require "src.lib.TestRunner"
require "src.lib.Tools"

local tests = {}

tests.migrateTable_DataVersion_ShouldBe_Updated = function ()
	local p = {dataVersion = 2,	newField1 = "a"	}
	local t = {dataVersion = 1, oldField1 = "old"}
	Tools.migrateTable(t,p)
	if t["dataVersion"] ~= 2 then error("dataVersion is not 2") end
end

tests.migrateTable_ExistingFields_ShouldBe_Unchanged = function ()
	local p = {dataVersion = 2,	value = "b"	}
	local t = {dataVersion = 1, value = "a"}
	Tools.migrateTable(t,p)
	if t["value"] ~= "a" then error("value is not 'a'") end
end

tests.migrateTable_NewFields_ShouldBe_Added = function ()
	local p = {dataVersion = 2,	newField1 = "a"	}
	local t = {dataVersion = 1, oldField1 = "old"}
	Tools.migrateTable(t,p)
	if t["newField1"] ~= "a" then error("newField1 is not 'a'") end
end

tests.migrateTable_ForceUpdate_ShouldBe_Work = function ()
	local p = {dataVersion = 2,	value = "b", value_migrationUpdate=true}
	local t = {dataVersion = 1, value = "a"}
	Tools.migrateTable(t,p)
	if t["value"] ~= "b" then error("value is not 'b'") end
end

tests.migrateTable_OrphanedFields_ShouldBe_Removed = function ()
	local p = {dataVersion = 2,	newField1 = "a"	}
	local t = {dataVersion = 1,	oldField1 = "old"}
	Tools.migrateTable(t,p)
	if t["oldField1"] ~= nil then error("oldField1 is not nil") end
end

tests.stringSplit_separator = function ()
	local tokens = tools.stringSplit("a.b",".")
	if #tokens ~= 2 then error("2 tokens expected") end
	if tokens[1] ~= "a" then error("'a' expected") end
	if tokens[2] ~= "b" then error("'a' expected") end
end

tests.stringSplit_pattern = function ()
	local tokens = tools.stringSplit("a, b",",%s*")
	if #tokens ~= 2 then error("2 tokens expected") end
	if tokens[1] ~= "a" then error("'a' expected") end
	if tokens[2] ~= "b" then error("'a' expected") end
end

TestRunner.run(tests, "lib.Tools")