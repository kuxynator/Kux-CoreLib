--from Kux-Modifications
local mapEventNumnerToName = {}
for name, value in pairs(defines.events) do
	mapEventNumnerToName[value] = name
end

EventDistributor = EventDistributor or {}

EventDistributor.on_init = EventDistributor.on_init or {}
EventDistributor.on_configuration_changed = EventDistributor.on_configuration_changed or {}
EventDistributor.onLoaded = EventDistributor.onLoaded or {} --custom event, one time 60 ticks after on_load/on_init

local eventPair
eventPair = function (event)
	::start::
	local eventName = nil
	local eventId = nil	
	local eventType = type(event)
	if eventType == "number" then
		eventName = mapEventNumnerToName[event] --possible nil TODO
		eventId = event
	elseif eventType == "string" then
		eventName = event
		eventId = defines.events[event] -- possible nil TODO
	elseif eventType == "table" then
		event = event.name
		goto start
	end
	return eventName, eventId
end

local getEventDisplayName = function (event)
	local eventName, eventId = eventPair(event)
	return tostring(eventName).."("..tostring(eventId)..")"
end

EventDistributor.raise = function (e)
	local eventName, eventId = eventPair(e.name)
	print("EventDistributor.raise "..getEventDisplayName(e.name))
	local handler = EventDistributor[e.name] -- TODO e.name is always a number?
	for _,fnc in pairs(handler) do fnc(e) end
end

EventDistributor.register = function (event, fnc)
	print("EventDistributor.register "..getEventDisplayName(event))
	local eventName, eventId = eventPair(event)
	if not EventDistributor[eventId] then EventDistributor[eventId] = {fnc}
	else table.insert(EventDistributor[eventId], fnc) end
end

local isLoadRaised = false
EventDistributor.init = function ()
	print("EventDistributor.init")

	script.on_nth_tick(60,function (e)
		if isLoadRaised == false then
			isLoadRaised = true
			for _,fnc in pairs(EventDistributor.onLoaded) do fnc(e) end
		end
	end)

	for key, value in pairs(EventDistributor) do
		if key=="init" or  key=="raise" or  key=="register" then goto next end
		if type(key)=="number" then
			print("script.on_event "..getEventDisplayName(key))
			script.on_event(key, EventDistributor.raise)
		else
			print("script.on_event "..key .. " is not a number. skipped.")
		end
		::next::
	end
end