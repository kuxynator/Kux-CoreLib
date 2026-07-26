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

_G.new = require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/new")

--[[ !! needs debug.setupvalue
function _G.global_using(scope, fn)
	local proxy = {}
	for k, v in pairs(scope) do proxy[k] = v end
	setmetatable(proxy, { __index = _G })
	debug.setupvalue(fn, 1, proxy)
	return fn()
end
]]

---Allows the direct use uf scope member like global members
---@param scope table
---@param fn function
---<p>But provides no intellisense for LuaLS</p>
function gscope(scope, fn)
	--alias: using_scope, VB: with, C#: using static

	local backup = {}
	for key, value in pairs(scope) do backup[key] = _G[key] _G[key] = value end
	local result = fn()
	for key, value in pairs(scope) do _G[key] = backup[key] end
	return result
end


do --test gscope
	gscope(math, function()
		---@diagnostic disable-next-line: undefined-global
		assert(sin(0.5)==math.sin(0.5),"FAILED")
	end)
end


function _G.dofinally(fn, finally)
	local rsult = fn()
	finally()
	return rsult
end
