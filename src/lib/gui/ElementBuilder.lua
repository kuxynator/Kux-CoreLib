--|--------------------------------------------------------------------------------------------------------------------
--| class ElementBuilder
--|
--| part of GuiBuilder
--| usage: KuxCoreLib.require.GuiBuilder.ElementBuilder
--|--------------------------------------------------------------------------------------------------------------------


---@class KuxCoreLib.ElementBuilder
local ElementBuilder = {}
-- automatic handling of style parameters (moved to style and assigned after creation)
-- automatic handling of non add parameters (assigned after creation)

local trace = trace or function() end
local VGuiElement = KuxCoreLib.require.VGuiElement
local add_cache_element = KuxCoreLib.require.GuiElementCache2.add_cache_element
local temp_virtual_elements = {} ---@type {[number]:KuxCoreLib.VGuiElement}

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

---@param args table
---@param name string
---@param value string|number|boolean|table|nil
---<p>a) <code>fun(t, name, value)</code><br/>
---b) <code>fun(t, {name->value})</code></p>
---@overload fun(args:table, name:{[string]: string|number|boolean|table|nil})
function ElementBuilder.patch_tags(args, name, value)
	if args.tags == nil then args.tags = {} end
	if type(name) == "table" then
		for k, v in pairs(name) do args.tags[k] = type(v)=="table" and Table.deepCopy(v) or v end
	else
		args.tags[name] = value
	end
end

function ElementBuilder.patch(args, changes)
	if changes==nil then return end
	for k,v in pairs(changes) do
		if k == "tags" then
			local tags = args.tags or {}                                     --:: RW simple table
			for k,v in pairs(v) do tags[k] = v end
			args.tags = tags
		elseif k == "column_alignments" then                                 --:: R LuaCustomTable[uint → Alignment]
			for k,v in pairs(v) do args.column_alignments[k] = v end
		else
			args[k] = v
		end
	end
end

function ElementBuilder.replace_ui_element(args)
	--{gui.elements.SearchView.elem_type, elem_type = elem_type}
end

---@class KuxCoreLib.ElementBuilder.create.parameters
---@field container LuaGuiElement? The container element to add the new element to
---@field mod_name string? The current mod name
---@field view_name string? The current view name
---@field parent_view_name string? The parent view name
---@field all_names {string: LuaGuiElement|LuaGuiElement[]}?
---@field mode "new"|"append"|nil defaults to "new"
---@field [1] function|nil child


---@param container LuaGuiElement
---@param create_children_fnc function
---@param parameters KuxCoreLib.ElementBuilder.create.parameters
---@return LuaGuiElement
local function create(container, create_children_fnc, parameters)
	assert(container~=nil, "Invalid Argument. 'container' must not be nil.")
	assert(type(create_children_fnc)=="function", "Invalid Argument. 'create_children_fnc' must be a function but is '"..type(create_children_fnc).."'.")
	trace("ElementBuilder.create in "..container.name.." from "..type(create_children_fnc))
	if parameters.all_names == nil then parameters.all_names = {} end
	if parameters.mode == "new" then
		parameters.all_names[parameters.view_name] = {__parent_view_name=parameters.parent_view_name}
	end
	local list =
		type(create_children_fnc) == "function" and {create_children_fnc} or
		type(create_children_fnc) == "table" and create_children_fnc or
		error("Invalid Argument. 'create_children_fnc' must be a function or a table of functions.")
	local results = {}
	for _, fnc in ipairs(list) do
		assert(type(fnc)=="function", "Invalid Argument. 'create_children_fnc' must be a function or a table of functions. but is "..type(fnc)..": "..serpent.line(fnc).." container: "..container.name)
		local elmt = fnc(container, parameters)
		table.insert(results, elmt)
	end
	return type(create_children_fnc) == "function" and results[1] or results
end

