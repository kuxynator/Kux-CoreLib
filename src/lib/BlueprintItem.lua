--require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---@class KuxCoreLib.BlueprintItem.static
---@overload fun(obj: LuaItemStack|LuaRecord):KuxCoreLib.BlueprintItem
local BlueprintItem = {
	__class="BlueprintItemClass"
}

local Util = require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/_blueprint_utils").ctor(BlueprintItem) --[[@as KuxCoreLib.BlueprintUtils.internal]]

---@param self KuxCoreLib.BlueprintItem
local function export_stack(self)
	if self.itemStack then return self.itemStack.export_stack() end
	if self.record then return Util.export_record(self.record) end
	return nil
end

---@diagnostic disable-next-line: param-type-mismatch
setmetatable(BlueprintItem, {

	---Returns a new instance of BlueprintItem
	---@param self any
	---@param obj LuaItemStack|LuaRecord
	---@return KuxCoreLib.BlueprintItem
	__call = function(self, obj)
		local newObj = {} --@type KuxCoreLib.BlueprintItem
		newObj.__base = obj
		newObj.record = obj.object_name=="LuaRecord" and obj or false
		newObj.itemStack  = obj.object_name=="LuaItemStack" and obj or false
		newObj.valid_for_write = (newObj.itemStack and true) or (newObj.record and newObj.record.valid_for_write) or false
		newObj.item = (newObj.itemStack and newObj.item and newObj.item) or false
		newObj.export_stack = function() return export_stack(newObj) end
		setmetatable(newObj,{
			__index = obj,
			__newindex = obj
		})
		return setmetatable({}, {
			__index = function (t, key)
				if key=="record"    then return newObj.record and newObj.record or nil end
				if key=="itemStack" then return newObj.itemStack and newObj.itemStack or nil end
				if key=="item"      then return newObj.item and newObj.item or nil end
				if key=="valid_for_read" then
					return newObj.record and newObj.record.valid
						or newObj.itemStack and newObj.itemStack.valid_for_read
						or false
				end
				return newObj[key] or obj[key]
			end,
			__newindex=function () error("Invalid oparation") end,
		})
	end,
	__index=function () error("Invalid oparation") end,
	__newindex=function () error("Invalid oparation") end,
	__metatable = false
}
)


return BlueprintItem

--------------------------------------------------------------------------------
--#region Meta
--------------------------------------------------------------------------------


---Wrapper for LuaItemStack or LuaRecord
---@class KuxCoreLib.BlueprintItem : LuaItemStack, LuaRecord
---       ------------------------
---@field record LuaRecord? The LuaRecord if that is one, else nil
---@field itemStack LuaItemStack? The LuaItemStack if that is one, else nil
---@field valid_for_write boolean
---@field item LuaItem?
---@field export_stack fun():string

