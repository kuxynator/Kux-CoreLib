require((KuxCoreLibPath or "__Kux-CoreLib__/").."init")

if EventDistributor then
    if EventDistributor.__guid == "{ADD81DB1-53B9-4D61-9279-401AD277DBEE}" then return EventDistributor end
    error("A global EventDistributor class already exist.")
end

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
---@class EventDistributor
EventDistributor = {
	__class  = "EventDistributor",
	__guid   = "{ADD81DB1-53B9-4D61-9279-401AD277DBEE}",
	__origin = "Kux-CoreLib/lib/EventDistributor.lua",
}

-- to avoid circular references, the class MUST be defined before require other modules
KuxCoreLib = KuxCoreLib or require("__Kux_CoreLib__/init")
require(KuxCoreLib.lua)
require(KuxCoreLib.Table)
require(KuxCoreLib.List)

---Dictionary of EventId|EventName, table of function
local events={}

local isOnLoadedRaised = false

local mapEventNumnerToName = {}
for name, value in pairs(defines.events) do
	mapEventNumnerToName[value] = name
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
		eventName = mapEventNumnerToName[eventIdentifier]
		eventId = eventIdentifier
	elseif eventType == "string" then
		eventName = eventIdentifier
		eventId = defines.events[eventIdentifier]
		--if eventId==nil then eventId = 0 end -- "on_init" "on_load" "on_configuration_changed", o.a.
	elseif eventType == "table" then
		eventIdentifier = eventIdentifier.name
		goto start
	end
	return eventName, eventId
end

---Registers an custom event name with its id
---@param id integer number of the custom event
---@param name string name of the custom event
function EventDistributor.registerName(id,name)
	mapEventNumnerToName[id]=name
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
	local handler = events["on_init"]
	if(not handler) then return end
	for _,fnc in pairs(handler) do fnc() end
end

local function on_load()
	--print("EventDistributor.on_load")
	local handler = events["on_load"]
	if(not handler) then return end
	for _,fnc in pairs(handler) do fnc() end
end

local function on_configuration_changed(e)
	--print("EventDistributor.on_configuration_changed")
	local handler = events["on_configuration_changed"]
	if(not handler) then return end
	for _,fnc in pairs(handler) do fnc(e) end
end

local function on_nth_tick(e)
	--print("EventDistributor.on_nth_tick "..e.nth_tick)
	local handler = events["on_nth_tick"][e.nth_tick]
	if(handler) then
		for _,fnc in pairs(handler) do fnc(e) end
	end
end

local function on_loaded(e)
	--print("on_loaded")
	if(isOnLoadedRaised) then return end

	local handler = events.on_loaded
	if(handler) then
		for _,fnc in pairs(handler) do fnc(e) end
	end

	--print("set isLoadRaised=true")
	isOnLoadedRaised = true
	events["on_loaded"] = {}
	EventDistributor.unregister_on_nth_tick(e.nth_tick, on_loaded)
end

local function on_event(e)
	--print("on_event "..getDisplayName(e.name))
	local eventName, eventId = eventPair(e.name)
	local key = eventId or eventName
	local handler = events[key]
	if(not handler) then return end
	for _,fnc in pairs(handler) do fnc(e) end
end

local function on_built(e)
	--print("EventDistributor.on_built")
	local handler = events["on_built"]
	if(not handler) then return end
	for _,fnc in pairs(handler) do fnc(e) end
end

local function on_destroy(e)
	--print("EventDistributor.on_built")
	local handler = events["on_destroy"]
	if(not handler) then return end
	for _,fnc in pairs(handler) do fnc(e) end
end

---Registers an event in script
---@param eventIdentifier integer|uint|string
---@param ticks uint|nil only requiried for on_nth_tick
local function register(eventIdentifier, ticks)
	--log("register: "..getDisplayName(eventIdentifier))
	local eventName, eventId = eventPair(eventIdentifier)
	if    (eventName=="on_init"                 ) then script[eventName](on_init)
	elseif(eventName=="on_load"                 ) then script[eventName](on_load)
	elseif(eventName=="on_configuration_changed") then script[eventName](on_configuration_changed)
	elseif(eventName=="on_nth_tick"             ) then script.on_nth_tick(ticks, on_nth_tick)
	elseif(eventId and eventId > 0              ) then script.on_event(eventId, on_event)
	else error("Unknown event: "..getDisplayName(eventIdentifier))
	end
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
	--print("EventDistributor.register "..getDisplayName(eventIdentifier))
	if(not fnc) then error("Argument 'fnc' must not be nil!") end
	local eventName, eventId = eventPair(eventIdentifier)
	local key = eventId or eventName
	if    (eventName=="nth_tick"  ) then error("Argument out of range. name: eventIdentifier, value: "..eventIdentifier)
	elseif(eventName=="on_loaded" ) then EventDistributor.register_nth_tick(13, on_loaded)
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

---@deprecated
function EventDistributor.init()
	if(false) then
		for key, value in pairs(events) do
			if type(key)=="number" then
				--print("script.on_event "..getEventDisplayName(key))
				script.on_event(key, on_event)
			elseif(key=="on_init" or key=="on_load" or key=="on_configuration_changed")  then
				script[key](on_event)
			elseif(key=="on_nth_tick" ) then
				for ticks, value2 in pairs(value) do
					script.on_nth_tick(ticks,on_event)
				end
			else
				--print("script.on_event "..key .. " is not a number. skipped.")
			end
			-- register_on_entity_destroyed(entity)
			::next::
		end
	end
end

return EventDistributor