require "tests.setup"
local tests = {name="lib.String"}
---------------------------------

tests.stringSplit_separator = function ()
	local tokens = String.split("a.b",nil, ".")
	if #tokens ~= 2 then error("2 tokens expected") end
	if tokens[1] ~= "a" then error("'a' expected") end
	if tokens[2] ~= "b" then error("'a' expected") end
end

function tests.find()
	local startPos, endPos, capture = ("1.2/3"):find("[%./]",1 )
	startPos, endPos, capture = string.find("1.2/3", "(%.)|(/)",2)
end

tests.stringSplit_separatorArray = function ()
	local tokens = String.split("a.b/c",nil, {".","/"})
	if #tokens ~= 3 then error("3 tokens expected") end
	if tokens[1] ~= "a" then error("'a' expected") end
	if tokens[2] ~= "b" then error("'b' expected") end
	if tokens[3] ~= "c" then error("'c' expected") end
end

tests.stringSplit_pattern = function ()
	local tokens = String.split("a, b",",%s*")
	if #tokens ~= 2 then error("2 tokens expected") end
	if tokens[1] ~= "a" then error("'a' expected") end
	if tokens[2] ~= "b" then error("'a' expected") end
end

function tests.format()
	local n=tests["dummy"]
	assert(Assert.IsEqual(String.format("A%1%2","B","C"),"ABC"))
	assert(Assert.IsEqual(String.format("A%1",1),"A1")) -- integer
	assert(Assert.IsEqual(String.format("A%1",true),"Atrue"))	-- boolean
--	assert(Assert.IsEqual(String.format("A%1",n),"A"))	-- nil
	assert(Assert.IsEqual(String.format("A%1%2",n,"C"),"AC"))	-- nil
end

function tests.replace()
	local n=tests["dummy"]
	assert(Assert.IsEqual(String.replace("A{b}{c}",{b="B",c="C"}),"ABC"))	
	assert(Assert.IsEqual(String.replace("A{b}{c}",{b="B"}),"AB"))--key does not exist
	assert(Assert.IsEqual(String.replace("A{b}",{b=1}),"A1"))-- integer
	assert(Assert.IsEqual(String.replace("A{b}",{b=true}),"Atrue"))-- boolean
--	assert(Assert.IsEqual(String.replace("A{b}",{b=n}),"A"))-- nil
	assert(Assert.IsEqual(String.replace("A{b}{c}",{b=n, c="C"}),"AC"))-- nil
end

function tests.toChars()
	local chars = String.toChars("1A![$")
	--assert(Assert.Table.ContainsAll(chars,{"1","A","!","[","$"}))
	assert(Assert.IsEqual(chars[1],"1"))
	assert(Assert.IsEqual(chars[2],"A"))
	assert(Assert.IsEqual(chars[5],"$"))
end

function tests.escape()
	local s = "[23%.!1$]"
	assert(Assert.String.Contains(s,s))
	assert(Assert.String.ContainsAll(s,{"[","23","%",".","!","1$","]"}))
end

TestRunner.run(tests)