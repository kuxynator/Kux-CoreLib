require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")
if(KuxCoreLib.__modules.Factorissimo) then return KuxCoreLib.__modules.Factorissimo end

---Provides array functions
---@class KuxCoreLib.Factorissimo
local Factorissimo = {
	__class  = "Factorissimo",
	__guid   = "b5a1824b-c824-474c-a87a-25e7288d7423",
	__origin = "Kux-CoreLib/lib/mods/Factorissimo.lua",
}
KuxCoreLib.__modules.Factorissimo = Factorissimo
---------------------------------------------------------------------------------------------------
---Provides Factorissimo in the global namespace
---@return KuxCoreLib.Factorissimo
function Factorissimo.asGlobal() return KuxCoreLib.utils.asGlobal(Factorissimo) end
---------------------------------------------------------------------------------------------------

---Gets the Factorissimo API
---@type Factorissimo.API
Factorissimo.api = require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/mods/Factorissimo-API") --[[@as Factorissimo.API]]

---Gets a value indicating whether surface is is a Factorissimo floor
---@param surface LuaSurface|string Surface or surface name
---@return boolean
function Factorissimo.isFactoryFloor(surface)
	local surface_name =
		type(surface) == "string" and surface or
		type(surface) == "table" and surface.name or
		error("Invalid surface type: " .. type(surface))

	return surface_name:match("Factory floor %d+") or surface_name:match("factory%-floor%-%d+")
end


local function find_rectangle_by_tile_match(factory, tile)
	for index, value in ipairs(factory.layout.rectangles) do
		if(value.tile == tile) then
			return value
		end
	end
	log("factory.layout.rectangles:\n"..serpent.block(factory.layout.rectangles))
	error("rectangle not found '"..tile.."'. see log for details.")
end

---@param factory Factorissimo.FactoryObject
---@param rect table
---@return BoundingBox
local function get_absolute_rectangle(factory, rect)
	local result = {
		left_top = {
			x = rect.x1 + factory.inside_x,
			y = rect.y1 + factory.inside_y,
		},
		right_bottom = {
			x = rect.x2 + factory.inside_x,
			y = rect.y2 + factory.inside_y,
		}
	}

	--add shorthands
	result.left_top[1]=result.left_top.x
	result.left_top[2]=result.left_top.y
	result.right_bottom[1]=result.right_bottom.x
	result.right_bottom[2]=result.right_bottom.y
	result[1]=result.left_top
	result[2]=result.right_bottom
	--TODO: revise. this is not a union

	return result
end

---Gets the factory floor rectangle for the factyory at the given position
---@param surface LuaSurface
---@param position MapPosition
---@return BoundingBox? #the factory floor rectangle or nil if not found
function Factorissimo.getFactoryFloorRect(surface, position)
	local factory = Factorissimo.api.find_surrounding_factory(surface, position)
	if(not factory) then error("not in a factory") end
	local rect = factory.layout.rectangles[2]
	assert(rect.tile:match("factory%-floor"), "not a floor rectangle")
	return get_absolute_rectangle(factory, rect)
end

---Gets the factory wall rectangle for the factyory at the given position
---@param surface LuaSurface
---@param position MapPosition
---@return BoundingBox? #the factory wall rectangle or nil if not found
function Factorissimo.getFactoryWallRect(surface, position)
	local factory = Factorissimo.api.find_surrounding_factory(surface, position)
	if(not factory) then error("not in a factory") end
	local rect = factory.layout.rectangles[1]
	assert(rect.tile:match("factory%-wall"), "not a wall rectangle")
	return get_absolute_rectangle(factory, rect)
end

---Gets the top level surface of an entity
---@param entity LuaEntity
---@return LuaSurface
function Factorissimo.getToplevelSurface(entity)
	if(not Factorissimo.isFactoryFloor(entity.surface)) then return entity.surface end
	while true do
		local factory = Factorissimo.api.find_surrounding_factory(entity.surface, entity.position)
		if(not factory) then return entity.surface end
		entity = factory.building
	end
end

---@deprecated use Factorissimo.getToplevelSurface
Factorissimo.get_toplevel_surface = Factorissimo.getToplevelSurface

return Factorissimo