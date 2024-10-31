require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")
if(KuxCoreLib.__modules.Player) then return KuxCoreLib.__modules.Player end

---@class KuxCoreLib.Player
local Player = {
	__class  = "Player",
	__guid   = "b241c272-0cfd-44c2-82a9-83d6918b8ccb",
	__origin = "Kux-CoreLib/lib/Player.lua",
}
KuxCoreLib.__modules.Player = Player
---------------------------------------------------------------------------------------------------

---toLuaPlayer
---@param arg integer|LuaPlayer
---@return LuaPlayer
function Player.toLuaPlayer(arg)
	local t = (type(arg)=="table" or type(arg)=="userdata") and arg or nil
	if(t and t.object_name=="LuaPlayer") then return arg --[[@as LuaPlayer]] end
	if(type(arg)=="number") then return game.players[arg] end
	error("Invalid argument.")
end

--- @see Player.toLuaPlayer
Player.getPlayer = Player.toLuaPlayer

---------------------------------------------------------------------------------------------------

---Provides Player in the global namespace
---@return KuxCoreLib.Player
-- function Player.asGlobal(mode) return KuxCoreLib.utils.asGlobal(Player,mode) end
function Player.asGlobal(mode) return Player end -- concurrent 'Player 'already exist in various mods

return Player