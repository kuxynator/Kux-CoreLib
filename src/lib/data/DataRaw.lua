require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---@class KuxCoreLib.DataRaw
local DataRaw ={
	__class  = "DataRaw",
	__guid   = "92023dde-c5de-476e-8ca5-85270e130774",
	__origin = "Kux-CoreLib/lib/data/DataRaw.lua",
}
if KuxCoreLib.__classUtils.cache(DataRaw) then return KuxCoreLib.__classUtils.cached end
---------------------------------------------------------------------------------------------------
-- TODO FACTORIO 2.0

--list generated by reading prototypes.entity
DataRaw.entityTypes={"container", "logistic-container", "linked-container", "storage-tank", "simple-entity-with-force",
"loader", "linked-belt", "transport-belt", "underground-belt", "inserter", "splitter", "loader-1x1",
"furnace", "pipe", "pipe-to-ground", "pump", "electric-pole", "constant-combinator", "curved-rail",
"straight-rail", "train-stop", "rail-signal", "rail-chain-signal", "locomotive", "cargo-wagon", "fluid-wagon",
"artillery-wagon", "assembling-machine", "car", "spider-vehicle", "logistic-robot", "construction-robot",
"roboport", "lamp", "decider-combinator", "arithmetic-combinator", "power-switch", "programmable-speaker",
"rocket-silo", "accumulator", "wall", "gate", "simple-entity", "heat-pipe", "boiler", "burner-generator",
"generator", "reactor", "solar-panel", "mining-drill", "offshore-pump", "beacon", "electric-energy-interface",
"lab", "land-mine", "ammo-turret", "electric-turret", "fluid-turret", "artillery-turret", "radar", "unit",
"turret", "unit-spawner", "simple-entity-with-owner", "infinity-container", "infinity-pipe", "heat-interface",
"player-port", "smoke-with-trigger", "resource", "combat-robot", "cliff", "character", "fish", "tree",
"corpse", "rail-remnants", "explosion", "projectile", "particle-source", "fire", "sticker", "stream",
"artillery-flare", "artillery-projectile", "character-corpse", "arrow", "spider-leg", "speech-bubble",
"deconstructible-tile-proxy", "flying-text", "flame-thrower-explosion", "beam", "entity-ghost", "highlight-box",
"item-entity", "item-request-proxy", "leaf-particle", "particle", "rocket-silo-rocket", "rocket-silo-rocket-shadow",
"smoke", "tile-ghost", "market"}

--- from docu
DataRaw.entityTypes2={"arrow", "artillery-flare", "artillery-projectile", "beam", "character-corpse", "cliff", "corpse", "rail-remnants",
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

--list generated by reading game.item_prototypes
DataRaw.itemTypes = {"item", "rail-planner", "item-with-entity-data", "spidertron-remote", "item-with-tags",
"selection-tool", "module", "capsule", "tool", "mining-tool", "repair-tool", "blueprint", "deconstruction-item",
"upgrade-item", "blueprint-book", "copy-paste-tool", "gun", "ammo", "armor", "item-with-inventory", "item-with-label"}

function DataRaw.createIndex()
    DataRaw.index={}

    DataRaw.index.entities={}
    for _,typeName in ipairs(DataRaw.entityTypes) do
        for entityName, entity in pairs(data.raw[typeName]) do
            DataRaw.index.entities[entityName]=entity
        end
    end

    DataRaw.index.items={}
    for _,typeName in ipairs(DataRaw.itemTypes) do
        for entityName, entity in pairs(data.raw[typeName]) do
            DataRaw.index.items[entityName]=entity
        end
    end
end

function DataRaw.deleteIndex()
    DataRaw.index=nil
end


---@class CustomInputTemplate : data.CustomInputPrototype
---@name string? name of the prototype. nil: auto
---@name_prefix boolean|string false: nor prefix, true: use mod.prefix, string: custom prefix
DataRaw.CustomInput_key_template={
	type="custom-input",
	name=nil,
	key_sequence="",
	include_selected_prototype=true,
	consuming="game-only",
	name_prefix=false
}

DataRaw.mapping_keys_de={
	["Z"]="Y",
	["Y"]="Z",
	["ß"]="MINUS",			-- ß
	["´"]="EQUALS",			-- ´
	["Ü"]="LEFTBRACKET",	-- Ü
	["+"]="RIGHTBRACKET",	-- +
	["#"]="BACKSLASH",		-- #
	["Ö"]="SEMICOLON",		-- Ö
	["Ä"]="APOSTROPHE",		-- Ä
	["^"]="GRAVE",			-- ^
	["-"]="SLASH",			-- Minus Key
}

---Adds a keyboard CustomInput
---@param key_sequence CI_key_sequence|CI_key_sequence[]
function DataRaw.add_keyboard_CustomInput(key_sequence, template)
	if(type(key_sequence)=="table") then
		for _, v in ipairs(key_sequence) do	DataRaw.add_keyboard_CustomInput(v)	end
		return
	end
	template = template or DataRaw.CustomInput_key_template
	local t = table.deepcopy(template)
	t.name=key_sequence
	t.key_sequence=key_sequence
	data:extend{t}
end




---------------------------------------------------------------------------------------------------

function DataRaw.asGlobal() return KuxCoreLib.__classUtils.asGlobal(DataRaw) end

return DataRaw





