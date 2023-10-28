require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")
if(KuxCoreLib.__modules.PickerDollies) then return KuxCoreLib.__modules.PickerDollies end

---@class KuxCoreLib.PickerDollies
local PickerDollies = {
	__class  = "PickerDollies",
	__guid   = "b4f4811e-d7e6-4fdd-ac5d-97042bce5a7c",
	__origin = "Kux-CoreLib/lib/PickerDollies.lua",
}
KuxCoreLib.__modules.PickerDollies = PickerDollies
---------------------------------------------------------------------------------------------------
---Provides PickerDollies in the global namespace
---@return KuxCoreLib.PickerDollies
function PickerDollies.asGlobal() return KuxCoreLib.utils.asGlobal(PickerDollies) end
---------------------------------------------------------------------------------------------------
local ModInfo = KuxCoreLib.ModInfo

local _eventDistributor_callback
local _dolly_moved_entity_id = nil --[[@as uint?]]
local _filter = nil --[[@as EventFilter?]]

--https://mods.factorio.com/mod/PickerDollies


---@class PickerDollies.dolly_moved_entity
---@field player_index uint        The index of the player who moved the entity
---@field moved_entity LuaEntity   The entity that was moved
---@field start_pos    MapPosition The position that the entity was moved from

---@param e PickerDollies.dolly_moved_entity
local function on_entity_moved(e)
	_eventDistributor_callback(e)
end

---@param eventDistributor_callback function?
---@param filter EventFilter?
function PickerDollies.initialize(eventDistributor_callback, filter)
	--[[TRACE]]trace("PickerDollies.initialize")
	_eventDistributor_callback = _eventDistributor_callback or eventDistributor_callback or error("Invalid Argument: 'eventDistributor' must not be nil.")
	_filter = _filter or filter

	if(ModInfo.current_stage == "control") then return end -- ok, but wait for on_init or on_load

	if not remote.interfaces["PickerDollies"] or not remote.interfaces["PickerDollies"]["dolly_moved_entity_id"] then
		log("WARNING: PickerDollies is not available. event on_entity_moved woll not be raised.")
		return
	end

	_dolly_moved_entity_id = remote.call("PickerDollies", "dolly_moved_entity_id") --[[@as uint]]
	local handler = script.get_event_handler(_dolly_moved_entity_id)
	if(handler) then error("PickerDollies event handler already registered") end
	script.on_event(_dolly_moved_entity_id, on_entity_moved)
end


---------------------------------------------------------------------------------------------------



return PickerDollies
