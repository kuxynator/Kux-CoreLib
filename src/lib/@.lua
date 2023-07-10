require((KuxCoreLibPath or "__Kux-CoreLib__/").."init")

if(_require and _require ~= require) then --OK
elseif _require == nil then error("_require is nil!")
elseif(_require == require) then error("require is not overridden!")
end
---
---usage: require "__Kux-CoreLib__/lib/@"
---

KuxCoreLib.lua             .asGlobal()
KuxCoreLib.Modules         .asGlobal()
KuxCoreLib.Colors          .asGlobal()
KuxCoreLib.Debug           .asGlobal()
KuxCoreLib.Log             .asGlobal("integrate")
KuxCoreLib.EventDistributor.asGlobal()
KuxCoreLib.FileWriter      .asGlobal()
KuxCoreLib.FlyingText      .asGlobal()
KuxCoreLib.String          .asGlobal()
KuxCoreLib.Array           .asGlobal()
KuxCoreLib.Dictionary      .asGlobal()
KuxCoreLib.List            .asGlobal()
KuxCoreLib.Table           .asGlobal()
KuxCoreLib.Version         .asGlobal()
KuxCoreLib.Path            .asGlobal()
KuxCoreLib.ModInfo         .asGlobal()
KuxCoreLib.Player          .asGlobal()
KuxCoreLib.That            .asGlobal() -- ??

-- entities --
-- KuxCoreLib.Inserter        .asGlobal()

-- global --
KuxCoreLib.Global          .asGlobal()
KuxCoreLib.GlobalPlayer    .asGlobal()
KuxCoreLib.GlobalPlayers   .asGlobal()

-- gui --
KuxCoreLib.GuiBuilder      .asGlobal()



return KuxCoreLib
