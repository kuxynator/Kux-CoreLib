require("lib.TestRunner")
require("lib.lua")

local tests = {
	name="lib.lua",
	
	testA = function ()
		local a = {b={c=3}}
		if safeget(a) ~= a then error("Test failed!") end
		if safeget(a,"b","c") ~= 3 then error("Test failed!") end
		if safeget(a,"b2","c") ~= nil then error("Test failed!") end
		--TODO if tools.get(a,"b","c","err") should throw error
	end,

	testB = function()
		local b = {}
		safeset(b,"a","c",3)
		if b.a.c ~=3 then error("Test failed!") end

		safeset(b,"c",2)
		if b.c ~=2 then error("Test failed!") end
	end
}


TestRunner.run(tests)