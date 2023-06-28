if KuxCoreLib then
    if KuxCoreLib.__guid == "7c4df965-a929-4f58-92e6-4cfa6a60f4b8" then return KuxCoreLib end
    error("A global KuxCoreLib class already exist.")
end

--- int path if necessary
if((mods and data) or script) then
    KuxCoreLibPath = KuxCoreLibPath or "__Kux-CoreLib__/"
else
    KuxCoreLibPath = KuxCoreLibPath or "src/"
end

---Provides access to KuxCoreLib modules  
---Usage: `require(KuxCoreLib.MODULENAME)`
---@class KuxCoreLib
KuxCoreLib = {
	__class  = "KuxCoreLib",
	__guid   = "7c4df965-a929-4f58-92e6-4cfa6a60f4b8",
	__origin = "Kux-CoreLib/init.lua",
}

local path = KuxCoreLibPath.."lib/"

KuxCoreLib.lua=path.."lua"
KuxCoreLib.Modules=path.."Modules"
KuxCoreLib.Assert=path.."Assert"
KuxCoreLib.Colors=path.."Colors"
KuxCoreLib.Debug=path.."Debug"
KuxCoreLib.Log=path.."Log"
KuxCoreLib.EventDistributor=path.."EventDistributor"
KuxCoreLib.FileWriter=path.."FileWriter"
KuxCoreLib.FlyingText=path.."FlyingText"
KuxCoreLib.String=path.."String"
KuxCoreLib.Array=path.."Array"
KuxCoreLib.Dictionary=path.."Dictionary"
KuxCoreLib.List=path.."List"
KuxCoreLib.Table=path.."Table"
KuxCoreLib.Version=path.."Version"
KuxCoreLib.Path=path.."Path"

KuxCoreLib.Data = KuxCoreLib.Data or {}

KuxCoreLib.Data.DataRaw=path.."data/DataRaw"
KuxCoreLib.Data.EntityData=path.."data/EntityData"
KuxCoreLib.Data.ItemData=path.."data/ItemData"
KuxCoreLib.Data.PrototypeData=path.."data/PrototypeData"
KuxCoreLib.Data.RecipeData=path.."data/RecipeData"
KuxCoreLib.Data.SettingsDatra=path.."data/SettingsDatra"
KuxCoreLib.Data.TechnologyData=path.."data/TechnologyData"
KuxCoreLib.Data.TechnologyIndex=path.."data/TechnologyIndex"

---provides loaded modues
KuxCoreLib.modules = {}

KuxCoreLib.require = {}

function KuxCoreLib.require.String()
	return KuxCoreLib.modules.String or require(KuxCoreLib.String)
end

local String = KuxCoreLib.require.String
local Table = KuxCoreLib.require.Table

return KuxCoreLib
