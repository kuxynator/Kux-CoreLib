require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")
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

---#region obsolete, use shorthands

---addIntSetting
---@param t IntSetting
---@deprecated use extend
function SettingsData.addIntSetting(t)
	t.type="int-setting"
	data:extend{t}
	return t
end

---addStringSetting
---@param t StringSetting
---@deprecated use extend
function SettingsData.addStringSetting(t)
	t.type="string-setting"
	data:extend{t}
	return t
end
--#region

local function merge(order_index, common, data, final_fixes)
	--print("merge", order_index, common, data, final_fixes)
	local merged = {}
	--merge common-- << extend(common)
	for k,v in pairs(common) do merged[k] = v end
	merged.setting_type = merged.setting_type or common[1] or error("Missing value 'setting_type'")
	merged.order = (merged.order or common[2])
	if(merged.order) then merged.order = string.format("%s%02d", merged.order, order_index or 0) end
	--print("  order", merged.order)
	--correct missspelled names
	if(merged.setting_type:match("user")) then merged.setting_type = "runtime-per-user"
	elseif(merged.setting_type:match("global")) then merged.setting_type = "runtime-global"
	elseif(merged.setting_type:match("runtime")) then merged.setting_type = "runtime-global"
	end

	--merge data-- << x:int(data)
	for k,v in pairs(data) do merged[k] = type(k)~="number" and v or nil end

	--merge final_fixes--
	for k,v in pairs(final_fixes) do merged[k] = v; end
	merged.allowed_values = final_fixes.allowed_values --WORKOROUND, I dont know wjy allowed_values is set to 0 

	--clean up--
	merged.prefix = nil

	return merged
end

---@class KuxCorelib.ExtendArguments
---@field setting_type "startup"|"runtime-global"|"runtime-user"
---@field order string

---Creates a new Extend object
---@param t KuxCorelib.ExtendArguments | table ExtendArguments | {setting_type, order}
---@return KuxCorelib.Extend
local function call_extend(self, t)
	local new = {common = t, count = 0}
	setmetatable(new, {
		__index = SettingsData.extend
	})
	return new
end

---@class KuxCorelib.Extend
SettingsData.extend = {
	---@type string
	prefix = nil,
	---@type table
	common = nil
}
setmetatable(SettingsData.extend,{
	__call =call_extend
})

local function getPrefix(self)
	return (self.common.prefix or SettingsData.extend.prefix or mod.prefix)
end
local function getName(self, name)
	return getPrefix(self)..name
end

---@class KuxCorelib.BoolSetting
---@field name string
---@field default_value bool Defines the default value of the setting.
---@field forced_value bool

---Adds bool-setting
---@param t KuxCorelib.BoolSetting|table BoolSetting | {name, default_value}
function SettingsData.extend:bool(t)
	self.count = self.count + 1
	local d = merge(self.count, self.common, t, {
		type          = "bool-setting",
		name          =  getName(self, t.name or t[1]),
		default_value = tostring(t.default_value or t[2] or false),
		-- forced_value -- Only loaded if hidden = true
	})
	data:extend{d}
end

---@class KuxCorelib.IntSetting
---@field name string
---@field default_value int64 Defines the default value of the setting.
---@field minimum_value int64 Defines the lowest possible number.
---@field maximum_value int64 Defines the highest possible number.
---@field allowed_values int64[] Makes it possible to force the player to choose between the defined numbers, creates a dropdown instead of a texfield. If only one allowed value is given, the settings is forced to be of that value. 

---Adds int-setting
---@param t KuxCorelib.IntSetting|table IntSetting | {name, default_value, allowed_values}
function SettingsData.extend:int(t)
	self.count = self.count + 1
	local d = merge(self.count, self.common, t, {
		type           = "int-setting",
		name           = getName(self, t.name or t[1]),
		default_value  = t.default_value or t[2] or t.default or error("Missing value 'default_value'"),
		allowed_values = t.allowed_values or t.allowed or t[3],
		minimum_value  = t.minimum_value or t.min,
		maximum_value  = t.maximum_value or t.max,
	})
	data:extend{d}
end

---@class KuxCorelib.DoubleSetting
---@field name string
---@field default_value double Defines the default value of the setting.
---@field minimum_value double Defines the lowest possible number.
---@field maximum_value double Defines the highest possible number.
---@field allowed_values double[] Makes it possible to force the player to choose between the defined numbers, creates a dropdown instead of a texfield. If only one allowed value is given, the settings is forced to be of that value. 

---Adds double-setting
---@param t KuxCorelib.DoubleSetting|table DoubleSetting | {name, default_value, allowed_values}
function SettingsData.extend:double(t)
	self.count = self.count + 1
	local d = merge(self.count, self.common, t, {
		type           = "double-setting",
		name           = getName(self, t.name or t[1]),
		default_value  = t.default_value or t[2] or t.default or error("Missing value 'default_value'"),
		allowed_values = t.allowed_values or t.allowed or t[3],
		minimum_value  = t.minimum_value or t.min,
		maximum_value  = t.maximum_value or t.max,
	})
	data:extend{d}
end

---@class KuxCorelib.StringSetting
---@field name string
---@field default_value string Defines the default value of the setting.
---@field allow_blank bool Defines whether it's possible for the user to set the textfield to empty and apply the setting.
---@field auto_trim bool Whether values that are input by the user should have whitespace removed from both ends of the string.
---@field allowed_values double[] Makes it possible to force the player to choose between the defined numbers, creates a dropdown instead of a texfield. If only one allowed value is given, the settings is forced to be of that value. 

---Adds string-setting
---@param t KuxCorelib.StringSetting|table StringSetting | {name, default_value, allowed_values}
function SettingsData.extend:string(t)
	self.count = self.count + 1
	local d = merge(self.count, self.common, t, {
		type           = "string-setting",
		name           = getName(self, t.name or t[1]),
		default_value  = t.default_value or t[2] or t.default or error("Missing value 'default_value'"),
		allowed_values = t.allowed_values or t.allowed or t[3],
		--allow_blank 
		--auto_trim 
	})
	data:extend{d}
end

---@class KuxCorelib.ColorSetting
---@field name string
---@field default_value Color Defines the default value of the setting.

---Adds color-setting
---@param t KuxCorelib.ColorSetting|table ColorSetting | {name, default_value}
function SettingsData.extend:color(t)
	self.count = self.count + 1
	local d = merge(self.count, self.common, t, {
		type          = "color-setting",
		name          = getName(self, t.name or t[1]),
		default_value = t.default_value or t[2] or t.default or error("default_value is mandatory"),
	})
	data:extent{d}
end

---------------------------------------------------------------------------------------------------

function SettingsData.asGlobal() return KuxCoreLib.utils.asGlobal(SettingsData) end

return SettingsData