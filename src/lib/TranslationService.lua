require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---Provides translation functions
---@class KuxCoreLib.TranslationService : KuxCoreLib.Class
---@field asGlobal fun():KuxCoreLib.TranslationService
local TranslationService = {
	__class  = "KuxCoreLib.TranslationService",
	__guid   = "{e0c523bd-4c87-4eb9-8c30-a4761f3c3a32}",
	__origin = "Kux-CoreLib/lib/TranslationService.lua",
}
if not KuxCoreLib.__classUtils.ctor(TranslationService) then return self end
-----------------------------------------------------------------------------------------------------------------------
local Events = KuxCoreLib.require.Events
local ModInfo = KuxCoreLib.require.ModInfo
local LocalizationUtils = KuxCoreLib.require.LocalizationUtils
local TranslationProgressWindow = require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/TranslationProgressWindow")
local Storage = KuxCoreLib.require.Storage


Storage.register("storage.__KuxCoreLib__.TranslationService", TranslationService.__class)
Storage.register("storage.__KuxCoreLib__.TranslationService.registry", "KuxCoreLib.TranslationService.registry")

---@class KuxCoreLib.TranslationService.handler
local handler = {
	__class  = "KuxCoreLib.TranslationService.handler",
}

---@class KuxCoreLib.TranslationService.parser
local parser = {
	__class  = "KuxCoreLib.TranslationService.parser",
}

---queued loc registrations
local gui_localizations = {}

---local copy of storage.__KuxCoreLib__.TranslationService.registry
---@type KuxCoreLib.TranslationService.registry
local registry

local last_update_tick = 0
local progress_max = 0

