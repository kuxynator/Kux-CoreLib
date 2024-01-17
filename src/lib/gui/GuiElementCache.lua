require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")
if(KuxCoreLib.__modules.GuiElementCache) then return KuxCoreLib.__modules.GuiElementCache end

---Provides GUI helper functions
---@class KuxCoreLib.GuiElementCache
local GuiElementCache = {
	__class  = "GuiElementCache",
	__guid   = "db23b85a-9298-46f3-9653-d2a6f058ff5b",
	__origin = "Kux-CoreLib/lib/gui/GuiElementCache.lua",

	__isInitialized = false,
	__on_initialized = {}
}
KuxCoreLib.__modules.GuiElementCache = GuiElementCache
---------------------------------------------------------------------------------------------------
---Provides GuiElementCache in the global namespace
---@return KuxCoreLib.GuiElementCache
function GuiElementCache.asGlobal() return KuxCoreLib.utils.asGlobal(GuiElementCache) end

---@return KuxCoreLib.GuiElementCache
local function finalize()
	GuiElementCache.__isInitialized = true
	for _, fnc in ipairs(GuiElementCache.__on_initialized) do fnc() end
	return GuiElementCache
end
---------------------------------------------------------------------------------------------------

local GuiHelper = KuxCoreLib.GuiHelper

---@class KuxCoreLib.GuiElementCache.Instance : table<string, LuaGuiElement>
---@field __missing table<string, boolean>
---@field __root LuaGuiElement
---@field __count uint

---@param root LuaGuiElement
---@return KuxCoreLib.GuiElementCache.Instance
function GuiElementCache.new(root)
	assert(root, "Invalid Argument. 'root' must not be nil.")
	assert(type(root)=="table" and root.object_name=="LuaGuiElement", "Invalid Argument. 'root' must be a LuaGuiElement. but is "..trace.getIdentifier(root))
	--[[TRACE]]trace("GuiElementCache.new")

	local cache = {__root = root, __count = 0, __missing = {}} --[[@as KuxCoreLib.GuiElementCache.Instance ]]
	local function R(parent)
		for _,element in pairs(parent.children or {}) do
			if(not cache[element.name]) then
				cache[element.name] = element
				cache.__count = cache.__count + 1
			end
		end
		for _,element in pairs(parent.children or {}) do
			R(element)
		end
	end

	local c=0
	local key = next(cache)
	while key do c = c + 1; key = next(cache, key) end

	R(root)
	return cache
end

---@param cache KuxCoreLib.GuiElementCache.Instance
function GuiElementCache.rebuild(cache)
	assert(cache, "Invalid Argument. 'cache' must not be nil.")
	assert(cache.__root, "Invalid Argument. 'cache.__root' must not be nil.")
	--[[TRACE]]trace("GuiElementCache.rebuild")
	local newCache = GuiElementCache.new(cache.__root)
	--clear
	for k,_ in pairs(cache) do if(not k:sub(1,2)=="__") then cache[k]=nil end end
	--copy new elements
	for k,v in pairs(newCache) do cache[k]=v end
end

---
---@param player LuaPlayer
---@param elementName string
---@param cache table<string, LuaGuiElement>
---@return LuaGuiElement?
function GuiElementCache.getElementByName(player, elementName, cache, prefix)
	--[[TRACE]]trace("SettingsView.getElementByName "..player.name.." "..elementName)
	local element = cache[elementName] --[[@as LuaGuiElement? ]]
	if(not element) then
		cache.__missing = cache.__missing or {}
		local missing = cache.__missing --[[@as {string: boolean} ]]
		if(missing[elementName]) then return nil end
		--rebuildElementsCache()
		local root = cache.__root or player.gui
		element = GuiHelper.findElementRecursive(root, elementName, prefix)
		trace.append("  element: "..trace.line(element))
		if(element) then
			cache[elementName] = element
			--[[TRACE]]trace.exit("found "..element.name)
			return element
		else
			missing[elementName] = true
			--[[TRACE]]trace.exit("not found "..elementName)
			return nil
		end
	elseif(not element.valid) then
		GuiElementCache.rebuild(cache)
		return cache[elementName]
	end
	return element
end
---------------------------------------------------------------------------------------------------
return finalize()