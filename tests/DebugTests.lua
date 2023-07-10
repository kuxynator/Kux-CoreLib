require "tests.setup"
local tests = {name="Test"}
local ignore = {}
---------------------------------------------------------------------------------------------------
local Debug = KuxCoreLib.Debug
local Path = KuxCoreLib.Path

function tests.getClassFileName()
	local result = Debug.util.getClassFileName(tests)
	assert(That.IsEqual(Path.getFileName(result),"DebugTests.lua"))
end

function tests.getExecutingMod()
	Debug.getExecutingMod()
end

---------------------------------------------------------------------------------------------------
TestRunner.run(tests)