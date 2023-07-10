require((KuxCoreLibPath or "__Kux-CoreLib__/").."init")
if(KuxCoreLib.__modules.Event) then return KuxCoreLib.__modules.Event end

--- @class KuxCoreLib.Event The event class represents an event.
--- @field name string Gets the name of the event. [ReadOnly]
--- @field id integer Gets the ID of the event. [ReadOnly]
local Event = {
	__class  = "Event",
	__guid   = "2f60d204-a0b5-4dd1-ae43-63bc65cfbe14",
	__origin = "Kux-CoreLib/lib/Event.lua",
}
KuxCoreLib.__modules.Event = Event

---Create a new event.
---@param eventIdentifier any
---@return KuxCoreLib.Event
function Event:new(eventIdentifier)
	self = {}
	setmetatable(self, Event)
	self.__index = Event
	--self.name, self.id = eventPair(eventIdentifier)
	return self
end

function Event:raise()
	print("raise "..self.id)
end

---------------------------------------------------------------------------------------------------

function Event.asGlobal() return KuxCoreLib.utils.asGlobal(Event) end

return Event