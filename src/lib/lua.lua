require((KuxCoreLibPath or "__Kux-CoreLib__/").."init")

---@diagnostic disable: lowercase-global

---iif
---@param condition boolean
---@param trueValue any
---@param falseValue any
---@return any
function iif(condition, trueValue, falseValue)
	local retValue
	if condition then
		retValue = trueValue
	else
		retValue = falseValue
	end

	if type(retValue) =="function" then
		retValue = retValue()
	end

	return retValue
end

---try/catch/finaly
---@param f function
---@param catch_f? function
---@param finally_f? function
function try(f, catch_f, finally_f)
	local status, exception = pcall(f)
	if not status and catch_f then
		catch_f(exception)
	end
	if finally_f then finally_f() end
end

---switch
---@param key string|integer
---@param dictionary table
---@param default any
---@return any
function switch(key, dictionary, default)
	local v = dictionary[key]
	if v == nil then return default end
	return v
end

---switch
---@param key string|integer
---@param ... unknown
---@return any
function switchp(key, ...)
	local dic = {}
	local count = select("#",...)
	local default = nil
	for i = 1, count, 2 do
		local k = select(i,...)
		if type(k) == "function" then k = k() end
		if(i+1>count) then default = k; break end
		local v = select(i+1,...)
		if type(v) == "function" then v = v() end
		dic[k]=v
		if(i+1==count) then default = v end
	end
	return switch(key,dic,default)
end


local function getValue(object, fragment, createPartIfNotExits)
	local name, index = string.match(fragment, "^([^.]+)%[(%d+)%]$")
	if name and index then
		if(object[name]==nil) then
			if(createPartIfNotExits) then
				object[name]={}
			else
				return nil
			end
		end
		if(object[name][tonumber(index)]==nil and createPartIfNotExits) then object[name][tonumber(index)]={} end
		return object[name][tonumber(index)]
	else
		if(object[fragment]==nil and createPartIfNotExits) then object[fragment]={} end
		return object[fragment]
	end
end

local function setValue(object, fragment, value)
	local name, index = string.match(fragment, "^([^.]+)%[(%d+)%]$")
	if name and index then
		if(object[name]==nil) then object[name]={} end
		object[name][tonumber(index)]=value
	else
		object[fragment]=value
	end
end

---safe get accessor
---@param ... any path fragmnents
---Usage: value = safeget(obj,"fieldA","fieldB") equivalent to obj.fieldA.fieldB, but w/o error if a field is nil
function safeget(...)
	local o, p
	local c = select("#",...)
	for i = 1, c do
		local v = select(i,...)
		if i == 1 then
			o = v
		else
			local fragments = String.split(v,nil, {".","/"})
			for _,fragment in ipairs(fragments) do
				p=o;
				o=getValue(p,fragment)
			end
		end
		if i == c then return o end
		if o == nil then return nil end
	end
end

---safe set accessor
---@param ... any path framents, last parameter is the value to set
---example: safeset(t, "foo[1].bar.baz", value)
---example: safeset(t, foo", index, "bar.baz", value)
function safeset(...)
	local p = nil
	local o = select(1,...)
	local c = select("#",...)
	local lastFragment = nil
	for i = 2, c-1 do
		local v = select(i,...)
		local fragments = String.split(v,nil, {".","/"})
		for iFragment,fragment in ipairs(fragments) do
			if(i==c-1 and iFragment == #fragments) then lastFragment=fragment; break end
			p = o;
			o = getValue(p,fragment,true)
		end
	end
	setValue(o,lastFragment,select(c,...))
end

function anypairs(t)
	return next, t, nil
end

