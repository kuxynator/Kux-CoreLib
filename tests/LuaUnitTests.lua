local luaunit = require"luaunit"

-- local functions are not detected

function testPass()
    luaunit.assertEquals({1, 2, 3}, {1, 2, 3})
end

function testFail()
    luaunit.assertEquals({1, 2, 3}, {1, 2, 4})
end

local function runthis()
    luaunit.assertEquals({1, 2, 3}, {1, 2, 4})
end

local tests={}

function tests.testPass()
    luaunit.assertEquals({1, 2, 3}, {1, 2, 3})
end

function tests.testFail()
    luaunit.assertEquals({1, 2, 3}, {1, 2, 4})
end

os.exit(luaunit.LuaUnit.run())