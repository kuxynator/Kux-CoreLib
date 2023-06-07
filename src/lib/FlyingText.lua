
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
---@class FlyingText
FlyingText = {
	moduleName ="FlyingText",
	guid       = "{8BFF3C82-2A4F-41F8-A7B3-C2969A741749}",
	origin     = "Kux-CoreLib/lib/FlyingText.lua",

	create = function (player, text, color)
		color = color or {0.8,0.8,0.8}
		player.surface.create_entity({
			name = "flying-text",
			position = posOffset(player.position,{x=-0.5, y=0.2}),
			text = text, color = color
		})
	end
}

return FlyingText