require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")
local collection_util = require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/collections/_collection_util") --[[@as collection_util]]

---Provides array functions
---@class KuxCoreLib.Queue : KuxCoreLib.Class
---@field length integer The length of the queue
---@field asGlobal fun():KuxCoreLib.Queue
local Queue = {
	__class  = "Queue",
	__guid   = "{38dd5977-2f40-4bf7-90cd-d9872c29253b}",
	__origin = "Kux-CoreLib/lib/collections/Queue.lua",
}
if not KuxCoreLib.__classUtils.ctor(Queue) then return self end
-----------------------------------------------------------------------------------------------------------------------

local mt = {
	__class="KuxCoreLib.Queue.Metatable",
	__guid = "{b3e209a6-627b-4293-9eef-4f8cd9dba699}"
}

---@class KuxCoreLib.Queue.Instance
---@field length integer
local impl = {}

local table = collection_util.table_o

---Creates a new Queue
---@param values any[]?
---@param length integer?
---@return KuxCoreLib.Queue.Instance
function Queue.new(values, length)
	local t = values and collection_util.shallowCopy(values) or {}
	setmetatable(t, mt)
	t.length = length or #t
	return t
end

---Converts into Queue
---@param t any[]
---@param length integer?
---@return KuxCoreLib.Queue.Instance
function Queue.convert(t, length)
	setmetatable(t, mt) ---@cast t KuxCoreLib.Queue.Instance
	t.length = length or #t
	return t
end

function impl:enqueue(value)
	if value==nil then error("value must not be nil") end
	local len = rawget(self, "__len")
	rawset(self, len+1, value)
	rawset(self, "__len", len+1)
end


function impl:dequeue()
	local len = rawget(self, "__len")
	if len < 1 then error("queue is empty") end
	local v = self[1]
	table.remove(self, 1)
	rawset(self, "__len", len - 1)
	return v
end

function impl:peek()
	local len = rawget(self, "__len")
	if len < 1 then error("queue is empty") end
	local v = self[1]
	return v
end


---Returns true if the Queue is nil or empty
function Queue.isNilOrEmpty(t) return not t or #t==0 end


--[ metatable ]----------------------------------------------------------------

function mt.__len(t)
	return rawget(t,"__len") or 0
end

function mt.__index(t,k)
	if k=="length" then return rawget(t,"__len") or 0 end
	--if type(k)==string and impl[k] then return function(...) return impl[k].insert(t, ...) end end
	if type(k)=="string" and impl[k] then rawset(t,"__action", k) return t end
	if type(k)~="number" then error("only numeric indexes are allowed") end
end

function mt.__newindex(t,k,v)
	--if k=="length" then set_length(t,v) end
	error("not allowed")
end

function mt.__call(t,...)
	local action = impl[rawget(t,"__action")] or error("attempt to call a table value", 2)
	rawset(t,"__action",nil)
	return action(t,...)
end

collection_util.register_metatable_and_guard(mt)

--[ global ]----------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------

return Queue