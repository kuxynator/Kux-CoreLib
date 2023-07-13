require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")
if(KuxCoreLib.__modules.FlyingText) then return KuxCoreLib.__modules.FlyingText end

local function posOffset( pos, offset )
	return { x=pos.x + offset.x, y=pos.y + offset.y }
end

local function localiseString(text)
	if(type(text)~="table") then return text end
	local flattenedTable = {""}

	local function flatten(tbl)
		for _, value in ipairs(tbl) do
			if type(value) == "table" then
				flatten(value)
			elseif(value=="") then
				--skip empty string
			else
				table.insert(flattenedTable, value)
			end
		end
	end
	flatten(text)
	return flattenedTable
end

---flying-text
---@class KuxCoreLib.FlyingText
local FlyingText = {
	__class  ="FlyingText",
	__guid   = "{8BFF3C82-2A4F-41F8-A7B3-C2969A741749}",
	__origin = "Kux-CoreLib/lib/FlyingText.lua",

	create = function (player, text, color)
		color = color or {0.8,0.8,0.8}
		player.surface.create_entity({
			name = "flying-text",
			position = posOffset(player.position,{x=-0.5, y=0.2}),
			text = text, color = color
		})
	end
}
KuxCoreLib.__modules.FlyingText = FlyingText

---------------------------------------------------------------------------------------------------

---Provides FlyingText in the global namespace
---@return KuxCoreLib.FlyingText
function FlyingText.asGlobal() return KuxCoreLib.utils.asGlobal(FlyingText) end

return FlyingText