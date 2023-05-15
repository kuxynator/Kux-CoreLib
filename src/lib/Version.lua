local mod = require("mod")
local String = require(mod.KuxCoreLibPath.."String")

Version = Version or {}

Version.baseVersionGreaterOrEqual1d1 = function ()
	local v = ""
	---@diagnostic disable-next-line: undefined-global
	if mods then v = mods["base"] else v = script.active_mods["base"] end
	if String.startsWith(v,"0.") then return false end
	if String.startsWith(v,"1.0") then return false end
	return true
end
