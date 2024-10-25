-- USAGE: require("__Kux-CoreLib__/lib/Globals")


if(script) then -- control-stage
	_G.mods = script.active_mods
end
_G.isV1 = string.sub(mods["base"], 1, 2) == "1."
_G.isV2 = string.sub(mods["base"], 1, 2) == "2."

