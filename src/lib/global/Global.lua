require((KuxCoreLibPath or "__Kux-CoreLib__/").."init")
if(KuxCoreLib.__modules.Global) then return KuxCoreLib.__modules.Global end

---Provides managed access to the Factorio global table
---@class KuxCoreLib.Global
---@field players KuxCoreLib.GlobalPlayers
local Global = {
	__class  = "Global",
	__guid   = "431a60fa-6289-4f1e-b0f8-9047cf33b2d0",
	__origin = "Kux-CoreLib/lib/global/Global.lua",
}
KuxCoreLib.__modules.Global = Global
---------------------------------------------------------------------------------------------------

local GlobalPlayers = KuxCoreLib.GlobalPlayers

local getter = {
	players = function (self) global.players = global.players or {}; return GlobalPlayers end
}
local function defaultGetter(self) return rawget(self)end

local mt = {}

function mt.__index(self,key)
	return (getter[key] or defaultGetter)(self)
end

function mt.__newindex(self,key,value)
	if(getter[key]) then error("Property is read only. Property:'"..key.."'") end
	rawset(self,key,value)
end

---------------------------------------------------------------------------------------------------

function Global.asGlobal() return KuxCoreLib.utils.asGlobal(Global) end

setmetatable(Global,mt)

return Global