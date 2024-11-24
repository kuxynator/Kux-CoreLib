require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---@class KuxCoreLib.ItemData : KuxCoreLib.Class
---@field asGlobal fun():KuxCoreLib.ItemData
local ItemData = {
	__class  = "KuxCoreLib.ItemData",
	__guid   = "{AD869786-5B06-420C-9866-E83F3AB736C0}",
	__origin = "Kux-CoreLib/lib/data/ItemData.lua",
}
if KuxCoreLib.__classUtils.cache(ItemData) then return KuxCoreLib.__classUtils.cached end
---------------------------------------------------------------------------------------------------
local DataRaw = KuxCoreLib.DataRaw

---Clone an item prototype
---@param name string The name of the item prototype to clone
---@param entity data.EntityPrototype The corresponding entity prototype
---@return data.ItemPrototype #The cloned item prototype
function ItemData.clone(name, entity)
	local base = data.raw["item"][name] or ItemData.find(name)
	if(not base) then error("Item prrototype not found: "..name) end
	local item = table.deepcopy(base)
	item.name = entity.name
	item.localised_name = {"item-name."..entity.name}
	item.place_result = entity.name
	item["base"] = base -- additional data, only for data stage
	return item
end

---Find an item prototype by name
---@param itemName string The name of the item prototype to find
---@return data.ItemPrototype? #The first found item prototype or nil
function ItemData.find(itemName)
    for _,typeName in ipairs(DataRaw.itemTypes) do
        local item = data.raw[typeName][itemName]
        if(item) then return item end
    end
end

---Find an item prototype by name and return the type
---@param itemName string The name of the item prototype to find
---@return string? #The type of the first found item prototype or nil
function ItemData.findType(itemName)
    for _,typeName in ipairs(DataRaw.itemTypes) do
        local item = data.raw[typeName][itemName]
        if(item) then return typeName end
    end
end

---------------------------------------------------------------------------------------------------
return ItemData