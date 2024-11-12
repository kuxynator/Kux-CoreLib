--- Wrapper for the "freeplay" remote interface.
---@class KuxCoreLib.FreeplayInterface
local Freeplay = {}

---Gets a value indicating whether the 'freeplay' remote interfaces is available.
Freeplay.isAvailable = remote.interfaces["freeplay"] ~= nil

---Gets the created items.
---@return table
function Freeplay:get_created_items()
	return remote.call("freeplay", "get_created_items")
end

---Sets the created items.
---@param items table
function Freeplay:set_created_items(items)
	remote.call("freeplay", "set_created_items", items)
end

---Gets the respawn items.
---@return table
function Freeplay:get_respawn_items()
	return remote.call("freeplay", "get_respawn_items")
end

---Sets the respawn items.
---@param items table
function Freeplay:set_respawn_items(items)
	remote.call("freeplay", "set_respawn_items", items)
end

---Sets whether to skip the intro.
---@param skip boolean
function Freeplay:set_skip_intro(skip)
	remote.call("freeplay", "set_skip_intro", skip)
end

---Gets whether the intro is set to be skipped.
---@return boolean
function Freeplay:get_skip_intro()
	return remote.call("freeplay", "get_skip_intro")
end

---Sets the custom intro message.
---@param message string
function Freeplay:set_custom_intro_message(message)
	remote.call("freeplay", "set_custom_intro_message", message)
end

---Gets the custom intro message.
---@return string
function Freeplay:get_custom_intro_message()
	return remote.call("freeplay", "get_custom_intro_message")
end

---Sets the chart distance.
---@param distance number
function Freeplay:set_chart_distance(distance)
	remote.call("freeplay", "set_chart_distance", distance)
end

--[[ MISSING
---Gets the chart distance.
---@return number
function Freeplay:get_chart_distance()
	return remote.call("freeplay", "get_chart_distance")
end
]]

---Sets whether the crash site is disabled.
---@param disable boolean
function Freeplay:set_disable_crashsite(disable)
	remote.call("freeplay", "set_disable_crashsite", disable)
end

---Gets whether the crash site is disabled.
---@return boolean
function Freeplay:get_disable_crashsite()
	return remote.call("freeplay", "get_disable_crashsite")
end

---Gets whether the initialization has run.
---@return boolean
function Freeplay:get_init_ran()
	return remote.call("freeplay", "get_init_ran")
end

---Gets the ship items.
---@return table
function Freeplay:get_ship_items()
	return remote.call("freeplay", "get_ship_items")
end

---Sets the ship items.
---@param items table
function Freeplay:set_ship_items(items)
	remote.call("freeplay", "set_ship_items", items)
end

---Gets the debris items.
---@return table
function Freeplay:get_debris_items()
	return remote.call("freeplay", "get_debris_items")
end

---Sets the debris items.
---@param items table
function Freeplay:set_debris_items(items)
	remote.call("freeplay", "set_debris_items", items)
end

---Gets the ship parts.
---@return table
function Freeplay:get_ship_parts()
	return remote.call("freeplay", "get_ship_parts")
end

---Sets the ship parts.
---@param parts table
function Freeplay:set_ship_parts(parts)
	remote.call("freeplay", "set_ship_parts", parts)
end

setmetatable(Freeplay, {
	__index = function(t, k)
		error("Attempt to access non-existant Member '"..k.."' in Freeplay interface.")
	end,
})

local p = setmetatable({}, {
	__index = Freeplay,
	__newindex = function(t, k, v)
		error("Attempt to write to protected object. Member '"..k.."' in Freeplay interface.")
	end,
})
return p --[[@as KuxCoreLib.FreeplayInterface]]
