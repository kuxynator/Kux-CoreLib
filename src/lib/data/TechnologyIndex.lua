if TechnologyIndex then
    if TechnologyIndex.__guid == "{88118D09-81A2-4CE6-AF80-309BCA5F4136}" then return TechnologyIndex end
    error("A global TechnologyIndex class already exist.")
end

-- https://wiki.factorio.com/Prototype/Technology

---@class TechnologyIndex
TechnologyIndex = {
	__class  = "Dictionary",
	__guid   = "{88118D09-81A2-4CE6-AF80-309BCA5F4136}",
	__origin = "Kux-CoreLib/lib/data/TechnologyIndex.lua",
}

TechnologyIndex.normal={
	effectsUnlockRecipe = {},
	ingredients = {},
	prerequisites = {}
}

TechnologyIndex.expensive={
	effectsUnlockRecipe = {},
	ingredients = {},
	prerequisites = {}
}

---dictionary of recipe_name → technology_name[]
---@type { [string]: string[] }
TechnologyIndex.effectsUnlockRecipe = TechnologyIndex.normal.effectsUnlockRecipe

---dictionary of ingredient_name → technology_name[]
---@type { [string]: string[] }
TechnologyIndex.ingredients = TechnologyIndex.normal.ingredients

---dictionary of prerequisite_name → technology_name[]
---@type {string: string[]}
TechnologyIndex.prerequisites = TechnologyIndex.normal.prerequisites

---Gets the data for the technology depending on mode
---@param technology Technology
---@param mode "normal"|"expensive"
---@return TechnologyData?
local function getData(technology, mode)
	if(technology.normal==nil and technology.expensive==nil) then
		return technology --[[@as TechnologyData]]
	end
	if(mode=="normal") then
		if(type(technology.normal)=="table") then
			return technology.normal --[[@as TechnologyData]]
		elseif(technology.normal==false) then
			return nil
		elseif(technology.normal==nil and type(technology.expensive)=="table") then
			return technology.expensive --[[@as TechnologyData]]
		else
			return nil -- configuration error
		end
	else
		if(type(technology.expensive)=="table") then
			return technology.expensive --[[@as TechnologyData]]
		elseif(technology.expensive==false) then
			return nil
		elseif(technology.expensive==nil and type(technology.normal)=="table") then
			return technology.normal --[[@as TechnologyData]]
		else
			return nil -- configuration error
		end
	end
end

local function build(mode)
    TechnologyIndex[mode].effectsUnlockRecipe = {}
    TechnologyIndex[mode].ingredients = {}
    TechnologyIndex[mode].prerequisites = {}

    for _, tech --[[@as TechnologyData]] in pairs(data.raw.technology) do
		local data = getData(tech,mode)
		if(not data) then goto next_tech end

        for _, effect in ipairs(data.effects or {}) do
            if(effect.type == "unlock-recipe") then
                ---@cast effect UnlockRecipeModifierPrototype
                local list = TechnologyIndex.effectsUnlockRecipe[effect.recipe] or {}
                if(#list==0) then TechnologyIndex.effectsUnlockRecipe[effect.recipe] = list end
                table.insert(list, tech.name)
            end
        end

        for _, ingredient in ipairs(data.unit.ingredients or {}) do
            if((ingredient[2] or 0)>0) then
                local list = TechnologyIndex.ingredients[ingredient[1]] or {}
                if(#list==0) then TechnologyIndex.ingredients[ingredient[1]] = list end
                table.insert(list, tech.name)
            end
        end

        for _, prerequisite in ipairs(data.prerequisites or {}) do
            local list = TechnologyIndex.prerequisites[prerequisite] or {}
            if(#list==0) then TechnologyIndex.prerequisites[prerequisite] = list end
            table.insert(list, tech.name)
        end
		::next_tech::
    end

end

---Builds the technology index
---@return TechnologyIndex
function TechnologyIndex.build()
    build("normal")
    build("expensive")
    return TechnologyIndex
end

return TechnologyIndex.build()