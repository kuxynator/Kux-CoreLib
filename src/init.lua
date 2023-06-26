
if((mods and data) or script) then
    KuxCoreLibPath = KuxCoreLibPath or "__Kux-CoreLib__/lib/"
else
    KuxCoreLibPath = KuxCoreLibPath or "lib/"
end
KuxCoreLib=KuxCoreLib or {}

KuxCoreLib.lua=KuxCoreLibPath.."lua"
KuxCoreLib.Modules=KuxCoreLibPath.."Modules"
KuxCoreLib.Assert=KuxCoreLibPath.."Assert"
KuxCoreLib.Colors=KuxCoreLibPath.."Colors"
KuxCoreLib.Debug=KuxCoreLibPath.."Debug"
KuxCoreLib.Log=KuxCoreLibPath.."Log"
KuxCoreLib.EventDistributor=KuxCoreLibPath.."EventDistributor"
KuxCoreLib.FileWriter=KuxCoreLibPath.."FileWriter"
KuxCoreLib.FlyingText=KuxCoreLibPath.."FlyingText"
KuxCoreLib.String=KuxCoreLibPath.."String"
KuxCoreLib.Array=KuxCoreLibPath.."Array"
KuxCoreLib.Dictionary=KuxCoreLibPath.."Dictionary"
KuxCoreLib.List=KuxCoreLibPath.."List"
KuxCoreLib.Table=KuxCoreLibPath.."Table"
KuxCoreLib.Version=KuxCoreLibPath.."Version"
KuxCoreLib.Path=KuxCoreLibPath.."Path"

KuxCoreLib.Data = KuxCoreLib.Data or {}

KuxCoreLib.Data.DataRaw=KuxCoreLibPath.."data/DataRaw"
KuxCoreLib.Data.EntityData=KuxCoreLibPath.."data/EntityData"
KuxCoreLib.Data.ItemData=KuxCoreLibPath.."data/ItemData"
KuxCoreLib.Data.PrototypeData=KuxCoreLibPath.."data/PrototypeData"
KuxCoreLib.Data.RecipeData=KuxCoreLibPath.."data/RecipeData"
KuxCoreLib.Data.TechnologyData=KuxCoreLibPath.."data/TechnologyData"
KuxCoreLib.Data.TechnologyIndex=KuxCoreLibPath.."data/TechnologyIndex"

return KuxCoreLib
