require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")
if(KuxCoreLib.__modules.PrototypeData) then return KuxCoreLib.__modules.PrototypeData end

---@class KuxCoreLib.PrototypeData
local PrototypeData = {
	__class  = "PrototypeData",
	__guid   = "{29042CED-24D6-446E-8265-151D08B0A991}",
	__origin = "Kux-CoreLib/lib/data/PrototypeData.lua",
}
KuxCoreLib.__modules.PrototypeData = PrototypeData
---------------------------------------------------------------------------------------------------
function PrototypeData.setIconTint(item, tint)
	if(item.icons) then
		if(item.icons[1] and item.icons[1].tint==nil) then
			item.icons[1].tint = tint
		else
			log("WARNING could not tint the icon! "..item.type ..".".. item.name.."\n"..serpent.block(item))
		end
	elseif(item.icon) then
		item.icons = {{
			icon = item.icon,
			tint = tint
		}}
		item.icon = nil
	end
end

function PrototypeData.energyFactor(value, factor)
	-- DOCU: https://wiki.factorio.com/Types/Energy
	local energy = tonumber(string.match(value, "%d+"))
	local unit = string.match(value, "%a+")
	energy = energy * factor -- TODO round
	return tostring(energy) .. unit
end

function PrototypeData.energyUsageFactor(entity, factor)
	-- DOCU: https://wiki.factorio.com/Prototype/CraftingMachine#energy_usage
	entity.energy_usage = PrototypeData.energyFactor(entity.energy_usage, factor)
end

---@type KuxCorelib.PrototypeData.Extend
PrototypeData.extend = require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/data/PrototypeData-extend") --[[@as KuxCorelib.PrototypeData.Extend]]

---------------------------------------------------------------------------------------------------

function PrototypeData.asGlobal() return KuxCoreLib.utils.asGlobal(PrototypeData) end

return PrototypeData