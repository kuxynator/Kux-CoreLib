require((KuxCoreLibPath or "__Kux-CoreLib__/").."init")
if(KuxCoreLib.__modules.GlobalPlayers) then return KuxCoreLib.__modules.GlobalPlayers end

---@class KuxCoreLib.GlobalPlayers
local GlobalPlayers = {
	__class  = "GlobalPlayers",
	__guid   = "eeb5d79b-3522-4296-919a-40d8c430eb5d",
	__origin = "Kux-CoreLib/lib/global/GlobalPlayers.lua",
}
KuxCoreLib.__modules.GlobalPlayers = GlobalPlayers
---------------------------------------------------------------------------------------------------
local Global = KuxCoreLib.Global
local GlobalPlayer = KuxCoreLib.GlobalPlayer
local Player = KuxCoreLib.Player

local mt = {}

local globalPlayers

--- Funktion, um den Indexzugriff zu behandeln
---@param self KuxCoreLib.GlobalPlayers
---@param key any
---@return KuxCoreLib.GlobalPlayer?
local function indexHandler(self, key)
    globalPlayers = globalPlayers or Global.players
	
	local player = toLuaPlayer(key)
	if(not player) then return nil end

	-- local pi = global.players[player.index]
	-- if(pi==nil) then
	-- 	pi = {}
	-- 	global.players[player.index]=pi
	-- end
	-- return 

	local data = global.players[key] or {}
	local gp=GlobalPlayer:new(player, data)
	global.players[key]=data
	rawset(self,player.index,gp)	--self[player.index] = gp	
	return gp --[[@as KuxCoreLib.GlobalPlayer]]
end

---@return KuxCoreLib.GlobalPlayer
mt.__index = indexHandler

function mt.__newindex(self,key,value)
	-- global.players = global.players or {}
	-- local player = toLuaPlayer(key)
	-- global.players[player.index] = value
	--if(type(key)=="number") then self[key]=value; return end
	error("GlobalPlayers is protected.")
end

function GlobalPlayers.asGlobal() return KuxCoreLib.utils.asGlobal(GlobalPlayers) end

setmetatable(GlobalPlayers,mt)
return GlobalPlayers

