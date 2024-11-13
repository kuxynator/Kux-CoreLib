--- Recipe class
-- @classmod Data.Recipe

local Data = require('__kry_stdlib__/stdlib/data/data')
local Table = require('__kry_stdlib__/stdlib/utils/table')

local Recipe = {
    __class = 'Recipe',
    __index = Data,
}

function Recipe:__call(recipe)
    local new = self:get(recipe, 'recipe')
    -- rawset(new, 'Ingredients', {})
    -- rawset(new, 'Results', {})
    return new
end
setmetatable(Recipe, Recipe)

--- Remove an ingredient from an ingredients table.
-- @tparam table ingredients
-- @tparam string name Name of the ingredient to remove
local function remove_ingredient(ingredients, name)
    for i, ingredient in pairs(ingredients or {}) do
        if ingredient[1] == name or ingredient.name == name then
            table.remove(ingredients, i)
            return true
        end
    end
end

--- Replace an ingredient.
-- @tparam table ingredients
-- @tparam string find ingredient to replace
-- @tparam concepts.ingredient replace
-- @tparam boolean replace_name_only Don't replace amounts
local function replace_ingredient(ingredients, find, replace, replace_name_only)
    for i, ingredient in pairs(ingredients or {}) do
        if ingredient.name == find then
            if replace_name_only then
                local amount = ingredient.amount
                replace.amount = amount
            end
            ingredients[i] = replace
            return true
        end
    end
end

--- Remove a product from results table.
-- @tparam table results
-- @tparam string name Name of the product to remove
local function remove_result(results, name)
    name = name.name
    for i, product in pairs(results or {}) do
        if product[1] == name or product.name == name then
            table.remove(results, i)
            return true
        end
    end
end

--- Replace a product.
-- @tparam table results
-- @tparam string find product to replace
-- @tparam concepts.product product replace
-- @tparam boolean replace_name_only Don't replace amounts
local function replace_result(results, find, replace)
    for i, product in pairs(results or {}) do
        if product[1] == find or product.name == find then
            results[i] = replace
            return true
        end
    end
end

--- Add a new ingredient to a recipe.
-- @tparam string|Concepts.ingredient ingredient Name or table to add
-- @tparam[opt] number count Amount of ingredient
-- @treturn Recipe
function Recipe:add_ingredient(ingredient, count)
    if self:is_valid() then
		if type(ingredient)=="string" then
			local count = count or 1
			if type(count)=="boolean" then -- error handling for outdated mods
				count = 1 
			end
			ingredient = {type="item",name=ingredient,amount=count}
		end
        if self.ingredients then
			local original_amount = false	-- prevent duplicate entries
			for _, ingred in pairs(self.ingredients) do
				if ingred.name == ingredient.name then
					original_amount = ingred.amount
				end
			end
			if original_amount then
				ingredient.amount = ingredient.amount + original_amount
				self:replace_ingredient(ingredient.name,ingredient)
			else
				table.insert(self.ingredients,ingredient)
			end
        end
    end
    return self
end
Recipe.add_ing = Recipe.add_ingredient

--- Remove one ingredient completely.
-- @tparam string ingredient Name of ingredient to remove
-- @treturn Recipe
function Recipe:remove_ingredient(ingredient)
    if self:is_valid() then
        if self.ingredients then
            remove_ingredient(self.ingredients, ingredient)
        end
    end
    return self
end
Recipe.rem_ing = Recipe.remove_ingredient

--- Replace one ingredient with another.
-- @tparam string replace Name of ingredient to be replaced
-- @tparam string|Concepts.ingredient ingredient Name or table to add
-- @tparam[opt] number count Amount of ingredient
-- @treturn Recipe
function Recipe:replace_ingredient(replace, ingredient, count)
    assert(replace, 'Missing recipe to replace')
    if self:is_valid() then
		local replace_name_only = false
		if type(ingredient)=="string" and count then
			ingredient = {name=ingredient,amount=count,type="item"}
		elseif type(ingredient)=="string" then
			replace_name_only = true
			ingredient = {name=ingredient,amount=1,type="item"}
		end
		if self.ingredients then
            replace_ingredient(self.ingredients, replace, ingredient, replace_name_only)
        end
    end
    return self
end
Recipe.rep_ing = Recipe.replace_ingredient

--- Removes all ingredients from recipe completely.
-- @treturn self
function Recipe:clear_ingredients()
    if self:is_valid() then
		self.ingredients = {}
    end
    return self
end

--- Copies ingredients from one recipe to another.
-- @tparam string recipe Name of the recipe to copy ingredients from
-- @tparam[opt] boolean keep_ingredients Whether to keep the original ingredients
-- @treturn self
function Recipe:copy_ingredients(recipe, keep_ingredients)
	if self:is_valid() then
		local recipe = Recipe(recipe)
		if recipe:is_valid() then
			if not keep_ingredients then
				self:clear_ingredients()
			end
			for _, ingredient in pairs(recipe:get_ingredients()) do
				self:add_ingredient(ingredient)
			end
		end
	end
    return self
end

--- Shorthand to get ingredient table associated with recipe.
-- @treturn table Ingredients
function Recipe:get_ingredients()
    if self:is_valid() then
		return table.deepcopy(self.ingredients)
    end
