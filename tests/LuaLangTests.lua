require "lib.TestRunner"
require "lib.Assert"

local tests = {name="Lua"}

--- ipairs loop ends after first nil! this is critical with varargs.
function tests.array_with_nil_ipairs_loop_ends_after_first_nil()
	local t = {"A",nil,"C"}
	assert(Assert.IsEqual(#t,3))
	local c=0;
	for i, v in ipairs(t) do c=c+1 end -- ends after first nil!
	assert(Assert.IsEqual(c,1))
end

function tests.array_with_nil_pairs_loop_skips_each_nil()
	local t = {"A",nil,"C"}
	assert(Assert.IsEqual(#t,3))
	local c=0
	local s=""
	for i, v in pairs(t) do c=c+1; s=s..v end -- skips each nil!
	assert(Assert.IsEqual(c,2)) -- 
	assert(Assert.IsEqual(s,"AC")) -- 
end

function tests.dictionary_with_nil_pairs_loop_count()
	local t = {a="A",b=nil,c="C"}
	local c=0;
	for k, v in pairs(t) do c=c+1 end
	assert(Assert.IsEqual(c,2)) -- UNEXPECTED key 'b' does not exist
end

function tests.varargs_with_nil_count()
	local function c(...) return #{...} end
	assert(Assert.IsEqual(c("A",nil,"C"),3))
end

function tests.array_with_nil_next_each_nill_is_skipped()
	local t = {"A",nil,"C"}
	assert(Assert.IsEqual(#t,3))
	local c=0; local s=""
	for k, v in next, t, nil do c=c+1; s=s..v end
	assert(Assert.IsEqual(c,2))  -- each nil is skipped! (like with pairs)
	assert(Assert.IsEqual(s,"AC"))
end

function tests.array_with_nil_for_loop()
	local t = {"A",nil,"C"}
	assert(Assert.IsEqual(#t,3))
	local c=0; local s=""
	for i = 1, #t, 1 do	c=c+1; s=s..tostring(t[i]) end
	assert(Assert.IsEqual(c,3))
	assert(Assert.IsEqual(s,"AnilC"))
end

function tests.dictionary_with_nil_value_next_loop()
	local t = {a="A",b=nil,c="C"}
	assert(Assert.IsEqual(#t,0)) -- dictionary can't be counted
	local c=0;
	for k, v in next, t, nil do c=c+1 end
	assert(Assert.IsEqual(c,2)) -- 2: because 'b' not exists
end

function tests.mix_table_pairs_loop()
	local t = {a="A",b=nil,c="C","1",nil,"3",d="D"}
	assert(Assert.IsEqual(#t,3))
	local values=""
	local keys=""
	-- sequence: numbers -> keys, but order of keys is not deterministic, 
	-- nil values are skipped (by pairs)
	for k, v in pairs(t) do
		keys = keys..tostring(k)
		values = values..tostring(v)
	end
	-- for each test there is a other order
	--assert(Assert.IsEqual(keys,"13cad")) -- numbers first, but sequence of keys is not linear a > ca > dac > adc
	--assert(Assert.IsEqual(values,"13CAD"))
	assert(Assert.IsEqual(#keys,5)) --"13cad"
	assert(Assert.IsEqual(#values,5)) --"13CAD"
	assert(Assert.IsTrue(String.startsWith(keys,"13")))
	assert(Assert.IsNotNil(string.match(keys,"a")))
	assert(Assert.IsNotNil(string.match(keys,"c")))
	assert(Assert.IsNotNil(string.match(keys,"d")))
	assert(Assert.IsTrue(String.startsWith(values,"13")))
	assert(Assert.IsNotNil(string.match(values,"A")))
	assert(Assert.IsNotNil(string.match(values,"C")))
	assert(Assert.IsNotNil(string.match(values,"D")))
	assert(Assert.String.ContainsAll(values,String.toChars("13CAD")))
end

TestRunner.run(tests)