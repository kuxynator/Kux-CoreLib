-- This file is reqired by ElementBuilder.element_builder only

--adapted for Factorio 2.0 ( no changes )

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
	"value_step", "vertical_centering", "vertical_scroll_policy", "visible", "zoom",
	"auto_center", "drag_target", "elem_tooltip", "location",
	}
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
local function isInteger(value) return type(value)=="number" and math.floor(value)==value end

-- check for names which can be used as add field and as style field
for _,name in ipairs(_style_writable_fields) do
	assert(isAddField[name]==nil, "Style field '"..name.."' is also an add field.")
end

local t = {"%self%","%parent%","%parent.parent%"}
local supported_variables = {}; for _,v in ipairs(t) do supported_variables[v]=true end

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

---Cleans up args by removing all style parameters and returning them as style table. args.style:string is retained or created
---@param args table
---@return table|nil #The style table or nil
local function prep_style(args)
	local style = {}
	if(not args.style) then
		--do nothing
	elseif(type(args.style)=="string") then
		--keep "style" in args, as add paramter
	elseif(type(args.style)=="table") then
		style = table.deepcopy(args.style)
		args.style = style.base or style.parent or args.base_style --set "style" in args, as add paramter
		style.base = nil; style.parent = nil; style.type = nil
		args.base_style = nil
	else
		error("Invalid Parameter. 'style' must be a string or a table but is "..type(args.style)..": "..serpent.line(args.style))
	end

	if args.style and not prototypes.style[args.style] then error("Style '"..args.style.."' does not exist.") end

	-- handle style fields
	for k,v in pairs(args) do
		if (not isInteger(k) and isWriteableStyleField[k])
			or k=="column_alignments"  --field is readonly, but we can set the content later
		then
			style = style or {}
			style[k] = v
			args[k] = nil
			--[[TRACE]]--trace.append("  prep_style '"..k.."' moved to style")
		end
	end

	return style
end

local function prep_children(args)
	local children= {}
	for i = 1, #args, 1 do
		if type(args[i]) == "function" then
			table.insert(children, args[i])
			args[i] = nil
		end
	end
	if(args.children) then
		if #children > 0 then error("Duplicate definition of children.") end
		children = args.children
		args.children = nil
	end
	if(type(args[#args])=="table") then
		if #children > 0 then error("Duplicate definition of children.") end
		children = args[#args]
		args[#args] = nil
	end

	return #children > 0 and children or nil
end

---filters args and returns a table with fields that are not supported by LuaGuiElement.add
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

local function prep_name(args, container)
	if(args.name) then
		return
	elseif(args[1] and type(args[1])=="string") then
		args.name = args[1]
		args[1] = nil
	else
	--	args.name = create_element_name(container) --TODO: why do we need a name?
	end
end


---Applies the style to the element
---@param element LuaGuiElement
---@param style table
local function apply_style(element, style)
	if( not style) then return end
	for k,v in pairs(style) do
		if k == "column_alignments" then
			for i, alignment in pairs(v) do
				element.style.column_alignments[i] = alignment
			end
		else
			element.style[k] = v
		end
	end
end

---Applies the extra properties to the element
---@param element LuaGuiElement
---@param extra table
local function apply_extra(element, extra)
	if( not extra) then return end
	for k,v in pairs(extra) do
		if k:find("^on_") then -- on_gui_click = ...
			tags = element.tags
			tags[k] = v
			element.tags = tags
		else
			element[k] = v
			-- Given object is not a LuaGuiElement.
			-- on drag_target = "%parent%"
		end
	end
end

local function apply_post(element, post_args)
	for k,v in pairs(post_args) do
		if(v == "%parent%") then -- drag_target = "%parent%"
			element[k] = element.parent
		elseif(v == "%parent.parent%") then
			element[k] = element.parent.parent
		elseif(v == "%self%") then
			element[k] = element
		else
			error("Unsupported variable: "..v)
		end
	end
end

---@class KuxCoreLib.internal.ElementFactoryUtils
local element_factory_utils = {
	---@class KuxCoreLib.internal.ElementFactoryUtils.prep
	prep = {
		style = prep_style,
		add = prep_add,
		children = prep_children,
		name = prep_name,
		caption = prep_caption,
		post = prep_post
	},
	---@class KuxCoreLib.internal.ElementFactoryUtils.apply
	apply = {
		style = apply_style,
		extra = apply_extra,
		post = apply_post
	}
}

return element_factory_utils