---@param container LuaGuiElement
---@param create_children_fnc function[]
---@param parameters KuxCoreLib.ElementBuilder.create.parameters
---@return LuaGuiElement[]
local function create_multi(container, create_children_fnc, parameters)
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
	for _, fnc in ipairs(list) do
		assert(type(fnc)=="function", "Invalid Argument. 'create_children_fnc' must be a function or a table of functions. but is "..type(fnc)..": "..serpent.line(fnc).." container: "..container.name)

		local result =  fnc(container, parameters) ---@type LuaGuiElement|fun(container,parameters)
		local elmt = type(result)=="function" and result(container, parameters) or result
		if elmt then results[#results+1] = elmt end
	end
	return results
end

---@param container LuaGuiElement
---@param create_children_fnc function
---@return LuaGuiElement
---@deprecated I no longer know what it was intended for
function ElementBuilder.create(container, create_children_fnc)
	return create(container, create_children_fnc, {all_names={}, mod_name=nil})
end

---createView
---@param args KuxCoreLib.ElementBuilder.create.parameters
---@return LuaGuiElement
---<p>-> createView{container, mod_name, view_name, all_names, children}</p>
function ElementBuilder.createView_v2(args)
	args.mode = args.mode or "new"
	return create(args.container, args[1], args)
end

---@param root_container LuaGuiElement
---@param create_children_fnc function
---@param all_names {[string]:LuaGuiElement|LuaGuiElement[]}?  --filled with all named elements for the complete tree
---@param mod_name string? --name of the mod for the elements. stored in tags.mod_name
---@return LuaGuiElement
function ElementBuilder.createView(root_container, create_children_fnc, all_names, mod_name)
	return create(root_container, create_children_fnc, {all_names=all_names or {}, mod_name=mod_name})
end

---@param el LuaGuiElement
---@param all_elements {[string]:LuaGuiElement|LuaGuiElement[]}
---@param view_elements {[string]:LuaGuiElement|LuaGuiElement[]}
function ElementBuilder.destroy_element(el, all_elements, view_elements)
	assert(el~=nil, "Invalid Argument. 'el' must not be nil.")
	assert(type(all_elements)=="table", "Invalid Argument. 'all_elements' must be a table but is "..type(all_elements)..": "..serpent.line(all_elements))
	assert(type(view_elements)=="table", "Invalid Argument. 'view_elements' must be a table but is "..type(view_elements)..": "..serpent.line(view_elements))
	local t = all_elements[el.name]
	if type(t) == "table" then
		Table.remove(t, el)
		if     #t == 0 then all_elements[el.name] = nil
		elseif #t == 1 then all_elements[el.name] = t[1]
		end
	else
		all_elements[el.name] = nil
	end

	t = view_elements[el.name]
	if type(t) == "table" then
		Table.remove(t, el)
		if     #t == 0 then view_elements[el.name] = nil
		elseif #t == 1 then view_elements[el.name] = t[1]
		end
	else
		view_elements[el.name] = nil
	end
	local p = el.parent
	el.destroy()
end


---@param container LuaGuiElement
---@param definitions table
---@param parameters KuxCoreLib.ElementBuilder.create.parameters
---@return LuaGuiElement[]
function ElementBuilder.add(container, definitions, parameters)
	if type(definitions)~="table" then definitions = {definitions} end
	local results = {}
	if #definitions==0 then return results end
	local def1 = definitions[1]
	for i, def in ipairs(definitions) do
		local children = def.children; def.children = nil
		results[i] = ElementBuilder.factory(def)(container, parameters)
		ElementBuilder.add(results[i], children, parameters)
	end
	return results
end

-------------------------------------------------------------------------------
--#region: element_factory
-------------------------------------------------------------------------------

local element_factory_utils = require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/gui/element_factory_utils")
local prep = element_factory_utils.prep
local apply = element_factory_utils.apply

---Base function to create a gui element creation function
---@param args table the arguments for the element as specified in then designer
---@return fun(container:LuaGuiElement, parameters:KuxCoreLib.ElementBuilder.create.parameters) #A function that creates the element in the given container
local function element_factory(args)
	assert(args~=nil, "Invalid Argument. 'args' must not be nil.")

	---@param container LuaGuiElement
	---@param parameters KuxCoreLib.ElementBuilder.create.parameters
	return function(container, parameters)
		assert(container~=nil, "Invalid Argument. 'container' must not be nil.")
		--TODO Make log configurable if required
		--log("ElementBuilder.element_factory "..tostring(container.name).." "..tostring(args.name))

		local is_virtual_root = args.virtual and container.object_name == "LuaGuiElement" or false
		local is_virtual = args.virtual or container.object_name == nil

		local element = nil
		local children = nil

		if is_virtual then
			args.virtual = nil
			children = prep.children(args)
			args.children=nil
			if is_virtual_root then
				temp_virtual_elements = {}
				element = VGuiElement.new(args,{parent = container})
				element.vid = #temp_virtual_elements
				table.insert(temp_virtual_elements, element)
				local tags = container.tags
				tags.virtual_children=tags.virtual_children or {}
				table.insert(tags.virtual_children--[[@as table]], element.vid)
				container.tags = tags --> ERROR: value (function) can't be saved in property tree at ROOT.0.children[0]
			else
				element = container.add(args)
			end
		else
			local all_names = parameters.all_names or error("Invalid Argument. 'parameters.all_names' must not be nil.")
							 prep.caption(args) --[2]
			local style    = prep.style(args)
			      children = prep.children(args)
			local post     = prep.post(args) -- execute before prep_add
			local extra    = prep.add(args)
			--[[TRACE]]--trace("ElementBuilder.element_base "..tostring(container.name).." "..tostring(args.name))
			--[[TRACE]]--trace.append("  args:  "..serpent.line(args))
			--[[TRACE]]--trace.append("  style: "..serpent.line(style))
			--[[TRACE]]--trace.append("  extra: "..serpent.line(extra))
			prep.name(args, container) --[1]

			element = container.add(args)
			--if all_names then add_cache_element(all_names, element) end
			--if view_names then add_cache_element(view_names, element) end
			if all_names then
				all_names[element.name] = element                       -- add ti index, no duplicates, only last one is saved
				if parameters.view_name then all_names[parameters.view_name][element.name] = element  end-- add to view index, no duplicates, only last one is saved
			end
			if(style) then apply.style(element, style) end
			if(extra) then apply.extra(element, extra) end
			if(post ) then apply.post (element, post ) end
		end

		local tags = element.tags
		tags.mod_name = parameters.mod_name
		tags.view_name = parameters.view_name
		element.tags = tags
		if(children) then create_multi(element, children, parameters) end

		if is_virtual_root then
			VGuiElement.freeze(element)
			local tags = container.tags
			tags.virtual_children=tags.virtual_children or {}
			tags.virtual_children[#tags.virtual_children] = element
			container.tags = tags
		end

		return element
	end
end
ElementBuilder.factory = element_factory


-------------------------------------------------------------------------------
---#region: elements
-------------------------------------------------------------------------------

---A clickable element. Relevant event: on_gui_click
---@param args KuxCoreLib.ElementBuilder.button.args
---@return function
---<p><a href="https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add">View Documentation</a></p>
function ElementBuilder.button(args)
	args["type"]="button"
	return element_factory(args)
end

---A button that displays a sprite rather than text. Relevant event: on_gui_click
---@param args KuxCoreLib.ElementBuilder.spritebutton.args
---@return function
---<p><a href="https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add">View Documentation</a></p>
function ElementBuilder.spritebutton(args)
	args["type"]="sprite-button"
	return element_factory(args)
end

---@type Decorative

---A clickable element with a check mark that can be turned off or on. Relevant event: on_gui_checked_state_changed
---@param args KuxCoreLib.ElementBuilder.checkbox.args
---@return function
---<p><a href="https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add">View Documentation</a></p>
function ElementBuilder.checkbox(args)
	args["type"]="checkbox"
	return element_factory(args)
end

---An invisible container that lays out its children either horizontally or vertically.
---@param args KuxCoreLib.ElementBuilder.flow.args
---@return function
---<p><a href="https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add">View Documentation</a></p>
function ElementBuilder.flow(args)
	args["type"]="flow"
	return element_factory(args)
end

---A non-transparent box that contains other elements. It can have a title (set via the caption attribute). Just like a flow, it lays out its children either horizontally or vertically. Relevant event: on_gui_location_changed
---@param args KuxCoreLib.ElementBuilder.frame.args
---@return function
function ElementBuilder.frame(args)
	args["type"]="frame"
	return element_factory(args)
end

---A piece of text.
---@param args KuxCoreLib.ElementBuilder.label.args
---@return function
---<p><a href="https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add">View Documentation</a></p>
function ElementBuilder.label(args)
	args["type"]="label"
	return element_factory(args)
end

---A horizontal or vertical separation line.
---@param args KuxCoreLib.ElementBuilder.line.args
---@return function
---<p><a href="https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add">View Documentation</a></p>
function ElementBuilder.line(args)
	args["type"]="line"
	return element_factory(args)
end

---A partially filled bar that can be used to indicate progress.
---@param args KuxCoreLib.ElementBuilder.progressbar.args
---@return function
---<p><a href="https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add">View Documentation</a></p>
function ElementBuilder.progressbar(args)
	args["type"]="progressbar"
	return element_factory(args)
end

---An invisible container that lays out its children in a specific number of columns. The width of each column is determined by the widest element it contains.
---@param args KuxCoreLib.ElementBuilder.table.args
---@return function
---<p><a href="https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add">View Documentation</a></p>
function ElementBuilder.table(args)
	args["type"]="table"
	return element_factory(args)
end

---A single-line box the user can type into. Relevant events: on_gui_text_changed, on_gui_confirmed
---@param args KuxCoreLib.ElementBuilder.textfield.args
---@return function
---<p><a href="https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add">View Documentation</a></p>
function ElementBuilder.textfield(args)
	args["type"]="textfield"
	return element_factory(args)
end

---An element that is similar to a checkbox, but with a circular appearance. Clicking a selected radio button will not unselect it. Radio buttons are not linked to each other in any way. Relevant event: on_gui_checked_state_changed
---@param args KuxCoreLib.ElementBuilder.radiobutton.args
---@return function
---<p><a href="https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add">View Documentation</a></p>
function ElementBuilder.radiobutton(args)
	args["type"]="radiobutton"
	return element_factory(args)
end

---An element that shows an image.
---@param args KuxCoreLib.ElementBuilder.sprite.args
---@return function
---<p><a href="https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add">View Documentation</a></p>
function ElementBuilder.sprite(args)
	args["type"]="sprite"
	return element_factory(args)
end

---An invisible element that is similar to a flow, but has the ability to show and use scroll bars.
---@param args KuxCoreLib.ElementBuilder.scrollpane.args
---@return function
---<p><a href="https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add">View Documentation</a></p>
function ElementBuilder.scrollpane(args)
	args["type"]="scroll-pane"
	return element_factory(args)
end

---A drop-down containing strings of text. Relevant event: on_gui_selection_state_changed
---@param args KuxCoreLib.ElementBuilder.dropdown.args
---@return function
---<p><a href="https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add">View Documentation</a></p>
function ElementBuilder.dropdown(args)
	args["type"]="drop-down"
	return element_factory(args)
end

---A list of strings, only one of which can be selected at a time. Shows a scroll bar if necessary. Relevant event: on_gui_selection_state_changed
---@param args KuxCoreLib.ElementBuilder.listbox.args
---@return function
---<p><a href="https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add">View Documentation</a></p>
function ElementBuilder.listbox(args)
	args["type"]="list-box"
	return element_factory(args)
end

---A camera that shows the game at the given position on the given surface. It can visually track an entity that is set after the element has been created.
---@param args KuxCoreLib.ElementBuilder.camera.args
---@return function
---<p><a href="https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add">View Documentation</a></p>
function ElementBuilder.camera(args)
	args["type"]="camera"
	return element_factory(args)
end

---A button that lets the player pick from a certain kind of prototype, with optional filtering. Relevant event: on_gui_elem_changed
---@param args KuxCoreLib.ElementBuilder.chooseelembutton.args
---@return function
---<p><a href="https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add">View Documentation</a></p>
function ElementBuilder.chooseelembutton(args)
	args["type"]="choose-elem-button"
	return element_factory(args)
end

---A multi-line textfield. Relevant event: on_gui_text_changed
---@param args KuxCoreLib.ElementBuilder.textbox.args
---@return function
---<p><a href="https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add">View Documentation</a></p>
function ElementBuilder.textbox(args)
	args["type"]="text-box"
	return element_factory(args)
end

---A horizontal number line which can be used to choose a number. Relevant event: on_gui_value_changed
---@param args KuxCoreLib.ElementBuilder.slider.args
---@return function
---<p><a href="https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add">View Documentation</a></p>
function ElementBuilder.slider(args)
	args["type"]="slider"
	return element_factory(args)
end

---A minimap preview, similar to the normal player minimap. It can visually track an entity that is set after the element has been created.
---@param args KuxCoreLib.ElementBuilder.minimap.args
---@return function
---<p><a href="https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add">View Documentation</a></p>
function ElementBuilder.minimap(args)
	args["type"]="minimap"
	return element_factory(args)
end

---A preview of an entity. The entity has to be set after the element has been created.
---@param args KuxCoreLib.ElementBuilder.entitypreview.args
---@return function
---<p><a href="https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add">View Documentation</a></p>
function ElementBuilder.entitypreview(args)
	args["type"]="entity-preview"
	return element_factory(args)
end

---An empty element that just exists. The root GUI elements screen and relative are empty-widgets.
---@param args KuxCoreLib.ElementBuilder.emptywidget.args
---@return function
---<p><a href="https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add">View Documentation</a></p>
function ElementBuilder.emptywidget(args)
	args["type"]="empty-widget"
	return element_factory(args)
end

---A collection of tabs and their contents. Relevant event: on_gui_selected_tab_changed
---@param args KuxCoreLib.ElementBuilder.tabbedpane.args
---@return function
---<p><a href="https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add">View Documentation</a></p>
function ElementBuilder.tabbedpane(args)
	args["type"]="tabbed-pane"
	return element_factory(args)
end

---A tab for use in a tabbed-pane.
---@param args KuxCoreLib.ElementBuilder.tab.args
---@return function
---<p><a href="https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add">View Documentation</a></p>
function ElementBuilder.tab(args)
	args["type"]="tab"
	return element_factory(args)
end

---A switch with three possible states. Can have labels attached to either side. Relevant event: on_gui_switch_state_changed
---@param args KuxCoreLib.ElementBuilder.switch.args
---@return function
---<p><a href="https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#add">View Documentation</a></p>
function ElementBuilder.switch(args)
	args["type"]="switch"
	return element_factory(args)
end

return ElementBuilder


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