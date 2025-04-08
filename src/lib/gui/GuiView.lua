require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---Provides array functions
---@class KuxCoreLib.GuiView.static : KuxCoreLib.Class
---@field asGlobal fun():KuxCoreLib.GuiView.static
local GuiView = {
	__class  = "KuxCoreLib.GuiView",
	__guid   = "aaf81fca-5fcf-4cd1-9b94-b7b7801da56f",
	__origin = "Kux-CoreLib/lib/ui/GuiView.lua",
}
if KuxCoreLib.__classUtils.cache(GuiView) then return KuxCoreLib.__classUtils.cached end
---------------------------------------------------------------------------------------------------
---@class KuxCoreLib.GuiView.metatable
local mt = {}

---@class KuxCoreLib.GuiView
---       ------------------
---@field __class "KuxCoreLib.GuiView" The class name
---@field element LuaGuiElement The root element of the view
---@field name string The name of the view
---@field path string[] The path to the view element in the view hierarchy
local impl = {
	__class = "KuxCoreLib.GuiView",
	__element = nil,
	__name = nil,
	__path = nil,
}

---
---@param el LuaGuiElement
---@param name string
---@param value number|string|boolean|table
local function setTag(el, name, value)
	local tags = el.tags or {}
	el.tags[name] = value
	el.tags = tags
end

---------------------------------------------------------------------------------------------------
--- #region: instance implementation
---------------------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------------------
--- #region: meta table implementation
---------------------------------------------------------------------------------------------------

mt.__index = function(t, k) return nil end -- dummy

script.register_metatable("KuxCoreLib.GuiView.metatable", mt)

---------------------------------------------------------------------------------------------------
--- #region: static implementation
---------------------------------------------------------------------------------------------------

---@param el LuaGuiElement
function GuiView.new(el)
	return KuxCoreLib.__classUtils.new(impl, {element=el}, mt)
end

setmetatable(GuiView, {
	__index = function(t, k) error("Member not found. name='"..k.."'") end,
	__newindex = function(t, k, v) error("Member not found. name='"..k.."'") end,
	__call = function(t, el) return GuiView.new(el) end,
})

---------------------------------------------------------------------------------------------------
return GuiView