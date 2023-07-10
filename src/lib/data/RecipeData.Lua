require((KuxCoreLibPath or "__Kux-CoreLib__/").."init")
if(KuxCoreLib.__modules.RecipeData) then return KuxCoreLib.__modules.RecipeData end

---@class KuxCoreLib.RecipeData
local RecipeData= {
	__class  = "RecipeData",
	__guid   = "{6B1DC373-2A83-4C81-94BD-92E772340FDE}",
	__origin = "Kux-CoreLib/lib/data/RecipeData.lua",
}
KuxCoreLib.__modules.RecipeData = RecipeData
---------------------------------------------------------------------------------------------------
RecipeData.clone = function(name, item)
	local base = data.raw["recipe"][name]
	if(not base) then error("Prototype not found: "..name.." (tyoe: recipe)") end
	local recipe = table.deepcopy(base)
	recipe.name = item.name
	recipe.localised_name = {"recipe-name."..item.name}
	RecipeData.setResults(recipe, {{amount = 1, name = item.name, type = "item"}})
	return recipe
end

RecipeData.setResults = function(recipe, results)
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

RecipeData.ingredientsFactor = function (ingredients, factor)
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

RecipeData.recipeFactor = function (recipe, factor)
	if(recipe.normal and recipe.normal~=false) then recipe.normal = RecipeData.ingredientsFactor(recipe.normal, factor) end
	if(recipe.expensive and recipe.expensive~=false) then recipe.expensive = RecipeData.ingredientsFactor(recipe.expensive, factor) end
	if(recipe.ingredients) then recipe.ingredients = RecipeData.ingredientsFactor(recipe.ingredients, factor) end
end

---------------------------------------------------------------------------------------------------

function RecipeData.asGlobal() return KuxCoreLib.utils.asGlobal(RecipeData) end

return RecipeData