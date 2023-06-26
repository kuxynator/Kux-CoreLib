KuxCoreLibPath=""
package.path = "tests/?.lua;"..package.path
package.path = "src/?.lua;"..package.path
package.path = "src/lib/?.lua;"..package.path
package.path = "../LuaLib/?.lua;"..package.path

if game then error("can not be called from within Factorio.") end
if util then error("can not be called from within Factorio.") end
--if not serpent then error("serpent not found") end

require("FactorioMocks")
serpent = require("serpent")
require("init")
Path = require(KuxCoreLib.Path)
Table = require(KuxCoreLib.Table)

-- local lfs = requ ire("lfs")
-- function listFilesWithExtension(directory, extension)
--     local files = {}
--     for file in lfs.dir(directory) do
--         if file ~= "." and file ~= ".." then
--             local fullPath = directory .. "/" .. file
--             local attributes = lfs.attributes(fullPath)
--             if attributes.mode == "file" and string.match(file, extension .. "$") then
--                 table.insert(files, fullPath)
--             end
--         end
--     end
--     return files
-- end

local function listFiles(directory, pattern)
    local files = {}
    ---@diagnostic disable-next-line: undefined-field "lines"
    for file in io.popen('dir "' .. directory .. '" /b'):lines() do
        if file:match(pattern) then
            table.insert(files, file)
        end
    end
    return files
end

local files = listFiles("tests", "Tests%.lua")
Table.removeRange(files,{"LuaUnitTests.lua"})
print("package.path: "..package.path)

require("TestRunner")
TestRunner.isCollecting=true
-- require("LuaLangTests")
-- require("luaTests")
-- require("AssertTests")
-- require("StringTests")
-- require("TableTests")
-- require("ToolsTests")
for i, file in ipairs(files) do
    local name = Path.getFileNameWidthoutExtension(file)
    io.write("found: "..name.."\tloading...")
    require("tests/"..name)
    print("OK")
end

print("Tests running...")
TestRunner.runCollected()

-- local luaunit = require('luaunit')
-- require("LuaUnitTests")
-- os.exit(luaunit.LuaUnit.run())