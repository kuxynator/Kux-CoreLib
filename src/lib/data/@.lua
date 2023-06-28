require((KuxCoreLibPath or "__Kux-CoreLib__/").."init")

---
---usage: require "__Kux-CoreLib__/lib/data/@"
---

require(KuxCoreLibPath.."lib/@")

require(KuxCoreLib.Data.DataRaw)
require(KuxCoreLib.Data.EntityData)
require(KuxCoreLib.Data.ItemData)
require(KuxCoreLib.Data.PrototypeData)
--deprecated prototypeUtils.
require(KuxCoreLib.Data.RecipeData)
require(KuxCoreLib.Data.TechnologyData)
require(KuxCoreLib.Data.TechnologyIndex)

return KuxCoreLib


