KuxCoreLibPath="/" --set path
package.path = "tests/?.lua;"..package.path
package.path = "src/?.lua;"..package.path
package.path = "src/lib/?.lua;"..package.path
package.path = "../LuaLib/?.lua;"..package.path

if game and game.object_name == "LuaGameScript" then error("can not be called from within Factorio.") end
if util then error("can not be called from within Factorio.") end
--if not serpent then error("serpent not found") end

require("tests/FactorioMocks")
serpent = require("serpent")
require("src.lib.init")
local Path = KuxCoreLib.Path
local Table = KuxCoreLib.Table
local String = KuxCoreLib.String
local TestRunner = KuxCoreLib.TestRunner

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

-- local function listFilesRecursive(directory, pattern, files)
--     files = files or {}
--     ---@diagnostic disable-next-line: undefined-field "lines"
--     for file in io.popen('dir "' .. directory .. '" /b'):lines() do
--         if file:match(pattern) then
--             table.insert(files, file)
--         end
--     end
--     return files
-- end

local function listFilesRecursive(directory, pattern, files)
    files = files or {}

    for file in io.popen('dir "' .. directory .. '" /b'):lines() do
        local filePath = directory .. '/' .. file

        if not file:match("[\\/]+$") and file:match(pattern) then
            table.insert(files, filePath)
        end
    end

    for subdirectory in io.popen('dir "' .. directory .. '" /ad /b'):lines() do
        local subdirectoryPath = directory .. '/' .. subdirectory
        listFilesRecursive(subdirectoryPath, pattern, files)
    end

    return files
end


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

require("CodeGenerator").run()


local files = listFilesRecursive("tests", "Tests%.lua")
Table.removeRange(files,{"tests/LuaUnitTests.lua"})
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
    local name = Path.getFileNameWithoutExtension(file)
    io.write("found: "..String.padRight(name,20).."\tloading...")
    require(file:sub(1,-5))
    print("\x1b[10DOK        ") --replace "loading..." with "OK"
end

print("Tests running...")
TestRunner.runCollected()

-- local luaunit = require('luaunit')
-- require("LuaUnitTests")
-- os.exit(luaunit.LuaUnit.run())