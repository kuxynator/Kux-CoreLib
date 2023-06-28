require((KuxCoreLibPath or "__Kux-CoreLib__/").."init")

---
---usage: require "__Kux-CoreLib__/lib/@"
---

require(KuxCoreLib.lua)
require(KuxCoreLib.Modules)
require(KuxCoreLib.Assert)
require(KuxCoreLib.Colors)
require(KuxCoreLib.Debug)
require(KuxCoreLib.Log)
require(KuxCoreLib.EventDistributor)
require(KuxCoreLib.FileWriter)
require(KuxCoreLib.FlyingText)
require(KuxCoreLib.String)
require(KuxCoreLib.Array)
require(KuxCoreLib.Dictionary)
require(KuxCoreLib.List)
require(KuxCoreLib.Table)
require(KuxCoreLib.Version)
require(KuxCoreLib.Path)

return KuxCoreLib
