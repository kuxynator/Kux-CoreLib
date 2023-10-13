---@class KuxCorelib.PrototypeData.Extend.Arguments

---@class KuxCorelib.PrototypeData.Extend
---@field prefix string
local extend = {
	---@type string
	prefix = nil,
	---@type table
	common = {}
}

---Creates a new Extend object
---@param t KuxCorelib.PrototypeData.Extend.Arguments | table ExtendArguments | {setting_type, order}
---@return KuxCorelib.PrototypeData.Extend
local function call_extend(self, t)
	local new = {common = t or {}, count = 0}
	setmetatable(new, {
		__index = extend
	})
	return new
end

setmetatable(extend,{
	__call = call_extend
})

local function getPrefix(self)
	return (self.common.prefix or extend.prefix or mod.prefix)
end
local function getName(self, name)
	return getPrefix(self)..name
end

local function merge(common, data, final_fixes)
	--print("merge", order_index, common, data, final_fixes)
	local merged = {}
	--merge common-- << extend(common)
	for k,v in pairs(common) do merged[k] = v end
		
	--merge data-- << x:int(data)
	for k,v in pairs(data) do merged[k] = type(k)~="number" and v or nil end

	--merge final_fixes--
	for k,v in pairs(final_fixes) do merged[k] = v; end

	--clean up--
	merged.prefix = nil

	return merged
end

---@class KuxCorelib.CustomInputPrototypeData
---@field key_sequence	string	The default key sequence for this custom input.
---@field alternative_key_sequence	string	The alternative key binding for this control.
---@field controller_key_sequence	string	The controller (game pad) keybinding for this control.
---@field controller_alternative_key_sequence	string	The alternative controller (game pad) keybinding for this control.
---@field linked_game_control	string	When a custom-input is linked to a game control it won't show up in the control-settings GUI and will fire when the linked control is pressed.
---@field consuming	ConsumingType	Sets whether internal game events associated with the same key sequence should be fired or blocked.
---@field enabled	bool	If this custom input is enabled.
---@field enabled_while_spectating	bool	
---@field enabled_while_in_cutscene	bool	
---@field include_selected_prototype	bool	If true, the type and name of the currently selected prototype will be provided as "selected_prototype" in the raised Lua event.
---@field item_to_spawn	ItemID	The item will be created when this input is pressed and action is set to "spawn-item".
---@field action	string "lua" or "spawn-item" or "toggle-personal-roboport" or "toggle-personal-logistic-requests" or "toggle-equipment-movement-bonus"

---Adds a custom-input  
---[View documentation](https://lua-api.factorio.com/latest/classes/LuaCustomInputPrototype.html)
---@param t KuxCorelib.CustomInputPrototypeData|table CustomInputPrototype | {name, key_sequence}
function extend:custom_input(t)
	local d = merge(self.common, t, {
		type          = "custom-input",
		name          =  getName(self, t.name or t[1]),
		key_sequence  = t.key_sequence or t[2] or "",
		consuming     = t.consuming or "none",
		-- forced_value -- Only loaded if hidden = true
	})
	data:extend{d}
end

return extend