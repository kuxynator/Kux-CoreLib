--package.path = "src/?.lua;src/lib/?.lua;src/lib/data/?.lua;tests/?.lua;"
--package.path = "./src/?/?.lua;tests/?.lua;"
KuxCoreLibPath = "/"
require("src.lib.init")
require("tests/FactorioMocks")
TestRunner = KuxCoreLib.TestRunner.asGlobal()
That = KuxCoreLib.That.asGlobal()