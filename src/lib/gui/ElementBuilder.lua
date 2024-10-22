
---@class KuxCoreLib.ElementBuilder
local ElementBuilder = {}
-- automatic handling of style parameters (moved to style and assigned after creation)
-- automatic handling of non add parameters (assigned after creation)

local _add_fields = {"achievement", "allow_decimal", "allow_negative", "allow_none_state",
	"anchor", "auto_toggle", "badge_text", "caption", "chart_player_index",
	"clear_and_focus_on_right_click", "clicked_sprite", "column_count", "decorative", "direction",
	"discrete_slider", "discrete_values", "draw_horizontal_line_after_headers",
	"draw_horizontal_lines", "draw_vertical_lines", "elem_filters", "elem_type", "enabled",
	"entity", "equipment", "fluid", "force", "game_controller_interaction",
	"horizontal_scroll_policy", "hovered_sprite", "ignored_by_interaction", "index", "is_password",
	"item", "item-group", "items", "left_label_caption", "left_label_tooltip",
	"lose_focus_on_confirm", "maximum_value", "minimum_value", "mouse_button_filter", "name",
	"number", "numeric", "position", "raise_hover_events", "recipe", "resize_to_sprite",
	"right_label_caption", "right_label_tooltip", "selected_index",
	"show_percent_for_small_numbers", "signal", "sprite", "state", "style", "surface_index",
	"switch_state", "tags", "technology", "text", "tile", "toggled", "tooltip", "type", "value",
	"value_step", "vertical_centering", "vertical_scroll_policy", "visible", "zoom"}
local _style_writable_fields = {"badge_font", "badge_horizontal_spacing", "bar_width",
	"bottom_cell_padding", "bottom_margin", "bottom_padding", "cell_padding", "clicked_font_color",
	"clicked_vertical_offset", "color", "default_badge_font_color", "disabled_badge_font_color",
	"disabled_font_color", "draw_grayscale_picture", "extra_bottom_margin_when_activated",
	"extra_bottom_padding_when_activated", "extra_left_margin_when_activated",
	"extra_left_padding_when_activated", "extra_margin_when_activated",
	"extra_padding_when_activated", "extra_right_margin_when_activated",
	"extra_right_padding_when_activated", "extra_top_margin_when_activated",
	"extra_top_padding_when_activated", "font", "font_color", "height", "horizontal_align",
	"horizontal_spacing", "horizontally_squashable", "horizontally_stretchable",
	"hovered_font_color", "left_cell_padding", "left_margin", "left_padding", "margin",
	"maximal_height", "maximal_width", "minimal_height", "minimal_width", "natural_height",
	"natural_width", "padding", "pie_progress_color", "rich_text_setting", "right_cell_padding",
	"right_margin", "right_padding", "selected_badge_font_color", "selected_clicked_font_color",
	"selected_font_color", "selected_hovered_font_color", "single_line", "size",
	"stretch_image_to_widget_size", "strikethrough_color", "top_cell_padding", "top_margin",
	"top_padding", "use_header_filler", "vertical_align", "vertical_spacing",
	"vertically_squashable", "vertically_stretchable", "width"}

local isAddField = {}; for _,n in ipairs(_add_fields) do isAddField[n]=true end
local isWriteableStyleField = {}; for _,n in ipairs(_style_writable_fields) do isWriteableStyleField[n]=true end

-- check for names which can be used as add field and as style field
for _,name in ipairs(_style_writable_fields) do
	assert(isAddField[name]==nil, "Style field '"..name.."' is also an add field.")
end

