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

	local RecipeWithQuality = require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/RecipeWithQuality")

	---@param entity LuaEntity
	---@return KuxCoreLib.RecipeWithQuality?
	function __getRecipe(entity)
		-- 'get_recipe' can only be used if this is crafting-machine
		-- 'previous_recipe' can only be used if this is Furnace

		-- try get_recipe for (crafting-machine->) assembling-machine|furnace|rocket-silo
		if entity.type == "assembling-machine" or entity.type == "furnace"  or entity.type == "rocket-silo" then
			local r,qp = entity.get_recipe();
			if r then return RecipeWithQuality.new(r,qp) end
		end

		--fallback: try previous_recipe for furnace
		if entity.type == "furnace" then
			local pri = entity.previous_recipe --> RecipeIDAndQualityIDPair?
			if not pri then return nil end
			local force = getForce(entity.force)
			local r = entity.previous_recipe.name -- RecipeIDAndQualityIDPair.name ->  RecipeID:LuaRecipePrototype|LuaRecipe|string
			if type(r) == "string" then r = force.recipes[r]
			elseif type(r) ~= "userdata" then r = force.recipes[r.name]
			end
			local q = pri.quality
			if type(q) == "string" then q = prototypes.quality[q] end

			return RecipeWithQuality.new(r,q)
		end
		return nil
	end

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

	---@param var any
	---@param object_name "LuaPlayer"|"LuaSurface"|"LuaForce"|"LuaRecipe"
	---@param prop string?
	---@param returnNilOnError boolean?
	---@return any
	local function getLuaObject(var, object_name, prop, returnNilOnError)
		if is_obj(var, "LuaEntity") then ---@cast var LuaEntity
			if     object_name == "LuaEntity"  then var = var
			elseif object_name == "LuaSurface" then var = var.surface
			elseif object_name == "LuaForce"   then var = var.force
			elseif object_name == "LuaPlayer"  then var = var.last_user
			elseif object_name == "LuaRecipe"  then var = __getRecipe(var)
			else error("Invalid parameter") end
		elseif is_obj(var, "LuaPlayer") then ---@cast var LuaPlayer
			var =  object_name == "LuaPlayer"  and var
				or object_name == "LuaSurface" and var.surface
				or object_name == "LuaForce"   and var.force
				or var
		elseif is_obj(var, "LuaPlanet") then ---@cast var LuaPlanet
			var =  object_name == "LuaPlanet"  and var
				or object_name == "LuaSurface" and var.surface
				or error("Invalid parameter")
		elseif is_obj(var, "LuaRecipe") then ---@cast var LuaRecipe
			var =  object_name == "LuaRecipe"  and var
				or error("Invalid parameter")
		end

		local list = object_name == "LuaPlayer" and game.players
			or object_name == "LuaSurface" and game.surfaces
			or object_name == "LuaForce" and game.forces
			or object_name == "LuaRecipe" and prototypes.recipe
			or error("Invalid object_name: "..object_name)
		local type = type(var)

		local obj = type=="string" and list[var]
			     or type=="number" and list[var]
			     or type=="userdata" and var["object_name"]==object_name and var
			     or nil
		if not obj and type=="table" and object_name =="LuaPlayer" then
			local field_var = var.player_index or var.player
			if field_var then return getLuaObject(field_var, object_name, prop, returnNilOnError) end
		end
		if obj == nil then
			if returnNilOnError then return nil end
			error("Invalid input: "..serpent.block(var))
		end
		if not obj.valid then
			if returnNilOnError then return nil end
			error("Invalid "..object_name)
		end
		if prop == nil then return obj end
		return obj[prop]
	end

	---@alias LuaPlayerId integer|string|LuaPlayer
	---@alias LuaSurfaceId integer|string|LuaSurface
	---@alias LuaForceId integer|string|LuaForce

	---@param var LuaPlayerId --{player_index:number}|{player:LuaPlayer}
	---@return string
	function _G.getPlayerName(var) return getLuaObject(var, "LuaPlayer", "name")--[[@as string]] end

	---@param var LuaPlayerId
	---@return LuaPlayer
	---@overload fun(var:{player_index:number}):LuaPlayer
	---@overload fun(var:{player:LuaPlayer}):LuaPlayer
	function _G.getPlayer(var) return getLuaObject(var, "LuaPlayer", nil)--[[@as LuaPlayer]] end

	---@param var LuaPlayerId --{player_index:number}|{player:LuaPlayer}
	---@return LuaPlayer?
	function _G.getPlayerOrNil(var) return getLuaObject(var, "LuaPlayer", nil, true)--[[@as LuaPlayer?]] end

	---@param var LuaSurfaceId|LuaEntity|LuaPlayer|LuaPlanet
	---@return string
	function _G.getSurfaceName(var) return getLuaObject(var, "LuaSurface", "name")--[[@as string]] end

	---@param var LuaSurfaceId|LuaEntity|LuaPlayer|LuaPlanet
	---@return LuaSurface
	function _G.getSurface(var) return getLuaObject(var, "LuaSurface", nil)--[[@as LuaSurface]] end

	---@param var LuaSurfaceId|LuaEntity|LuaPlayer|LuaPlanet
	---@return LuaSurface?
	function _G.getSurfaceOrNil(var) return getLuaObject(var, "LuaSurface", nil, true)--[[@as LuaSurface?]] end

	---@param var LuaForceId|LuaEntity|LuaPlayer
	---@return string
	function _G.getForceName(var) return getLuaObject(var, "LuaForce", "name")--[[@as string]] end

	---@param var LuaForceId|LuaEntity|LuaPlayer
	---@return LuaForce
	function _G.getForce(var) return getLuaObject(var, "LuaForce", nil)--[[@as LuaForce]] end

	---@param var LuaForceId|LuaEntity|LuaPlayer
	---@return LuaForce?
	function _G.getForceOrNil(var) return getLuaObject(var, "LuaForce", nil, true)--[[@as LuaForce?]] end


	---@param var LuaRecipe|string|LuaEntity
	---@return string
	function _G.getRecipeName(var) return getLuaObject(var, "LuaRecipe", "name")--[[@as string]] end

	---@param var LuaRecipe|string|LuaEntity
	---@return LuaRecipe
	function _G.getRecipe(var) return getLuaObject(var, "LuaRecipe", nil)--[[@as LuaRecipe]] end

	---@param var LuaRecipe|string|nil|LuaEntity
	---@return LuaRecipe?
	function _G.getRecipeOrNil(var) return getLuaObject(var, "LuaRecipe", nil, true)--[[@as LuaRecipe?]] end

	-- getRecipe can not work in all case (string -> LuaRecipe) Which force is used?
end


