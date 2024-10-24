-- USAGE: local mod = require("__Kux-CoreLib__/lib/mod-base"):clone("<YOUR-MOD-NAME>")

local mod = {}

mod.name = "mod-base"
mod.path="__"..mod.name.."__/"
mod.prefix=mod.name.."-"

if(script) then -- control-stage
	_G.isV1 = pcall(function() return game.active_mods ~= nil end)
	_G.mods = script.active_mods
end
_G.isV2 = string.sub(mods["base"], 1, 2) == "2."


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