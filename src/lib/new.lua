---`new` provides centralized access to create new objects
---@class new
---@field array fun(...):KuxCoreLib.Array.Instance
---@field dictionary fun(...):KuxCoreLib.Dictionary.Instance
---@field list fun(...):KuxCoreLib.List.Instance
---@field LocalizationDictionary fun():KuxCoreLib.LocalizationDictionary
---@field [string] fun(...):any
---<p>Usage:<br>
---<pre>new.addFactory("Foo", function() return {__class="Foo"} <..do more..> end)
---foo = new.Foo()</pre>
_G.new = {
	__meta = {
		__class = "new",
		__fqn = "KuxCoreLib.new",
		__guid = "27b6af13-b314-465a-a28b-c7f3f7f34473",
		__origin ="Kux-CoreLib/lib/new.lua"
	},
	__factories = {}
}


---Adds a new factory
---@param name string
---@param factory fun(...):any
function new.addFactory(name, factory)
	---@diagnostic disable-next-line: param-type-mismatch
	rawset(_G.new.__factories, name, factory)
end

setmetatable(new,{
	__index = function (t, k)
		return t.__meta[k] or
		 t.__factories[k] or
		function ()
			return {__class=k}
		end
	end,
	__newindex = function (t,k,v)
		if type(k)=="string" and type(v) then return new.addFactory(k,v) end
		error("attempt write in a protected object.")
	end

})

return new