function ElementBuilder.validateChildren(children)
	if(children==nil) then return true end
	local t = type(children)
	if(t~="table") then error("Invalid parameter. 'children' must be a table or nil, but is '"..t.."'") end
	if(#children==0) then return true end
	for i, f in ipairs(children) do
		if(type(f)~="function") then error("Invalid parameter. 'children' must be a table of functions, but element "..i.." is '"..type(f).."'") end
	end
	return true
end

---@param container LuaGuiElement
---@param create_children_fnc  function
---@param names_dic {string: LuaGuiElement}
---@return LuaGuiElement
local function create(container, create_children_fnc, names_dic)
	assert(container~=nil, "Invalid Argument. 'container' must not be nil.")
	assert(type(create_children_fnc)=="function", "Invalid Argument. 'create_children_fnc' must be a function but is '"..type(create_children_fnc).."'.")
	trace("ElementBuilder.create in "..container.name.." from "..type(create_children_fnc))
	local list =
		type(create_children_fnc) == "function" and {create_children_fnc} or
		type(create_children_fnc) == "table" and create_children_fnc or
		error("Invalid Argument. 'create_children_fnc' must be a function or a table of functions.")
	local results = {}
	for _, f in ipairs(list) do
		assert(type(f)=="function", "Invalid Argument. 'create_children_fnc' must be a function or a table of functions. but is "..type(f)..": "..serpent.line(f).." container: "..container.name)
		local elmt = f(container)
		if(names_dic and not names_dic[elmt.name]) then names_dic[elmt.name]=elmt end -- store first name only
		table.insert(results, elmt)
	end
	return type(create_children_fnc) == "function" and results[1] or results
end

---@param container LuaGuiElement
---@param create_children_fnc function[]
---@param names_dic {string: LuaGuiElement}
---@return LuaGuiElement[]
local function create_multi(container, create_children_fnc, names_dic)
	assert(container~=nil, "Invalid Argument. 'container' must not be nil.")
	trace("ElementBuilder.create in "..container.name.." from "..type(create_children_fnc))

	local flatten; flatten = function(t1, t2)
		t2 = t2 or {}
		for _, elmt in ipairs(t1) do
			if(type(elmt)=="table") then
				flatten(elmt, t2)
			else
				table.insert(t2, elmt)
			end
		end
		return t2
	end

	local list =
		type(create_children_fnc) == "function" and {create_children_fnc} or
		type(create_children_fnc) == "table" and flatten(create_children_fnc) or
		error("Invalid Argument. 'create_children_fnc' must be a function or a table of functions.")
	local results = {}
	for _, f in ipairs(list) do
		assert(type(f)=="function", "Invalid Argument. 'create_children_fnc' must be a function or a table of functions. but is "..type(f)..": "..serpent.line(f).." container: "..container.name)
		local elmt = f(container)
		if(names_dic and not names_dic[elmt.name]) then names_dic[elmt.name]=elmt end -- store first name only
		table.insert(results, elmt)
	end
	return results
end

---@param container LuaGuiElement
---@param create_children_fnc function
---@return LuaGuiElement
function ElementBuilder.create(container, create_children_fnc)
	return create(container, create_children_fnc, {})
end

---@param root_container LuaGuiElement
---@param create_children_fnc function
---@return LuaGuiElement
---@return KuxCoreLib.GuiElementCache.Instance
function ElementBuilder.createView(root_container, create_children_fnc)
	return create(root_container, create_children_fnc, nil)
end


local function isInteger(value) return type(value)=="number" and math.floor(value)==value end

---Prepares the style attribute
---@param args table
---@return table|nil #The style table or nil
local function prep_style(args)
	local style
	if(not args.style) then
		--do nothing
	elseif(type(args.style)=="string") then
		--do nothing, optional check if style exists
	elseif(type(args.style)=="table") then
		style = args.style
		args.style = style.base or args.base_style
		args.base_style = nil
	else
		error("Invalid Parameter. 'style' must be a string or a table but is "..type(args.style)..": "..serpent.line(args.style))
	end

	-- handle style fields
	for k,v in pairs(args) do
		if(not isInteger(k) and isWriteableStyleField[k]) then
			style = style or {}
			style[k] = v
			args[k] = nil
			--[[TRACE]]--trace.append("  prep_style '"..k.."' moved to style")
		end
	end

	return style
end

---Prepares all fields for `LuaGuiElement.add` and returns a table with the remaining fields
---@param args table
---@return table #The extra table
local function prep_add(args)
	local extra = {}
	for k,v in pairs(args) do
		if(not isInteger(k) and not isAddField[k]) then
			extra[k] = v
			args[k] = nil
		end
	end
	return extra
end

---Applies the style to the element
---@param element LuaGuiElement
---@param style table
local function apply_style(element, style)
	if( not style) then return end
	for k,v in pairs(style) do
		element.style[k] = v
	end
end

---Applies the extra properties to the element
---@param element LuaGuiElement
---@param extra table
local function apply_extra(element, extra)
	if( not extra) then return end
	for k,v in pairs(extra) do
		-- Given object is not a LuaGuiElement.
		-- on drag_target = "%parent%"
		element[k] = v
	end
end

---@param container LuaGuiElement
local function create_element_name(container)
	--("elmt_"..#container.children)
	local hn=0
	for _, name in pairs(container.children_names) do
		local sn=tonumber(name:match("^elmt_(%d+)$"))
		if(sn and sn>hn) then hn=sn end
	end
	return "elmt_"..(hn+1)
end

local function prep_children(args)
	if(args.children) then
		local children = args.children
		args.children = nil
		return children
	elseif(type(args[#args])=="table") then
		local children = args[#args]
		args[#args] = nil
		return children
	else
		return nil
	end
end

local function prep_name(args, container)
	if(args.name) then
		return
	elseif(args[1] and type(args[1])=="string") then
		args.name = args[1]
	else
		args.name = create_element_name(container)
	end
end

local function prep_caption(args)
	-- https://lua-api.factorio.com/latest/concepts.html#LocalisedString
	-- LocalisedString :: string or number or boolean or LuaObject or nil or array[LocalisedString]
	if(args.caption) then return
	elseif(type(args[2])=="function") then return
	elseif(type(args[2])=="nil") then return
	elseif(type(args[2])=="table" and #args[2]>0 and type(args[2][1])=="function") then	return
	else
		args.caption = args[2]
		args[2] = nil
	end
end

local t = {"%self%","%parent%","%parent.parent%"}
local supported_variables = {}; for _,v in ipairs(t) do supported_variables[v]=true end

local function prep_post(args)
	local post_args = {}

	for k,v in pairs(args) do
		-- TODO: make this more generic
		if(supported_variables[v]) then
			post_args[k] = v
			args[k] = nil
		end
	end
	-- trace("ElementBuilder.prep_post "..tostring(args.name))
	-- trace.append(serpent.block(post_args))
	return post_args
end

local function apply_post(element, post_args)
	for k,v in pairs(post_args) do
		if(v == "%parent%") then -- drag_target = "%parent%"
			element[k] = element.parent
		elseif(v == "%parent.parent%") then
			element[k] = element.parent.parent
		elseif(v == "%self%") then
			element[k] = element
		end
	end
end

---Base function to create a gui element creation function
---@param args table
local function element_factory(args)
	assert(args~=nil, "Invalid Argument. 'args' must not be nil.")

	return function(container)
		assert(container~=nil, "Invalid Argument. 'container' must not be nil.")
		log("ElementBuilder.element_factory "..tostring(container.name).." "..tostring(args.name))
		local names_dic = args.names_dic or {}; args.names_dic = nil
		prep_name(args, container)
		prep_caption(args)
		local style    = prep_style(args)
		local children = prep_children(args)
		local post     = prep_post(args) -- execute before prep_add
		local extra    = prep_add(args)
		--[[TRACE]]--trace("ElementBuilder.element_base "..tostring(container.name).." "..tostring(args.name))
		--[[TRACE]]--trace.append("  args:  "..serpent.line(args))
		--[[TRACE]]--trace.append("  style: "..serpent.line(style))
		--[[TRACE]]--trace.append("  extra: "..serpent.line(extra))
		local element = container.add(args)
		if(names_dic and not names_dic[element.name]) then names_dic[element.name]=element end -- store first name only
		if(style) then apply_style(element, style) end
		if(extra) then apply_extra(element, extra) end
		if(post ) then apply_post (element, post ) end

		if(children) then create_multi(element, children, names_dic) end
		return element
	end
end
ElementBuilder.factory = element_factory

---A clickable element. Relevant event: on_gui_click
---@param args KuxCoreLib.ElementBuilder.parameter.button
---@return function
function ElementBuilder.button(args)
	args["type"]="button"
	return element_factory(args)
end

---A button that displays a sprite rather than text. Relevant event: on_gui_click
---@param args KuxCoreLib.ElementBuilder.parameter.sprite-button
---@return function
function ElementBuilder.spritebutton(args)
	args["type"]="sprite-button"
	return element_factory(args)
end

---A clickable element with a check mark that can be turned off or on. Relevant event: on_gui_checked_state_changed
---@param args KuxCoreLib.ElementBuilder.parameter.checkbox
---@return function
function ElementBuilder.checkbox(args)
	args["type"]="checkbox"
	return element_factory(args)
end

---An invisible container that lays out its children either horizontally or vertically.
---@param args KuxCoreLib.ElementBuilder.parameter.flow
---@return function
function ElementBuilder.flow(args)
	args["type"]="flow"
	return element_factory(args)
end

---A non-transparent box that contains other elements. It can have a title (set via the caption attribute). Just like a flow, it lays out its children either horizontally or vertically. Relevant event: on_gui_location_changed
---@param args KuxCoreLib.ElementBuilder.parameter.frame
---@return function
function ElementBuilder.frame(args)
	args["type"]="frame"
	return element_factory(args)
end

---A piece of text.
---@param args KuxCoreLib.ElementBuilder.parameter.label
---@return function
function ElementBuilder.label(args)
	args["type"]="label"
	return element_factory(args)
end

---A horizontal or vertical separation line.
---@param args KuxCoreLib.ElementBuilder.parameter.line
---@return function
function ElementBuilder.line(args)
	args["type"]="line"
	return element_factory(args)
end

---A partially filled bar that can be used to indicate progress.
---@param args KuxCoreLib.ElementBuilder.parameter.progressbar
---@return function
function ElementBuilder.progressbar(args)
	args["type"]="progressbar"
	return element_factory(args)
end

---An invisible container that lays out its children in a specific number of columns. The width of each column is determined by the widest element it contains.
---@param args KuxCoreLib.ElementBuilder.parameter.table
---@return function
function ElementBuilder.table(args)
	args["type"]="table"
	return element_factory(args)
end

---A single-line box the user can type into. Relevant events: on_gui_text_changed, on_gui_confirmed
---@param args KuxCoreLib.ElementBuilder.parameter.textfield
---@return function
function ElementBuilder.textfield(args)
	args["type"]="textfield"
	return element_factory(args)
end

---An element that is similar to a checkbox, but with a circular appearance. Clicking a selected radio button will not unselect it. Radio buttons are not linked to each other in any way. Relevant event: on_gui_checked_state_changed
---@param args KuxCoreLib.ElementBuilder.parameter.radiobutton
---@return function
function ElementBuilder.radiobutton(args)
	args["type"]="radiobutton"
	return element_factory(args)
end

---An element that shows an image.
---@param args KuxCoreLib.ElementBuilder.parameter.sprite
---@return function
function ElementBuilder.sprite(args)
	args["type"]="sprite"
	return element_factory(args)
end

---An invisible element that is similar to a flow, but has the ability to show and use scroll bars.
---@param args KuxCoreLib.ElementBuilder.parameter.scroll-pane
---@return function
function ElementBuilder.scrollpane(args)
	args["type"]="scroll-pane"
	return element_factory(args)
end

---A drop-down containing strings of text. Relevant event: on_gui_selection_state_changed
---@param args KuxCoreLib.ElementBuilder.parameter.drop-down
---@return function
---[View Documentation](https://lua-api.factorio.com/latest/LuaGuiElement.html#LuaGuiElement.add)
function ElementBuilder.dropdown(args)
	args["type"]="drop-down"
	return element_factory(args)
end

---A list of strings, only one of which can be selected at a time. Shows a scroll bar if necessary. Relevant event: on_gui_selection_state_changed
---@param args KuxCoreLib.ElementBuilder.parameter.list-box
---@return function
function ElementBuilder.listbox(args)
	args["type"]="list-box"
	return element_factory(args)
end

---A camera that shows the game at the given position on the given surface. It can visually track an entity that is set after the element has been created.
---@param args KuxCoreLib.ElementBuilder.parameter.camera
---@return function
function ElementBuilder.camera(args)
	args["type"]="camera"
	return element_factory(args)
end

---A button that lets the player pick from a certain kind of prototype, with optional filtering. Relevant event: on_gui_elem_changed
---@param args KuxCoreLib.ElementBuilder.parameter.choose-elem-button
---@return function
function ElementBuilder.chooseelembutton(args)
	args["type"]="choose-elem-button"
	return element_factory(args)
end

---A multi-line textfield. Relevant event: on_gui_text_changed
---@param args KuxCoreLib.ElementBuilder.parameter.text-box
---@return function
function ElementBuilder.textbox(args)
	args["type"]="text-box"
	return element_factory(args)
end

---A horizontal number line which can be used to choose a number. Relevant event: on_gui_value_changed
---@param args KuxCoreLib.ElementBuilder.parameter.slider
---@return function
function ElementBuilder.slider(args)
	args["type"]="slider"
	return element_factory(args)
end

---A minimap preview, similar to the normal player minimap. It can visually track an entity that is set after the element has been created.
---@param args KuxCoreLib.ElementBuilder.parameter.minimap
---@return function
function ElementBuilder.minimap(args)
	args["type"]="minimap"
	return element_factory(args)
end

---A preview of an entity. The entity has to be set after the element has been created.
---@param args KuxCoreLib.ElementBuilder.parameter.entity-preview
---@return function
function ElementBuilder.entitypreview(args)
	args["type"]="entity-preview"
	return element_factory(args)
end

---An empty element that just exists. The root GUI elements screen and relative are empty-widgets.
---@param args KuxCoreLib.ElementBuilder.parameter.empty-widget
---@return function
function ElementBuilder.emptywidget(args)
	args["type"]="empty-widget"
	return element_factory(args)
end

---A collection of tabs and their contents. Relevant event: on_gui_selected_tab_changed
---@param args KuxCoreLib.ElementBuilder.parameter.tabbed-pane
---@return function
function ElementBuilder.tabbedpane(args)
	args["type"]="tabbed-pane"
	return element_factory(args)
end

---A tab for use in a tabbed-pane.
---@param args KuxCoreLib.ElementBuilder.parameter.tab
---@return function
function ElementBuilder.tab(args)
	args["type"]="tab"
	return element_factory(args)
end

---A switch with three possible states. Can have labels attached to either side. Relevant event: on_gui_switch_state_changed
---@param args KuxCoreLib.ElementBuilder.parameter.switch
---@return function
function ElementBuilder.switch(args)
	args["type"]="switch"
	return element_factory(args)
end

return ElementBuilder

--TODO: ---@field type
--TODO: ---@field style
--TODO: ---@field children

---@class KuxCoreLib.ElementBuilder.parameter.base
---@field type	GuiElementType	The kind of element to add, which potentially has its own attributes as listed below.
---@field name	string?	Name of the child element. It must be unique within the parent element.
---@field caption	LocalisedString?	Text displayed on the child element. For frames, this is their title. For other elements, like buttons or labels, this is the content. Whilst this attribute may be used on all elements, it doesn't make sense for tables and flows as they won't display it.
---@field tooltip	LocalisedString?	Tooltip of the child element.
---@field enabled	boolean?	Whether the child element is enabled. Defaults to true.
---@field visible	boolean?	Whether the child element is visible. Defaults to true.
---@field ignored_by_interaction	boolean?	Whether the child element is ignored by interaction. Defaults to false.
---@field style	string|LuaStyle|KuxCoreLib.ElementBuilder.style-parameter|nil	The name of the style prototype or a LuaStyle to apply to the new element.
---@field tags	Tags?	Tags associated with the child element.
---@field index	uint?	Location in its parent that the child element should slot into. By default, the child will be appended onto the end.
---@field anchor	GuiAnchor?	Where to position the child element when in the relative element.
---@field game_controller_interaction	uint?	defines.game_controller_interaction?	How the element should interact with game controllers. Defaults to defines.game_controller_interaction.normal.
---@field raise_hover_events	boolean?	Whether this element will raise on_gui_hover and on_gui_leave. Defaults to false.

---[View documentation](https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add)
---@class KuxCoreLib.ElementBuilder.parameter.label : KuxCoreLib.ElementBuilder.parameter.base

---[View documentation](https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add)
---@class KuxCoreLib.ElementBuilder.parameter.button : KuxCoreLib.ElementBuilder.parameter.base
---@field mouse_button_filter	MouseButtonFlags?	Which mouse buttons the button responds to. Defaults to "left-and-right".
---@field auto_toggle	boolean?	Whether the button will automatically toggle when clicked. Defaults to false.
---@field toggled	boolean?	The initial toggled state of the button. Defaults to false.
---@field style string|KuxCoreLib.ElementBuilder.button-style-parameter|nil The name of the style prototype or a LuaStyle to apply to the new element.

---[View documentation](https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add)
---@class KuxCoreLib.ElementBuilder.parameter.flow : KuxCoreLib.ElementBuilder.parameter.base
---@field direction	string?	The initial direction of the flow's layout. See LuaGuiElement::direction. Defaults to "horizontal".
---@field style string|KuxCoreLib.ElementBuilder.flow-style-parameter|nil The name of the style prototype or a LuaStyle to apply to the new element.

---[View documentation](https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add)
---@class KuxCoreLib.ElementBuilder.parameter.frame : KuxCoreLib.ElementBuilder.parameter.base
---@field direction	string?	The initial direction of the frame's layout. See LuaGuiElement::direction. Defaults to "horizontal".
---@field style string|KuxCoreLib.ElementBuilder.frame-style-parameter|nil The name of the style prototype or a LuaStyle to apply to the new element.

---[View documentation](https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add)
---@class KuxCoreLib.ElementBuilder.parameter.table : KuxCoreLib.ElementBuilder.parameter.base
---@field column_count	uint	Number of columns. This can't be changed after the table is created.
---@field draw_vertical_lines	boolean?	Whether the table should draw vertical grid lines. Defaults to false.
---@field draw_horizontal_lines	boolean?	Whether the table should draw horizontal grid lines. Defaults to false.
---@field draw_horizontal_line_after_headers	boolean?	Whether the table should draw a single horizontal grid line after the headers. Defaults to false.
---@field vertical_centering	boolean?	Whether the content of the table should be vertically centered. Defaults to true.
---@field style string|KuxCoreLib.ElementBuilder.table-style-parameter|nil The name of the style prototype or a LuaStyle to apply to the new element.

---[View documentation](https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add)
---@class KuxCoreLib.ElementBuilder.parameter.textfield : KuxCoreLib.ElementBuilder.parameter.base
---@field text	string?	The initial text contained in the textfield.
---@field numeric	boolean?	Defaults to false.
---@field allow_decimal	boolean?	Defaults to false.
---@field allow_negative	boolean?	Defaults to false.
---@field is_password	boolean?	Defaults to false.
---@field lose_focus_on_confirm	boolean?	Defaults to false.
---@field clear_and_focus_on_right_click	boolean?	Defaults to false.
---@field style string|KuxCoreLib.ElementBuilder.textfield-style-parameter|nil The name of the style prototype or a LuaStyle to apply to the new element.

---[View documentation](https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add)
---@class KuxCoreLib.ElementBuilder.parameter.progressbar : KuxCoreLib.ElementBuilder.parameter.base
---@field value	double?	The initial value of the progressbar, in the range [0, 1]. Defaults to 0.
---@field style string|KuxCoreLib.ElementBuilder.progressbar-style-parameter|nil The name of the style prototype or a LuaStyle to apply to the new element.

---[View documentation](https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add)
---@class KuxCoreLib.ElementBuilder.parameter.checkbox : KuxCoreLib.ElementBuilder.parameter.base
---@field state	boolean	The initial checked-state of the checkbox.
---@field style string|KuxCoreLib.ElementBuilder.checkbox-style-parameter|nil The name of the style prototype or a LuaStyle to apply to the new element.

---[View documentation](https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add)
---@class KuxCoreLib.ElementBuilder.parameter.radiobutton : KuxCoreLib.ElementBuilder.parameter.base
---@field state	boolean	The initial checked-state of the radiobutton.
---@field style string|KuxCoreLib.ElementBuilder.radiobutton-style-parameter|nil The name of the style prototype or a LuaStyle to apply to the new element.

---[View documentation](https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add)
---@class KuxCoreLib.ElementBuilder.parameter.sprite-button : KuxCoreLib.ElementBuilder.parameter.base
---@field sprite	SpritePath?	Path to the image to display on the button.
---@field hovered_sprite	SpritePath?	Path to the image to display on the button when it is hovered.
---@field clicked_sprite	SpritePath?	Path to the image to display on the button when it is clicked.
---@field number	double?	The number shown on the button.
---@field show_percent_for_small_numbers	boolean?	Formats small numbers as percentages. Defaults to false.
---@field mouse_button_filter	MouseButtonFlags?	The mouse buttons that the button responds to. Defaults to "left-and-right".
---@field auto_toggle	boolean?	Whether the button will automatically toggle when clicked. Defaults to false.
---@field toggled	boolean?	The initial toggled state of the button. Defaults to false.
---@field style string|KuxCoreLib.ElementBuilder.sprite-button-style-parameter|nil The name of the style prototype or a LuaStyle to apply to the new element.

---[View documentation](https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add)
---@class KuxCoreLib.ElementBuilder.parameter.sprite : KuxCoreLib.ElementBuilder.parameter.base
---@field sprite	SpritePath?	Path to the image to display.
---@field resize_to_sprite	boolean?	Whether the widget should resize according to the sprite in it. Defaults to true.
---@field style string|KuxCoreLib.ElementBuilder.sprite-style-parameter|nil The name of the style prototype or a LuaStyle to apply to the new element.

---[View documentation](https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add)
---@class KuxCoreLib.ElementBuilder.parameter.scroll-pane : KuxCoreLib.ElementBuilder.parameter.base
---@field horizontal_scroll_policy	string?	Policy of the horizontal scroll bar. Possible values are "auto", "never", "always", "auto-and-reserve-space", "dont-show-but-allow-scrolling". Defaults to "auto".
---@field vertical_scroll_policy	string?	Policy of the vertical scroll bar. Possible values are "auto", "never", "always", "auto-and-reserve-space", "dont-show-but-allow-scrolling". Defaults to "auto".
---@field style string|KuxCoreLib.ElementBuilder.scroll-pane-style-parameter|nil The name of the style prototype or a LuaStyle to apply to the new element.

---[View documentation](https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add)
---@class KuxCoreLib.ElementBuilder.parameter.drop-down : KuxCoreLib.ElementBuilder.parameter.base
---@field items	LocalisedString[]?	The initial items in the dropdown.
---@field selected_index	uint?	The index of the initially selected item. Defaults to 0.
---@field style string|KuxCoreLib.ElementBuilder.drop-down-style-parameter|nil The name of the style prototype or a LuaStyle to apply to the new element.

---[View documentation](https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add)
---@class KuxCoreLib.ElementBuilder.parameter.line : KuxCoreLib.ElementBuilder.parameter.base
---@field direction	string?	The initial direction of the line. Defaults to "horizontal".
---@field style string|KuxCoreLib.ElementBuilder.line-style-parameter|nil The name of the style prototype or a LuaStyle to apply to the new element.

---[View documentation](https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add)
---@class KuxCoreLib.ElementBuilder.parameter.list-box : KuxCoreLib.ElementBuilder.parameter.base
---@field items	LocalisedString[]?	The initial items in the listbox.
---@field elected_index	uint?	The index of the initially selected item. Defaults to 0.
---@field style string|KuxCoreLib.ElementBuilder.list-box-style-parameter|nil The name of the style prototype or a LuaStyle to apply to the new element.

---[View documentation](https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add)
---@class KuxCoreLib.ElementBuilder.parameter.camera : KuxCoreLib.ElementBuilder.parameter.base
---@field position	MapPosition	The position the camera centers on.
---@field surface_index	uint?	The surface that the camera will render. Defaults to the player's current surface.
---@field zoom	double?	The initial camera zoom. Defaults to 0.75.
---@field style string|KuxCoreLib.ElementBuilder.camera-style-parameter|nil The name of the style prototype or a LuaStyle to apply to the new element.

---[View documentation](https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add)
---@class KuxCoreLib.ElementBuilder.parameter.choose-elem-button : KuxCoreLib.ElementBuilder.parameter.base
---@field elem_type	string	The type of the button - one of the following values.
---@field item	string?	If type is "item" - the default value for the button.
---@field tile	string?	If type is "tile" - the default value for the button.
---@field entity	string?	If type is "entity" - the default value for the button.
---@field signal	SignalID?	If type is "signal" - the default value for the button.
---@field fluid	string?	If type is "fluid" - the default value for the button.
---@field recipe	string?	If type is "recipe" - the default value for the button.
---@field decorative	string?	If type is "decorative" - the default value for the button.
---@field item-group	string?	If type is "item-group" - the default value for the button.
---@field achievement	string?	If type is "achievement" - the default value for the button.
---@field equipment	string?	If type is "equipment" - the default value for the button.
---@field technology	string?	If type is "technology" - the default value for the button.
---@field elem_filters	PrototypeFilter?	Filters describing what to show in the selection window. The applicable filter depends on the elem_type.
---@field style string|KuxCoreLib.ElementBuilder.choose-elem-button-style-parameter|nil The name of the style prototype or a LuaStyle to apply to the new element.

---[View documentation](https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add)
---@class KuxCoreLib.ElementBuilder.parameter.text-box : KuxCoreLib.ElementBuilder.parameter.base
---@field text	string?	The initial text contained in the text-box.
---@field clear_and_focus_on_right_click	boolean?	Defaults to false.
---@field style string|KuxCoreLib.ElementBuilder.text-box-style-parameter|nil The name of the style prototype or a LuaStyle to apply to the new element.

---[View documentation](https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add)
---@class KuxCoreLib.ElementBuilder.parameter.slider : KuxCoreLib.ElementBuilder.parameter.base
---@field minimum_value	double?	The minimum value for the slider. Defaults to 0.
---@field maximum_value	double?	The maximum value for the slider. Defaults to 30.
---@field value	double?	The initial value for the slider. Defaults to minimum_value.
---@field value_step	double?	The minimum value the slider can move. Defaults to 1.
---@field discrete_slider	boolean?	Defaults to false.
---@field discrete_values	boolean?	Defaults to true.
---@field style string|KuxCoreLib.ElementBuilder.slider-style-parameter|nil The name of the style prototype or a LuaStyle to apply to the new element.

---[View documentation](https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add)
---@class KuxCoreLib.ElementBuilder.parameter.minimap : KuxCoreLib.ElementBuilder.parameter.base
---@field position	MapPosition?	The position the minimap centers on. Defaults to the player's current position.
---@field surface_index	uint?	The surface the camera will render. Defaults to the player's current surface.
---@field chart_player_index	uint?	The player index the map should use. Defaults to the current player.
---@field force	string?	The force this minimap should use. Defaults to the player's current force.
---@field zoom	double?	The initial camera zoom. Defaults to 0.75.
---@field style string|KuxCoreLib.ElementBuilder.minimap-style-parameter|nil The name of the style prototype or a LuaStyle to apply to the new element.

---[View documentation](https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add)
---@class KuxCoreLib.ElementBuilder.parameter.tab : KuxCoreLib.ElementBuilder.parameter.base
---@field badge_text	LocalisedString?	The text to display after the normal tab text (designed to work with numbers).
---@field style string|KuxCoreLib.ElementBuilder.tab-style-parameter|nil The name of the style prototype or a LuaStyle to apply to the new element.

---[View documentation](https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add)
---@class KuxCoreLib.ElementBuilder.parameter.switch : KuxCoreLib.ElementBuilder.parameter.base
---@field switch_state	string?	Possible values are "left", "right", or "none". If set to "none", allow_none_state must be true. Defaults to "left".
---@field allow_none_state	boolean?	Whether the switch can be set to a middle state. Defaults to false.
---@field left_label_caption	LocalisedString?
---@field left_label_tooltip	LocalisedString?
---@field right_label_caption	LocalisedString?
---@field right_label_tooltip	LocalisedString?
---@field style string|KuxCoreLib.ElementBuilder.switch-style-parameter|nil The name of the style prototype or a LuaStyle to apply to the new element.

---[View documentation](https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add)
---@class KuxCoreLib.ElementBuilder.parameter.entity-preview : KuxCoreLib.ElementBuilder.parameter.base
---@field style string|KuxCoreLib.ElementBuilder.entity-preview-style-parameter|nil The name of the style prototype or a LuaStyle to apply to the new element.

---[View documentation](https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add)
---@class KuxCoreLib.ElementBuilder.parameter.empty-widget : KuxCoreLib.ElementBuilder.parameter.base
---@field style string|KuxCoreLib.ElementBuilder.empty-widget-style-parameter|nil The name of the style prototype or a LuaStyle to apply to the new element.

---[View documentation](https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add)
---@class KuxCoreLib.ElementBuilder.parameter.tabbed-pane : KuxCoreLib.ElementBuilder.parameter.base
---@field style string|KuxCoreLib.ElementBuilder.tabbed-pane-style-parameter|nil The name of the style prototype or a LuaStyle to apply to the new element.


---Style of a GUI element. All of the attributes listed here may be `nil` if not available for a particular GUI element.
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html)
---@class KuxCoreLib.ElementBuilder.style-parameter
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.badge_font)
---
---_Can only be used if this is TabStyle_
---@field badge_font string
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.badge_horizontal_spacing)
---
---_Can only be used if this is TabStyle_
---@field badge_horizontal_spacing int
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.bar_width)
---
---_Can only be used if this is LuaProgressBarStyle_
---@field bar_width uint
---[RW]
---Space between the table cell contents bottom and border.
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.bottom_cell_padding)
---
---_Can only be used if this is LuaTableStyle_
---@field bottom_cell_padding int
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.bottom_margin)
---@field bottom_margin int
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.bottom_padding)
---@field bottom_padding int
---[W]
---Space between the table cell contents and border. Sets top/right/bottom/left cell paddings to this value.
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.cell_padding)
---
---_Can only be used if this is LuaTableStyle_
---@field cell_padding int
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.clicked_font_color)
---
---_Can only be used if this is LuaButtonStyle_
---@field clicked_font_color Color
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.clicked_vertical_offset)
---
---_Can only be used if this is LuaButtonStyle_
---@field clicked_vertical_offset int
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.color)
---
---_Can only be used if this is LuaProgressBarStyle_
---@field color Color
---[R]
---Array containing the alignment for every column of this table element. Even though this property is marked as read-only, the alignment can be changed by indexing the LuaCustomTable, like so:
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.column_alignments)
---
---### Example
---```
---table_element.style.column_alignments[1] = "center"
---```
---@field column_alignments LuaCustomTable<uint,Alignment>
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.default_badge_font_color)
---
---_Can only be used if this is TabStyle_
---@field default_badge_font_color Color
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.disabled_badge_font_color)
---
---_Can only be used if this is TabStyle_
---@field disabled_badge_font_color Color
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.disabled_font_color)
---
---_Can only be used if this is LuaButtonStyle or LuaTabStyle_
---@field disabled_font_color Color
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.extra_bottom_margin_when_activated)
---
---_Can only be used if this is ScrollPaneStyle_
---@field extra_bottom_margin_when_activated int
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.extra_bottom_padding_when_activated)
---
---_Can only be used if this is ScrollPaneStyle_
---@field extra_bottom_padding_when_activated int
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.extra_left_margin_when_activated)
---
---_Can only be used if this is ScrollPaneStyle_
---@field extra_left_margin_when_activated int
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.extra_left_padding_when_activated)
---
---_Can only be used if this is ScrollPaneStyle_
---@field extra_left_padding_when_activated int
---[W]
---Sets `extra_top/right/bottom/left_margin_when_activated` to this value. An array with two values sets top/bottom margin to the first value and left/right margin to the second value. An array with four values sets top, right, bottom, left margin respectively.
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.extra_margin_when_activated)
---@field extra_margin_when_activated int|int[]
---[W]
---Sets `extra_top/right/bottom/left_padding_when_activated` to this value. An array with two values sets top/bottom padding to the first value and left/right padding to the second value. An array with four values sets top, right, bottom, left padding respectively.
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.extra_padding_when_activated)
---@field extra_padding_when_activated int|int[]
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.extra_right_margin_when_activated)
---
---_Can only be used if this is ScrollPaneStyle_
---@field extra_right_margin_when_activated int
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.extra_right_padding_when_activated)
---
---_Can only be used if this is ScrollPaneStyle_
---@field extra_right_padding_when_activated int
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.extra_top_margin_when_activated)
---
---_Can only be used if this is ScrollPaneStyle_
---@field extra_top_margin_when_activated int
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.extra_top_padding_when_activated)
---
---_Can only be used if this is ScrollPaneStyle_
---@field extra_top_padding_when_activated int
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.font)
---@field font string
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.font_color)
---@field font_color Color
---[R]
---Gui of the [LuaGuiElement](https://lua-api.factorio.com/latest/LuaGuiElement.html) of this style.
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.gui)
---@field gui LuaGui
---[W]
---Sets both minimal and maximal height to the given value.
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.height)
---@field height int
---[RW]
---Horizontal align of the inner content of the widget, if any. Possible values are "left", "center" or "right".
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.horizontal_align)
---@field horizontal_align? string
---[RW]
---Horizontal space between individual cells.
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.horizontal_spacing)
---
---_Can only be used if this is LuaTableStyle, LuaFlowStyle or LuaHorizontalFlowStyle_
---@field horizontal_spacing int
---[RW]
---Whether the GUI element can be squashed (by maximal width of some parent element) horizontally. `nil` if this element does not support squashing. This is mainly meant to be used for scroll-pane The default value is false.
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.horizontally_squashable)
---@field horizontally_squashable? boolean
---[RW]
---Whether the GUI element stretches its size horizontally to other elements. `nil` if this element does not support stretching.
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.horizontally_stretchable)
---@field horizontally_stretchable? boolean
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.hovered_font_color)
---
---_Can only be used if this is LuaButtonStyle_
---@field hovered_font_color Color
---[RW]
---Space between the table cell contents left and border.
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.left_cell_padding)
---
---_Can only be used if this is LuaTableStyle_
---@field left_cell_padding int
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.left_margin)
---@field left_margin int
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.left_padding)
---@field left_padding int
---[W]
---Sets top/right/bottom/left margins to this value. An array with two values sets top/bottom margin to the first value and left/right margin to the second value. An array with four values sets top, right, bottom, left margin respectively.
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.margin)
---@field margin int|int[]
---[RW]
---Maximal height ensures, that the widget will never be bigger than than that size. It can't be stretched to be bigger.
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.maximal_height)
---@field maximal_height int
---[RW]
---Maximal width ensures, that the widget will never be bigger than than that size. It can't be stretched to be bigger.
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.maximal_width)
---@field maximal_width int
---[RW]
---Minimal height ensures, that the widget will never be smaller than than that size. It can't be squashed to be smaller.
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.minimal_height)
---@field minimal_height int
---[RW]
---Minimal width ensures, that the widget will never be smaller than than that size. It can't be squashed to be smaller.
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.minimal_width)
---@field minimal_width int
---[R]
---Name of this style.
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.name)
---@field name string
---[RW]
---Natural height specifies the height of the element tries to have, but it can still be squashed/stretched to have a smaller or bigger size.
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.natural_height)
---@field natural_height int
---[RW]
---Natural width specifies the width of the element tries to have, but it can still be squashed/stretched to have a smaller or bigger size.
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.natural_width)
---@field natural_width int
---[R]
---The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.object_name)
---@field object_name string
---[W]
---Sets top/right/bottom/left paddings to this value. An array with two values sets top/bottom padding to the first value and left/right padding to the second value. An array with four values sets top, right, bottom, left padding respectively.
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.padding)
---@field padding int|int[]
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.pie_progress_color)
---
---_Can only be used if this is LuaButtonStyle_
---@field pie_progress_color Color
---[RW]
---How this GUI element handles rich text.
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.rich_text_setting)
---
---_Can only be used if this is LuaLabelStyle, LuaTextBoxStyle or LuaTextFieldStyle_
---@field rich_text_setting defines.rich_text_setting
---[RW]
---Space between the table cell contents right and border.
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.right_cell_padding)
---
---_Can only be used if this is LuaTableStyle_
---@field right_cell_padding int
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.right_margin)
---@field right_margin int
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.right_padding)
---@field right_padding int
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.selected_badge_font_color)
---
---_Can only be used if this is TabStyle_
---@field selected_badge_font_color Color
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.selected_clicked_font_color)
---
---_Can only be used if this is LuaButtonStyle_
---@field selected_clicked_font_color Color
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.selected_font_color)
---
---_Can only be used if this is LuaButtonStyle_
---@field selected_font_color Color
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.selected_hovered_font_color)
---
---_Can only be used if this is LuaButtonStyle_
---@field selected_hovered_font_color Color
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.single_line)
---
---_Can only be used if this is LabelStyle_
---@field single_line boolean
---[W]
---Sets both width and height to the given value. Also accepts an array with two values, setting width to the first and height to the second one.
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.size)
---@field size int|int[]
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.stretch_image_to_widget_size)
---
---_Can only be used if this is ImageStyle_
---@field stretch_image_to_widget_size boolean
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.strikethrough_color)
---
---_Can only be used if this is LuaButtonStyle_
---@field strikethrough_color Color
---[RW]
---Space between the table cell contents top and border.
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.top_cell_padding)
---
---_Can only be used if this is LuaTableStyle_
---@field top_cell_padding int
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.top_margin)
---@field top_margin int
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.top_padding)
---@field top_padding int
---[RW]
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.use_header_filler)
---
---_Can only be used if this is LuaFrameStyle_
---@field use_header_filler boolean
---[R]
---Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.valid)
---@field valid boolean
---[RW]
---Vertical align of the inner content of the widget, if any. Possible values are "top", "center" or "bottom".
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.vertical_align)
---@field vertical_align? string
---[RW]
---Vertical space between individual cells.
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.vertical_spacing)
---
---_Can only be used if this is LuaTableStyle, LuaFlowStyle, LuaVerticalFlowStyle or LuaTabbedPaneStyle_
---@field vertical_spacing int
---[RW]
---Whether the GUI element can be squashed (by maximal height of some parent element) vertically. `nil` if this element does not support squashing. This is mainly meant to be used for scroll-pane The default (parent) value for scroll pane is true, false otherwise.
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.vertically_squashable)
---@field vertically_squashable? boolean
---[RW]
---Whether the GUI element stretches its size vertically to other elements. `nil` if this element does not support stretching.
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.vertically_stretchable)
---@field vertically_stretchable? boolean
---[W]
---Sets both minimal and maximal width to the given value.
---
---[View documentation](https://lua-api.factorio.com/latest/LuaStyle.html#LuaStyle.width)
---@field width int

--TODO: style for each element

---@class KuxCoreLib.ElementBuilder.button-style-parameter : KuxCoreLib.ElementBuilder.style-parameter
---@class KuxCoreLib.ElementBuilder.sprite-button-style-parameter : KuxCoreLib.ElementBuilder.style-parameter
---@class KuxCoreLib.ElementBuilder.checkbox-style-parameter : KuxCoreLib.ElementBuilder.style-parameter
---@class KuxCoreLib.ElementBuilder.flow-style-parameter : KuxCoreLib.ElementBuilder.style-parameter
---@class KuxCoreLib.ElementBuilder.frame-style-parameter : KuxCoreLib.ElementBuilder.style-parameter
---@class KuxCoreLib.ElementBuilder.label-style-parameter : KuxCoreLib.ElementBuilder.style-parameter
---@class KuxCoreLib.ElementBuilder.line-style-parameter : KuxCoreLib.ElementBuilder.style-parameter
---@class KuxCoreLib.ElementBuilder.progressbar-style-parameter : KuxCoreLib.ElementBuilder.style-parameter
---@class KuxCoreLib.ElementBuilder.table-style-parameter : KuxCoreLib.ElementBuilder.style-parameter
---@class KuxCoreLib.ElementBuilder.textfield-style-parameter : KuxCoreLib.ElementBuilder.style-parameter
---@class KuxCoreLib.ElementBuilder.radiobutton-style-parameter : KuxCoreLib.ElementBuilder.style-parameter
---@class KuxCoreLib.ElementBuilder.sprite-style-parameter : KuxCoreLib.ElementBuilder.style-parameter
---@class KuxCoreLib.ElementBuilder.scroll-pane-style-parameter : KuxCoreLib.ElementBuilder.style-parameter
---@class KuxCoreLib.ElementBuilder.drop-down-style-parameter : KuxCoreLib.ElementBuilder.style-parameter
---@class KuxCoreLib.ElementBuilder.list-box-style-parameter : KuxCoreLib.ElementBuilder.style-parameter
---@class KuxCoreLib.ElementBuilder.camera-style-parameter : KuxCoreLib.ElementBuilder.style-parameter
---@class KuxCoreLib.ElementBuilder.choose-elem-button-style-parameter : KuxCoreLib.ElementBuilder.style-parameter
---@class KuxCoreLib.ElementBuilder.text-box-style-parameter : KuxCoreLib.ElementBuilder.style-parameter
---@class KuxCoreLib.ElementBuilder.slider-style-parameter : KuxCoreLib.ElementBuilder.style-parameter
---@class KuxCoreLib.ElementBuilder.minimap-style-parameter : KuxCoreLib.ElementBuilder.style-parameter
---@class KuxCoreLib.ElementBuilder.entity-preview-style-parameter : KuxCoreLib.ElementBuilder.style-parameter
---@class KuxCoreLib.ElementBuilder.empty-widget-style-parameter : KuxCoreLib.ElementBuilder.style-parameter
---@class KuxCoreLib.ElementBuilder.tabbed-pane-style-parameter : KuxCoreLib.ElementBuilder.style-parameter
---@class KuxCoreLib.ElementBuilder.tab-style-parameter : KuxCoreLib.ElementBuilder.style-parameter
---@class KuxCoreLib.ElementBuilder.switch-style-parameter : KuxCoreLib.ElementBuilder.style-parameter

--[[
button				A clickable element. Relevant event: on_gui_click
sprite-button		A button that displays a sprite rather than text. Relevant event: on_gui_click
checkbox			A clickable element with a check mark that can be turned off or on. Relevant event: on_gui_checked_state_changed
flow				An invisible container that lays out its children either horizontally or vertically.
frame				A non-transparent box that contains other elements. It can have a title (set via the caption attribute). Just like a flow, it lays out its children either horizontally or vertically. Relevant event: on_gui_location_changed
label				A piece of text.
line				A horizontal or vertical separation line.
progressbar			A partially filled bar that can be used to indicate progress.
table				An invisible container that lays out its children in a specific number of columns. The width of each column is determined by the widest element it contains.
textfield			A single-line box the user can type into. Relevant events: on_gui_text_changed, on_gui_confirmed
radiobutton			An element that is similar to a checkbox, but with a circular appearance. Clicking a selected radio button will not unselect it. Radio buttons are not linked to each other in any way. Relevant event: on_gui_checked_state_changed
sprite				An element that shows an image.
scroll-pane			An invisible element that is similar to a flow, but has the ability to show and use scroll bars.
drop-down			A drop-down containing strings of text. Relevant event: on_gui_selection_state_changed
list-box			A list of strings, only one of which can be selected at a time. Shows a scroll bar if necessary. Relevant event: on_gui_selection_state_changed
camera				A camera that shows the game at the given position on the given surface. It can visually track an entity that is set after the element has been created.
choose-elem-button	A button that lets the player pick from a certain kind of prototype, with optional filtering. Relevant event: on_gui_elem_changed
text-box			A multi-line textfield. Relevant event: on_gui_text_changed
slider				A horizontal number line which can be used to choose a number. Relevant event: on_gui_value_changed
minimap				A minimap preview, similar to the normal player minimap. It can visually track an entity that is set after the element has been created.
entity-preview		A preview of an entity. The entity has to be set after the element has been created.
empty-widget		An empty element that just exists. The root GUI elements screen and relative are empty-widgets.
tabbed-pane			A collection of tabs and their contents. Relevant event: on_gui_selected_tab_changed
tab					A tab for use in a tabbed-pane.
switch				A switch with three possible states. Can have labels attached to either side. Relevant event: on_gui_switch_state_changed
]]