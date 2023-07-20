require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")
if(KuxCoreLib.__modules.EventDistributor) then return KuxCoreLib.__modules.EventDistributor end
--[[
	Usage:
	[control.lua]	
	require "ModulA"

	[ModuleA.lua]
	local EventDistributor = require("__Kux-CoreLib__/lib/EventDistributor")
	local function handler(evt) ... end
	EventDistributor.register(80, handler)
	EventDistributor.register("on_init", handler)
]]
---@class KuxCoreLib.EventDistributor
local EventDistributor = {
	__class  = "EventDistributor",
	__guid   = "{ADD81DB1-53B9-4D61-9279-401AD277DBEE}",
	__origin = "Kux-CoreLib/lib/EventDistributor.lua",

	__isInitialized = false,
	__on_initialized = {}
}
setmetatable(EventDistributor,{
	---dummy method to use with `require.KuxCoreLib.EventDistributor()
	__call = function (t, ...) end
})
KuxCoreLib.__modules.EventDistributor = EventDistributor
local util = {}
---------------------------------------------------------------------------------------------------

if(KuxCoreLib.ModInfo.current_stage~="control") then
	function EventDistributor.asGlobal() return KuxCoreLib.utils.asGlobal(EventDistributor) end
	return nil
end -- events are only available in control stage

-- to avoid circular references, the class MUST be defined before require other modules
KuxCoreLib.lua.asGlobal()
local Table = KuxCoreLib.Table
local List = KuxCoreLib.List
local ModInfo = KuxCoreLib.ModInfo
local StringBuilder = KuxCoreLib.StringBuilder

---Dictionary of EventId|EventName, table of function
local events={}

local isOnLoadedRaised = false

local mapEventNumberToName = {}
for name, value in pairs(defines.events) do
	mapEventNumberToName[value] = name
end

---Get name and id of an event
---@param eventIdentifier any
---@return string
---@return uint
local function eventPair (eventIdentifier)
	::start::
	local eventName = nil
	local eventId = nil
	local eventType = type(eventIdentifier)
	if eventType == "number" then
		eventName = mapEventNumberToName[eventIdentifier]
		eventId = eventIdentifier
	elseif eventType == "string" then
		eventName = eventIdentifier
		eventId = defines.events[eventIdentifier]
		--if eventId==nil then eventId = 0 end -- "on_init" "on_load" "on_configuration_changed", o.a.
	elseif eventType == "table" then
		eventId = eventIdentifier.name
		eventName = mapEventNumberToName[eventIdentifier]
					or eventIdentifier.input_name --The prototype name of the custom input that was activated.
	end
	return eventName, eventId
end

---Registers an custom event name with its id
---@param id integer number of the custom event
---@param name string name of the custom event
function EventDistributor.registerName(id,name)
	mapEventNumberToName[id]=name
end

local function getDisplayName(event)
	local eventName, eventId = eventPair(event)
	if(not eventId or eventId==0) then
		return eventName or "unknown"
	else
		return (eventName or "custom").."("..tostring(eventId)..")"
	end
end

EventDistributor.getDisplayName=getDisplayName

local function on_init()
	--print("EventDistributor.on_init")
	local handlers = events["on_init"]
	if(not handlers) then return end
	for _,fnc in pairs(handlers) do fnc() end
end

local function on_load()
	--print("EventDistributor.on_load")
	local handlers = events["on_load"]
	if(not handlers) then return end
	for _,fnc in pairs(handlers) do fnc() end

	if(settings.global["Kux-CoreLib_".."on_load_LogEvents_Summary"].value) then
		util.log_summary()
	end
end

local function on_configuration_changed(e)
	--print("EventDistributor.on_configuration_changed")
	local handlers = events["on_configuration_changed"]
	if(not handlers) then return end
	for _,fnc in pairs(handlers) do fnc(e) end
end

local function on_nth_tick(e)
	--print("EventDistributor.on_nth_tick "..e.nth_tick)
	local handlers = events["on_nth_tick"][e.nth_tick]
	if(handlers) then
		for _,fnc in pairs(handlers) do fnc(e) end
	end
end

local function on_event(e)
	--log("on_event "..getDisplayName(e))
	local eventName, eventId = eventPair(e.name)
	local key = eventId or eventName
	local handlers = events[key]
	if(not handlers) then return end
	for _,fnc in pairs(handlers) do fnc(e) end
end

local function on_event_customInput(e)
	--log("on_event_customInput "..getDisplayName(e))
	local name, number = eventPair(e)
	local handlers = events[name]
	if(not handlers) then return end
	for _,fnc in pairs(handlers) do fnc(e) end
end

local function on_loaded(e)
	--print("on_loaded")
	if(isOnLoadedRaised) then return end

	EventDistributor.unregister_on_nth_tick(e.nth_tick, on_loaded)

	local handlers = events.on_loaded
	if(handlers) then
		for _,fnc in pairs(handlers) do fnc(e) end
	end

	--print("set isLoadRaised=true")
	isOnLoadedRaised = true
	events["on_loaded"] = {}
end

local function on_built(e)
	--print("EventDistributor.on_built")
	local handlers = events["on_built"]
	if(not handlers) then return end
	for _,fnc in pairs(handlers) do fnc(e) end
end

local function on_destroy(e)
	--print("EventDistributor.on_built")
	local handlers = events["on_destroy"]
	if(not handlers) then return end
	for _,fnc in pairs(handlers) do fnc(e) end
end

local function check_customInput(name)
	if(game.custom_input_prototypes[name]) then return end
	error("CustomInput does not exist. Name:'"..tostring(name).."'")
end

---Registers an event in script
---@param eventIdentifier integer|uint|string
---@param param any ticks | filter
local function register(eventIdentifier, param)
	--log("register: "..getDisplayName(eventIdentifier))
	local eventName, eventId = eventPair(eventIdentifier)
	if    (eventName=="on_init"                 ) then script[eventName](on_init)
	elseif(eventName=="on_load"                 ) then script[eventName](on_load)
	elseif(eventName=="on_configuration_changed") then script[eventName](on_configuration_changed)
	elseif(eventName=="on_nth_tick"             ) then script.on_nth_tick(param,  on_nth_tick)
	elseif(eventId and eventId > 0              ) then script.on_event(eventId,   on_event)
	else   --[[check_customInput(eventName); ]]        script.on_event(eventName, on_event_customInput)
	end
	-- can't use check_customInput, because 'game' is not yet available
end

---Unregisters an event in script
---@param eventIdentifier uint|string
---@param ticks uint|nil only requiried for on_nth_tick
local function unregister(eventIdentifier, ticks)
	--log("unregister: "..getDisplayName(eventIdentifier)..iif(ticks~=nil," ticks="..ticks,""))
	local eventName, eventId = eventPair(eventIdentifier)
	if    (eventName=="on_init"                 ) then script[eventName](nil)
	elseif(eventName=="on_load"                 ) then script[eventName](nil)
	elseif(eventName=="on_configuration_changed") then script[eventName](nil)
	elseif(eventName=="on_nth_tick"             ) then script.on_nth_tick(ticks, nil)
	elseif(eventId and eventId > 0              ) then script.on_event(eventId, nil)
	else error("Unknown event: "..getDisplayName(eventIdentifier))
	end
end

---Unregisters an event
---@param eventIdentifier integer|uint|string
---@param fnc function
function EventDistributor.unregister(eventIdentifier, fnc)
	if(not fnc) then error("Argument 'fnc' must not be nil!") end
	local eventName, eventId = eventPair(eventIdentifier)
	local key = eventId or eventName
	Table.remove(events[key], fnc)
	if(#events[key]>0) then return end
	if(eventName=="on_built") then
		EventDistributor.unregister(defines.events.on_built_entity,       on_built)
		EventDistributor.unregister(defines.events.on_robot_built_entity, on_built)
		EventDistributor.unregister(defines.events.script_raised_built,   on_built)
		EventDistributor.unregister(defines.events.script_raised_revive,  on_built)
	elseif(eventName=="on_destroy") then
		EventDistributor.unregister(defines.events.on_pre_player_mined_item, on_destroy)
		EventDistributor.unregister(defines.events.on_robot_pre_mined,       on_destroy)
		EventDistributor.unregister(defines.events.on_entity_died,           on_destroy)
		EventDistributor.unregister(defines.events.script_raised_destroy,    on_destroy)
	else
		unregister(key)
	end
end

---Registers an event
---@param eventIdentifier integer|uint|string
---@param fnc function
---@param param any Optional parameter, depends on eventIdentifier (filter)
---@return boolean #true if succesfully registered else false
function EventDistributor.register (eventIdentifier, fnc, param)
	if(eventIdentifier==nil) then error("Argumrnt 'eventIdentifier' must not be nil.") end
	if(fnc==nil) then error("Argument 'fnc' must not be nil.") end
	if(type(fnc)~="function") then error("Argument 'fnc' must be a function.") end
	if(type(eventIdentifier)=="table") then
		for _, ei in ipairs(eventIdentifier) do
			EventDistributor.register(ei, fnc, param)
		end
		return true
	end
	--print("EventDistributor.register "..getDisplayName(eventIdentifier))

	local eventName, eventId = eventPair(eventIdentifier)
	local key = eventId or eventName
	if    (eventName=="nth_tick"  ) then error("Argument out of range. name: eventIdentifier, value: "..eventIdentifier)
	elseif(eventName=="on_loaded" ) then EventDistributor.register_nth_tick(1, on_loaded)
	elseif(eventName=="on_built"  ) then EventDistributor.register_on_built(nil, fnc); return true
	elseif(eventName=="on_destroy") then EventDistributor.register_on_destroy(nil, fnc); return true
	end
	if(List.isNilOrEmpty(events[key])) then
		events[key] = {fnc}
		if(eventName ~= "on_loaded") then register(eventIdentifier, param) end
	else
		if(Table.contains(events[key], fnc)) then return false end
		table.insert(events[key], fnc)
	end
	return true
end

---Registers an on_nth_tick event
---@param ticks uint
---@param fnc function
---@return boolean #true if succesfully registered else false
function EventDistributor.register_nth_tick(ticks, fnc)
	--print("EventDistributor.register "..getDisplayName("on_nth_tick"))
	if(not fnc) then error("Argument 'fnc' must not be nil!") end
	if not events["on_nth_tick"] then events["on_nth_tick"] = {} end
	if (List.isNilOrEmpty(events["on_nth_tick"][ticks])) then
		events["on_nth_tick"][ticks] = {fnc}
		register("on_nth_tick",ticks)
	else
		if(Table.contains(events["on_nth_tick"][ticks], fnc))  then return false end
		table.insert(events["on_nth_tick"][ticks], fnc)
	end
	return true
end

---Registers an on_nth_tick event
---@param ticks uint
---@param fnc function
function EventDistributor.unregister_on_nth_tick(ticks, fnc)
	--print("EventDistributor.unregister_on_nth_tick "..tick)
	if(not fnc) then error("Argument 'fbc' must not be nil!") end
	Table.remove(events["on_nth_tick"][ticks], fnc)
	if(#events["on_nth_tick"][ticks]>0) then return end
	unregister("on_nth_tick",ticks)
end

local function register_artifical_event(key,fnc)
	if(List.isNilOrEmpty(events[key])) then
		events[key] = {fnc}
		--if(eventName ~= "on_loaded") then register(eventIdentifier, param) end
	else
		if(Table.contains(events[key], fnc)) then
			error("Multiple registration of same event is not supported. name: '"..key.."'")
			--TODO: allow reregister the event
			return false
		end
		table.insert(events[key], fnc)
	end
end

function EventDistributor.register_on_built(item_filter, fnc)
	register_artifical_event("on_built", fnc)

	--TODO: join item_filter. at the moment only the first resgistration works!
    EventDistributor.register(defines.events.on_built_entity,       on_built, item_filter)
    EventDistributor.register(defines.events.on_robot_built_entity, on_built, item_filter)
    EventDistributor.register(defines.events.script_raised_built,   on_built, item_filter)
    EventDistributor.register(defines.events.script_raised_revive,  on_built, item_filter)
end

function EventDistributor.register_on_destroy(item_filter, fnc)
	register_artifical_event("on_destroy", fnc)

	--TODO: join item_filter. at the moment only the first resgistration works!
	EventDistributor.register(defines.events.on_pre_player_mined_item, on_destroy, item_filter)
	EventDistributor.register(defines.events.on_robot_pre_mined,       on_destroy, item_filter)
	EventDistributor.register(defines.events.on_entity_died,           on_destroy, item_filter)
	EventDistributor.register(defines.events.script_raised_destroy,    on_destroy, item_filter)
end

function EventDistributor.unregister_on_built(fnc)
	EventDistributor.unregister("on_built", fnc)
end

function EventDistributor.unregister_on_destroy(fnc)
	EventDistributor.unregister("on_destroy", fnc)
end

---DRAFT ONLY
function EventDistributor.register_with_filter(eventIdentifier, filter, fnc)
	local eventName, eventId = eventPair(eventIdentifier)
	if(eventId ~= nil and eventId>0) then
		local currentFilters = script.get_event_filter(eventId) --[[@as table]]
		if(currentFilters==nil) then
			EventDistributor.register(eventIdentifier,fnc,filter)
			return
		elseif(#filter>0) then
			for _,f in ipairs(filter) do
				table.insert(currentFilters,f)
			end
		else
			table.insert(currentFilters,filter)
		end
		script.set_event_filter(eventId, currentFilters)
	end
end

function util.log_summary()
	local sb = StringBuilder:new()
	sb:appendLine(ModInfo.name.." registered events:")
	for key, v1 in pairs(events) do
		if(Table.isNilOrEmpty(v1)) then goto next end
		if(key=="on_nth_tick") then
			sb:appendLine("  " .. getDisplayName(key))
			for k2, v2 in pairs(v1) do
				if(not Table.isNilOrEmpty(v2)) then sb:appendLine("    " ..k2) end
				for _, v3 in ipairs(v2) do
					sb:appendLine("      " .. debug.getinfo(v3,"S").short_src)
				end
			end
		else
			sb:appendLine("  " .. getDisplayName(key))
			for _, v3 in ipairs(v1) do
				sb:appendLine("      " .. debug.getinfo(v3,"S").short_src)
			end
		end
		::next::
	end
	log(sb:toString())
end

local function internal_on_onit()
	ModInfo.current_stage="control-on-init"
end

local function internal_on_load()
	ModInfo.current_stage="control-on-load"
end

local function internal_on_configuration_changed()
	ModInfo.current_stage="control-on-configuration-changed"
end

local function internal_on_loaded(e)
	ModInfo.current_stage="control-on-loaded"

	-- if(game.players[e.player_index].mod_settings["Kux-CoreLib_".."on_loaded_LogEvents_StartUpSummary"].value) then
	-- end
end

EventDistributor.register("on_init", internal_on_onit)
EventDistributor.register("on_load", internal_on_load)
EventDistributor.register("on_loaded", internal_on_loaded)
EventDistributor.register("on_configuration_changed", internal_on_configuration_changed)

---------------------------------------------------------------------------------------------------

---Provides EventDistributor in the global namespace
---@return KuxCoreLib.EventDistributor
function EventDistributor.asGlobal() return KuxCoreLib.utils.asGlobal(EventDistributor) end

EventDistributor.__isInitialized = true
for _, fnc in ipairs(EventDistributor.__on_initialized) do fnc() end

return EventDistributor