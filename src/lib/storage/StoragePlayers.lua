require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")
if(KuxCoreLib.__modules.StoragePlayers) then return KuxCoreLib.__modules.StoragePlayers end

---@class KuxCoreLib.StoragePlayers
local StoragePlayers = {
	__class  = "StoragePlayers",
	__guid   = "eeb5d79b-3522-4296-919a-40d8c430eb5d",
	__origin = "Kux-CoreLib/lib/storage/StoragePlayers.lua",
}
KuxCoreLib.__modules.StoragePlayers = StoragePlayers
---------------------------------------------------------------------------------------------------
local Storage = KuxCoreLib.Storage
local StoragePlayer = KuxCoreLib.StoragePlayer
local Player = KuxCoreLib.Player

local mt = {}

local globalPlayers

--- Funktion, um den Indexzugriff zu behandeln
---@param self KuxCoreLib.StoragePlayers
---@param key any
---@return KuxCoreLib.StoragePlayer?
local function indexHandler(self, key)
    globalPlayers = globalPlayers or Storage.players

	local player = toLuaPlayer(key)
	if(not player) then return nil end

	-- local pi = storage.players[player.index]
	-- if(pi==nil) then
	-- 	pi = {}
	-- 	storage.players[player.index]=pi
	-- end
	-- return

	local storageTable = storage
	storageTable.players = storageTable.players or {}  -- Sicherstellen, dass players eine Tabelle ist
	storageTable.players[key] = data
	rawset(self,player.index,gp)	--self[player.index] = gp
	return gp --[[@as KuxCoreLib.StoragePlayer]]
end

---@return KuxCoreLib.StoragePlayer
mt.__index = indexHandler

function mt.__newindex(self,key,value)
	-- storage.players = storage.players or {}
	-- local player = toLuaPlayer(key)
	-- storage.players[player.index] = value
	--if(type(key)=="number") then self[key]=value; return end
	error("StoragePlayers is protected.")
end

function StoragePlayers.asGlobal() return KuxCoreLib.utils.asGlobal(StoragePlayers) end

setmetatable(StoragePlayers,mt)
return StoragePlayers

