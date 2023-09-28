require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")
if(KuxCoreLib.__modules.Events) then return KuxCoreLib.__modules.Events end

---@class KuxCoreLib.Events
local Events = {
	__class  = "Events",
	__guid   = "92a52084-19c4-4577-a8c7-714efb79644f",
	__origin = "Kux-CoreLib/lib/Events.lua",

	__isInitialized = false,
	__on_initialized = {}
}
KuxCoreLib.__modules.Events = Events
---------------------------------------------------------------------------------------------------
local function initilized()
	Events.__isInitialized = true
	for _, fnc in ipairs(Events.__on_initialized) do fnc() end
end

---Provides Events in the global namespace
---@return KuxCoreLib.Events
function Events.asGlobal() return KuxCoreLib.utils.asGlobal(Events) end
---------------------------------------------------------------------------------------------------

if(KuxCoreLib.ModInfo.current_stage ~= "control") then
	initilized()
	return Events
end -- events are only available in control stage

--- control stage only ----------------------------------------------------------------------------

local EventDistributor = KuxCoreLib.EventDistributor

Events.getDisplayName = EventDistributor.getDisplayName or error("Invalid state.")
Events.registerName = EventDistributor.registerName or error("Invalid state.")

---@param fnc function
---@return boolean
function Events.on_load(fnc) return EventDistributor.register("on_load", fnc) end

---[FOR DEVELOPMENT ONLY]
---@param fnc function
---@return boolean
function Events.on_loaded(fnc) return EventDistributor.register("on_loaded", fnc) end

---@param fnc function
---@return boolean
function Events.on_init(fnc) return EventDistributor.register("on_init", fnc) end

---@param fnc function
---@return boolean
function Events.on_configuration_changed(fnc) return EventDistributor.register("on_configuration_changed", fnc) end

---@param event integer|string defines.events or event name
---@param fnc function
---@param filters EventFilter?
---@return boolean
function Events.on_event(event, fnc, filters) return EventDistributor.register(event, fnc, filters) end

---@param tick uint
---@param fnc function
---@return boolean
function Events.on_nth_tick(tick, fnc) return EventDistributor.register_nth_tick(tick, fnc) end

---[EXPERIMENTAL] 
---@param tick uint
---@param fnc function
---@return boolean
function Events.on_timer(tick, fnc) return EventDistributor.register_on_timer(tick, fnc) end

---[EXPERIMENTAL] on_built_entity, on_robot_built_entity, script_raised_built, script_raised_revive
---@param fnc function
---@param filters EventFilter?
---@return boolean
function Events.on_built(fnc, filters) return EventDistributor.register("on_built", fnc, filters) end


---[EXPERIMENTAL] on_pre_player_mined_item, on_robot_pre_mined, on_entity_died, script_raised_destroy
---@param fnc function
---@param filters EventFilter?
---@return boolean
function Events.on_destroy(fnc, filters) return EventDistributor.register("on_destroy", fnc, filters) end

---[EXPERIMENTAL] on_entity_moved (using PickerDollies)
---@param fnc fun(e: KuxCoreLib.on_entity_moved)
---@param filters EventFilter? [Not Implemented]
---@return boolean
function Events.on_entity_moved(fnc, filters) return EventDistributor.register("on_entity_moved", fnc, filters) end

---Registeres an custom event
---@param input_name string
---@param fnc fun(e: EventData.CustomInputEvent)
---@return unknown
function Events.on_custom_input(input_name, fnc) return EventDistributor.register(input_name, fnc) end

---------------------------------------------------------------------------------------------------
initilized()
return Events