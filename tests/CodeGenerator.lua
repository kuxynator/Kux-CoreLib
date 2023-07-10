require("src.lib.init")

local CodeGenerator ={}
local private = {}
local ignore = {}

local Table=KuxCoreLib.Table
local String=KuxCoreLib.String
local Path=KuxCoreLib.Path

function CodeGenerator.run()
	for name, f in pairs(CodeGenerator) do
		if(name=="run") then goto next end
		if(type(f)~="function") then goto next end
		f()
		::next::
	end
end

function private.listFilesRecursive(directory, pattern, files)
    files = files or {}

    for file in io.popen('dir "' .. directory .. '" /b'):lines() do
        local filePath = directory .. '/' .. file

        if not file:match("[\\/]+$") and file:match(pattern) then
            table.insert(files, filePath)
        end
    end

    for subdirectory in io.popen('dir "' .. directory .. '" /ad /b'):lines() do
        local subdirectoryPath = directory .. '/' .. subdirectory
        private.listFilesRecursive(subdirectoryPath, pattern, files)
    end

    return files
end

function ignore.FileMapping()
	print("generate FileMapping ...")
	local root = "src/lib"
	local map = {}
	local files = private.listFilesRecursive(root,"%.lua$")
	for _, file in ipairs(files) do
		file = file:sub(#root+2)
		local name = Path.getFileNameWithoutExtension(file)
		if(name=="@") then goto next end
		if(map[name]) then error("Duplicate name found. " .. name .." = " .. file) end
		map[name] = file
		local line = String.format("\t%1 = \"%2\"", name, file:sub(1,-5-#name-1))
		table.insert(map, line)
		::next::
	end
	print("local require_map = { --AUTOGENERATED")
	print(String.join(",\n", map))
	print("}")
end

function CodeGenerator.DocMapping()
	-- ---@field Array KuxCoreLib.Array
	print("generate DocMapping ...")
	local root = "src/lib"
	local map = {}
	local files = private.listFilesRecursive(root,"%.lua$")
	for _, file in ipairs(files) do
		file = file:sub(#root+2)
		local name = Path.getFileNameWithoutExtension(file)
		if(name=="@") then goto next end
		if(map[name]) then error("Duplicate name found. " .. name .." = " .. file) end
		map[name] = file
		local line = String.format("---@field %1 KuxCoreLib.%1", name)
		table.insert(map, line)
		::next::
	end
	print(String.join("\n", map))
end

-- function CodeGenerator.listModules()
-- 	local files = listFiles("src/lib","%.lua$")
-- 	Table.appendRange(files, listFiles("src/lib/global","%.lua$"))
-- 	for _, name in ipairs(files) do
-- 		name = Path.getFileNameWithoutExtension(name)
-- 		print(String.format("---@field %1 KuxCoreLib.%1",name))
-- 	end
-- end

return CodeGenerator