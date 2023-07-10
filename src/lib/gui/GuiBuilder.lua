require((KuxCoreLibPath or "__Kux-CoreLib__/").."init")
if(KuxCoreLib.__modules.That) then return KuxCoreLib.__modules.That end

---@class KuxCoreLib.GuiBuilder
local GuiBuilder = {
	__class  = "GuiBuilder",
	__guid   = "5aa42fc3-2d53-47ab-9834-18170d832b9c",
	__origin = "Kux-CoreLib/lib/gui/GuiBuilder.lua",
}
KuxCoreLib.__modules.GuiBuilder = GuiBuilder
---------------------------------------------------------------------------------------------------
local Table= KuxCoreLib.Table()
local Debug= KuxCoreLib.Debug()
local GlobalPlayers = KuxCoreLib.GlobalPlayers

function GuiBuilder.generateName(name)
	return Debug.getCallingMod(true).."_"..name
end

---createRelativeToGui
---@param player LuaPlayer|integer
---@param name string
---@param caption string
---@param gui integer defines.relative_gui_type
---@param position integer defines.relative_gui_position
---@return LuaGuiElement
function GuiBuilder.createRelativeToGui(player, name, caption, gui, position)
	player = toLuaPlayer(player)
	name = GuiBuilder.generateName(name)
	print("createRelativeToGui '"..name.."'")
	if(not gui) then error("Argument must not nil! Name: 'gui'"); end
	if(not position) then error("Argument must not nil! Name: 'position'"); end
	local oldframe = GlobalPlayers[player.index].frames[name]
	if(oldframe) then oldframe.destroy(); GlobalPlayers[player.index].frames[name]=nil end

	local frame = player.gui.relative.add({
		type = "frame",
		name = name,
		direction = "vertical",
		caption = caption,
		anchor = {
			gui =  gui,
			position = position,
		}
	})

	GlobalPlayers[player.index].frames[name]=frame
	return frame
end

---destroyFrame
---@param player LuaPlayer|integer
---@param name string
function GuiBuilder.destroyFrame(player, name)
	player = toLuaPlayer(player)
	name = GuiBuilder.generateName(name)
	print("destroyFrame '"..name.."'")

	local frame = GlobalPlayers[player].frames[name]
	if frame then
		frame.destroy()
		GlobalPlayers[player].frames[name]=nil
	end
end

--#region Example
--[[
script.on_event(defines.events.on_gui_opened, function(event)
	if
		event.gui_type == defines.gui_type.entity
		and event.entity
		and event.entity.type == "container"
	then
		GuiBuilder.createRelativeToGui(event.player_index,"container_gui","Container Test",defines.relative_gui_type.container_gui, defines.relative_gui_position.right)
	end
end)

script.on_event(defines.events.on_gui_closed, function(event)
	if
		event.gui_type == defines.gui_type.entity
		and event.entity
		and event.entity.type == "container"
	then
		GuiBuilder.destroyFrame(event.player_index, "container_gui")
	end
end)
]]
--#endregion

---------------------------------------------------------------------------------------------------

function GuiBuilder.asGlobal() return KuxCoreLib.utils.asGlobal(GuiBuilder) end

return GuiBuilder