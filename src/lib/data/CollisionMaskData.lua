require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")
if(KuxCoreLib.__modules.CollisionMaskData) then return KuxCoreLib.__modules.CollisionMaskData end

---@class KuxCoreLib.CollisionMaskData
local CollisionMaskData = {
	__class  = "CollisionMaskData",
	__guid   = "72c0af7b-5840-4c8d-857d-b564bd4547bd",
	__origin = "Kux-CoreLib/lib/data/CollisionMaskData.lua",
}
KuxCoreLib.__modules.CollisionMaskData = CollisionMaskData
---------------------------------------------------------------------------------------------------
function CollisionMaskData.asGlobal() return KuxCoreLib.utils.asGlobal(CollisionMaskData) end
---------------------------------------------------------------------------------------------------
local collision_mask_util = require("__core__/lualib/collision-mask-util") --[[@as collision_mask_util]]

function CollisionMaskData.try_add_layer(prototype, layer)
	if(not prototype) then return end
	if(not prototype.type) then --assume {type, name}
		local t = data.raw[prototype[1]]; if not t then return end
		local p = t[prototype[2]]; if not p then return end
		prototype = p
	end
	prototype.collision_mask= prototype.collision_mask or collision_mask_util.get_default_mask(prototype.type)
	collision_mask_util.add_layer(prototype.collision_mask, layer)
end

function CollisionMaskData.try_remove_layer(prototype, layer)
	if(not prototype) then return end
	if(not prototype.type) then --assume {type, name}
		local t = data.raw[prototype[1]]; if not t then return end
		local p = t[prototype[2]]; if not p then return end
		prototype = p
	end
	prototype.collision_mask= prototype.collision_mask or collision_mask_util.get_default_mask(prototype.type)
	collision_mask_util.remove_layer(prototype.collision_mask, layer)
end

return