KuxCoreLibPath=""
package.path = "tests/?.lua;"..package.path
package.path = "src/?.lua;"..package.path
package.path = "src/lib/?.lua;"..package.path
package.path = "../LuaLib/?.lua;"..package.path

if game then error("can not be called from within Factorio.") end
if util then error("can not be called from within Factorio.") end
--if not serpent then error("serpent not found") end

require("FactorioMocks")
serpent = require("serpent")

print("package.path: "..package.path)
print("Tests running...")

require("lib.TestRunner")
TestRunner.isCollecting=true
require("LuaLangTests")
require("luaTests")
require("AssertTests")
require("StringTests")
require("TableTests")
require("ToolsTests")
TestRunner.runCollected()

-- local luaunit = require('luaunit')
-- require("LuaUnitTests")
-- os.exit(luaunit.LuaUnit.run())