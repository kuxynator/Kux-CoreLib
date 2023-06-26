---
---usage: require "__Kux-CoreLib__/lib/data/@"
---

KuxCoreLibPath = KuxCoreLibPath or "__Kux-CoreLib__/lib/"
require(KuxCoreLibPath.."@")

require(KuxCoreLib.Data.DataRaw)
require(KuxCoreLib.Data.EntityData)
require(KuxCoreLib.Data.ItemData)
require(KuxCoreLib.Data.PrototypeData)
--deprecated prototypeUtils.
require(KuxCoreLib.Data.RecipeData)
require(KuxCoreLib.Data.TechnologyData)
require(KuxCoreLib.Data.TechnologyIndex)

return KuxCoreLib


