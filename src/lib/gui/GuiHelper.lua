require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")
if(KuxCoreLib.__modules.GuiHelper) then return KuxCoreLib.__modules.GuiHelper end

---Provides GUI helper functions
---@class KuxCoreLib.GuiHelper
local GuiHelper = {
	__class  = "GuiHelper",
	__guid   = "490ea051-dc17-465b-9234-ccf654eb3e10",
	__origin = "Kux-CoreLib/lib/gui/GuiHelper.lua",

	__isInitialized = false,
	__on_initialized = {}
}
KuxCoreLib.__modules.GuiHelper = GuiHelper
---------------------------------------------------------------------------------------------------
---Provides GuiHelper in the global namespace
---@return KuxCoreLib.GuiHelper
function GuiHelper.asGlobal() return KuxCoreLib.utils.asGlobal(GuiHelper) end

---@return KuxCoreLib.GuiHelper
local function finalize()
	GuiHelper.__isInitialized = true
	for _, fnc in ipairs(GuiHelper.__on_initialized) do fnc() end
	return GuiHelper
end
---------------------------------------------------------------------------------------------------

---
---@param parent LuaGuiElement|LuaGui
---@param name string
---@param prefix string?
---@return LuaGuiElement?
function GuiHelper.findElementRecursive(parent, name, prefix)
	assert(parent, "Invalid Argument. 'parent' must not be nil.")
	--assert(type(parent)=="table" and parent.object_name=="LuaGuiElement", "Invalid Argument. 'parent' must be a LuaGuiElement. object_name: "..tostring(parent.object_name))
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

---@class KuxCoreLib.GuiElementCache : table<string, LuaGuiElement>
---@field __missing table<string, boolean>
---@field __root LuaGuiElement
---@field __count uint

---@param root LuaGuiElement
---@returne KuxCoreLib.GuiElementCache
function GuiHelper.createElementCache(root)
	assert(root, "Invalid Argument. 'root' must not be nil.")
	--[[TRACE]]trace("GuiHelper.rebuildElementsCache")

	local cache = {__root = root, __count = 0, __missing = {}} --[[@as KuxCoreLib.GuiElementCache ]]
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

local function rebuildElementCache(cache)
	assert(cache, "Invalid Argument. 'cache' must not be nil.")
	assert(cache.__root, "Invalid Argument. 'cache.__root' must not be nil.")
	--[[TRACE]]trace("GuiHelper.rebuildElementsCache")
	local newCache = GuiHelper.createElementCache(cache.__root)
	for k,_ in pairs(cache) do
		if(not k:sub(1,2)=="__") then cache[k]=nil end
	end
	for k,v in pairs(newCache) do cache[k]=v end
end

---
---@param player LuaPlayer
---@param elementName string
---@param cache table<string, LuaGuiElement>
---@return LuaGuiElement?
function GuiHelper.getElementByName(player, elementName, cache, prefix)
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
		rebuildElementCache(cache)
		return cache[elementName]
	end
	return element
end
---------------------------------------------------------------------------------------------------
return finalize()