require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---Provides generic wrapper for all LuaXYZPrototype objects
---@class KuxCoreLib.LuaGenericPrototype.static : KuxCoreLib.Class
---@field asGlobal fun():KuxCoreLib.LuaGenericPrototype.static
local LuaGenericPrototype = {
	__class  = "KuxCoreLib.LuaGenericPrototype.static",
	__guid   = "c4e0734d-c035-41c4-b03f-7a3341d23739",
	__origin = "Kux-CoreLib/lib/LuaGenericPrototype.lua",
}
if KuxCoreLib.__classUtils.cache(LuaGenericPrototype) then return KuxCoreLib.__classUtils.cached end

-----------------------------------------------------------------------------------------------------------------------

local mt = {}

-----------------------------------------------------------------------------------------------------------------------
---#region: instance implementation
-----------------------------------------------------------------------------------------------------------------------

---@class KuxCoreLib.LuaGenericPrototype : LuaEntityPrototype, LuaItemPrototype, LuaFluidPrototype, LuaEquipmentPrototype, LuaTilePrototype, LuaDecorativePrototype, LuaVirtualSignalPrototype
---@field public __class "KuxCoreLib.LuaGenericPrototype"
---@field public tags table<string, string|number|boolean|table>
---@field private __base LuaEntityPrototype|LuaItemPrototype|LuaFluidPrototype|LuaEquipmentPrototype|LuaTilePrototype|LuaDecorativePrototype|LuaVirtualSignalPrototype
local instance_impl = {
	__class = "KuxCoreLib.LuaGenericPrototype",
	__base = nil,
	category = nil, ---@type string|nil gets the category of the prototype (e.g. "item", "entity", "fluid", etc.)
}

-----------------------------------------------------------------------------------------------------------------------
---#region: meta table implementation
-----------------------------------------------------------------------------------------------------------------------

mt.__index = function(t, k)
	return instance_impl[k] or t.__base[k]
end

mt.__newindex = function(t, k, v)
	if k == "__class" then error("Member access violation. Field '..k..' is write-protected.") end
	t.__base[k] = v
end

script.register_metatable("KuxCoreLib.LuaGenericPrototype.metatable", mt)

-----------------------------------------------------------------------------------------------------------------------
---#region: static implementation
-----------------------------------------------------------------------------------------------------------------------

local object_name_to_category = {
	LuaEntity = "entity",
	LuaEntityPrototype = "entity",
	LuaItem = "item",
	LuaItemPrototype = "item",
	LuaFluid = "fluid",
	LuaFluidPrototype = "fluid",
	LuaRecipe = "recipe",
	LuaRecipePrototype = "recipe",
	LuaTechnology = "technology",
	LuaTechnologyPrototype = "technology",
	LuaEquipment = "equipment",
	LuaEquipmentPrototype = "equipment",
	LuaTile = "tile",
	LuaTilePrototype = "tile",
	LuaDecorativePrototype = "decorative",
	LuaVirtualSignalPrototype = "virtual_signal",
	LuaParticlePrototype = "particle",
	LuaAutoplaceControlPrototype = "autoplace_control",
	LuaModSettingPrototype = "mod_setting",
	LuaCustomInputPrototype = "custom_input",
	LuaAmmoCategoryPrototype = "ammo_category",
	LuaNamedNoiseExpression = "named_noise_expression",
	LuaNamedNoiseFunction = "named_noise_function",
	LuaGroup = "item_group",
	LuaFuelCategoryPrototype = "fuel_category",
	LuaResourceCategoryPrototype = "resource_category",
	LuaAchievementPrototype = "achievement",
	LuaModuleCategoryPrototype = "module_category",
	LuaEquipmentCategoryPrototype = "equipment_category",
	LuaTrivialSmokePrototype = "trivial_smoke",
	LuaShortcutPrototype = "shortcut",
	LuaRecipeCategoryPrototype = "recipe_category",
	LuaQualityPrototype = "quality",
	LuaSurfacePropertyPrototype = "surface_property",
	LuaSpaceLocationPrototype = "space_location",
	LuaSpaceConnectionPrototype = "space_connection",
	LuaCustomEventPrototype = "custom_event",
	LuaActiveTriggerPrototype = "active_trigger",
	LuaAsteroidChunkPrototype = "asteroid_chunk",
	LuaCollisionLayerPrototype = "collision_layer",
	LuaAirbornePollutantPrototype = "airborne_pollutant",
	LuaBurnerUsagePrototype = "burner_usage",
	LuaSurfacePrototype = "surface",
	LuaProcessionPrototype = "procession",
	LuaProcessionLayerInheritanceGroupPrototype = "procession_layer_inheritance_group"
}

local function get_category(pt)
	if _G.type(pt) == "userdata" then --[[@cast pt LuaObject]]
		assert(pt.object_name~=nil, "Invalid argument. userdata without object_name.")
		return object_name_to_category[pt.object_name]
				or error("Invalid argument. object_name="..pt.object_name)
	else
		error("Invalid argument. "..type(pt))
	end
end

---@param pt LuaEntityPrototype|LuaItemPrototype|LuaFluidPrototype|LuaEquipmentPrototype|LuaTilePrototype|LuaDecorativePrototype|LuaVirtualSignalPrototype
---@param category string|nil
function LuaGenericPrototype.new(pt, category)
	local obj = {
		__base = pt,
		category = category or get_category(pt),
		tags = {}
	}
	setmetatable(obj, mt)
	return obj
end

-----------------------------------------------------------------------------------------------------------------------
return LuaGenericPrototype