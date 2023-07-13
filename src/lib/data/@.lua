require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---
---usage: require "__Kux-CoreLib__/lib/data/@"
---

require(KuxCoreLibPath.."lib/@")

KuxCoreLib.Data.DataRaw        .asGlobal()
KuxCoreLib.Data.EntityData     .asGlobal()
KuxCoreLib.Data.ItemData       .asGlobal()
KuxCoreLib.Data.PrototypeData  .asGlobal()
KuxCoreLib.Data.RecipeData     .asGlobal()
KuxCoreLib.Data.TechnologyData .asGlobal()
KuxCoreLib.Data.TechnologyIndex.asGlobal()

return KuxCoreLib