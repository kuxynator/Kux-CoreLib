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
				o=p[fragment]
			end
		end
		if i == c then return o end
		if o == nil then return nil end
	end
end

---safe set accessor
---@param ... any path framents, last parameter is the value to set
function safeset(...)
	local p = nil
	local o = select(1,...)
	local c = select("#",...)
	for i = 2, c-2 do
		local v = select(i,...)
		p=o; o=p[v]
		if o == nil then o = {}; p[v]=o end
	end
	o[select(c-1,...)]=select(c,...)
end

function anypairs(t)
	return next, t, nil
end

