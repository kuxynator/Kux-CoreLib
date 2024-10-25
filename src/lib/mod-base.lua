-- USAGE: local mod = require("__Kux-CoreLib__/lib/mod-base"):clone("<YOUR-MOD-NAME>")

KuxCoreLibPath = KuxCoreLibPath or "__Kux-CoreLib__/"
require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/Globals")
require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/Factorio20Migrations")
require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/Factorio11BackwardCompatibility")

--- mod-base class
---@class KuxCoreLib.ModBase
---@field name string The name of the mod
---@field path string The file path of the mod
---@field prefix string The prefix used by the mod
local mod = {}

mod.name = "mod-base"
mod.path = "__"..mod.name.."__/"
mod.prefix = mod.name.."-"

mod.clone = function(self, name)
	local copy = {}
	for k, v in pairs(self) do
		if(k ~= "clone") then
        	copy[k] = v
		end
    end

	if(name) then
		copy.name = name
		copy.path="__"..name.."__/"
		copy.prefix=name.."-"
	else
		copy.name = nil
		copy.path = nil
		copy.prefix = nil
	end

	return copy
end

return mod