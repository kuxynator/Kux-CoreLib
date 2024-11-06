require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---@class KuxCoreLib.ItemData
local ItemData = {
	__class  = "ItemData",
	__guid   = "{AD869786-5B06-420C-9866-E83F3AB736C0}",
	__origin = "Kux-CoreLib/lib/data/ItemData.lua",
}
if KuxCoreLib.__classUtils.cache(ItemData) then return KuxCoreLib.__classUtils.cached end
---------------------------------------------------------------------------------------------------
local DataRaw = KuxCoreLib.DataRaw

function ItemData.clone(name, entity)
	local base = data.raw["item"][name] or ItemData.find(name)
	if(not base) then error("Item prrototype not found: "..name) end
	local item = table.deepcopy(base)
	item.name = entity.name
	item.localised_name = {"item-name."..entity.name}
	item.place_result = entity.name
	item.base=base
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

function ItemData.asGlobal() return KuxCoreLib.__classUtils.asGlobal(ItemData) end

return ItemData