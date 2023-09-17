require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")
if(KuxCoreLib.__modules.Trace) then return KuxCoreLib.__modules.Trace end

---Provides trace functions
---@class KuxCoreLib.Trace
local Trace = {
	__class  = "Trace",
	__guid   = "d37816ef-cba2-46af-8c46-56be0fd02322",
	__origin = "Kux-CoreLib/lib/Trace.lua",

	__isInitialized = false,
	__on_initialized = {}
}
KuxCoreLib.__modules.Trace = Trace
---------------------------------------------------------------------------------------------------
local function end_init()
	---Provides Trace in the global namespace
	---@return KuxCoreLib.Trace
	function Trace.asGlobal()
		---@type KuxCoreLib.Trace
		_G.trace = Trace
		return KuxCoreLib.utils.asGlobal(Trace)
	end

	setmetatable(Trace, {
		__call = function(_, ...) return Trace.write(...) end,
		__index = function(_, key) error("Invalid Operation. '"..(key or "<nil>").."' is not a member of 'Trace'") end,
		__newindex = function(_, key, value) error("Invalid Operation. 'Trace' is protected.") end,
	})

	Trace.__isInitialized = true
	for _, fnc in ipairs(Trace.__on_initialized) do fnc() end

	return Trace
end
---------------------------------------------------------------------------------------------------

_G._trace_isEnabled = true --TODO: set default from settings

local function timestamp()
	local ticks = (game or {}).tick or 0
    local ticks_per_second = 60 -- Ticks pro Sekunde
    local total_seconds = ticks / ticks_per_second
    local days = math.floor(total_seconds / 86400) -- Eine Sekunde pro Tag
    local hours = math.floor((total_seconds % 86400) / 3600) -- Eine Stunde pro Tag
    local minutes = math.floor((total_seconds % 3600) / 60)
    local seconds = math.floor(total_seconds % 60)
    local milliseconds = math.floor((total_seconds * 1000) % 1000)
    return string.format("%d,%02d:%02d:%02d.%03d", days, hours, minutes, seconds, milliseconds)
end

local function write(append, ...)
	if(not _trace_isEnabled) then return end
	local args = {...}
	local str = "● "..timestamp()..": "
	if(append) then str = str:gsub(".", " ") end
	for i, arg in ipairs(args) do
		if(type(arg)=="function") then pcall(function() arg = tostring(arg()) end) end
		if(type(arg)=="string") then
			--str = str .. "'"..tostring(arg) .. "' "
			str = str .. tostring(arg) .. " "
		--elseif(type(arg)=="table") then
		--	str = str .. serpent.block(arg, {comment=false}) .. " "
		else
			str = str .. tostring(arg) .. " "
		end
	end
	print(str)
end

function Trace.write(...) write(false, ...) end

function Trace.append(...) write(true, ...) end

function Trace.on() local last = _G._trace_isEnabled; _G._trace_isEnabled = true; return last end
function Trace.off() local last = _G._trace_isEnabled; _G._trace_isEnabled = false; return last end

function Trace.pause(fnc)
	local was_on = Trace.off()
	fnc()
	if was_on then Trace.on() end
end

if(KuxCoreLib.ModInfo.current_stage~="control") then return end_init() end

---[control stage only]----------------------------------------------------------------------------

local EventDistributor = KuxCoreLib.EventDistributor
local Events = KuxCoreLib.Events

local function on_close_clicked(e)
	if(not e.element or e.element.name~="KuxCoreLib_trace_messagebox_close") then return end
	local player = game.players[e.player_index]
	player.gui.screen.KuxCoreLib_trace_messagebox.destroy()
	EventDistributor.unregister(defines.events.on_gui_click, on_close_clicked)
	global.events.Trace.on_close_clicked = nil
end

function Trace.showMessage(player, message)
	--TODO: not for multiplayer
	--game.show_message_dialog{text=message, 
	-- style?=…, wrapper_frame_style?=
	local g = player.gui.screen.KuxCoreLib_trace_messagebox
	if(g) then g.destroy() end

	local frame = player.gui.screen.add {
		type = "frame",
		name = "KuxCoreLib_trace_messagebox",
		caption = "Trace Notice",
		direction = "vertical"
	}
    -- local screen_width = player.display_resolution.width
    -- local screen_height = player.display_resolution.height    
    -- frame.location = {screen_width - frame.style.minimal_width, screen_height - frame.style.minimal_height}

	local textbox = frame.add {
		type = "text-box",
		text = message,
		style = "textbox"
	}
	textbox.style.width = 500
	textbox.style.height = 400

	local confirm_button = frame.add {
		type = "button",
		name="KuxCoreLib_trace_messagebox_close",
		caption = "Close"
	}
	confirm_button.style.minimal_width = 100

	Events.on_event(defines.events.on_gui_click, on_close_clicked)
	global.events = global.events or {}
	global.events.Trace = global.events.Trace or {}
	global.events.Trace.on_close_clicked = true
end

function Trace.formatEntityEvent(e)
	local entity = e.entity or e.created_entity or e.last_entity
	if(not entity) then return "???" end
	local sb = ""
	if(entity.name=="entity-ghost") then
		sb=sb.."entity-ghost ("..(entity.ghost_name)..")"
	else
		sb=sb..entity.name.. " (#"..(entity.unit_number or "-")..")"
	end
	sb=sb.." ["..EventDistributor.getDisplayName(e.name).."]"
	return sb
end

local function on_events_initialized()
	Events.on_load(function()
		if(safeget("global.events.Trace.on_close_clicked")) then
			Events.on_event(defines.events.on_gui_click, on_close_clicked)
		end
	end)
end

if(Events.__isInitialized) then on_events_initialized() 
else table.insert(Events.__on_initialized, on_events_initialized) 
end
---------------------------------------------------------------------------------------------------
end_init()
return Trace