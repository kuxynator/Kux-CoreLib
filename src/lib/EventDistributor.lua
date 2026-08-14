require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

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
---@class KuxCoreLib.EventDistributor : KuxCoreLib.Class
---@field asGlobal fun():KuxCoreLib.EventDistributor Provides EventDistributor in the global namespace
local EventDistributor = {
	__class  = "KuxCoreLib.EventDistributor",
	__guid   = "{ADD81DB1-53B9-4D61-9279-401AD277DBEE}",
	__origin = "Kux-CoreLib/lib/EventDistributor.lua",
}
if not KuxCoreLib.__classUtils.ctor(EventDistributor) then return self end
-- to avoid circular references, the EventDistributor class MUST be defined before require other modules
--------------------------------------------------------------------------------
if(not script) -- events are only available in control stage
	then KuxCoreLib.__classUtils.finalize(EventDistributor) return EventDistributor end
--- control stage only ---------------------------------------------------------

KuxCoreLib.lua.asGlobal()
local Table         = KuxCoreLib.require.Table
local List          = KuxCoreLib.require.List
local ModInfo       = KuxCoreLib.require.ModInfo
local StringBuilder = KuxCoreLib.require.StringBuilder
local Storage       = KuxCoreLib.require.Storage
local PickerDollies = KuxCoreLib.require.PickerDollies ---@see KuxCoreLib.PickerDollies


---@class KuxCoreLib.EventDistributor.this
local this = {}

---@class KuxCoreLib.EventDistributor.handler
local handler = {}

---@class KuxCoreLib.EventDistributor.virtual_handler
local vhandler = {}


if(KuxCoreLib.ModInfo.current_stage ~= "control") then
	KuxCoreLib.__classUtils.finalize(EventDistributor)
	return EventDistributor
end -- events are only available in control stage


---Dictionary of EventName|EventId, table of function
---@type {[string|integer]:EventHandler[]|{[string|integer]: EventHandler[]}}
local events={}

local isOnLoadedRaised = false

---Gets the LuaPlayer for the current event. Managed by KuxCoreLib.EventDistributor. Can be `nil`.
---@type LuaPlayer
_G.player = _G.player

---dynamic registrated events (lazy init)
---@type KuxCoreLib.DynamicEventsRegistry
this.dynamic_events = nil

local mapEventNumberToName = {}; for n, v in pairs(defines.events) do mapEventNumberToName[v] = n end

---Get name and id of an event
---@param eventIdentifier any
---@return string
---@return uint
local function eventPair (eventIdentifier)
	::start::
	local eventName = nil
	local eventId = nil --[[@as defines.events?]]
	local eventType = type(eventIdentifier)
	if eventType == "number" then
		eventName = mapEventNumberToName[eventIdentifier]
		eventId = eventIdentifier
	elseif eventType == "string" then
		eventName = eventIdentifier
		eventId = defines.events[eventIdentifier] --[[@as defines.events]]
		--if eventId==nil then eventId = 0 end -- "on_init" "on_load" "on_configuration_changed", o.a.
	elseif eventType == "table" then
		eventIdentifier = eventIdentifier.name
		eventType = type(eventIdentifier)
		if eventType == "number" then
			eventName = mapEventNumberToName[eventIdentifier]
			eventId = eventIdentifier
		elseif eventType == "string" then
			eventName = eventIdentifier
			eventId = defines.events[eventIdentifier]--[[@as defines.events]]
		end
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
	if(not eventId or eventId<0) then
		return eventName or "unknown"
	else
		return (eventName or "custom").."(ID "..tostring(eventId)..")"
	end
end

EventDistributor.getDisplayName=getDisplayName

--#region event handlers (real handlers for script)

function handler.on_init()
	--print("EventDistributor.on_init")
	local handlers = events["on_init"]

	ModInfo.current_stage="control-on-init"
	Storage.canRead = true
	Storage.canWrite = true

	this.dynamic_events = Storage.getOrCreate("__KuxCoreLib__.EventDistributor.dynamic_events", {})

	for _,h in ipairs(handlers or {}) do h.fnc() end

	--finaly: we set the state in advance, the state is valid on next event or function call
	ModInfo.isModLoaded = true
	ModInfo.current_stage = "control-on-loaded"
