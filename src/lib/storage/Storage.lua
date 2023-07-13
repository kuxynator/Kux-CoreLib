require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")
if(KuxCoreLib.__modules.Storage) then return KuxCoreLib.__modules.Storage end

---Provides managed access to the Factorio's persistent 'global' table.  
---@class KuxCoreLib.Storage
---@field players KuxCoreLib.StoragePlayers
---@field events nil reserved
---  
---Because the name 'global' is ambiguous, we use 'storage' instead  
---Introduced as 'Global' in 2.7.0, renamed in 2.7.1  
local Storage = {
	__class  = "Storage",
	__guid   = "431a60fa-6289-4f1e-b0f8-9047cf33b2d0",
	__origin = "Kux-CoreLib/lib/storage/Storage.lua",
}
KuxCoreLib.__modules.Storage = Storage
---------------------------------------------------------------------------------------------------

local StoragePlayers = KuxCoreLib.StoragePlayers

local getter = {
	players = function (self) global.players = global.players or {}; return StoragePlayers end
}
local function defaultGetter(self) return rawget(self)end

local mt = {}

function mt.__index(self,key)
	return (getter[key] or defaultGetter)(self)
end

function mt.__newindex(self,key,value)
	if(getter[key]) then error("Property is read only. Property:'"..key.."'") end
	rawset(self,key,value)
end

---------------------------------------------------------------------------------------------------

function Storage.asGlobal() return KuxCoreLib.utils.asGlobal(Storage) end

setmetatable(Storage,mt)

return Storage

--[[	
In der global-Tabelle von Factorio können Sie eine Vielzahl von Daten speichern, darunter:

Numerische Werte wie Zahlen und Boolesche Werte
Tabellen und Arrays
Funktionen (die vorher definiert wurden oder als Closures erstellt wurden)
Zeichenketten (Strings)
Benutzerdefinierte Datenstrukturen
Es gibt jedoch einige Einschränkungen bei der Verwendung der global-Tabelle:

Metatables und userdata (einschließlich Funktionen, die als Metamethoden verwendet werden) können nicht in der global-Tabelle gespeichert werden.
]]