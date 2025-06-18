---@alias object_type "array"|"list"|"dictionary"


---Returns the type of the argument, coded as a string. The possible results of this function are "nil" (a string, not the value nil), "number", "string", "boolean", "object", "function", "thread", and "userdata".
---@param o any
---@return "number"|"string"|"boolean"|"object"|"function"|"thread"|"userdata"|"nil"|object_type
function _G.typeof(o)
	local n = o["__type"] or type(o)
	return n=="table" and "object" or n---@diagnostic disable-line: return-type-mismatch
end

---Returns the type of the argument, coded as a string.
---@param o any
---@return string
function _G.classof(o)
	return o["__class"] or o["__type"]
end

---Returns the userdata type of the argument, coded as a string.
---@param o any
---@return LuaObject.object_name
function _G.userdataof(o) --name is DRAFT alt: dataof(o) objectof(o) but too general
	if type(o) ~= "userdata" then return nil end --nil is not permitted, fallback to type?
	return o["object_name"]
end

---@class new
---@field array fun(...):KuxCoreLib.Array.Instance
---@field dictionary fun(...):KuxCoreLib.Dictionary.Instance
---@field list fun(...):KuxCoreLib.List.Instance
---@field [string] function
_G.new = {}

---@param name string
---@param factory fun(...):any
function _G.addFactory(name, factory)
	_G.new[name] = factory
end

setmetatable(new,{
	__index = function (t, k)
		return function (base)
			return {__class=k}
		end
	end
})