end

function handler.on_load()
	ModInfo.current_stage="control-on-load"
	Storage.canRead = true
	Storage.canWrite = false


	local handlers = events["on_load"]
	for _,h in ipairs(handlers or {}) do h.fnc() end

	local stored = this.restoreDynamicEvents()

	if(settings.global["Kux-CoreLib_".."on_load_LogEvents_Summary"].value) then
		this.log_summary()
	end

	if stored then this.dynamic_events = stored end

	 --finaly:  we set the state in advance, the state is valid on next event or function call
	 ModInfo.isModLoaded = true
	 ModInfo.current_stage = "control-on-loaded"
	 Storage.canWrite = true
end

function handler.on_configuration_changed(e)
	ModInfo.current_stage = "control-on-configuration-changed"
	Storage.canRead = true
	Storage.canWrite = true

	--print("EventDistributor.on_configuration_changed")
	local handlers = events["on_configuration_changed"]
	for _,h in ipairs(handlers or {}) do h.fnc(e) end

	-- we set the state in advance, the state is valid on next tick
	ModInfo.current_stage = "control-on-loaded"
end

---
function handler.on_nth_tick(e)
	--print("EventDistributor.on_nth_tick "..e.nth_tick)
	local handlers = events["on_nth_tick"][e.nth_tick]
	for _,h in ipairs(handlers or {}) do h.fnc(e) end
end


---
function handler.on_event(e)
	--log("on_event "..getDisplayName(e))

	local restore = _G.player
	_G.player = EventDistributor.getPlayerFnc(e) or _G.player
	local playerCheck = _G.player
	if e.player_index~=nil and not _G.player then error("invalid state") end
	local eventName, eventId = eventPair(e.name)
	local handlers = events[eventName or eventId]
	local repeat_handlers = {}
	for _,h in ipairs(handlers or {}) do
		h.fnc(e)
		if _G.player ~= playerCheck then
			local i = debug.getinfo(h.fnc, "Sl")
			error("invalid (global) player change detetcted.\n\tin "..i.short_src..":"..i.linedefined)
		end
		if e.distributor_repeat_low then repeat_handlers[h.fnc] = true end
	end
	for _,fnc in pairs(repeat_handlers or {}) do
		fnc(e)
		if _G.player ~= playerCheck then
			local i = debug.getinfo(fnc, "Sl")
			error("invalid (global) player change detetcted.\n\tin "..i.short_src..":"..i.linedefined)
		end
	end
	_G.player = restore
end



---
function handler.on_event_customInput(e)
	--log("on_event_customInput "..getDisplayName(e))

	local restore = _G.player
	_G.player = EventDistributor.getPlayerFnc(e)
	local name, number = eventPair(e)
	local handlers = events[name]
	for _,h in ipairs(handlers or {}) do h.fnc(e) end
	_G.player = restore
end

--#region virtual handler

---
---@param e KuxCoreLib.StartEventData
function vhandler.on_start(e)
	local handlers = events["on_start"]
	for _,h in ipairs(handlers or {}) do h.fnc(e) end
end

