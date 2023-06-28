--package.path = "src/?.lua;src/lib/?.lua;src/lib/data/?.lua;tests/?.lua;"
--package.path = "./src/?/?.lua;tests/?.lua;"
KuxCoreLibPath = "/"
require("src/init")
require("tests/FactorioMocks")
require("lib/data/@")
require("lib/TestRunner")
