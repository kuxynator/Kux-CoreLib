--Usage: local ptu = require(KuxCoreLib.prototypeUtils)

local prototypeUtils = {
	tableName = "prototypeUtils",
	guid      = "{7266BC62-B6AE-4DF7-8D52-B16ED45EC4C9}",
	origin    = "Kux-CoreLib/lib/prototypeUtils.lua"
}

---@deprecated
prototypeUtils.setResults = RecipeData.setResults

---@deprecated
prototypeUtils.cloneEntity = EntityData.clone

---@deprecated
prototypeUtils.clone = ItemData.clone

---@deprecated
prototypeUtils.cloneRecipe = RecipeData.clone

---@deprecated
prototypeUtils.cloneTechnology = TechnologyData.clone

---@deprecated
prototypeUtils.setIconTint = PrototypeData.setIconTint

---@deprecated
prototypeUtils.ingredientsFactor = RecipeData.ingredientsFactor

---@deprecated
prototypeUtils.recipeFactor = RecipeData.recipeFactor

---@deprecated
prototypeUtils.energyFactor = PrototypeData.energyFactor

---@deprecated
prototypeUtils.energyUsageFactor = PrototypeData.energyUsageFactor

return prototypeUtils