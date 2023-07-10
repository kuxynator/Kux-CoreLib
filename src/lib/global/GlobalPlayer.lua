require((KuxCoreLibPath or "__Kux-CoreLib__/").."init")
if(KuxCoreLib.__modules.GlobalPlayer) then return KuxCoreLib.__modules.GlobalPlayer end

---Provides managed access to the Factorio global table
---@class KuxCoreLib.GlobalPlayer
---@field frames {string:LuaGuiElement}
local GlobalPlayer = {
	__class  = "GlobalPlayer",
	__guid   = "2eab6777-b887-4cf0-922c-41458b63dd2b",
	__origin = "Kux-CoreLib/lib/global/GlobalPlayer.lua",
}
KuxCoreLib.__modules.GlobalPlayer = GlobalPlayer
---------------------------------------------------------------------------------------------------

local mt = {}

local getter = {
	frames = function (self,key) return safegetOrCreate(global,"players["..self.index.."].frames") end,
}

local function defaultGetter(self, key) return global.players[self.index][key]end

function mt.__index(self,key)
	return (getter[key] or defaultGetter)(self,key)
end

function mt.__newindex(self, key, value)
	if(getter[key]) then error("Property is write protected.") end
	global.players[self.index][key]=value
end

---Creates a new GlobalPlayer.  
--Usually this function does not need to be called manually. The access is made via Global.Players[index]
---@param player LuaPlayer|integer
---@param defaultData? table
---@return GlobalPlayer
function GlobalPlayer:new(player, defaultData)
	if(type(player)=="number") then player=game.players[player] end
	if(not player) then error("Player does not exist.") end --TODO: return nil??
	data = safeget("global.players["..player.index.."]")
	if(not data) then data = defaultData or {}; safeset("global.players["..player.index.."]", defaultData) end
	local globalPlayer={index=player.index,_data=data}
	setmetatable(globalPlayer,mt)
	return globalPlayer
end

---------------------------------------------------------------------------------------------------

function GlobalPlayer.asGlobal() return KuxCoreLib.utils.asGlobal(GlobalPlayer) end

return GlobalPlayer