TestRunner = {}

TestRunner.run = function(tests, testName)
	local successedTest = 0
	local failedTests = 0
	for name, f in pairs(tests) do
		if type(f)~="function" then goto next end

		print(testName .. " "..name)
		local success, ex = pcall(f)
		if success then
			successedTest=successedTest+1
			print("  Successful")
		else
			failedTests=failedTests+1
			print("  Error: "..ex)
		end
		print("--------------------------------------------------------------------------------")
		::next::
	end
	print(testName)
	print(failedTests.." tests failed. "..successedTest.." successful.")
	print("================================================================================")
end
return TestRunner