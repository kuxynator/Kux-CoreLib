require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")
if(KuxCoreLib.__modules.ItemData) then return KuxCoreLib.__modules.ItemData end

---@class KuxCoreLib.ItemData
local ItemData = {
	__class  = "ItemData",
	__guid   = "{AD869786-5B06-420C-9866-E83F3AB736C0}",
	__origin = "Kux-CoreLib/lib/data/ItemData.lua",
}
KuxCoreLib.__modules.ItemData = ItemData
---------------------------------------------------------------------------------------------------
local DataRaw = KuxCoreLib.DataRaw

function ItemData.clone(name, entity)
	local base = data.raw["item"][name] or ItemData.find(name)
	if(not base) then error("Item prrototype not found: "..name) end
	local item = table.deepcopy(base)
	item.name = entity.name
	item.localised_name = {"item-name."..entity.name}
	item.place_result = entity.name
	return item
end

function ItemData.find(itemName)
    for _,typeName in ipairs(DataRaw.itemTypes) do
        local item = data.raw[typeName][itemName]
        if(item) then return item end
    end
end

function ItemData.findType(itemName)
    for _,typeName in ipairs(DataRaw.itemTypes) do
        local item = data.raw[typeName][itemName]
        if(item) then return typeName end
    end
end

---------------------------------------------------------------------------------------------------

function ItemData.asGlobal() return KuxCoreLib.utils.asGlobal(ItemData) end

return ItemData