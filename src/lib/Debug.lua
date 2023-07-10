require((KuxCoreLibPath or "__Kux-CoreLib__/") .. "init")
if(KuxCoreLib.__modules.Debug) then return KuxCoreLib.__modules.Debug end

local function isEnabled()
	-- return game.get_player(1).mod_settings["Kux-CoreLib_Debug"].value
	return false --TODO
end

---@class KuxCoreLib.Debug
local Debug = {
	__class  = "Debug",
	__guid   = "{62243C3D-5389-42F7-B7C2-D87967E2D9AF}",
	__origin = "Kux-CoreLib/lib/Debug.lua"
}
KuxCoreLib.__modules.Debug = Debug

local String = KuxCoreLib.String
local Path = KuxCoreLib.Path

function Debug.onSettingsChanged()
	--
end

function Debug.trace(...)
	if not isEnabled() then return end

	local msg = ""
	local args = { ... }
	for i, v in ipairs(args) do
		if v == nil then v = "{nil}" end
		msg = msg .. v
	end
	game.get_player(1).print(msg, { r = 0.7, g = 0.7, b = 0.7, a = 1 })
end

function Debug.warning(...)
	if not isEnabled() then return end

	local msg = ""
	local args = { ... }
	for i, v in ipairs(args) do
		if v == nil then v = "{nil}" end
		msg = msg .. v
	end
	game.get_player(1).print(msg, { r = 1, g = 1, b = 0, a = 1 })
end

function Debug.error(...)
	if not isEnabled() then return end

	local msg = ""
	local args = { ... }
	for i, v in ipairs(args) do
		if v == nil then v = "{nil}" end
		msg = msg .. v
	end
	game.get_player(1).print(msg, { r = 1, g = 0, b = 0, a = 1 })
end

Debug.util = {}

local function unescapeWhitespaces(str)
	str = string.gsub(str, "\\n", "\n") -- Zeilenumbruch
	str = string.gsub(str, "\\t", "\t") -- Tabulator
	-- Weitere Escape-Sequenzen hinzufügen, falls erforderlich
	return str
end

local function unescape(str)
	local unescapedStr = str:gsub("\\(.)", function(c)
		if c == "a" then
			return "\a"
		elseif c == "b" then
			return "\b"
		elseif c == "f" then
			return "\f"
		elseif c == "n" then
			return "\n"
		elseif c == "r" then
			return "\r"
		elseif c == "t" then
			return "\t"
		elseif c == "v" then
			return "\v"
		elseif c == "\\" then
			return "\\"
		elseif c == "\"" then
			return "\""
		elseif c == "'" then
			return "'"
		elseif c == "[" then
			return "["
		elseif c == "]" then
			return "]"
		elseif c == "\n" then
			return ""
		elseif c == "\r" then
			return ""
		else
			return "\\" .. c
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
	if (String.startsWith(fileName, "...")) then
		fileName = Path.guessFullName(fileName)
	end

	return fileName, tonumber(lineNumber)
end

function Debug.util.dump(t)
	local lines = {}
	for n, v in pairs(t) do
		if(type(v)=="function") then table.insert(lines,"  "..n.." ("..type(v).." @ "..Debug.util.getClassFileName(t) or "?"..")")
		elseif(type(v)=="table") then table.insert(lines,"  "..n.." ("..type(v)..")")
		elseif(type(v)=="string") then table.insert(lines,"  "..n.." = \""..v.."\"")
		else table.insert(lines,"  "..n.." = "..tostring(v).."")
		end
	end
	return table.concat(lines,"\n")
end

---Gets the mod that contains the code that is currently executing.
---@return string?
function Debug.getExecutingMod()
	local stackTrace = debug.traceback()
	local mod = ""
	local c = 0
	for line in stackTrace:gmatch("[^\n]+") do
		c = c + 1
		if (c > 2) then
			mod = line:match("__([^/]+)__/")
			if (mod) then return mod end
		end
	end
	return nil
end

---Returns the mod of the method that invoked the currently executing method.
---@param excludeSelf boolean?
---@return string?
function Debug.getCallingMod(excludeSelf)
	local stackTrace = debug.traceback()
	local mod = ""
	local c = 0
	local self = ""
	for line in stackTrace:gmatch("[^\r\n]+") do
		c = c + 1
		if (c == 2) then
			self = line:match("__([^/]+)__/")
		elseif (c > 3) then
			local match = line:match("__([^/]+)__/")
			if match and match ~= self then return match end
		end
	end
	return nil
end

---Returns the first mod of the current call sequence.
---@return any
function Debug.getEntryMod()
	local stackTrace = debug.traceback()
	local mod = nil
	for line in stackTrace:gmatch("[^\r\n]+") do
		local match = line:match("__([^/]+)__/")
		if match then mod = match end
	end
	return mod
end

function Debug.util.getClassFileName(class)
	--local classTable = getmetatable(class)
	
	for key, value in pairs(class) do
	  if type(value) == "function" then
		local info = debug.getinfo(value, "S")
		if info.source and info.source ~= "=[C]" then
		  return info.source:gsub("@", "")
		end
	  end
	end
	
	return nil
end

---------------------------------------------------------------------------------------------------

function Debug.asGlobal(mode) return KuxCoreLib.utils.asGlobal(Debug, mode) end

return Debug
