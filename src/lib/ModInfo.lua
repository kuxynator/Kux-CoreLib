require((KuxCoreLibPath or "__Kux-CoreLib__/").."init")
if(KuxCoreLib.__modules.ModInfo) then return KuxCoreLib.__modules.ModInfo end

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
	__origin = "Kux-CoreLib/lib/ModInfo.lua"
}
KuxCoreLib.__modules.ModInfo = ModInfo
---------------------------------------------------------------------------------------------------
local Debug = KuxCoreLib.Debug

ModInfo.entryMod = Debug.getEntryMod
ModInfo.callingMod= Debug.getCallingMod(true)

---------------------------------------------------------------------------------------------------

function ModInfo.asGlobal() return KuxCoreLib.utils.asGlobal(ModInfo) end

return ModInfo