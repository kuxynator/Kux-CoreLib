--package.path = "src/?.lua;src/lib/?.lua;src/lib/data/?.lua;tests/?.lua;"
--package.path = "./src/?/?.lua;tests/?.lua;"
KuxCoreLibPath = "src/lib/"
require("src/init")
require("tests/FactorioMocks")
require(KuxCoreLibPath.."data/@")
require(KuxCoreLibPath.."TestRunner")
