if TechnologyData then
    if TechnologyData.__guid == "{5789A09A-2D34-40CA-80EB-7A3A81DD1201}" then return TechnologyData end
    error("A global TechnologyData class already exist.")
end

---@class TechnologyData
TechnologyData = {
	__class  = "Dictionary",
	__guid   = "{5789A09A-2D34-40CA-80EB-7A3A81DD1201}",
	__origin = "Kux-CoreLib/lib/data/TechnologyIndex.lua",
}

KuxCoreLib = KuxCoreLib or require("__Kux_CoreLib__/init")
local Table = require(KuxCoreLib.Table)--[[@as Table]]

---@deprecated
Technology=TechnologyData

function TechnologyData.clone(name, newName)
	local base = data.raw["technology"][name]
	if(not base) then error("Prototype not found: "..name.." (tyoe: technology)") end
	local technology = table.deepcopy(base)
	technology.name = newName
	--technology.localised_name = {"recipe-name."..newName}
	return technology
end

---Remove prerequisites
---@param technology Technology
---@param name string
function TechnologyData.removePrerequisites(technology, name)
	local i = Table.indexOf(technology.prerequisites, name)
	if(i>0) then table.remove(technology.prerequisites,i) end
end

function TechnologyData.indexOfIngredient(technology, name)
	for i, v in ipairs(technology.unit.ingredients) do
		print(v[1] or v["name"])
		if(v[1] == name) then return i end
		if(v["name"]==name) then return i end
	end
	return 0
end

function TechnologyData.findIngredient(technology, name)
	for i, v in ipairs(technology.unit.ingredients) do
		print(v[1] or v["name"])
		if(v[1] == name) then return v end
		if(v["name"]==name) then return v end
	end
	return nil
end

function TechnologyData.removeIngredients(technology, name)
	local i = TechnologyData.indexOfIngredient(technology, name)
	if(i>0) then table.remove(technology.unit.ingredients,i) end
end

function TechnologyData.findByEffectsUnlockRecipe(recipe, findAll)
	local dicOfTechnologies = {}
	for _, tech in pairs(data.raw.technology) do
		for iEffect, effect in ipairs(tech.effects) do
			if(effect.type == "unlock-recipe" and effect.recipe == recipe) then
				if(not findAll) then return tech.name, iEffect end
				dicOfTechnologies[tech.name] = iEffect
			end
		end
	end
	return dicOfTechnologies
end

function TechnologyData.findByPrerequisites(prerequisite)
	local technologyNames = {}
	for _, tech in pairs(data.raw.technology) do
		local i = Table.indexOf(tech.prerequisites, prerequisite)
		if(i>0) then table.insert(technologyNames, tech.name) end
	end
	return technologyNames
end

function TechnologyData.findByIngredient(ingredient)
	local technologyNames = {}
	for _, tech in pairs(data.raw.technology) do
		for _, value in ipairs(tech.unit.ingredients) do
			if(value[1] == ingredient and (value[2] or 0)>0) then
				table.insert(technologyNames, tech.name)
			end
		end
	end
	return technologyNames
end

