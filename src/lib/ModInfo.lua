require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")
if(KuxCoreLib.__modules.ModInfo) then
	if(KuxCoreLib.__modules.ModInfo.__isInitialized) then
		KuxCoreLib.__modules.ModInfo.update()
	end
	return KuxCoreLib.__modules.ModInfo
end

-- local isOverriding
-- if ModInfo then
--     if ModInfo.__guid == "35fb3f52-acde-45b9-9792-d1c0f570408b" then return ModInfo end
-- 	-- for key, value in pairs(Log) do print("  "..key) end
--     -- error("A global Log class already exist.")
-- 	log("WARNING Mod incompatibility detected. Override existing 'ModInfo'.")
-- end

-- if(isOverriding) then
-- 	ModInfo.__isOverridden = true
-- 	ModInfo.__extensions=ModInfo.__extensions or {}
-- 	table.insert(ModInfo.__extensions, {
-- 		name  = "Kux-CoreLib",
-- 		guid   = "35fb3f52-acde-45b9-9792-d1c0f570408b",
-- 		origin = "Kux-CoreLib/lib/ModInfo.lua",
-- 		order = #ModInfo.__extensions + 1
-- 	})
-- else
-- 	ModInfo = {
-- 		__class  = "ModInfo",
-- 		__guid   = "35fb3f52-acde-45b9-9792-d1c0f570408b",
-- 		__origin = "Kux-CoreLib/lib/ModInfo.lua"
-- 	}
-- end

---@class KuxCoreLib.ModInfo
local ModInfo = {
	__class  = "ModInfo",
	__guid   = "35fb3f52-acde-45b9-9792-d1c0f570408b",
	__origin = "Kux-CoreLib/lib/ModInfo.lua",

	__isInitialized = false,
	__on_initialized = {},
}
KuxCoreLib.__modules.ModInfo = ModInfo
---------------------------------------------------------------------------------------------------
local debug_util =  require((KuxCoreLibPath or "__Kux-CoreLib__/").."modules/debug_util")

ModInfo.entryMod = debug_util.getEntryMod()

ModInfo.callingMod = debug_util.getCallingMod(true)

---Gets the current stage
---@type "settings"|"settings-updates"|"settings-final-fixes"|"data"|"data-updates"|"data-final-fixes"|"control"|"control-on-init"|"control-on-load"|"control-on-configuration-changed"|"control-on-loaded"|"undefined"
ModInfo.current_stage = "undefined" -- mostly used with match, so nil would be not helpfull

---Gets the current mod name  
---@type string
---example `ModName`
ModInfo.name = nil

---Gets the current mod name as path  
---@type string
---example `__ModName__/`
ModInfo.path = nil

---Gets the current mod name as prefix  
---@type string
---example `ModName_`
ModInfo.prefix = nil

---getEntryStage
---@return "settings"|"settings-updates"|"settings-final-fixes"|"data"|"data-updates"|"data-final-fixes"|"control"
ModInfo.getEntryStage = debug_util.getEntryStage

---Update current_stage
function ModInfo.update()
	if(ModInfo.current_stage~="undefined" and ModInfo.current_stage:match("^control") and ModInfo.name) then return end
	local stackTrace = debug.traceback()
	local stage = "undefined"
	local mod_name = nil
	for line in stackTrace:gmatch("[^\r\n]+") do
		local m, f = line:match("__([^/]+)__/([^%.]+)%.lua")
		if m and f then stage = f; mod_name = m end
	end
	if(not ModInfo.current_stage or not ModInfo.current_stage:match("^control")) then
		ModInfo.current_stage = stage
	end
	if(mod_name and stage) then
		ModInfo.name = mod_name
		ModInfo.path = "__"..mod_name.."__/"
		ModInfo.prefix = mod_name.."_"
	end
end

---------------------------------------------------------------------------------------------------

---Provides ModInfo in the globale namespace
---@return KuxCoreLib.ModInfo
function ModInfo.asGlobal() return KuxCoreLib.utils.asGlobal(ModInfo) end

ModInfo.update()

ModInfo.__isInitialized = true
for _, fnc in ipairs(ModInfo.__on_initialized) do fnc() end

if(ModInfo.current_stage=="control") then
	KuxCoreLib.EventDistributor() -- this is reqired for update control states
end

function ModInfo.new()
	local mod = setmetatable(
		{
			__base = KuxCoreLib.ModInfo
		},
		{
			__index = KuxCoreLib.ModInfo,
			__metatable = "Metatable is protected!"
		}
	)
	return mod
end

return ModInfo