local mod = {}

mod.name = "Kux-CoreLib"
mod.path="__"..mod.name.."__/"
mod.prefix=mod.name.."-"

mod.KuxCoreLibPath=mod.path.."lib/"

mod.KuxCoreLib={}
mod.KuxCoreLib.path="__Kux-CoreLib__/lib/"
mod.KuxCoreLib.Table   = mod.KuxCoreLib.path.."Table"
mod.KuxCoreLib.String  = mod.KuxCoreLib.path.."String"
mod.KuxCoreLib.Version = mod.KuxCoreLib.path.."Version"
mod.KuxCoreLib.FlyingText = mod.KuxCoreLib.path.."FlyingText"
mod.KuxCoreLib.Assert = mod.KuxCoreLib.path.."Assert"
mod.KuxCoreLib.Debug = mod.KuxCoreLib.path.."Debug"
mod.KuxCoreLib.Log = mod.KuxCoreLib.path.."Log"

---@deprecated Use KuxCoreLib.path
KuxCoreLibPath=mod.KuxCoreLib.path

_G.mod = mod
_G.KuxCoreLib = mod.KuxCoreLib
return mod