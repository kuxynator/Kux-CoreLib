--Usage: local ptu = require(KuxCoreLib.prototypeUtils)

local prototypeUtils = {
	tableName = "prototypeUtils",
	guid      = "{7266BC62-B6AE-4DF7-8D52-B16ED45EC4C9}",
	origin    = "Kux-CoreLib/lib/prototypeUtils.lua"
}

prototypeUtils.setResults = function(recipe, results)
	if(recipe.normal) then
		recipe.normal.results = results
		recipe.normal.result = nil
		recipe.results = nil
		recipe.result = nil
		if(recipe.expensive) then
			recipe.expensive.results = results
			recipe.expensive.result = nil
		end
	else
		recipe.results = results
		recipe.result = nil
	end
end

prototypeUtils.cloneEntity = function(type,name,newName)
	local base = data.raw[type][name]
	if(not base) then error("Prototype not found: "..name.." (type: "..type..")") end
	local entity = table.deepcopy(base) or {}
	entity.name = newName
	if(entity.minable) then
		if entity.minable.results then

		elseif entity.minable.result then
			if(entity.minable.result == name) then entity.minable.result = newName end
		end
	end
	return entity
end

prototypeUtils.cloneItem = function(name, entity)
	local base = data.raw["item"][name]
	if(not base) then base = data.raw["item-with-entity-data"][name] end
	if(not base) then error("Prototype not found: "..name.." (tyoe: item|item-with-entity-data)") end
	local item = table.deepcopy(base)
	item.name = entity.name
	item.localised_name = {"item-name."..entity.name}
	item.place_result = entity.name
	return item
end

prototypeUtils.cloneRecipe = function(name, item)
	local base = data.raw["recipe"][name]
	if(not base) then error("Prototype not found: "..name.." (tyoe: recipe)") end
	local recipe = table.deepcopy(base)
	recipe.name = item.name
	recipe.localised_name = {"recipe-name."..item.name}
	prototypeUtils.setResults(recipe, {{amount = 1, name = item.name, type = "item"}})
	return recipe
end

prototypeUtils.cloneTechnology = function(name, newName)
	local base = data.raw["technology"][name]
	if(not base) then error("Prototype not found: "..name.." (tyoe: technology)") end
	local technology = table.deepcopy(base)
	technology.name = newName
	--technology.localised_name = {"recipe-name."..newName}
	return technology
end

prototypeUtils.setIconTint = function(item, tint)
	if(item.icons) then
		if(item.icons[1] and item.icons[1].tint==nil) then
			item.icons[1].tint = tint
		else
			log("WARNING could not tint the icon! "..item.type ..".".. item.name.."\n"..serpent.block(item))
		end
	elseif(item.icon) then
		item.icons = {{
			icon = item.icon,
			tint = tint
		}}
		item.icon = nil
	end
end

prototypeUtils.ingredientsFactor = function (ingredients, factor)
	if(not ingredients) then return nil end
	ingredients = table.deepcopy(ingredients) or {}

	--ingredients = {{type = "item", name = "iron-stick", amount = 2}, {type = "item", name = "iron-plate", amount = 3}}
	--ingredients = {{type="fluid", name="water", amount=50}, {type="fluid", name="crude-oil", amount=100}}
	-- ingredients = {{"iron-stick", 2}, {"iron-plate", 3}}
	for index, value in ipairs(ingredients) do
		if(value~=nil) then
			if(value.amount) then value.amount = value.amount * factor
			elseif(value[2]) then value[2] = value[2] * factor end
		end
	end
	return ingredients
end

prototypeUtils.recipeFactor = function (recipe, factor)
	if(recipe.normal and recipe.normal~=false) then recipe.normal = prototypeUtils.ingredientsFactor(recipe.normal, factor) end
	if(recipe.expensive and recipe.expensive~=false) then recipe.expensive = prototypeUtils.ingredientsFactor(recipe.expensive, factor) end
	if(recipe.ingredients) then recipe.ingredients = prototypeUtils.ingredientsFactor(recipe.ingredients, factor) end
end

prototypeUtils.energyFactor = function (value, factor)
	-- DOCU: https://wiki.factorio.com/Types/Energy
	local energy = tonumber(string.match(value, "%d+"))
	local unit = string.match(value, "%a+")
	energy = energy * factor -- TODO round
	return tostring(energy) .. unit
end

prototypeUtils.energyUsageFactor = function (entity, factor)
	-- DOCU: https://wiki.factorio.com/Prototype/CraftingMachine#energy_usage
	entity.energy_usage = prototypeUtils.energyFactor(entity.energy_usage, factor)
end

prototypeUtils.entityTypes={"arrow", "artillery-flare", "artillery-projectile", "beam", "character-corpse", "cliff", "corpse", "rail-remnants",
	"deconstructible-tile-proxy", "entity-ghost", "particle" --[[for migration, cannot be used]], "leaf-particle"--[[for migration, cannot be used]],
	"accumulator", "artillery-turret", "beacon", "boiler", "burner-generator", "character", "arithmetic-combinator", "decider-combinator", "constant-combinator",
	"container", "logistic-container", "infinity-container", "assembling-machine", "rocket-silo", "furnace", "electric-energy-interface", "electric-pole",
	"unit-spawner", "combat-robot", "construction-robot", "logistic-robot", "gate", "generator", "heat-interface", "heat-pipe", "inserter", "lab", "lamp",
	"land-mine", "linked-container", "market", "mining-drill", "offshore-pump", "pipe", "infinity-pipe", "pipe-to-ground", "player-port", "power-switch",
	"programmable-speaker", "pump", "radar", "curved-rail", "straight-rail", "rail-chain-signal", "rail-signal", "reactor", "roboport", "simple-entity-with-owner",
	"simple-entity-with-force", "solar-panel", "storage-tank", "train-stop", "linked-belt", "loader-1x1", "loader", "splitter", "transport-belt", "underground-belt",
	"turret", "ammo-turret", "electric-turret", "fluid-turret", "unit", "car", "artillery-wagon", "cargo-wagon", "fluid-wagon", "locomotive",
	"spider-vehicle", "wall", "fish", "simple-entity", "spider-leg", "tree", "explosion", "flame-thrower-explosion", "fire", "stream", "flying-text", "highlight-box",
	"item-entity", "item-request-proxy", "particle-source", "projectile", "resource", "rocket-silo-rocket", "rocket-silo-rocket-shadow",
	"smoke"--[[for migration, cannot be used]], "smoke-with-trigger", "speech-bubble", "sticker", "tile-ghost"}

return prototypeUtils