---@return KuxCoreLib.TranslationService.registry
local function createRegistry()
	return {
		num_queued = 0,
		num_requests = 0,
		queue={}, ---@type {[string]: {[string]: {localised_string:LocalisedString, player_index:number}}} -- locale -> {hash -> {localised_string, player_index}
		requests={}, -- locale -> {id -> hash}
		translated={}, -- locale -> {hash -> LocalisedString}
		idx_hash_localised_string={} -- {hash -> LocalisedString}
	} --[[@as KuxCoreLib.TranslationService.registry]]
end

---@return KuxCoreLib.TranslationService.registry
local function getRegistry()
	local cached = Storage.get("storage.__KuxCoreLib__.TranslationService.registry")
	if not cached and Storage.canWrite then
		cached = createRegistry()
		Storage.set("storage.__KuxCoreLib__.TranslationService.registry", cached)
	end
	if not cached then log("\n  " .. ModInfo.name .. " TranslationService.getRegistry: WARNING can not write storage!") end
	return cached
end


---Gets a stable string as hash
---@param localizable_string LocalisedString
---@return string
---<p>We use a string as hash because table reference as key is not safe.</p>
local function getHash(localizable_string)
	--return type(localizable_string)=="table" and helpers.table_to_json(localizable_string) or tostring(localizable_string)
	if type(localizable_string) ~= "table" then  error("invalid key. table expected") end
	if #localizable_string == 1 then
		local first = localizable_string[1]
		if type(first) ~= "string" then error("invalid key, string expected at #1") end
		return first
	end
	return helpers.table_to_json(localizable_string)
end


local dic_rid_guiElement= {}

---
---@param elem LuaGuiElement
---@param parameters {localization_section:string} --   KuxGuiLib.ElementBuilder.create.parameters
function TranslationService.autoTranslateGuiElement(elem, parameters)

	if not elem.name or elem.name:find("^[@.~]") then return end --exclude special names
	local section = parameters and parameters.localization_section
		or LocalizationUtils.getCfgSection(elem.tags.context_view_name or elem.tags.view_name, elem.tags.mod_name)

	local keys = {-- v2 [section] name.prop
		caption = string.format("%s.%s.%s", section, elem.name, "caption"),
		tooltip = string.format("%s.%s.%s", section, elem.name, "tooltip")
	}
	local player = game.players[elem.player_index]

	---@param prop "caption"|"tooltip"
	local function f(prop)
		local reg = registry
		if TranslationService.hasTranslation(keys[prop], player.locale) then
			local transl = TranslationService.get(keys[prop], player.locale, true)
			if not transl or transl:find("^Unknown key") then return end -- do not show "Unknown key:"
			elem[prop] = transl
			return
		end
		local tid, err = TranslationService.request(player, keys[prop], true)
		if not tid then error("invalid state") end
		dic_rid_guiElement[tid] = {element=elem, property=prop, player_index=player.index, path=elem.tags.path}
		--wait for on_string_translated
	end

	f("caption"); f("tooltip")
end


---Gets a Unknown key message
---@param key LocalisedString
---@return string
function TranslationService.getUnknownKey(key)
	return "Unknown key: "..str(getHash(key))
end

---@param localizable_string LocalisedString
---@param locale string
---@return string
function TranslationService.loc(localizable_string, locale)
	if type(localizable_string) == "string" then localizable_string = {localizable_string} end -- <FEATURE
	if type(localizable_string) ~= "table" then return tostring(localizable_string) end -- no translate
	local hash = getHash(localizable_string)
	local loc = registry.translated[locale]
	if loc[hash] then return loc[hash] end
	return hash
end

---@param localizable_string LocalisedString
---@param locale string
---@return boolean
function TranslationService.hasTranslation(localizable_string, locale)
	if type(localizable_string) == "string" then localizable_string = {localizable_string} end -- <FEATURE
	if type(localizable_string) ~= "table" then return false end
	return (registry.translated[locale] or {})[getHash(localizable_string)]~=nil
end

---Checks if a valid translation exists for the given `LocalisedString` in the specified `locale`.
---@param localizable_string LocalisedString
---@param locale string
---@param partial boolean?
---@return boolean #returnes `true` if the translation is not empty and does not begin with “Unknown key”. If `partial` is set to `true`, "Unknown key" in nested translations will be ignored.
function TranslationService.hasValidTranslation(localizable_string, locale, partial)
	if type(localizable_string) == "string" then localizable_string = {localizable_string} end -- <FEATURE
	if type(localizable_string) ~= "table" then return false end
	local transl = TranslationService.get(localizable_string, locale, partial)
	local notValid = transl==nil or transl=="" or transl:find("^Unknown key")
	return notValid == false
end

---Returns translated string, or partial result if enabled.
---@param localised_string LocalisedString
---@param locale string
---@param partial boolean? If true, resolve with partial fallback
---@return string|nil
function TranslationService.get(localised_string, locale, partial)
	if type(localised_string) == "string" then localised_string = {localised_string} end
	if type(localised_string) ~= "table" then return tostring(localised_string) end

	local hash = getHash(localised_string)
	local translated = registry.translated[locale]
	local result = translated and translated[hash]
	if result and result ~= "" then return result end
	if partial then return parser.resolve(localised_string, locale) end
	return nil
end

local supertype = {
	gun = "item",   module = "item",      rail_planner = "item",     item_with_inventory = "item",
	item = "item",  fluid = "fluid",      shortcut = "shortcut",     item_with_entity_data = "item",
	tool = "item",  capsule = "item",     item_with_tags = "item",   virtual_signal = "virtual-signal",
	ammo = "item",  recipe = "recipe",    equipment = "equipment",   item_with_rocket_launcher = "item",
	tile = "tile",  mining_tool = "item", item_with_label = "item",
	armor = "item", repair_tool = "item", technology = "technology",
}

---Gets the localisable string for the given prototype and field. (gets not the translation!)
---@param pt LuaPrototypeBase
---@param field "localised_name"|"localised_description"|"localised_tooltip"
---@return LocalisedString
function TranslationService.getLocalizableString(pt, field)
	local dic = {["localised_name"]="name",["localised_description"]="description",["localised_tooltip"]="tooltip"}
	return pt[field] or (supertype[pt.type].."-"..dic[field].."."..pt[dic[field]])
end

local function fill_placeholders(text, placeholders)
	for i, v in ipairs(placeholders) do
		text = text:gsub("__"..i.."__", v)
	end
	return text
end

---Finds a valid `LuaPlayer` for the specified `locale`
---@param locale string
---@return LuaPlayer?
local function findPlayer(locale)
	for _, player in pairs(game.players) do
		if not player.valid or not player.connected then goto next end
		if player.locale == locale then return player end
		::next::
	end
end

---
---@param locale any
---@param localizable_string any
---@param hash any
---@param direct boolean?
---@return integer? id only if direct=true
---@return string? justification
function request_core(locale, localizable_string, hash, direct)
	local loc = registry.translated[locale]
	if loc[hash] then return nil, "already translated" end
	registry.requests[locale] = registry.requests[locale] or {}
	registry.queue[locale] = registry.queue[locale] or {}
	if direct then
		if registry.requests[locale][hash] then
			local tid = registry.requests[locale][hash]
			return tid, "still requesting"
		end
		local player = findPlayer(locale) or error("invalid state")
		registry.num_queued = registry.num_queued + 1 -- request_internal: num_queued - 1
		progress_max = progress_max + 1
		local tid = request_internal(player.index, hash, localizable_string)
		return tid
	else
		if registry.queue[locale][hash] then return nil, "already queued" end
		if registry.requests[locale][hash] then return nil, "still requesting" end
		registry.queue[locale][hash] = {localised_string = localizable_string}
		registry.num_queued = registry.num_queued + 1
		progress_max = progress_max + 1
		return nil, "queued"
	end
end

---@param player LuaPlayer
---@param localizable_string LocalisedString
---@param direct boolean?
function TranslationService.request(player, localizable_string, direct)
	--log("TranslationService.request "..tostring(player.index).." "..tostring(localizable_string))
	if localizable_string == nil then return end
	if type(localizable_string) == "string" then localizable_string = {localizable_string} end -- <FEATURE
	if type(localizable_string) ~= "table" then return end
	if not player.valid then return end
	if not player.connected then return end

	if registry.num_queued + registry.num_requests == 0 then --new batch
		progress_max = 0
	end
	local locale = player.locale
	registry.translated[locale] = registry.translated[locale] or {}
	local hash = getHash(localizable_string)
	local keys = parser.extract_keys(localizable_string)

	local tid
	local needOriginal = true
	for _, ls in ipairs(keys) do
		local lsh = getHash(ls)
		if lsh == hash then needOriginal=false end
		registry.idx_hash_localised_string[lsh]=ls -- stores all requested strings
		tid = request_core(locale, ls, lsh, direct)
	end
	if needOriginal then
		registry.idx_hash_localised_string[hash]=localizable_string -- stores all requested strings
		tid = request_core(locale, localizable_string, hash, direct)
	end
	return tid
end


---
---@param loc table
---<p>CALLED-BY: loc file
function TranslationService.add_gui_localization(loc)
	table.insert(gui_localizations, loc)
end


---
---@param player LuaPlayer
---<p>CALLED-BY: control.on_loaded</p>
function TranslationService.request_gui_localization(player)
	print("TranslationService.request_gui_localization")
	for _, loc in pairs(gui_localizations) do
		LocalizationUtils.request_translation(player, loc)
	end
	print("end TranslationService.request_gui_localization")
end


---
---@return boolean
function TranslationService.is_idle()
	return registry.num_queued == 0 and registry.num_requests == 0
end

---@param localised_string LocalisedString
---@return integer?
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
	return id
end

function TranslationService.start(mod_name)
	handler.on_start{source="on_custom_start", mod_name=mod_name}
end


--#region Parser

---
---@param ls LocalisedString
---@return LocalisedStringData
function parser.split(ls)
	if type(ls) == "string" then
		return { type = "plain", value = ls }
	elseif type(ls) ~= "table" then
		return { type = "unknown", value = ls }
	elseif ls[1] == "" then
		local values = {}
		for i = 2, #ls do values[#values+1] = parser.split(ls[i]) end
		return { type = "chain", values = values }
	elseif #ls == 1 then
		return { type = "key", key = ls[1] }
	end
	local parameters = {}
	for i = 2, #ls do parameters[#parameters+1] = parser.split(ls[i]) end
	return { type = "key", key = ls[1], parameters = parameters }
end

---
---@param node LocalisedStringData
---@return LocalisedString[] list
function parser.extract_keys(node)
	if type(node)=="string" then return {} end
	if type(node)~="table" then error("invalid argument. table expected, but got "..type(node)..": "..str(node)) end
	if not node.type then node = parser.split(node) end

	local list = {} ---@type LocalisedString[]
	local function extract(node)
		if node.type == "key" then
			local params = {}
			if node.parameters then
				for i = 1, #node.parameters do
					extract(node.parameters[i])
					params[i] = string.format("__%d__",i)
				end
			end
			table.insert(list, { node.key, table.unpack(params) })
		elseif node.type == "chain" then
			for _, v in ipairs(node.values) do
				extract(v)
			end
		end
	end
	extract(node)
	return list
end

function parser.toLocalisedString(node)
	if node.type == "plain" then
		return node.value
	elseif node.type == "key" then
		if not node.parameters then
			return { node.key }
		end
		local params = {}
		for i = 1, #node.parameters do
			params[i] = parser.toLocalisedString(node.parameters[i])
		end
		return { node.key, table.unpack(params) }
	elseif node.type == "chain" then
		local values = { "" }
		for i = 1, #node.values do
			values[i+1] = parser.toLocalisedString(node.values[i])
		end
		return values
	else
		error("unknown node type: " .. tostring(node.type))
	end
end

function parser.resolve(ls, locale)
	local function resolveNode(node)
		if node.type == "plain" then
			return node.value

		elseif node.type == "key" then
			local str = {node.key}
			local hash = getHash(str)
			local result

			-- wenn Parameter existieren → baue Placeholder-Key
			if node.parameters then
				local params = {}
				for i = 1, #node.parameters do
					params[i] = "__" .. i .. "__"
				end

				local placeholderKey = {node.key, table.unpack(params)}
				local placeholderHash = getHash(placeholderKey)
				local translated = registry.translated[locale] and registry.translated[locale][placeholderHash]

				local resolvedParams = {}
				for i, param in ipairs(node.parameters) do
					resolvedParams[i] = resolveNode(param)
				end

				result = (translated and translated ~= "")
					and fill_placeholders(translated, resolvedParams)
					or TranslationService.getUnknownKey(str)

			else
				-- kein Parameter → normaler Key
				local translated = registry.translated[locale] and registry.translated[locale][hash]
				result = (translated and translated ~= "") and translated
					or TranslationService.getUnknownKey(str)
			end

			return result

		elseif node.type == "chain" then
			local resolved = {}
			for _, part in ipairs(node.values) do
				resolved[#resolved+1] = resolveNode(part)
			end
			return table.concat(resolved)

		else
			return "<invalid>"
		end
	end

	return resolveNode(parser.split(ls))
end

do --test
   local err = { "Kux-GuiLib-GuiEventDistributor.error",
		 		--[[__1__]] {"mod-name."..script.mod_name},
				--[[__2__]] script.active_mods[script.mod_name],
				--[[__3__]] script.mod_name,
				--[[__4__]] {"","Error while running event ",script.mod_name,"::","on_gui_click","\n", "<error message>" }
			}
	local data = parser.split(err)
	local keys = parser.extract_keys(data)
	print(keys)
end

local TEST_tid
if not commands.commands["test-ts"] then commands.add_command("test-ts","", function (e)
	local ls = { "Kux-GuiLib-GuiEventDistributor.error",
		 		--[[__1__]] {"mod-name."..script.mod_name},
				--[[__2__]] script.active_mods[script.mod_name],
				--[[__3__]] script.mod_name,
				--[[__4__]] {"","Error while running event ",script.mod_name,"::","on_gui_click","\n", "<error message>" }
			}
	TEST_tid = TranslationService.request(game.players[e.player_index], ls, true)
end)end

--#region Event handler


function handler.on_nth_tick_1(e) local _ = "fnc{cc5f09b5-19a9-45ae-a63e-7bcf896113fc}"
	--log(ModInfo.name.." TranslationService.on_nth_tick_1")

	--[[DEVELOP]] if not registry then registry = getRegistry() end --[[DEVELOP]]

	if registry.num_queued == 0 then return end
	local count = 100
	local orphaned = {}
	for locale, list in pairs(registry.queue) do
		local player = findPlayer(locale)
		if not player then
			orphaned[locale]=true
			goto next_locale
		end
		for hash, data in pairs(list) do
			request_internal(player.index, hash, data.localised_string)
			count = count - 1
			if count == 0 then return end
		end
		::next_locale::
	end
	for locale, _ in pairs(orphaned) do
		local c = 0 for _, _ in pairs(registry.queue[locale]) do c=c+1 end
		registry.num_queued = registry.num_queued - c
		registry.queue[locale]=nil
	end
	--print("end TranslationService.on_nth_tick_1")
end

---can be called multiple times (on_loaded / on_player_joined_game)
---@param e {source: string, mod_name: string} | ConfigurationChangedData
function handler.on_start(e)
	log("TranslationService.on_start source: "..e.source..(e.mod_name and ", mod_name: "..e.mod_name or ""))
	if not registry then registry = getRegistry() end
	if e.source == "on_load" then return end

	--Events.on_timer(500, function ()
	-- Events.on_next_tick({},function ()
		--log(ModInfo.name.." on_next_tick "..game.tick.."--------------------------------------------------------")
		local locale = {}
		for _, player in pairs(game.connected_players) do
			if not locale[player.locale] then
				locale[player.locale] = true;
				TranslationService.request_gui_localization(player)
			end
		end
	-- end)
end

---called in single player and multiplayer headless server
function handler.on_loaded()
	log(ModInfo.name.." TranslationService.on_loaded "..game.tick.."--------------------------------------------------------")
	handler.on_start({source="on_loaded"})
end

---called in multiplayer only
---@param e EventData.on_player_joined_game
function handler.on_player_joined_game(e)
	print (e.tick, "on_player_joined_game", e.player_index)
	handler.on_start({source="on_loon_player_joined_gameaded"})
end

---@param e EventData.on_player_created
function handler.on_player_created(e)
	print (e.tick, "on_player_created", e.player_index)
end

---@param e EventData.on_player_locale_changed
function handler.on_player_locale_changed(e)
	local player = game.players[e.player_index]
	print (e.tick, "on_player_locale_changed", e.player_index, e.old_locale, player.locale)
	if registry.queue[player.locale] then return end
	for hash, localised_string in pairs(registry.idx_hash_localised_string) do
		request_core(player.locale,localised_string,hash)
	end
end

---@param e EventData.on_string_translated
function handler.on_string_translated(e) local _ = "fnc{49483a93-e3fc-442e-a632-5630ebfc6c11}"
	--print("TranslationService on_string_translated")
	local player = game.players[e.player_index]
	local locale = player.locale
	if not registry.requests[locale] then return end --requested by other mod
	local hash = registry.requests[locale][e.id]
	if not hash then return end  --requested by other mod
	--clean request
	registry.requests[locale][e.id] = nil
	registry.requests[locale][hash] = nil
	--save result
	registry.translated[locale][hash] = e.result
	registry.num_requests = registry.num_requests - 1
	--print("TranslationService result :"..locale.." "..str(hash).." "..str(e.result))

	if (last_update_tick) < game.tick-10 or registry.num_requests+registry.num_queued == 0 then
		last_update_tick = game.tick
		local current = progress_max - registry.num_requests - registry.num_queued
		TranslationProgressWindow.show(script.mod_name, current, progress_max)
	end

	local guiReq = dic_rid_guiElement[e.id]
	if guiReq then
		if not guiReq.element or not guiReq.element.valid then
			local player = game.players[guiReq.element.player_index]
			---@diagnostic disable-next-line: undefined-global, undefined-field
			guiReq.element = Gui.getElement(player, guiReq.element.path)
		end
		dic_rid_guiElement[e.id] = nil
		local transl = TranslationService.get(e.localised_string, locale, true) or ""
		if transl:find("^Unknown key") then return end
		guiReq.element[guiReq.property] = transl
		return
	end
end

---handler for command `/test-ts`
---@param e EventData.on_string_translated
function handler.on_string_translated_test(e)
	--log("TranslationService.on_string_translated")
	if TEST_tid and e.id == TEST_tid then
		local t= registry.translated
		local s
		if e.result=="" then
			s = parser.resolve(e.localised_string, game.players[e.player_index].locale)
		end
		game.players[e.player_index].print("Test erfolgreich: "..s)
		TEST_tid = nil
	end
end

Events.on_start(handler.on_start)
Events.on_event(defines.events.on_player_joined_game, handler.on_player_joined_game)
Events.on_loaded(handler.on_loaded)
Events.on_nth_tick(1, handler.on_nth_tick_1)
Events.on_event(defines.events.on_string_translated, function (e) handler.on_string_translated(e) end)
Events.on_event(defines.events.on_player_created, handler.on_player_created)
Events.on_event(defines.events.on_string_translated, handler.on_string_translated_test)
Events.on_event(defines.events.on_player_locale_changed, handler.on_player_locale_changed)

-----------------------------------------------------------------------------------------------------------------------
KuxCoreLib.__classUtils.finalize(TranslationService)
return TranslationService

---@alias LocalisedStringType "plain"|"chain"|"key"

---@class LocalisedStringData
---       ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
---@field type LocalisedStringType
---@field value LocalisedStringData? type "plain"
---@field values LocalisedStringData[]? type "chain"
---@field parameters LocalisedStringData[]? ftype "key"


---@class KuxCoreLib.TranslationService.registry
---       ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
---@field num_queued integer
---@field num_requests integer
---@field queue table<string, table<string, {localised_string:LocalisedString, player_index:number}>> locale -> {hash -> {localised_string, player_index}
---@field requests table<string, table<integer, string>>            locale -> {id -> hash}
---@field translated table<string, table<string, string>>           locale -> {hash -> LocalisedString}
---@field idx_hash_localised_string table<string, LocalisedString>  {hash -> LocalisedString}
