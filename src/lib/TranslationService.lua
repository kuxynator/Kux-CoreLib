require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---Provides translation functions
---@class KuxCoreLib.TranslationService : KuxCoreLib.Class
---@field asGlobal fun():KuxCoreLib.TranslationService
local TranslationService = {
	__class  = "KuxCoreLib.TranslationService",
	__guid   = "{e0c523bd-4c87-4eb9-8c30-a4761f3c3a32}",
	__origin = "Kux-CoreLib/lib/TranslationService.lua",
}
if KuxCoreLib.__classUtils.cache(TranslationService) then return KuxCoreLib.__classUtils.cached end
-----------------------------------------------------------------------------------------------------------------------
local LocalizationUtils = KuxCoreLib.require.LocalizationUtils

---@class KuxCoreLib.TranslationService.handler
local handler = {
	__class  = "KuxCoreLib.TranslationService.handler",
}

---queued loc registrations
local gui_localizations = {}

---@class KuxCoreLib.TranslationService.registry
local registry = {
	num_queued = 0,
	num_requests = 0,
	queue={}, ---@type {[string]: {[string]: {localised_string:LocalisedString, player_index:number}}} -- locale -> {hash -> {localised_string, player_index}
	requests={}, -- locale -> {id -> hash}
	translated={} -- locale -> {hash -> LocalisedString}
}

---@param localizable_string LocalisedString
---@return string
local function getHash(localizable_string)
	return type(localizable_string)=="table" and helpers.table_to_json(localizable_string) or tostring(localizable_string)
end

---@param localizable_string LocalisedString
---@param locale string
---@return string
function TranslationService.loc(localizable_string, locale)
	local hash = getHash(localizable_string)
	local loc = registry.translated[locale]
	if loc[hash] then return loc[hash] end
	return hash
end

local supertype = {
	item = "item",
	capsule = "item",
	gun = "item",
	armor = "item",
	mining_tool = "item",
	repair_tool = "item",
	rail_planner = "item",
	tool = "item",
	ammo = "item",
	module = "item",
	item_with_entity_data = "item",
	item_with_inventory = "item",
	item_with_label = "item",
	item_with_tags = "item",
	item_with_rocket_launcher = "item",
	fluid = "fluid",
	recipe = "recipe",
	technology = "technology",
	tile = "tile",
	virtual_signal = "virtual-signal",
	equipment = "equipment",
	shortcut = "shortcut"
}

---Gets the localisable string for the given prototype and field. (gets not the translation!)
---@param pt LuaPrototypeBase
---@param field "localised_name"|"localised_description"|"localised_tooltip"
---@return LocalisedString
function TranslationService.getLocalizableString(pt, field)
	local dic = {["localised_name"]="name",["localised_description"]="description",["localised_tooltip"]="tooltip"}
	return pt[field] or (supertype[pt.type].."-"..dic[field].."."..pt[dic[field]])
end

---@param player LuaPlayer
---@param localisable_string LocalisedString
function TranslationService.request(player, localisable_string)
	if localisable_string == nil then return end
	if not player.valid then return end
	if not player.connected then return end
	local locale = player.locale
	local hash = getHash(localisable_string)
	registry.translated[locale] = registry.translated[locale] or {}

	local loc = registry.translated[locale]
	if loc[hash] then return end -- already translated

	registry.queue[locale] = registry.queue[locale] or {}
	if registry.queue[locale][hash] then return end -- already queued

	registry.requests[locale] = registry.requests[locale] or {}
	if registry.requests[locale][hash] then return end -- still requesting

	registry.queue[locale][hash] = {player_index = player.index, localised_string = localisable_string}
	registry.num_queued = registry.num_queued + 1
end


---
---@param loc any
---<p>CALLED-BY: loc file
function TranslationService.add_gui_localization(loc)
	table.insert(gui_localizations, loc)
end


---
---@param player LuaPlayer
---<p>CALLED-BY: control.on_loaded</p>
function TranslationService.reqest_gui_localization(player)
	for _, loc in pairs(gui_localizations) do
		LocalizationUtils.request_translation(player, loc)
	end
end

---
---@return boolean
function TranslationService.is_idle()
	return registry.num_queued == 0 and registry.num_requests == 0
end

---@param localised_string LocalisedString
function request_internal(player_index, hash, localised_string)
	if localised_string == nil then return end
	local player = game.players[player_index]
	if not player or not player.valid or not player.connected then return end
	local locale = player.locale
	local id = player.request_translation(localised_string)
	if not id then return end -- request failed
--	print("TranslationService request :"..locale.." "..str(hash))
	registry.requests[locale][id] = hash
	registry.requests[locale][hash] = id
	registry.queue[locale][hash] = nil
	registry.num_requests = registry.num_requests + 1
	registry.num_queued = registry.num_queued - 1
end

---@param e EventData.on_string_translated
function handler.on_string_translated(e)
	local _ = "fnc{49483a93-e3fc-442e-a632-5630ebfc6c11}"
	local player = game.players[e.player_index]
	local locale = player.locale
	if not registry.requests[locale] then return end
	local hash = registry.requests[locale][e.id]
	if not hash then return end
	--clean request
	registry.requests[locale][e.id] = nil
	registry.requests[locale][hash] = nil
	--save result
	registry.translated[locale][hash] = e.result
	registry.num_requests = registry.num_requests - 1
end


function handler.on_nth_tick_1(e)
	local _ = "fnc{cc5f09b5-19a9-45ae-a63e-7bcf896113fc}"
	if registry.num_queued == 0 then return end
	local count = 1000
	for locale, list in pairs(registry.queue) do
		for hash, data in pairs(list) do
			request_internal(data.player_index, hash, data.localised_string)
			count = count - 1
			if count == 0 then return end
		end
	end
end

Events.on_event(defines.events.on_string_translated, function (e) handler.on_string_translated(e) end)
Events.on_nth_tick(1, handler.on_nth_tick_1)
-----------------------------------------------------------------------------------------------------------------------
return TranslationService


