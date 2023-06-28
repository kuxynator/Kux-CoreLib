require "tests.setup"
local tests = {	name="lib.lua"}
---------------------------------------------------------------------------------------------------

function tests.safeget()
	local data={a={b="b"}}
	assert(Assert.IsEqual(safeget(data,"a.b"),"b"))

	data={a={{b="b"}}}
	assert(Assert.IsEqual(safeget(data,"a[1].b"),"b"))
end

function tests.safeset()
	local data={a={b="b"}}
	safeset(data,"a.b","b2")
	assert(Assert.IsEqual(data.a.b,"b2"))

	data={}
	safeset(data,"a.b","b2")
	assert(Assert.IsEqual(data.a.b,"b2"))

	data={}
	safeset(data,"a[1].b","b2")
	assert(Assert.IsEqual(data.a[1].b,"b2"))
end

function tests.testA ()
	local a = {b={c=3}}
	if safeget(a) ~= a then error("Test failed!") end
	if safeget(a,"b","c") ~= 3 then error("Test failed!") end
	if safeget(a,"b2","c") ~= nil then error("Test failed!") end
	--TODO if tools.get(a,"b","c","err") should throw error
end

function tests.testB ()
	local b = {}
	safeset(b,"a","c",3)
	if b.a.c ~=3 then error("Test failed!") end

	safeset(b,"c",2)
	if b.c ~=2 then error("Test failed!") end
end

---------------------------------------------------------------------------------------------------
TestRunner.run(tests)