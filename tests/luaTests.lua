package.path = 'D:\\Develop\\Factorio\\?.lua;' .. package.path
TestRunner = require("Kux-CoreLib.src.lib.TestRunner")
local tools=require("src.lib.tools")

local tests = {
	testA = function ()
		local a = {b={c=3}}
		if tools.safeget(a) ~= a then error("Test failed!") end
		if tools.safeget(a,"b","c") ~= 3 then error("Test failed!") end
		if tools.safeget(a,"b2","c") ~= nil then error("Test failed!") end
		--TODO if tools.get(a,"b","c","err") should throw error
	end,

	testB = function()
		local b = {}
		tools.safeset(b,"a","c",3)
		if b.a.c ~=3 then error("Test failed!") end

		tools.safeset(b,"c",2)
		if b.c ~=2 then error("Test failed!") end
	end
}

TestRunner.run(tests,"lib.tools")