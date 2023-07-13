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
---@param obj integer|LuaPlayer
---@return LuaPlayer
---@diagnostic disable-next-line: lowercase-global
function toLuaPlayer(obj)
	local t = iif(type(obj)=="table", obj, nil)
	if(t and t.create_character) then return obj --[[@as LuaPlayer]] end
	if(type(obj)=="number") then return game.players[obj] end
	error("Invalid argument.")
end

---------------------------------------------------------------------------------------------------

---Provides Player in the global namespace
---@return KuxCoreLib.Player
-- function Player.asGlobal(mode) return KuxCoreLib.utils.asGlobal(Player,mode) end
function Player.asGlobal(mode) return Player end -- concurrent 'Player 'already exist in various mods

return Player