--[[---------------------------------------------------------------------------
	Defines all global variables (used in Kux-CoreLib)
	REQIRE THIS file ONLY ONE TIME in lib/init.lua
--]]---------------------------------------------------------------------------

--NOTE: KuxCoreLib.require.Xxy does not work here!

require("Kua")

---@class KuxCoreLib.Globals.private
local this = {}

-- ---@type mathlib
-- _G.math = math

---@type debug.kua
_G.debug = debug

---@type package
_G.package = package

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

---@type boolean Gets if the current factorio version is 2.0.x
_G.isV20 = false

---@type boolean Gets if the current factorio version is 2.1.x
_G.isV21 = true

---@type table<string,string> The active mods
_G.mods = _G.mods or {}

---@param version string
---@param compare string verison with operator ">=2.1"
---@return boolean
---@overload fun(compare:string):boolean compare with mods["base"]
function _G.isVersion(version, compare)
	if compare == nil then -- overload fun(compare:string):boolean
		compare = version
		version = (script and script.active_mods or mods)["base"]
	end

	if version == nil then return false end

	local op, target = compare:match("^(>=|<=|==|>|<)(.+)$")
	if not op then op = "=="; target = compare end

	local function split(v)
		local major, minor, patch = v:match("^(%d+)%.?(%d*)%.?(%d*)")
		return tonumber(major) or 0, tonumber(minor) or 0, tonumber(patch) or 0
	end

	local a1, a2, a3 = split(version)
	local b1, b2, b3 = split(target)

	local result = 0
	if     a1 ~= b1 then result = a1 < b1 and -1 or 1
	elseif a2 ~= b2 then result = a2 < b2 and -1 or 1
	elseif a3 ~= b3 then result = a3 < b3 and -1 or 1
	end

	if op == "==" then return result == 0 end
	if op == ">=" then return result >= 0 end
	if op == "<=" then return result <= 0 end
	if op == ">"  then return result > 0 end
	if op == "<"  then return result < 0 end

	error("Invalid version comparison: "..compare)
end

if not KuxCoreLibPath or KuxCoreLibPath:match("^__") then
	require(lualibPath.."util") --require("__core__/lualib/")

	if(script--[[control-stage]]) then mods = script.active_mods end

	isV1 = string.sub(mods["base"], 1, 2) == "1."
	isV2 = string.sub(mods["base"], 1, 2) == "2."
	isV10 = string.sub(mods["base"], 1, 4) == "1.0."
	isV11 = string.sub(mods["base"], 1, 4) == "1.1."
	isV20 = string.sub(mods["base"], 1, 4) == "2.0."
	isV21 = string.sub(mods["base"], 1, 4) == "2.1."
	isV20ge = isVersion(">=2.0.0")
	isV21ge = isVersion(">=2.1.0")
else -- local mock 2.1
	evironment = "local"
	isFactorio = false
	isLocal = true

	--fallback if localFactorioPath is not set
	if not localFactorioPath then
		--_G.localFactorioPath = "E:/Program Files/Factorio/1.1/"
		localFactorioPath = "E:/Program Files/Factorio/2.1/latest/"
	end
	lualibPath = localFactorioPath.."data/core/lualib/"
	dofile(lualibPath.."util.lua")
	_G.mods = { --local mock
		["base"] = "2.1.12",
		["Kux-CoreLib"] = "4.0.0"
	}
end


---@param value any
---@param enum table
---@return string|nil
function _G.getEnumName(value, enum)
	for name, val in pairs(enum) do
		if val == value then return name end
	end
	return nil
end

---A constant 'nil' function reference
_G.fnil = function()_="fid{00000000-0000-0000-0000-000000000000}" end

local tnil_mt = {
	__index=function (t,k) return k=="is_nil" and true or  k=="isNil" and true or nil end,
	__newindex=function () error("attempt to change a read-only object") end
}
---A constant 'nil' table reference
---@class tnil
---@field is_nil true
---@field isNil true
_G.tnil = setmetatable({}, tnil_mt)
if script then script.register_metatable("{a405b7de-019e-473f-80ef-26df77c00fcd}",tnil_mt) end

