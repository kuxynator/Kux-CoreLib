require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---@class KuxCoreLib.EntityData
local EntityData = {
	__class  = "EntityData",
	__guid   = "{990068A3-AA60-4453-A786-A4F2C7E7CA7F}",
	__origin = "Kux-CoreLib/lib/data/EntityData.lua",
}
if KuxCoreLib.__classUtils.cache(EntityData) then return KuxCoreLib.__classUtils.cached end
---------------------------------------------------------------------------------------------------
local Table= KuxCoreLib.Table
local DataRaw = KuxCoreLib.DataRaw

---Clone an entity prototype
---@param type string
---@param name string
---@param newName string
---@return data.EntityPrototype
 function EntityData.clone(type, name, newName)
	local base = data.raw[type][name]
	if(not base) then error("Prototype not found: "..name.." (type: "..type..")") end
	local entity = table.deepcopy(base) or {} --[[@as data.EntityPrototype]]
	entity.name = newName
	if(entity.minable) then
		if entity.minable.results then

		elseif entity.minable.result then
			if(entity.minable.result == name) then entity.minable.result = newName end
		end
	end

	---@diagnostic disable-next-line: assign-type-mismatch, inject-field
	entity.base = base

	return entity
end

---Remove entries from entity.collision_mask table.
---@param entity table? The entity prototype
---@param mask string|table The entries to remove
---@return boolean #true if the entry was found and removed; otherwise false
function EntityData.removeCollisionMask(entity, mask)
    if(not entity or mask==nil or not entity.collision_mask) then return false end
    if(type(mask)~="table") then mask={mask} end
    for _, v in ipairs(mask) do
        print("Table.remove(entity.collision_mask, "..v..")")
        return Table.remove(entity.collision_mask, v)
    end
    return false
end

---Remove entries from entity.collision_mask_with_flags table.
---@param entity table? The entity prototype
---@param mask string|table The entries to remove
---@return boolean #true if the entry was found and removed; otherwise false
function EntityData.removeCollisionMaskWithFlags(entity,mask)
    if(not entity or mask==nil or not entity.collision_mask_with_flags) then return false end
    if(type(mask)~="table") then mask={mask} end
    for _, v in ipairs(mask) do
        return Table.remove(entity.collision_mask_with_flags, v)
    end
    return false
end

---Finds an entity by name
---@param entityName string
---@param throwOnError boolean|nil
---@return table|nil
function EntityData.find(entityName, throwOnError)
    for _,typeName in ipairs(DataRaw.entityTypes) do
        local entity = data.raw[typeName][entityName]
        if(entity) then return entity --[[@as table]] end
    end
    if(throwOnError) then error("Entity not found. Name:'"..entityName.."'") end
    return nil
end

function EntityData.findType(entityName)
    for _,typeName in ipairs(DataRaw.entityTypes) do
        local entity = data.raw[typeName][entityName]
        if(entity) then return typeName end
    end
end

---------------------------------------------------------------------------------------------------

function EntityData.asGlobal() return KuxCoreLib.__classUtils.asGlobal(EntityData) end

return EntityData