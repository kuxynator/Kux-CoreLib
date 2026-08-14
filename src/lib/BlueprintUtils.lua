require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")


---@class KuxCoreLib.BlueprintUtils : KuxCoreLib.Class
---@field asGlobal fun():KuxCoreLib.BlueprintUtils Provides BlueprintUtils in the global namespace
local BlueprintUtils = {
	__class  = "KuxCoreLib.BlueprintUtils",
	__guid   = "{00898ff5-aab3-4b85-a947-b1fd9d9dd364}",
	__origin = "Kux-CoreLib/lib/BlueprintUtils.lua",
}
if not KuxCoreLib.__classUtils.ctor(BlueprintUtils) then return self end
-- to avoid circular references, the EventDistributor class MUST be defined before require other modules
--------------------------------------------------------------------------------
if(not script) -- events are only available in control stage
	then KuxCoreLib.__classUtils.finalize(BlueprintUtils) return BlueprintUtils end
--- control stage only ---------------------------------------------------------

local BlueprintItem = KuxCoreLib.require.BlueprintItem -- workaround to initialize _blueprint_utils
local internal = require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/_blueprint_utils") --[[@as KuxCoreLib.BlueprintUtils.internal]]
BlueprintUtils.internal = internal

BlueprintUtils.get_blueprint = internal.get_blueprint
BlueprintUtils.copy_record_to_table = internal.copy_record_to_table
BlueprintUtils.copy_table_to_item_stack = internal.copy_table_to_item_stack
BlueprintUtils.export_record = internal.export_record
BlueprintUtils.copy_blueprint = internal.copy_blueprint

--------------------------------------------------------------------------------
return BlueprintUtils