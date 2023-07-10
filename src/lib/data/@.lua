require((KuxCoreLibPath or "__Kux-CoreLib__/").."init")

---
---usage: require "__Kux-CoreLib__/lib/data/@"
---

require(KuxCoreLibPath.."lib/@")

require(KuxCoreLib.Data.DataRaw        ).asGlobal()
require(KuxCoreLib.Data.EntityData     ).asGlobal()
require(KuxCoreLib.Data.ItemData       ).asGlobal()
require(KuxCoreLib.Data.PrototypeData  ).asGlobal()
require(KuxCoreLib.Data.RecipeData     ).asGlobal()
require(KuxCoreLib.Data.TechnologyData ).asGlobal()
require(KuxCoreLib.Data.TechnologyIndex).asGlobal()

return KuxCoreLib