require((KuxCoreLibPath or "__Kux-CoreLib__/").."init")
if(KuxCoreLib.__modules.SettingsData) then return KuxCoreLib.__modules.SettingsData end

---@class KuxCoreLib.SettingsData
local SettingsData = {
	__class  = "SettingsData",
	__guid   = "{6B1DC373-2A83-4C81-94BD-92E772340FDE}",
	__origin = "Kux-CoreLib/lib/data/SettingsData.lua",
}
KuxCoreLib.__modules.SettingsData = SettingsData
---------------------------------------------------------------------------------------------------

SettingsData.startup = {}
SettingsData.runtime = {}
SettingsData.runtime.global = {}
SettingsData.runtime.user = {}

---addIntSetting
---@param t IntSetting
function SettingsData.addIntSetting(t)
	t.type="int-setting"
	data:extend{t}
	return t
end

---addStringSetting
---@param t StringSetting
function SettingsData.addStringSetting(t)
	t.type="string-setting"
	data:extend{t}
	return t
end

---------------------------------------------------------------------------------------------------

function SettingsData.asGlobal() return KuxCoreLib.utils.asGlobal(SettingsData) end

return SettingsData