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

---------------------------------------------------------------------------------------------------
Debug.util = require((KuxCoreLibPath or "__Kux-CoreLib__/").."modules/debug_util") --[[@as debug_util]]
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
	for _, v in ipairs(args) do
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

--TODO: remove Path dependency
function Debug.util.extractLineInfo(inputString)
	local fileName, lineNumber = inputString:match("%s*(.-):(%d+)")
	if (string.match(fileName, "^%.%.%.")) then
		fileName = Path.guessFullName(fileName)
	end

	return fileName, tonumber(lineNumber)
end

---Gets the mod that contains the code that is currently executing.
---@return string?
Debug.getExecutingMod = Debug.util.getExecutingMod

---Returns the mod of the method that invoked the currently executing method.
---@param excludeSelf boolean?
---@return string?
Debug.getCallingMod = Debug.util.getExecutingMod


---------------------------------------------------------------------------------------------------

---Provides Debug in the global namespace
---@return KuxCoreLib.Debug
function Debug.asGlobal(mode) return KuxCoreLib.utils.asGlobal(Debug, mode) end

return Debug
