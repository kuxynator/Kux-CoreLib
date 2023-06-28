require((KuxCoreLibPath or "__Kux-CoreLib__/").."init")

SettingsData = {

}

SettingsData.startup = {}
SettingsData.runtime = {}
SettingsData.runtime.global = {}
SettingsData.runtime.user = {}

---comment
---@param t IntSetting
function DataRaw.addIntSetting(t)
	t.type="int-setting"
	data:extend{t}
	return t
end

---comment
---@param t StringSetting
function DataRaw.addStringSetting(t)
	t.type="string-setting"
	data:extend{t}
	return t
end
