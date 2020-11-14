print("Load lib.lua")
function iif(condition, p0, p1)
	if condition then
		return p0
	else
		return p1
	end
end

function try(f, catch_f, finally_f)
	local status, exception = pcall(f)
	if not status then
		catch_f(exception)
	end
	if finally_f then finally_f() end
end

function switch(key, dictionary, default)
	local v = dictionary[key]
	if v == nil then return default end
	return v
end

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

--- safe get accessor
-- Usage: value = safeget(obj,"fieldA","fieldB") equivalent to obj.fieldA.fieldB, but w/o error if a field is nil
function safeget(...)
	local o, p
	local c = select("#",...)
	for i = 1, c do
		local v = select(i,...)
		if i == 1 then o = v else p=o; o=p[v] end
		if i == c then return o end
		if o == nil then return nil end
	end
end

--- safe set accessor
-- Usage: safeset(obj,"fieldA","fieldB", newValue) equivalent to obj.fieldA.fieldB = newValue, but w/o error if a field is nil
-- missing fields are created as tables.
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