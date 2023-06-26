if ItemData then
    if ItemData.__guid == "{AD869786-5B06-420C-9866-E83F3AB736C0}" then return ItemData end
    error("A global ItemData class already exist.")
end

---@Class ItemData
ItemData = {
	__class  = "ItemData",
	__guid   = "{AD869786-5B06-420C-9866-E83F3AB736C0}",
	__origin = "Kux-CoreLib/lib/data/ItemData.lua",
}

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