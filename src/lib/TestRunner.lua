---@class TestRunner
---Example:<br>
---local tests = {name="Lua"}<br>
---function tests.myTest() ..[your test code].. end <br>
---TestRunner.run(tests)
TestRunner = {}
---@class private
local private = {}

---@class settings TestRunner settings
TestRunner.settings = {
	name="TestRunner.settings",
}

---@class settings TestRunner results
TestRunner.results = {
	name="TestRunner.results",
	successedTest=0,
	failedTests=0
}

TestRunner.tests={}

function private.runTestClass(testClass)
	if not testClass.name then testClass.name ="(unnamed)" end

	for name, f in pairs(testClass) do
		if type(f)~="function" then goto next end

		-- print(testClass.name .. " "..name)
		local success, ex = pcall(f)
		if success then
			TestRunner.results.successedTest = TestRunner.results.successedTest+1
			-- print("  Successful")
		else
			TestRunner.results.failedTests=TestRunner.results.failedTests+1	
			-- print("  FAIL: "..ex)
			print("FAIL: "..testClass.name.." "..name.."> "..ex)
		end
		-- print("--------------------------------------------------------------------------------")
		::next::
	end
	-- print(testClass.name)
	-- print(failedTests.." tests failed. "..successedTest.." successful.")
	-- print("================================================================================")
end

---By default run() starts immediately the test, with isCollecting=true you can collect first and then call runCollected()
TestRunner.isCollecting=false

function TestRunner.run(testClass)
	if TestRunner.isCollecting then
		table.insert(TestRunner.tests,testClass)
	else
		TestRunner.results.successedTest = 0
		TestRunner.results.failedTests = 0
		private.runTestClass(testClass)
	end
end

function TestRunner.runCollected()
	TestRunner.results.successedTest = 0
	TestRunner.results.failedTests = 0
	for _,testClass in ipairs(TestRunner.tests) do
		private.runTestClass(testClass)
	end
	print("--------------------------------------------------------------------------------")
	print(TestRunner.results.failedTests.." tests failed. "..TestRunner.results.successedTest.." successful.")
	print("================================================================================")
end

return TestRunner