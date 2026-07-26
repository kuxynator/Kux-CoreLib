require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---
---usage: require()"__Kux-CoreLib__/lib/@")
---

KuxCoreLib.lua                                        .asGlobal()
Modules          = KuxCoreLib.require.Modules         .asGlobal()
Colors           = KuxCoreLib.require.Colors          .asGlobal()
Debug            = KuxCoreLib.require.Debug           .asGlobal()
Trace            = KuxCoreLib.require.Trace           .asGlobal()
Log              = KuxCoreLib.require.Log             .asGlobal()
ErrorHandler     = KuxCoreLib.require.ErrorHandler    .asGlobal()
EventDistributor = KuxCoreLib.require.EventDistributor--.asGlobal()
Events           = KuxCoreLib.require.Events          .asGlobal()
String           = KuxCoreLib.require.String          .asGlobal()
Array            = KuxCoreLib.require.Array           .asGlobal()
Dictionary       = KuxCoreLib.require.Dictionary      .asGlobal()
List             = KuxCoreLib.require.List            .asGlobal()
Table            = KuxCoreLib.require.Table           .asGlobal()
Version          = KuxCoreLib.require.Version         .asGlobal()
Path             = KuxCoreLib.require.Path            .asGlobal()
ModInfo          = KuxCoreLib.require.ModInfo         .asGlobal()
That             = KuxCoreLib.require.That            .asGlobal()
StringBuilder    = KuxCoreLib.require.StringBuilder   .asGlobal()

if not script then return KuxCoreLib end

--[ runtime only ]--

KuxCoreLib.require.Player          .asGlobal()

-- entities --
-- KuxCoreLib.Inserter        .asGlobal()

-- storage --
--TODO DISABELD Storage         = KuxCoreLib.Storage          .asGlobal()
--TODO DISABELD PlayerStorage   = KuxCoreLib.PlayerStorage    .asGlobal()
--TODO DISABELD StoragePlayer   = KuxCoreLib.StoragePlayer    .asGlobal()
--TODO DISABELD StoragePlayers  = KuxCoreLib.StoragePlayers   .asGlobal()


return KuxCoreLib
