


local function scale_point(point, scale)
	if not point then return nil end
	if point.x then
		local x = point.x or error("Invalid point")
		local y = point.y or error("Invalid point")
		return {x = x * scale,y =  y * scale}
	elseif point[1] then
		local x = point[1] or error("Invalid point")
		local y = point[2] or error("Invalid point")
		return {x * scale, y * scale}
	else error("Invalid point") end
end

local function scale_rect(rect, scale)
	if not rect then return nil end
	if rect.left_top then
		local tl = rect.left_top or error("Invalid rect")
		local br = rect.right_bottom or error("Invalid rect")
		return { left_top =  scale_point(tl, scale), right_bottom = scale_point(br, scale)}
	elseif rect[1] then
		local tl = rect[1] or error("Invalid rect")
		local br = rect[2] or error("Invalid rect")
		return {scale_point(tl, scale), scale_point(br, scale)}
	else error("Invalid rect") end
end

---@param animation data.Animation
---@param scale number
---[View Documentation](https://lua-api.factorio.com/latest/types/Animation.html)
local function scale_Animation(animation, scale)
	if not animation then return end
	for _, layer in ipairs(animation.layers or {}) do
		scale_Animation(layer, scale)
	end
	animation.scale = (animation.scale or 1) * scale
	animation.shift = scale_point(animation.shift, scale)
end

---@param animation data.Animation|data.Animation4Way.struct
---@param scale number
---[View Documentation](https://lua-api.factorio.com/latest/types/Animation4Way.html)
local function scale_Animation4Way(animation, scale)
	if not animation then return end
	if not animation.north then return scale_Animation(animation --[[@as data.Animation]], scale) end
	scale_Animation(animation.north, scale)
	scale_Animation(animation.east, scale)
	scale_Animation(animation.south, scale)
	scale_Animation(animation.west, scale)
	scale_Animation(animation.north_east, scale)
	scale_Animation(animation.north_west, scale)
	scale_Animation(animation.south_east, scale)
	scale_Animation(animation.south_west, scale)
end

---@param sprite data.SpriteParameters
---@param scale number
---[View Documentation](https://lua-api.factorio.com/latest/types/SpriteParameters.html)
local function scale_SpriteParameters(sprite, scale)
	if not sprite then return end

	sprite.scale = (sprite.scale or 1) * scale
	sprite.shift = scale_point(sprite.shift, scale)
end

---@param sprite data.Sprite
---@param scale number
---[View Documentation](https://lua-api.factorio.com/latest/types/Sprite.html)
local function scale_Sprite(sprite, scale)
	if not sprite then return end

	sprite.scale = (sprite.scale or 1) * scale
	sprite.shift = scale_point(sprite.shift, scale)
end

---@param sheet data.SpriteNWaySheet
---@param scale number
---[View Documentation](https://lua-api.factorio.com/latest/types/SpriteNWaySheet.html)
local function scale_SpriteNWaySheet(sheet, scale)
	if not sheet then return end

	sheet.scale = (sheet.scale or 1) * scale
	sheet.shift = scale_point(sheet.shift, scale)
end

---@param sprite data.Sprite|data.Sprite4Way.struct
---@param scale number
---[View Documentation](https://lua-api.factorio.com/latest/types/Sprite4Way.html)
local function scale_Sprite4Way(sprite, scale)
	if not sprite then return end
	if not sprite.north then return scale_Sprite(sprite --[[@as data.Sprite]], scale) end
	scale_Sprite(sprite.north, scale)
	scale_Sprite(sprite.east, scale)
	scale_Sprite(sprite.south, scale)
	scale_Sprite(sprite.west, scale)
	scale_SpriteNWaySheet(sprite.sheet, scale)
	for _, value in ipairs(sprite.sheets) do
		scale_SpriteNWaySheet(value, scale)
	end
end

---@param sprite data.RotatedSprite
---@param scale number
---[View Documentation](https://lua-api.factorio.com/latest/types/RotatedSprite.html)
local function scale_RotatedSprite(sprite, scale)
	if sprite.layers then
		for _, layer in ipairs(sprite.layers) do
			scale_RotatedSprite(layer, scale)
		end
	else
		scale_SpriteParameters(sprite, scale) -- base
	end
	--TODO: frames :: array[RotatedSpriteFrame]
end

---@param value data.WorkingVisualisation
---@param scale number
---[View Documentation](https://lua-api.factorio.com/latest/types/WorkingVisualisation.html)
local function scale_WorkingVisualisation(value, scale)
	if not value then return end
	scale_Animation(value.animation, scale)
	scale_Animation(value.east_animation, scale)
	scale_Animation(value.north_animation, scale)
	scale_Animation(value.south_animation, scale)
	scale_Animation(value.west_animation, scale)
end

---
---@param graphics_set data.CraftingMachineGraphicsSet
---@param scale number
---[View Documentation](https://lua-api.factorio.com/latest/types/CraftingMachineGraphicsSet.html)
local function scale_CraftingMachineGraphicsSet(graphics_set, scale)
	if not graphics_set then return end
	scale_Animation4Way(graphics_set.animation, scale)
	scale_Animation4Way(graphics_set.idle_animation, scale)
	for _, value in ipairs(graphics_set.working_visualisations or {}) do
		scale_WorkingVisualisation(value, scale)
	end
end

-----------------------------------------------------------------------------------------------------------------------

local function calculate_fraction(decimal)
    local denominator = 1
    local numerator = decimal
    while math.floor(numerator) ~= numerator do numerator = numerator * 10; denominator = denominator * 10 end
    local function gcd(a, b) while b ~= 0 do a, b = b, a % b end return a end
    local divisor = gcd(numerator, denominator)
    return numerator / divisor, denominator / divisor
end

local function f(a, b)
    local numerator, denominator = calculate_fraction(b)
    return a * (numerator - 1 / denominator - 1)
end

---@param pt data.CraftingMachinePrototype
---@param pos TilePosition
---@return data.PipeConnectionDefinition?
---@return integer?
---@return data.FluidBox?
local function get_pipe_connection_by_pos(pt, pos)
	if not pt.fluid_boxes then return end
	for _, box in pairs(pt.fluid_boxes) do
		if not box.pipe_connections then goto next_box end
		for i, connection in pairs(box.pipe_connections) do
			local p = connection.position or {0,0}
			local px = p.x or p[1] or 0
			local py = p.y or p[2] or 0
			local posx = pos.x or pos[1] or 0
			local posy = pos.y or pos[2] or 0
			if px == posx and py == posy then
				return box.pipe_connections[i], i, box
			end
		end
		::next_box::
	end
end

---
---@param pt data.CraftingMachinePrototype
---@param pos TilePosition
local function remove_pipe_connection(pt, pos)
	local con, i, box = get_pipe_connection_by_pos(pt, pos)
	if not con or not box then return end
	table.remove(box.pipe_connections, i)
end

---
---@param pt data.CraftingMachinePrototype
---@param pos TilePosition
local function move_pipe_connection(pt, pos, new_pos)
	local con, i, box = get_pipe_connection_by_pos(pt, pos)
	if not con or not box then return end
	con.position = new_pos
end


---
---@param pt data.CraftingMachinePrototype
local function scale_pipe_connections(pt, original_size, target_size)
	--       5                   4                3            2        1
	-- -2 -1 0 1 2  ->  -1.5 -0.5 0.5 1.5  ->  -1 0 1  ->  -0.5 0.5  ->
	--  O    O   O                              O O O        O   O      O
	--                                          O   O        O   O      O
	--                                            O          O          O

end

-----------------------------------------------------------------------------------------------------------------------
local function scale_EntityPrototype(pt, scale)
	pt.collision_box = scale_rect(pt.collision_box, scale)
	pt.selection_box = scale_rect(pt.selection_box, scale)
	pt.hit_visualization_box = scale_rect(pt.hit_visualization_box, scale)
end

local function scale_EntityWithHealthPrototype(pt, scale)
	scale_EntityPrototype(pt, scale) --base

	scale_Sprite4Way(pt.integration_patch, scale)
end

local function scale_EntityWithOwnerPrototype(pt, scale)
	scale_EntityWithHealthPrototype(pt, scale) --base
end

local function scale_CraftingMachinePrototype(pt, scale)
	scale_EntityWithOwnerPrototype(pt, scale) --base

	scale_CraftingMachineGraphicsSet(pt.graphics_set, scale)
	scale_CraftingMachineGraphicsSet(pt.graphics_set_flipped, scale)
end

-----------------------------------------------------------------------------------------------------------------------

---@param pt data.FurnacePrototype
---@param scale number
---[View Documentation](https://lua-api.factorio.com/latest/prototypes/FurnacePrototype.html)
local function scale_Furnace(pt, scale)
	scale_CraftingMachinePrototype(pt, scale) -- base
end

---@param pt data.AssemblingMachinePrototype
---@param scale number
---[View Documentation](https://lua-api.factorio.com/latest/prototypes/AssemblingMachinePrototype.html)
local function scale_AssemblingMachine(pt, scale)
	scale_CraftingMachinePrototype(pt, scale) -- base
end

---@param pt data.RadarPrototype
---@param scale number
---[View Documentation](https://lua-api.factorio.com/latest/prototypes/RadarPrototype.html)
local function scale_Radar(pt, scale)
	scale_EntityWithOwnerPrototype(pt, scale) -- base

	scale_RotatedSprite(pt.pictures, scale)
	--TODO: scale_CircuitConnectorDefinition(pt.circuit_connector, scale)
end

-----------------------------------------------------------------------------------------------------------------------

---@param entity data.EntityPrototype
---@param scale number
local function scale(entity, scale)
	if not entity then return end
	if scale == 1 then return end
	assert(type(scale) == "number", "scale must be a number")

	---@diagnostic disable: param-type-mismatch
	if     entity.type == "furnace"            then scale_Furnace(entity, scale)
	elseif entity.type == "assembling-machine" then scale_AssemblingMachine(entity, scale)
	elseif entity.type == "radar"              then scale_Radar(entity, scale)
	else error("Unsupported entity type: " .. entity.type)
	end
	---@diagnostic enable: param-type-mismatch
end

return {
	scale = scale,
	pipes = {
		get_pipe_connection_by_pos = get_pipe_connection_by_pos,
		remove_pipe_connection = remove_pipe_connection,
		move_pipe_connection = move_pipe_connection,
		scale_pipe_connections = scale_pipe_connections,
	},
}