---Returns the type of te argument, coded as a string. The possible results of this function are "nil" (a string, not the value nil), "number", "string", "boolean", "table", "function", "thread", and "userdata".
---@param v any
---@return "boolean"|"function"|"nil"|"number"|"string"|"table"|"thread"|"userdata"
function typeof(v) return type(v) end

---Return the name of the argument
---@param v any
---@return string
---<p>The name depends on type: <br>
---for userdata from <code>__object_name</code>, <br>
---for tables from <code>__class</code>, <code>__class_name</code> or <code>__object_name</code> (in this order, first non nil), <br>
---for functions via <code>fname()</code>(require FunctionUtils). <br>
---or <code>nil</code> if no name is found.</p>
function nameof(v)
	local t = type(v)
	if t=="userdata" then return v.object_name end
	if t=="table" then return v.__class or v.__class_name or v.object_name or error("no name object") end
	if t=="function" and KuxCoreLib.__modules.FunctionUtils then return KuxCoreLib.__modules.FunctionUtils.nameof(v) or error("no name function") end
	error("invalid argument")
end

function seqpairs(t)
	local keys = {}
	local len = rawget(t, "__len")
	if type(len) == "number" then
		for i = 1, len do
			if t[i] ~= nil then keys[#keys+1] = i end
		end
	end
	for k in pairs(t) do
		if type(k) ~= "number" or (not len or k > len) then
			keys[#keys+1] = k
		end
	end

	table.sort(keys, function(a, b)
		local ta, tb = type(a), type(b)
		if ta == "number" and tb == "number" then return a < b end
		if ta == "number" then return true end
		if tb == "number" then return false end
		return tostring(a) < tostring(b)
	end)

	local i = 0
	return function()
		i = i + 1
		local k = keys[i]
		if not k then return nil end
		return k, t[k]
	end, t, nil
end

function numpairs(t)
	local keys = {}
	for k in pairs(t) do
		if type(k) == "number" and t[k] ~= nil then
			keys[#keys+1] = k
		end
	end
	table.sort(keys)
	local i = 0
	return function()
		i = i + 1
		local k = keys[i]
		if not k then return nil end
		return k, t[k]
	end, t, nil
end

function alphapairs(t)
	local keys = {}
	for k in pairs(t) do
		if type(k) == "string" and t[k] ~= nil then
			keys[#keys+1] = k
		end
	end
	table.sort(keys)
	local i = 0
	return function()
		i = i + 1
		local k = keys[i]
		if not k then return nil end
		return k, t[k]
	end, t, nil
end



-----------------------------------------------------------------------------------------------------------------------
--#region: runtime
-----------------------------------------------------------------------------------------------------------------------

if script then

	local RecipeWithQuality = require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/RecipeWithQuality")

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
	---@return string? error_message The reason why the result is nil
	local function getLuaObject(var, object_name, prop, returnNilOnError)
		if var == nil then
			local msg = "argument was nil"
			if returnNilOnError then return nil, msg else error(msg) end
		elseif is_obj(var, "LuaEntity") then ---@cast var LuaEntity
			if     object_name == "LuaEntity"  then var = var
			elseif object_name == "LuaSurface" then var = var.surface
			elseif object_name == "LuaForce"   then var = var.force
			elseif object_name == "LuaPlayer"  then var = var.last_user
			elseif object_name == "LuaRecipe"  then var = _G.getRecipeWithQualityFromEntity(var)
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
			local msg = "Invalid input: "..serpent.line(var)
			if returnNilOnError then return nil, msg else error(msg) end
		end
		if not obj.valid then
			local msg = "Invalid "..object_name
			if returnNilOnError then return nil, msg else error(msg) end
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

		---
	---@param obj string|number|LuaPlayer|LuaGui|LuaGuiElement|table|any
	---@return integer?
	_G.getPlayerIndex = function(obj)
		local t = type(obj)
		if t == "number" then return obj end
		if t == "string" then return game.players[obj].index end
		if t == "userdata" then
			if obj.object_name=="LuaPlayer" then return obj.index end
			if obj.object_name=="LuaGui" then return obj.player.index end
			if obj.object_name=="LuaGuiElement" then return obj.player_index end
		end
		if t == "table" then
			if obj.player_index then return obj.player_index end
			if obj.player then return obj.player.index end
		end
		return getPlayer(obj).index
		--error("Invalid player argument: "..serpent.block(player))
	end

	---@param var LuaPlayerId
	---@return LuaPlayer? player
	---@return string? error_message The error message if result is nil
	---@overload fun(var:{player_index:number}):LuaPlayer,string?
	---@overload fun(var:{player:LuaPlayer}):LuaPlayer,string?
	function _G.getPlayer(var) return getLuaObject(var, "LuaPlayer", nil) end

	---@param var LuaSurfaceId|LuaEntity|LuaPlayer|LuaPlanet
	---@return string
	---@return string? error_message The error message if result is nil
	function _G.getSurfaceName(var) return getLuaObject(var, "LuaSurface", "name") end

	---@param var LuaSurfaceId|LuaEntity|LuaPlayer|LuaPlanet
	---@return LuaSurface
	---@return string? error_message The error message if result is nil
	function _G.getSurface(var) return getLuaObject(var, "LuaSurface", nil) end

	---@param var LuaForceId|LuaEntity|LuaPlayer
	---@return string
	---@return string? error_message The error message if result is nil
	function _G.getForceName(var) return getLuaObject(var, "LuaForce", "name") end

	---@param var LuaForceId|LuaEntity|LuaPlayer
	---@return LuaForce
	---@return string? error_message The error message if result is nil
	function _G.getForce(var) return getLuaObject(var, "LuaForce", nil) end

	---@param var LuaRecipe|string|LuaEntity
	---@return string
	---@return string? error_message The error message if result is nil
	function _G.getRecipeName(var) return getLuaObject(var, "LuaRecipe", "name") end

	---@param var LuaRecipe|string|LuaEntity
	---@return LuaRecipe
	---@return string? error_message The error message if result is nil
	function _G.getRecipe(var) return getLuaObject(var, "LuaRecipe", nil) end

	-- getRecipe can not work in all case (string -> LuaRecipe) Which force is used?

	---@param entity LuaEntity
	---@return LuaRecipe? recipe
	---@return string? err
	function _G.getRecipeFromEntity(entity)
		if entity.type == "assembling-machine" or entity.type == "furnace" or entity.type == "rocket-silo" then
		-- 'get_recipe' can only be used if this is crafting-machine
			local recipe, quality_prototype = entity.get_recipe();
			if recipe then return recipe end
		end
		if entity.type == "furnace" then
		-- 'previous_recipe' can only be used if this is Furnace
			if not entity.previous_recipe then return nil end
			local r, err = this.RecipeID_to_LuaRecipe(entity.previous_recipe.name, entity.force)
			if not r then return nil,err end
			return r
		end
		return nil, "no recipe available. entity: "..entity.name .." ("..entity.type..")"
	end

		---@param entity LuaEntity
	---@return LuaRecipe?
	---@return LuaQualityPrototype?
	---@return string?
	function _G.getRecipeAndQualityFromEntity(entity)
		if entity.type == "assembling-machine" or entity.type == "furnace" or entity.type == "rocket-silo" then
		-- 'get_recipe' can only be used if this is crafting-machine
			local recipe, quality_prototype = entity.get_recipe();
			if recipe then return recipe, quality_prototype end
		end
		if entity.type == "furnace" then
		-- 'previous_recipe' can only be used if this is Furnace
			if not entity.previous_recipe then return nil end
			local r, err = this.RecipeID_to_LuaRecipe(entity.previous_recipe.name, entity.force)
			if not r then return nil,nil,err end
			local q, err = this.QualityID_to_LuaQualityPrototype(entity.previous_recipe.quality)
			if not q then return nil,nil,err end
			return r,q
		end
		return nil
	end

	---@param entity LuaEntity
	---@return KuxCoreLib.RecipeWithQuality?
	function _G.getRecipeWithQualityFromEntity(entity)
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

	---
	---@param recipeId RecipeID
	---@param force ForceID
	---@return LuaRecipe?
	---@return string?
	function this.RecipeID_to_LuaRecipe(recipeId, force)
		--RecipeID : LuaRecipePrototype|LuaRecipe|string
		local type = type(recipeId)
		local recipe_name
		if type=="nil" then return nil, "argument is nil"
		elseif type=="userdata" and recipeId.object_name=="LuaRecipe" then
			return recipeId
		elseif type=="string" then ---@cast recipeId string
			if not prototypes[recipeId] then error("recipe name not valid") end
			recipe_nae = recipeId
		elseif type=="userdata" and recipeId.object_name=="LuaQualityPrototype" then
			recipe_name = recipeId.name
		else
			return nil, "invalid argument"
		end

		force,err = getForce(force)
		if force == nil and _G.player~=nil then force=player.force end
		if not force then return nil, "no force available" end
		local r = force.recipes[recipe_name]
		if not r then return nil, "recipe not valid for force" end
		return r
	end

	---
	---@param qualityId QualityID
	---@return LuaQualityPrototype?
	---@return string? err
	function this.QualityID_to_LuaQualityPrototype(qualityId)
		-- QualityID :: LuaQualityPrototype | string
		local type = type(qualityId)
		if type=="nil" then return nil, "argument is nil"
		elseif type=="string" then return prototypes.quality[qualityId], prototypes.quality[qualityId]==nil and "quality not exists" or nil
		elseif type=="userdata" and qualityId.object_name=="LuaQualityPrototype" then return qualityId
		else return nil, "invalid argument" end
	end

	---
	---@param arg ElemID|Ingredient|Product|string|LuaEntity|LuaItem|LuaRecipe|LuaTechnology|LuaObject|RecipeInfo|SelectedPrototypeData
	---@param expected_type string? -- Can also contain multiple types separated by "|"
	---@return any
	---@return string? type
	function getPrototypeAndCategory(arg, expected_type)
		if not arg then return nil, nil end
		local name, types

		if _G.type(arg) == "userdata" then --[[@cast arg LuaObject]]
			if arg.object_name =="LuaEntity" then --[[@cast arg LuaEntity]]
				return arg.prototype, "entity"
			elseif arg.object_name =="LuaEntityPrototype" then --[[@cast arg LuaEntityPrototype]]
				return arg, "entity"
			elseif arg.object_name =="LuaItem" then --[[@cast arg LuaItem]]
				return arg.prototype, "item"
			elseif arg.object_name =="LuaItemPrototype" then --[[@cast arg LuaItemPrototype]]
				return arg, "item"
			elseif arg.object_name =="LuaRecipe" then --[[@cast arg LuaRecipe]]
				return arg.prototype, "recipe"
			elseif arg.object_name =="LuaRecipePrototype" then --[[@cast arg LuaRecipePrototype]]
				return arg, "recipe"
			elseif arg.object_name =="LuaTechnology" then --[[@cast arg LuaTechnology]]
				return arg.prototype, "technology"
			elseif arg.object_name =="LuaTechnologyPrototype" then --[[@cast arg LuaTechnologyPrototype]]
				return arg, "technology"
			else
				error("Invalid argument. object_name="..arg.object_name)
			end
		elseif _G.type(arg) == "table" then
			if arg["__class"] == "RecipeInfo" then --[[@cast arg RecipeInfo]]
				return arg.prototype, "recipe"
			else
				name = arg.name or arg["value"] or error("Invalid argument: missing name")
				types = { arg.type or arg.base_type or error("Invalid argument: missing type") }
			end

		elseif _G.type(arg) == "string" then
			name = arg
			if not expected_type then error("Missing expected_type for string argument") end
			-- Zerlege den expected_type-String in eine Liste von Typen
			types = {}
			for t in expected_type:gmatch("[^|,%s/]+") do table.insert(types, t) end
		else
			error("Invalid argument type")
		end

		-- Check all specified types in the given order
		for _, type in ipairs(types) do
			local t = prototypes[type]
			if t then
				local prototype = t[name]
				if prototype then
					return prototype, type
				end
			end
		end

		error("Invalid name or type not found")
	end

	rawset(_G, "toElemID", function(arg)
		-- do simple coversion only. for full conversion we need ElementUtils
		if type(arg)=="nil" then return nil end
		if type(arg)=="string" and prototypes.item[arg] then return {name = arg, type="item"} end
		if type(arg)=="table" then
			local elemID = {
				name = type(arg.name)=="string" and arg.name or arg.name.name,
				type = arg.type or "item",
				quality = toQualityName(arg.quality)
			}
			if prototypes[elemID.type][elemID.name] then return elemID end
		end
		error("ElementUtils must be required before use toElemID")
	end)

	---
	---@param a any
	---@param b any
	---@param inclQuality boolean?
	---@return boolean
	---TODO: quality is not fully supported
	function _G.eqElemID(a, b, inclQuality)
		if a == nil and b == nil then return true end
		a = toElemID(a)
		b = toElemID(b)
		if a == nil and b == nil then return true end
		if a == nil or b == nil then return false end
		if inclQuality then return
			a.type == b.type and
			a.name == b.name and
			(a.quality or "normal") == (b.quality or "normal")
		else return a.type == b.type and a.name == b.name end
	end

	---
	---@param arg string?
	---@return string?
	function _G.toQualityName(arg)
		if arg==nil then return nil end
		if type(arg)=="string" then verifyQualityName(arg) return arg end
	end

	---@param quality string?
	---@return string?
	function _G.verifyQualityName(quality)
		if not prototypes.quality[quality] then error("unknown quality "..str(quality)) end
		return quality
	end

	---Gets ta valid sprite
	---@param arg string|{name:string, type:string?}|SpritePath
	---@param fallback true|SpritePath|nil
	---@return SpritePath?
	function _G.getSprite(arg, fallback)
		if type(arg)=="table" and arg.name then
			local sprite = (arg.type or "item").."/" .. arg.name
			if helpers.is_valid_sprite_path(sprite) then return sprite end
		end
		if type(arg)=="string" and helpers.is_valid_sprite_path(arg) then return arg end
		if type(arg)=="string" then
			local paths = { "item/", "fluid/", "recipe/", "entity/", "virtual-signal/" }
			for _, prefix in ipairs(paths) do
				local sprite = prefix .. arg
				if helpers.is_valid_sprite_path(sprite) then return sprite end
			end
		end
		if type(fallback)=="string" and helpers.is_valid_sprite_path(fallback) then return fallback end
		if fallback == true then return "utility/questionmark" end
		return nil
	end

	---Sets the last error (added by KuxCoreLib)
	---@param msg string
	---@param data table<string,AnyBasic>?
	---@return nil
	function debug.setLastError(msg, data)
		debug.lastError = {---@type DebugErrorInfo
			message = msg,
			data = data or {},
			trace = debug.traceback("", 2),
			tick = game.tick,
		}
		return nil
	end
	_G.setLastError = debug.setLastError

	---Gets the last error (added by KuxCoreLib)
	---@return DebugErrorInfo
	function debug.getLastError()
		return debug.lastError
	end
	_G.getLastError = debug.getLastError

end -- runtime

---@class DebugErrorInfo
---       ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
---@field message string
---@field data table<string,AnyBasic>
---@field trace string
---@field tick number game.tick


---@class debug.kua : debug
---       ‾‾‾‾‾‾‾‾‾‾
---@field lastError DebugErrorInfo
---@field setLastError fun(msg: string, data?: table): nil
---@field getLastError fun(): DebugErrorInfo