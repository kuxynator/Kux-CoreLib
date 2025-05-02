require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---
---@class KuxCoreLib.LocalizationUtils : KuxCoreLib.Class
---@field asGlobal fun():KuxCoreLib.LocalizationUtils
local LocalizationUtils = {
	__class  = "KuxCoreLib.LocalizationUtils",
	__guid   = "{d74e3752-c3ad-4e7d-b5c0-5239b6222b07}",
	__origin = "Kux-CoreLib/lib/LocalizationUtils.lua",
}
if KuxCoreLib.__classUtils.cache(LocalizationUtils) then return KuxCoreLib.__classUtils.cached end
-----------------------------------------------------------------------------------------------------------------------
local TranslationService = KuxCoreLib.require.TranslationService

---Maps the lacalisation string to keys. after mapping the 'loc' table contains the key for a `LocalisedString`
---@param loc {[string]: string|{[string]:string}} The localization data
---@param view_name string The name of the view
---<p>CALLED_BY: loc definition file</p>
function LocalizationUtils.map_keys(loc,view_name)
	for k1, v1 in pairs(loc) do
		if type(v1) == "string" then
			loc[k1] = "factorium-"..view_name.."."..k1
		elseif type(v1) == "table" then
			for k2, v2 in pairs(v1) do
				v1[k2] = "factorium-"..view_name.."-"..k1.."."..k2
			end
		else
			error("invalid value")
		end
	end
end

---@param player LuaPlayer
---@param loc {[string]: string|{[string]:string}} The localization data
---<p>CALLED_BY: control.on_loaded</p>
function LocalizationUtils.request_translation(player, loc)
	for k1, v1 in pairs(loc) do
		if type(v1) == "string" then
			TranslationService.request(player, v1)
		elseif type(v1) == "table" then
			for k2, v2 in pairs(v1) do
				TranslationService.request(player, v2)
			end
		else
			error("invalid value")
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------
return LocalizationUtils

--[[
local loc = {
	num_results = "__1__ results",
	search_prompt = "Search...",
	nothing_found = "Nothing found",
	search_instructions = "Search for items, fluids, entities, etc.",
	show_disabled = "D",
	show_hidden = "H",
	localised_search_unavailable = "Localised search unavailable",

	caption = {
		show_disabled ="D",
		show_hidden = "H"
	}
	tooltip = {
		control_hint = "",
		show_disabled = "Show disabled item/recipes",
		show_hidden = "Show hidden item/recipes",
	}
}

LocalizationUtils.map_keys(loc,"ViewName")
TranslationService.add_gui_localization(loc)
return loc

]]