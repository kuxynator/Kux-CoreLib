--[[---------------------------------------------------------------------------
	Defines all global variables (used in Kux-CoreLib)
	REQIRE THIS file ONLY ONE TIME in lib/init.lua
--]]---------------------------------------------------------------------------


---@type "factorio"|"local" Gets the current environment
_G.evironment = "factorio"

---@type boolean Gets if the the current environment is factorio
_G.isFactorio = true

---@type boolean Gets if the the current environment is local
_G.isLocal = false

---@type string The path to the local factorio installation
_G.localFactorioPath = _G.localFactorioPath or nil

---@type string The path to the lualib folder
_G.lualibPath = "__core__/lualib/"

---@type boolean Gets if the current factorio version is 1.x
_G.isV1 = false

---@type boolean Gets if the current factorio version is 2.x
_G.isV2 = true

---@type table<string,string> The active mods
_G.mods = _G.mods or {}

if not KuxCoreLibPath or KuxCoreLibPath:match("^__") then
	require(lualibPath.."util") --require("__core__/lualib/")

	if(script) then -- control-stage
		mods = script.active_mods
	end
	isV1 = string.sub(mods["base"], 1, 2) == "1."
	isV2 = string.sub(mods["base"], 1, 2) == "2."
	isV10 = string.sub(mods["base"], 1, 4) == "1.0."
	isV11 = string.sub(mods["base"], 1, 4) == "1.1."
	isV20 = string.sub(mods["base"], 1, 4) == "2.0."
else
	evironment = "local"
	isFactorio = false
	isLocal = true

	--fallback if localFactorioPath is not set
	if not localFactorioPath then
		--_G.localFactorioPath = "E:/Program Files/Factorio/1.1/"
		localFactorioPath = "E:/Program Files/Factorio/2.0/2.0/"
	end
	lualibPath = localFactorioPath.."data/core/lualib/"

	dofile(lualibPath.."util.lua")

	isV1 = false
	isV10 = false
	isV10 = false
	isV2 = true
	isV20 = true

	_G.mods = { --local mock
		["base"] = "2.0.0",
		["Kux-CoreLib"] = "3.0.0"
	}
end

if(script)then

	---Gets a value indicating wether `value` is a table or userdata
	---@param value any
	---@param object_name string? The object_name to check for
	---@return boolean
	---@overload fun(value:any):boolean
	---@overload fun(value:any, object_name:string):boolean
	function _G.is_obj(value, object_name)
		local t = type(value)
		local isO = t == "table" or t == "userdata"
		if object_name then return isO and value.object_name == object_name
		else return isO end
	end

	local function getLuaObject(var, object_name, prop)
		local type = type(var)
		local t = object_name == "LuaPlayer" and game.players
			or object_name == "LuaPlayer" and game.players
			or object_name == "LuaSurface" and game.surfaces
			or object_name == "LuaForce" and game.forces
			or error("Invalid object_name: "..object_name)

		local obj = type=="string" and t[var]
			or type=="number" and t[var]
			or type=="userdata" and var["object_name"]==object_name and var
			or error("Invalid input: "..serpent.block(var))
		if not obj.valid then error("Invalid "..object_name) end
		if prop == nil then return obj end
		return obj[prop]
	end

	---@alias LuaPlayerId integer|string|LuaPlayer
	---@alias LuaSurfaceId integer|string|LuaSurface
	---@alias LuaForceId integer|string|LuaForce

	---@param var LuaPlayerId
	---@return string
	function _G.getPlayerName(var) return getLuaObject(var, "LuaPlayer", "name")--[[@as string]] end

	---@param var LuaPlayerId
	---@return LuaPlayer
	function _G.getPlayer(var) return getLuaObject(var, "LuaPlayer", nil)--[[@as LuaPlayer]] end

	---@param var LuaSurfaceId
	---@return string
	function _G.getSurfaceName(var) return getLuaObject(var, "LuaSurface", "name")--[[@as string]] end

	---@param var LuaSurfaceId
	---@return LuaSurface
	function _G.getSurface(var) return getLuaObject(var, "LuaSurface", nil)--[[@as LuaSurface]] end

	---@param var LuaForceId
	---@return string
	function _G.getForceName(var) return getLuaObject(var, "LuaForce", "name")--[[@as string]] end

	---@param var LuaForceId
	---@return LuaForce
	function _G.getForce(var) return getLuaObject(var, "LuaForce", nil)--[[@as LuaForce]] end
end


