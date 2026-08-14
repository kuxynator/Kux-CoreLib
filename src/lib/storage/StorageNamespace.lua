--INTERNAL class of KuxCoreLib.Storage

---@class KuxCoreLib.StorageNamespace.static
---@field path string
---@field owner string
---@field raw table
local StorageNamespace = {
	__class  = "StorageNamespace",
	__guid   = "{6a0c2d6f-3b5c-4b2f-b2c4-4bb2e0a7db57}",
	__origin = "Kux-CoreLib/lib/storage/StorageNamespace.lua",
}
---------------------------------------------------------------------------------------------------

local Storage ---@type KuxCoreLib.Storage

local mt = {}

function mt.__index(self, key)
	return Storage.get(self.__path, key) -- bad perfoamce. TODO: use cached raw value
	-- local raw = rawget(self,"__raw")
	-- if not raw then
	-- 	raw = {}
	-- 	rawset(self,"__raw", Storage.set(self.__path, raw))
	-- 	return nil
	-- else
	-- 	return raw[value]
	-- end
end

function mt.__newindex(self, key, value)
	Storage.set(self.__path, key, value) -- bad perfoamce. TODO: use cached raw value
end

---Creates a namespace proxy for a storage subtree.
---@param path string
---@param owner string?
---@return table
function StorageNamespace.new(path, owner)
	--new ist allowed everwhere, so don't change global state!
	local instance = {}
	instance.__path = Storage.register(instance.__path, owner)
	return setmetatable(instance, mt)
end


---@param StorageClass KuxCoreLib.Storage
function StorageNamespace.ctor(StorageClass)
	Storage = StorageClass
	return StorageNamespace
end

return StorageNamespace
