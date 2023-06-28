require((KuxCoreLibPath or "__Kux-CoreLib__/").."init")

if Debug then
    if Debug.__guid == "{62243C3D-5389-42F7-B7C2-D87967E2D9AF}" then return Debug end
    error("A global Debug class already exist.")
end

local function isEnabled()
	-- return game.get_player(1).mod_settings["Kux-CoreLib_Debug"].value
    return false --TODO
end

---@class Debug
Debug = {
	__class  = "Debug",
	__guid   = "{62243C3D-5389-42F7-B7C2-D87967E2D9AF}",
	__origin = "Kux-CoreLib/lib/Debug.lua",

	onSettingsChanged = function ()
		--
	end,

	trace = function(...)
		if not isEnabled() then return end

		local msg = ""
		local args = {...}
		for i,v in ipairs(args) do
			if v == nil then v = "{nil}" end
		   msg = msg .. v
		end
		game.get_player(1).print(msg, {r = 0.7, g = 0.7, b = 0.7, a = 1})
	end,

	warning = function(...)
		if not isEnabled() then return end

		local msg = ""
		local args = {...}
		for i,v in ipairs(args) do
			if v == nil then v = "{nil}" end
		   msg = msg .. v
		end
		game.get_player(1).print(msg, {r = 1, g = 1, b = 0, a = 1})
	end,

	error = function(...)
		if not isEnabled() then return end

		local msg = ""
		local args = {...}
		for i,v in ipairs(args) do
			if v == nil then v = "{nil}" end
		   msg = msg .. v
		end
		game.get_player(1).print(msg, {r = 1, g = 0, b = 0, a = 1})
	end
}
Debug.util = Debug.util or {}

local function unescapeWhitespaces(str)
    str = string.gsub(str, "\\n", "\n") -- Zeilenumbruch
    str = string.gsub(str, "\\t", "\t") -- Tabulator
    -- Weitere Escape-Sequenzen hinzufügen, falls erforderlich
    return str
end

local function unescape(str)
    local unescapedStr = str:gsub("\\(.)", function(c)
        if c == "a" then return "\a"
        elseif c == "b" then return "\b"
        elseif c == "f" then return "\f"
        elseif c == "n" then return "\n"
        elseif c == "r" then return "\r"
        elseif c == "t" then return "\t"
        elseif c == "v" then return "\v"
        elseif c == "\\" then return "\\"
        elseif c == "\"" then return "\""
        elseif c == "'" then return "'"
        elseif c == "[" then return "["
        elseif c == "]" then return "]"
        elseif c == "\n" then return ""
        elseif c == "\r" then return ""
        else return "\\" .. c
        end
    end)
    return unescapedStr
end

function Debug.util.extractLineBeforeXpcall(stackTrace)
--[[
stack traceback:
        [C]: in function 'error'
        D:\Develop\Factorio\Mods\Kux-CoreLib/src/lib/String.lua:159: in function 'split'
        D:\Develop\Factorio\Mods\Kux-CoreLib/src/lib/String.lua:189: in function 'split'
        tests/StringTests.lua:18: in function <tests/StringTests.lua:17>
        [C]: in function 'xpcall'
		D:\Develop\Factorio\Mods\Kux-CoreLib/src/lib/TestRunner.lua:31: in function 'runTestClass'        
        D:\Develop\Factorio\Mods\Kux-CoreLib/src/lib/TestRunner.lua:78: in function 'run'	
        tests/StringTests.lua:65: in main chunk
		[C]: in function 'require'
        D:\Develop\Factorio\Mods\Kux-CoreLib/tests/run.lua:22: in main chunk
        [C]: in ?
--']]

    local previousLine = nil
	stackTrace = unescapeWhitespaces(stackTrace)
    for line in stackTrace:gmatch("[^\n]+") do
        if line:find("in function 'xpcall'") then
            return previousLine
        end
		previousLine = line
    end
    return nil
end

function Debug.util.extractFunctionInfo(callstackLine)
    local fileName, lineNumber = callstackLine:match("<(.-):(.-)>")
    return fileName, tonumber(lineNumber)
end

function Debug.util.extractLineInfo(inputString)
    local fileName, lineNumber = inputString:match("%s*(.-):(%d+)")
    return fileName, tonumber(lineNumber)
end

return Debug