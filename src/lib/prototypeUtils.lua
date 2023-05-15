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
	if(not base) then error("Prototype not found: "..type.."/"..name) end
	local entity = table.deepcopy(base)
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
	if(not base) then error("Prototype not found: item/"..name) end
	local item = table.deepcopy(base)
	item.name = entity.name
	item.localised_name = {"item-name."..entity.name}
	item.place_result = entity.name
	return item
end

prototypeUtils.cloneRecipe = function(name, item)
	local base = data.raw["recipe"][name]
	if(not base) then error("Prototype not found: recipe/"..name) end
	local recipe = table.deepcopy(base)
	recipe.name = item.name
	recipe.localised_name = {"recipe-name."..item.name}
	prototypeUtils.setResults(recipe, {{amount = 1, name = item.name, type = "item"}})
	return recipe
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
	if(ingredients==nil) then return nil end
	ingredients = table.deepcopy(ingredients)

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

return prototypeUtils