end

--- Multiplies the amount of each ingredient in a recipe.
-- @tparam number mult Amount to multiply each ingredient by
-- @treturn self
function Recipe:multiply_ingredients(mult)
	if self:is_valid() then
		if self.ingredients then
			for _, ingred in pairs(self.ingredients) do
				ingred.amount = mult*ingred.amount
			end
		end
	end
	return self
end

--- Change the recipe category.
-- @tparam string category_name The new crafting category
-- @treturn self
function Recipe:change_category(category_name)
    if self:is_valid() then
        local Category = require('__kry_stdlib__/stdlib/data/category')
        self.category = Category(category_name, 'recipe-category'):is_valid() and category_name or self.category
    end
    return self
end
Recipe.set_category = Recipe.change_category

--- Add to technology as a recipe unlock.
-- @tparam string tech_name Name of the technology to add the unlock too
-- @treturn self
function Recipe:add_unlock(tech_name)
    if self:is_valid() then
        local Tech = require('__kry_stdlib__/stdlib/data/technology')
        Tech.add_effect(self, tech_name) --self is passed as a valid recipe
    end
    return self
end

--- Remove the recipe unlock from the technology.
-- @tparam string tech_name Name of the technology to remove the unlock from
-- @treturn self
function Recipe:remove_unlock(tech_name)
    if self:is_valid('recipe') then
        local Tech = require('__kry_stdlib__/stdlib/data/technology')
        Tech.remove_effect(self, tech_name, 'unlock-recipe')
    end
    return self
end

-- Locate the first technology that unlocks recipe, and adds this recipe to that technology
function Recipe:copy_unlock(recipe)
	if self:is_valid() then
        local Tech = require('__kry_stdlib__/stdlib/data/technology')
		local originalTech = ""
		-- Locate the originalTech for recipe
		for _, tech in pairs(data.raw.technology) do
			if tech.effects and (not string.find(tech.name, "demo-")) then
				for _, effect in pairs (tech.effects) do
					if recipe == effect.recipe then
						originalTech = tech.name
						break
					end
				end
			end
		end
		--Then add this recipe to originalTech
		if Tech(originalTech):is_valid() then
			self:add_unlock(originalTech)
		else
			self:set_enabled(true)	-- assume no tech, so should be enabled from start
		end
	end
end

--- Set the enabled status of the recipe.
-- @tparam boolean enabled Enable or disable the recipe
-- @treturn self
function Recipe:set_enabled(enabled)
    if self:is_valid() then
        self.enabled = enabled
    end
    return self
end

--- Set the main product of the recipe.
-- @tparam string main_product
-- @treturn self
function Recipe:set_main_product(main_product)
    if self:is_valid('recipe') then
		local Item = require('__kry_stdlib__/stdlib/data/item')
		if Item(main_product):is_valid() then
			self.main_product = main_product
		end
    end
    return self
end

--- Remove the main product of the recipe.
-- @treturn self
function Recipe:remove_main_product()
    if self:is_valid('recipe') then
        self.main_product = ""
    end
    return self
end

--- Add a new product to results table.
-- @tparam string|Concepts.product product Name or table to add
-- @tparam[opt] number count Amount of product
-- @treturn Recipe
function Recipe:add_result(product, count)
    if self:is_valid() then
		if type(product)=="string" then
			local count = count or 1
			product = {type="item",name=product,amount=count}
		end
        if self.results then
			table.insert(self.results,product)
        end
    end
    return self
end

--- Remove a product from results table.
-- @tparam string|Concepts.product product Name or table to add
-- @treturn Recipe
function Recipe:remove_result(product)
    if self:is_valid() then
        if self.results then
            remove_result(self.results, product)
        end
    end
    return self
end

--- Replace a product from results with a new product.
-- @tparam string replace Name of product to be replaced
-- @tparam string|Concepts.product product Name or table to add
-- @tparam[opt] number count Amount of product
-- @treturn Recipe
function Recipe:replace_result(replace, product, count)
    if self:is_valid() then
		if type(product)=="string" then
			product = {name=product,amount=1,type="item"}
		end
		if self.results then
            replace_result(self.results, replace, product)
        end
    end
    return self
end

--- Removes all results from recipe completely.
-- @treturn self
function Recipe:clear_results()
    if self:is_valid() then
		self.results = {}
    end
    return self
end

--- Copies results from one recipe to another.
-- @tparam string recipe Name of the recipe to copy results from
-- @tparam[opt] boolean keep_results Whether to keep the original results
-- @treturn self
function Recipe:copy_results(recipe, keep_results)
	if self:is_valid() then
		local recipe = Recipe(recipe)
		if recipe:is_valid() then
			if not keep_results then
				self:clear_results()
			end
			for _, result in pairs(recipe:get_results()) do
				self:add_result(result)
			end
		end
	end
    return self
end

--- Shorthand to get results table associated with recipe.
-- @treturn table Results
function Recipe:get_results()
    if self:is_valid() then
		return self["results"]
    end
end

--- Removes all surface conditions from recipe completely.
-- @treturn self
function Recipe:clear_surface_conditions()
    if self:is_valid() then
		self.surface_conditions = {}
    end
    return self
end
return Recipe