---@param e NthTickEventData
function vhandler.on_loaded(e)
	if isOnLoadedRaised then return end

	EventDistributor.unregister_on_nth_tick(e.nth_tick, vhandler.on_loaded)
	isOnLoadedRaised = true

	local handlers = events.on_loaded
	events.on_loaded = {}

	if game.is_multiplayer() and #game.connected_players > 0 then
		log("\nWARNING: on_loaded supressed for clients due multiplayer restrictions. "..ModInfo.name)
		return end

	log("EventDistributor.on_loaded "..#handlers.." handlers")
	for _, h in ipairs(handlers or {}) do h.fnc(e) end
end


---
function vhandler.on_built(e)
	--print("EventDistributor.on_built")
	local restore = _G.player
	_G.player = EventDistributor.getPlayerFnc(e) or _G.player
	local handlers = events["on_built"]
	if(not handlers) then return end
	for _,h in ipairs(handlers or {}) do h.fnc(e) end
	_G.player = restore
end

---
function vhandler.on_destroy(e)
	--print("EventDistributor.on_destroy")
	local restore = _G.player
	_G.player = EventDistributor.getPlayerFnc(e) or _G.player
	if     e.name == defines.events.on_robot_pre_mined then return
	elseif e.name == defines.events.on_pre_player_mined_item then return
	elseif e.name == defines.events.on_space_platform_pre_mined then return
	end

	local handlers = events["on_destroy"]
	if(not handlers) then return end
	for _,h in ipairs(handlers or {}) do h.fnc(e) end
	_G.player = restore
end

---@param e NthTickEventData
local function on_timer(e)
	local handlers = events["on_timer"][e.tick]
	if(handlers) then
		for _,h in ipairs(handlers or {}) do h.fnc(e) end
		events["on_timer"][e.tick] = nil
		if(Table.count(events["on_timer"]) == 0) then
			EventDistributor.unregister_on_nth_tick(1, on_timer)
		end
	end
end

---@class KuxCoreLib.on_entity_moved : PickerDollies.dolly_moved_entity
---@field name string name of the event "on_entity_moved"
---@field tick uint the tick the event was raised
---@field entity LuaEntity the entity that was moved
---@field start_postion MapPosition the position the entity was moved from

---@param e PickerDollies.dolly_moved_entity
local function on_entity_moved(e)
	local restore = _G.player
	_G.player = EventDistributor.getPlayerFnc(e) or _G.player
	local handlers = events["on_entity_moved"]
	if not handlers then return end
	local e1 = e ---@cast e1 KuxCoreLib.on_entity_moved
	-- we leave the dolly_moved_entity fields intact and add the on_entity_moved fields
	e1.name = "on_entity_moved"
	e1.entity = e.moved_entity
	e1.start_postion = e.start_pos

	for _,h in ipairs(handlers) do h.fnc(e1) end
	_G.player = restore
end

--#endregion event handlers

local function check_customInput(name)
	if(prototypes.custom_input[name]) then return end
	error("CustomInput does not exist. Name:'"..tostring(name).."'")
end

---Registers an event in script
---@param eventIdentifier integer|uint|string|defines.events
---@param param any ticks | filter
function this.script_register(eventIdentifier, param, isRestore)
	--log("register: "..getDisplayName(eventIdentifier))
	local eventName, eventId = eventPair(eventIdentifier)
	local key = eventName or eventId

	if    (eventName=="on_init"                 ) then script[eventName](handler.on_init)
	elseif(eventName=="on_load"                 ) then script[eventName](handler.on_load)
	elseif(eventName=="on_configuration_changed") then script[eventName](handler.on_configuration_changed)
	elseif(eventName=="on_nth_tick"             ) then script.on_nth_tick(param,  handler.on_nth_tick)
	elseif(eventId and eventId >= 0             ) then script.on_event(eventId,   handler.on_event, param)
	else   --[[check_customInput(eventName); ]]        script.on_event(eventName, handler.on_event_customInput)
	end
	-- can't use check_customInput, because 'game' is not yet available

	if not isRestore and ModInfo.isModLoaded and this.dynamic_events then
		if eventName=="on_nth_tick" then
			this.dynamic_events[key] = this.dynamic_events[key] or {}
			this.dynamic_events[key][param] = true
		else
			this.dynamic_events[key] = true
		end
	end
end

local function removeHandler(t, fnc)
	for i, v in ipairs(t) do
		if v.fnc == fnc then table.remove(t,i) return end
	end
end

---Unregisters an event in script
---@param eventIdentifier eventIdentifier
---@param ticks uint|nil only required for on_nth_tick
local function script_unregister(eventIdentifier, ticks)
	if eventIdentifier == "on_nth_tick"  and not ticks then error("ticks are required for on_nth_tick") end

	local eventName, eventId = eventPair(eventIdentifier)
	local key = eventName or eventId

	if ModInfo.isModLoaded and this.dynamic_events then
		if key == "on_nth_tick" then
			this.dynamic_events[key] = this.dynamic_events[key] or {}
			if not this.dynamic_events[key][ticks or 0] then return end
		else
			if not this.dynamic_events[key] then return end
		end
	end

	--if(game.is_multiplayer()) then return end
	--log("unregister: "..getDisplayName(eventIdentifier)..iif(ticks~=nil," ticks="..ticks,""))

	if    (eventName=="on_init"                 ) then script[eventName](nil)
	elseif(eventName=="on_load"                 ) then script[eventName](nil)
	elseif(eventName=="on_configuration_changed") then script[eventName](nil)
	elseif(eventName=="on_nth_tick"             ) then script.on_nth_tick(ticks, nil)
	elseif(eventId and eventId >= 0             ) then script.on_event(eventId, nil)
	else error("Unknown event: "..getDisplayName(eventIdentifier))
	end

	if ModInfo.isModLoaded and this.dynamic_events then
		if key == "on_nth_tick" then
			this.dynamic_events[key] = this.dynamic_events[key] or {}
			this.dynamic_events[key][ticks or 0] = nil
		else
			this.dynamic_events[key] = nil
		end
	end
end

---Unregisters an event
---@param eventIdentifier integer|uint|string|defines.events
---@param fnc function
function EventDistributor.unregister(eventIdentifier, fnc)
	assert(fnc~=nil, "Invalid Argument. 'fnc' must not be nil!")
	local eventName, eventId = eventPair(eventIdentifier)
	local key = eventName or eventId
	removeHandler(events[key], fnc)
	if(not events[key] or #events[key]>0) then return end
	if(eventName=="on_built") then
		EventDistributor.unregister(defines.events.on_built_entity,                 vhandler.on_built)
		EventDistributor.unregister(defines.events.on_robot_built_entity,           vhandler.on_built)
		EventDistributor.unregister(defines.events.script_raised_built,             vhandler.on_built)
		EventDistributor.unregister(defines.events.script_raised_revive,            vhandler.on_built)
		EventDistributor.unregister(defines.events.on_space_platform_built_entity,  vhandler.on_built)
	elseif(eventName=="on_destroy") then
		EventDistributor.unregister(defines.events.on_pre_player_mined_item,        vhandler.on_destroy)
		EventDistributor.unregister(defines.events.on_robot_pre_mined,              vhandler.on_destroy)
		EventDistributor.unregister(defines.events.on_entity_died,                  vhandler.on_destroy)
		EventDistributor.unregister(defines.events.script_raised_destroy,           vhandler.on_destroy)
		EventDistributor.unregister(defines.events.on_space_platform_mined_entity,  vhandler.on_destroy)
	elseif(eventName=="on_entity_moved") then
		error("Not implemented")
		--TODO PickerDollies.unregister()
	else
		script_unregister(eventIdentifier)
	end
end

local function containsFunction(t,fnc)
	for i, v in ipairs(t) do
		if v.fnc == fnc then return i end
	end
end

---
---@param list table
---@param fnc function
---@param prio integer
---@return boolean
function insertSorted(list, fnc, prio)
	-- check duplicate
	for _, h in ipairs(list) do if h.fnc == fnc then return false end end

	-- search position
	local pos = #list + 1
	for i = 1, #list do
		if (list[i].prio or 0) < prio then
			pos = i
			break
		end
	end

	-- insert
	table.insert(list, pos, { fnc = fnc, prio = prio })
	return true
end

---@param key string
---@param fnc function
---@return boolean
local function register_artifical_event(key, fnc)
	events[key] = events[key] or {}
	if #events[key]==0 then
		--if(eventName ~= "on_loaded") then register(eventIdentifier, param) end
	else
		if(containsFunction(events[key], fnc)) then
			error("Multiple registration of same event is not supported. name: '"..key.."'")
			--TODO: allow reregister the event
			return false
		end
	end
	local r insertSorted(events[key], fnc, 0); return r --avoids fucking tail calls!! who came up with this nonsense?
end

---
---@param prio nil|"low"|"hight"|integer
---@return integer
local function toPrio(prio)
	return prio=="low" and -1 or  prio=="hight" and 1 or prio or 0 --[[@as integer]]
end

---Registers an event
---@param eventIdentifier integer|uint|string|defines.events|table
---@param fnc function
---@param arg any Optional parameter, depends on eventIdentifier (filter)
---@param prio nil|"low"|"hight"|integer
---@return boolean #true if succesfully registered else false
function EventDistributor.register (eventIdentifier, fnc, arg, prio)
	assert(eventIdentifier~=nil,  "Invalid Argument. 'eventIdentifier' must not be nil.")
	assert(fnc~=nil,              "Invalid Argument. 'fnc' must not be nil.")
	assert(type(fnc)=="function", "Invalid Argument. 'fnc' must be a function.")

	if(type(eventIdentifier)=="table") then
		for _, ei in ipairs(eventIdentifier) do
			EventDistributor.register(ei, fnc, arg)
		end
		return true
	end
	--print("EventDistributor.register "..getDisplayName(eventIdentifier))

	local eventName, eventId = eventPair(eventIdentifier)
	local key = eventName or eventId
	if    (eventName=="nth_tick"       ) then error("Argument out of range. name: eventIdentifier, value: "..eventIdentifier)
	elseif(eventName=="on_loaded"      ) then EventDistributor.register_nth_tick(1, vhandler.on_loaded)
	elseif(eventName=="on_next_tick"   ) then EventDistributor.register_on_next_tick(arg, fnc)
	elseif(eventName=="on_timer"       ) then error("Argument out of range. name: eventIdentifier, value: "..eventIdentifier)
	elseif(eventName=="on_built"       ) then EventDistributor.register_on_built(arg, fnc); return true
	elseif(eventName=="on_start"       ) then EventDistributor.register_on_start(fnc); return true
	elseif(eventName=="on_destroy"     ) then EventDistributor.register_on_destroy(arg, fnc); return true
	elseif(eventName=="on_entity_moved") then EventDistributor.register_on_entity_moved(fnc, arg) return true
	end

	local no_script_register={on_loaded=true}
	events[key] = events[key] or {}
	if(#events[key] == 0) then
		if not no_script_register[eventName] then this.script_register(eventIdentifier, arg) end
	end
	return insertSorted(events[key], fnc, toPrio(prio))
end

---Registers an on_nth_tick event
---@param ticks uint
---@param fnc function
---@param prio nil|"low"|"hight"|integer
---@return boolean #true if succesfully registered else false
function EventDistributor.register_nth_tick(ticks, fnc, prio)
	--print("EventDistributor.register "..getDisplayName("on_nth_tick"))
	assert(type(fnc)=="function", "Invalid Argument. 'fnc' must be a function.")
	events["on_nth_tick"] = events["on_nth_tick"] or {}
	events["on_nth_tick"][ticks] = events["on_nth_tick"][ticks] or {}
	if #events["on_nth_tick"][ticks] == 0 then
		this.script_register("on_nth_tick",ticks)
	end
	return insertSorted(events["on_nth_tick"][ticks],fnc,toPrio(prio))
end

---Registers an on_nth_tick event
---@param ticks uint
---@param fnc function
function EventDistributor.unregister_on_nth_tick(ticks, fnc)
	--print("EventDistributor.unregister_on_nth_tick "..tick)
	assert(type(fnc)=="function", "Invalid Argument. 'fnc' must be a function.")
	removeHandler(events["on_nth_tick"][ticks], fnc)
	if(#events["on_nth_tick"][ticks]>0) then return end
	script_unregister("on_nth_tick",ticks)
end

---Registers an on_timer
---@param tick uint the number of ticks after the event is raised.
---@param fnc function
---@param prio nil|"low"|"hight"|integer
---@return boolean #true if succesfully registered else false
function EventDistributor.register_on_timer(tick, fnc, prio)
	assert(type(tick)=="number", "Invalid Argument. 'tick' must be a integer.")
	assert(type(fnc)=="function", "Invalid Argument. 'fnc' must be a function.")
	tick = tick + game.tick
	events["on_timer"] = events["on_timer"] or {}
	events["on_timer"][tick] = events["on_timer"][tick] or {}
	if (#events["on_timer"][tick]==0) then
		EventDistributor.register_nth_tick(1, on_timer)
	end
	return insertSorted(events["on_timer"][tick], fnc, toPrio(prio))
end

---@type {[uint]:{fnc:function,state:any}[]}
local next_tick_registrations = {}

---@class KuxCoreLib.NextTickEventData
---@field tick uint 32 bit unsigned integer. Ranges from 0 to 4 294 967 295, or [0, 2^32-1] <br/>The tick during which the event happened.
---@field name "on_next_tick"
---@field state object? custom event data

---distributes the on_next_tick events
---@param e NthTickEventData
local function on_next_tick(e)
	local reg = next_tick_registrations[e.tick]
	if not reg then return end
	for _, d in ipairs(reg) do
		local arg = {
			tick = e.tick,
			name = "on_next_tick",
			state = d.state
		}
		d.fnc(arg) -- raise --TODO use pcal?
	end
	next_tick_registrations[e.tick] = nil
end

---Registers a function to be called on next tick
---@param state object? a custom state object for the event
---@param fnc fun(KuxCoreLib.NextTickEventData)
---@return true
function EventDistributor.register_on_next_tick(state, fnc)
	next_tick_registrations[game.tick+1] = next_tick_registrations[game.tick+1] or {}
	table.insert(next_tick_registrations[game.tick+1],{fnc=fnc,state=state})
	EventDistributor.register_nth_tick(1, on_next_tick)
	return true
end


function EventDistributor.register_on_built(item_filter, fnc)
	register_artifical_event("on_built", fnc)

	--TODO: join item_filter. at the moment only the first resgistration works!

	--on_pre_build
    EventDistributor.register(defines.events.on_built_entity,       vhandler.on_built, item_filter)
    EventDistributor.register(defines.events.on_robot_built_entity, vhandler.on_built, item_filter)
    EventDistributor.register(defines.events.script_raised_built,   vhandler.on_built, item_filter)
    EventDistributor.register(defines.events.script_raised_revive,  vhandler.on_built, item_filter)
	EventDistributor.register(defines.events.on_space_platform_built_entity,  vhandler.on_built, item_filter) -- new in Factorio 2.0
end

function EventDistributor.register_on_start(fnc)
	register_artifical_event("on_start", fnc)

	EventDistributor.register("on_init", function() vhandler.on_start({source="on_init"}) end)
	EventDistributor.register("on_load", function() vhandler.on_start({source="on_load"}) end)
	EventDistributor.register("on_configuration_changed", function(e)
		local e1 = table.deepcopy(e)
		e1.source = "on_configuration_changed";
		vhandler.on_start(e1)
	end)
end

function EventDistributor.register_on_destroy(item_filter, fnc)
	register_artifical_event("on_destroy", fnc)

	--TODO: join item_filter. at the moment only the first resgistration works!

	--internal only, not distributed:
	EventDistributor.register(defines.events.on_pre_player_mined_item,       vhandler.on_destroy, item_filter)
	EventDistributor.register(defines.events.on_robot_pre_mined,             vhandler.on_destroy, item_filter)
	EventDistributor.register(defines.events.on_space_platform_pre_mined,    vhandler.on_destroy, item_filter) -- new in Factorio 2.0
	--EventDistributor.register(defines.events.on_robot_mined,                 vhandler.on_destroy, nil)

	--distributed: (this are all event where the entity is yet valid)
	EventDistributor.register(defines.events.on_player_mined_entity,         vhandler.on_destroy, item_filter)
	EventDistributor.register(defines.events.on_robot_mined_entity,          vhandler.on_destroy, item_filter)
	EventDistributor.register(defines.events.on_entity_died,                 vhandler.on_destroy, item_filter)
	EventDistributor.register(defines.events.script_raised_destroy,          vhandler.on_destroy, item_filter)
	EventDistributor.register(defines.events.on_space_platform_mined_entity, vhandler.on_destroy, item_filter) -- new in Factorio 2.0

	--on_post_entity_died?
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

function EventDistributor.register_on_entity_moved(fnc, filter)
	--[[TRACE]]trace("EventDistributor.register_on_entity_moved")
	register_artifical_event("on_entity_moved", fnc)
	PickerDollies.initialize(on_entity_moved, filter)
	if(ModInfo.current_stage=="control") then
		--we can not register the event yet, because we need the event Id from PickerDollies and this can only be retrieved when an event occurs.
		EventDistributor.register("on_load", PickerDollies.initialize)
		EventDistributor.register("on_init", PickerDollies.initialize)
	end
end

---@type fun(event:table):LuaPlayer?
EventDistributor.getPlayerFnc = function(e)
	if not e then return nil end
	if(e.player_index) then return game.players[e.player_index] end
	return nil
end

function this.log_summary()
	local sb = StringBuilder:new()
	sb:appendLine(ModInfo.name.." registered events:")
	for key, v1 in pairs(events) do
		if(Table.isNilOrEmpty(v1)) then goto next end
		if(key=="on_nth_tick") then
			sb:appendLine("  " .. getDisplayName(key))
			for k2, v2 in ipairs(v1) do
				if(not Table.isNilOrEmpty(v2)) then sb:appendLine("    " ..k2) end
				for _, v3 in ipairs(v2) do
					sb:appendLine("      " .. debug.getinfo(v3.fnc,"S").short_src)
				end
			end
		else
			sb:appendLine("  " .. getDisplayName(key))
			for _, v3 in ipairs(v1) do
				sb:appendLine("      " .. debug.getinfo(v3.fnc,"S").short_src)
			end
		end
		::next::
	end
	log(sb:toString())
end


---@class this_mt
local this_mt = {}

function this_mt.__index(t,k)
	if k=="dynamic_events" then
		if not Storage.canWrite then return nil end
		rawset(t, k, Storage.getOrCreate("__KuxCoreLib__.EventDistributor.dynamic_events", {}))
	else
		return EventDistributor[k]
	end
end
setmetatable(this, this_mt)

---Restores the dynamic events from storage, if present, and returns the restored table; otherwise returns nil
---@return KuxCoreLib.DynamicEventsRegistry?
function this.restoreDynamicEvents()
	local stored = Storage.get("__KuxCoreLib__.EventDistributor.dynamic_events")
	if not stored then return nil end
	local isRestore = true
	for key, value in pairs(stored) do
		if key == "on_nth_tick" then
			for ticks in pairs(value) do
				this.script_register(key, ticks, isRestore)
			end
		elseif value then
			this.script_register(key, nil, isRestore)
		end
	end
	return stored
end


local function internal_on_init() end
local function internal_on_load() end
local function internal_on_configuration_changed(e) end
local function internal_on_loaded(e)end

EventDistributor.register("on_init"                 , internal_on_init)
EventDistributor.register("on_load"                 , internal_on_load)
EventDistributor.register("on_configuration_changed", internal_on_configuration_changed)
EventDistributor.register("on_loaded"               , internal_on_loaded)

---------------------------------------------------------------------------------------------------
KuxCoreLib.__classUtils.finalize(EventDistributor)
return EventDistributor

---@alias eventIdentifier int|string|defines.events

---@alias KuxCoreLib.DynamicEventsRegistry {[eventIdentifier]: ("true" | {[integer]: "true"}) }

---@class EventHandler
---       ‾‾‾‾‾‾‾‾‾‾‾‾‾
---@field fnc function
---@field prio integer


---@class (exact) KuxCoreLib.PlayerStartupEventData
---               ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
---@field mod_name string?         The name of the mod that raised the event if it was raised using LuaBootstrap::raise_event.
---@field tick integer             The tick during which the event happened.
---@field name "on_player_startup" Identifier of the event.
---@field original_name defines.events|string Identifier of the event.
---@field player_index integer


---@class (exact) KuxCoreLib.StartEventData : ConfigurationChangedData
---               ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
---@field source "on_init"|"on_load"|"on_configuration_changed"|"custom_start"
---@field mod_name string The mod that triggered a `custom_start`
---
---Old version of the map. Present only when loading map version other than the current version.
---@field old_version? string
---@
---
---New version of the map. Present only when loading map version other than the current version.
---@field new_version? string
---@
---
---Dictionary of mod changes. It is indexed by mod name.
---@field mod_changes table<string,ModChangeData>
---@
---
---`true` when mod startup settings have changed since the last time this save was loaded.
---@field mod_startup_settings_changed boolean
---@
---
---`true` when mod prototype migrations have been applied since the last time this save was loaded.
---@field migration_applied boolean
---@
---
---Dictionary of prototype changes due to [migrations](https://lua-api.factorio.com/latest/migrations.html). The inner dictionary maps the old prototype name to the new prototype name. The new name will be an empty string if the prototype was removed. Entries are omitted if the old and new prototype name are the same.
---@field migrations table<IDType,table<string,string>>
---@