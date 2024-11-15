require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---Provides GUI helper functions
---@class KuxCoreLib.GuiHelper
local GuiHelper = {
	__class  = "GuiHelper",
	__guid   = "490ea051-dc17-465b-9234-ccf654eb3e10",
	__origin = "Kux-CoreLib/lib/gui/GuiHelper.lua",
}
if KuxCoreLib.__classUtils.cache(GuiHelper) then return KuxCoreLib.__classUtils.cached end
---------------------------------------------------------------------------------------------------
---Provides GuiHelper in the global namespace
---@return KuxCoreLib.GuiHelper
function GuiHelper.asGlobal() return KuxCoreLib.__classUtils.asGlobal(GuiHelper) end

---------------------------------------------------------------------------------------------------

---
---@param parent LuaGuiElement|LuaGui
---@param name string
---@param prefix string?
---@return LuaGuiElement?
function GuiHelper.findElementRecursive(parent, name, prefix)
	assert(parent, "Invalid Argument. 'parent' must not be nil.")
	--assert(is_obj(parent,"LuaGuiElement"), "Invalid Argument. 'parent' must be a LuaGuiElement. object_name: "..tostring(parent.object_name))
	assert(name, "Invalid Argument. 'name' must not be nil.")
	--[[TRACE]]trace("GuiHelper.findElementRecursive "..tostring(parent.object_name=="LuaGui" and "LuaGui" or parent.name).." "..name)
	local full_name = name
	local short_name = name
	if(prefix) then
		if string.sub(name, 1, #prefix) ~= prefix then
			full_name = prefix..name
		else
			short_name = string.sub(name, #prefix+1)
		end
	end

	local function R(parent, level)
		--[[TRACE]]trace.append("  "..string.rep("  ",level)..tostring(parent.object_name=="LuaGui" and "LuaGui" or parent.name).."..")
		for _,element in pairs(parent.children or {}) do
			if(element.name == full_name) then trace.exit("found full name "..element.name); return element end
			if(element.name == short_name) then trace.exit("found partial name "..element.name); return element end
		end
		for _,element in pairs(parent.children or {}) do
			local result = R(element, level+1)
			if(result) then return result end
		end
		return nil
	end
	return R(parent,0)
end


---------------------------------------------------------------------------------------------------
return KuxCoreLib.__classUtils.finalize(GuiHelper)