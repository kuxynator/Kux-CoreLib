require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---@class KuxCoreLib.Player
local Player = {
	__class  = "Player",
	__guid   = "b241c272-0cfd-44c2-82a9-83d6918b8ccb",
	__origin = "Kux-CoreLib/lib/Player.lua",
}
if KuxCoreLib.__classUtils.cache(Player) then return KuxCoreLib.__classUtils.cached end
---------------------------------------------------------------------------------------------------

---toLuaPlayer
---@param arg integer|LuaPlayer
---@return LuaPlayer
function Player.toLuaPlayer(arg)
	if is_obj(arg, "LuaPlayer") then return arg --[[@as LuaPlayer]] end
	if type(arg)=="number" then return game.players[arg] end
	error("Invalid argument. "..tostring(arg))
end

--- @see Player.toLuaPlayer
Player.getPlayer = Player.toLuaPlayer

function Player.character_personal_logistic_requests_enabled(player)
	player = Player.toLuaPlayer(player); if not player then return false end
	---@diagnostic disable-next-line: undefined-field
	if isV1 then return player.character_personal_logistic_requests_enabled end

	local c = player.character; if not c then return false end
	local rp = player.character.get_requester_point(); if not rp then return false end
	return rp.enabled
end

---------------------------------------------------------------------------------------------------

---Provides Player in the global namespace
---@return KuxCoreLib.Player
-- function Player.asGlobal(mode) return KuxCoreLib.__classUtils.asGlobal(Player,mode) end
function Player.asGlobal(mode) return Player end -- concurrent 'Player 'already exist in various mods

return Player