--- @class Event The event class represents an event.
--- @field name string Gets the name of the event. [ReadOnly]
--- @field id integer Gets the ID of the event. [ReadOnly]
local Event = {}

--require("__Kux-CoreLib__/")

---Create a new event.
---@param eventIdentifier any
---@return Event
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

return Event