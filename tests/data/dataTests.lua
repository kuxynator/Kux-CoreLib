require "tests.setup"
local tests = {name="Test"}
local ignore = {}
---------------------------------------------------------------------------------------------------

function tests.requireAll()
	--#region Mock
	data = {}
	data.raw = {}
	data.raw.technology={}
	--#endregion

	local result = require("src/lib/data/@")
end


---------------------------------------------------------------------------------------------------
TestRunner.run(tests)