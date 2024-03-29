-- print(debug.getinfo(1,"S").source)
-- @D:\Develop\Factorio\Mods\Kux-CoreLib/src\lib\init.lua
-- @__Kux-CoreLib__/lib/init.lua
KuxCoreLibPath = KuxCoreLibPath or "__Kux-CoreLib__/"

if KuxCoreLib then
    if KuxCoreLib.__guid == "7c4df965-a929-4f58-92e6-4cfa6a60f4b8" then
		--log("Init KuxCoreLib, repeated, initialized:"..tostring(KuxCoreLib.__isInitialized)..", required by \n"..debug.traceback(2))
		--require(KuxCoreLibPath.."modules/require-override")
		return KuxCoreLib
	end
    error("A global class 'KuxCoreLib' already exist.")
else
	--log("Init KuxCoreLib, first time, required by \n"..debug.traceback(2))
end

---Provides access to Kux-CoreLib modules  
---Usage: `require(KuxCoreLib.MODULENAME)`
---@class KuxCoreLib
---@field Array KuxCoreLib.Array
---@field ColorConverter KuxCoreLib.ColorConverter
---@field Colors KuxCoreLib.Colors
---@field Debug KuxCoreLib.Debug
---@field Dictionary KuxCoreLib.Dictionary
---@field Event KuxCoreLib.Event
---@field EventDistributor KuxCoreLib.EventDistributor
---@field Events KuxCoreLib.Events
---@field FileWriter KuxCoreLib.FileWriter
---@field Flags KuxCoreLib.Flags
---@field FlyingText KuxCoreLib.FlyingText
---@field List KuxCoreLib.List
---@field Log KuxCoreLib.Log
---@field Trace KuxCoreLib.Trace
---@field ErrorHandler KuxCoreLib.ErrorHandler
---@field lua KuxCoreLib.lua
---@field Math KuxCoreLib.Math
---@field ModInfo KuxCoreLib.ModInfo
---@field Modules KuxCoreLib.Modules
---@field Path KuxCoreLib.Path
---@field Player KuxCoreLib.Player
---@field String KuxCoreLib.String
---@field Table KuxCoreLib.Table
---@field Technology KuxCoreLib.Technology
---@field StringBuilder KuxCoreLib.StringBuilder
---@field TestRunner KuxCoreLib.TestRunner
---@field That KuxCoreLib.That
---@field Version KuxCoreLib.Version
---@field DataRaw KuxCoreLib.DataRaw
---@field EntityData KuxCoreLib.EntityData
---@field ItemData KuxCoreLib.ItemData
---@field RecipeData KuxCoreLib.RecipeData
---@field PrototypeData KuxCoreLib.PrototypeData
---@field SettingsData KuxCoreLib.SettingsData
---@field TechnologyData KuxCoreLib.TechnologyData
---@field TechnologyIndex KuxCoreLib.TechnologyIndex
---@field BigData KuxCoreLib.BigData
---@field Inserter KuxCoreLib.Inserter
---@field Storage KuxCoreLib.Storage
---@field StoragePlayer KuxCoreLib.StoragePlayer
---@field StoragePlayers KuxCoreLib.StoragePlayers
---@field GuiBuilder KuxCoreLib.GuiBuilder
---@field PickerDollies KuxCoreLib.PickerDollies
---@field Factorissimo KuxCoreLib.Factorissimo
---@field SurfacesMod KuxCoreLib.SurfacesMod
---@field CollisionMaskData KuxCoreLib.CollisionMaskData
---@field DataGrid KuxCoreLib.DataGrid
---@field GuiHelper KuxCoreLib.GuiHelper

KuxCoreLib = {
	__class  = "KuxCoreLib",
	__guid   = "7c4df965-a929-4f58-92e6-4cfa6a60f4b8",
	__origin = "Kux-CoreLib/init.lua",

	---stores loaded modules
	__modules = {}
}
---------------------------------------------------------------------------------------------------
--NOTE: We must not 'require' lib modules! circular reference!
-- e.g. local Debug=require(KuxCoreLibPath.."lib/Debug")

--require(KuxCoreLibPath.."modules/require-override")
if not KuxCoreLibPath or KuxCoreLibPath:match("^__") then
	require("__core__/lualib/util") 
else
	dofile("E:/Program Files/Factorio/1.1/data/core/lualib/util.lua")
end

--
--table.deepcopy = util.deepcopy --WORKARROUND for table.deepcopy is nil

local require_map = { --RUN (F5) to AUTOGENERATE
        Array = "",
        ColorConverter = "",
        Colors = "",
        Debug = "",
        Dictionary = "",
        Event = "",
        EventDistributor = "",
		Events = "",
        FileWriter = "",
        Flags = "",
        FlyingText = "",
        List = "",
        Log = "",
		Trace = "",
        lua = "",
        Math = "",
        ModInfo = "",
        Modules = "",
        Path = "",
        Player = "",
        String = "",
        Table = "",
        Technology = "",
        TestRunner = "",
        That = "",
        Version = "",
		PickerDollies = "",
		DataGrid = "",
		ErrorHandler = "",

		CollisionMaskData = "data",
        DataRaw = "data",
        EntityData = "data",
        ItemData = "data",
		RecipeData = "data",
        PrototypeData = "data",
        SettingsData = "data",
        TechnologyData = "data",
        TechnologyIndex = "data",
		BigData = "data",

        Inserter = "entities",
        Storage = "storage",
        StoragePlayer = "storage",
        StoragePlayers = "storage",

        GuiBuilder = "gui",
		ElementBuilder = "gui",
		GuiHelper = "gui",

		Factorissimo = "mods",
		SurfacesMod = "mods",
}

local KuxCoreLib_metatable = {}
function KuxCoreLib_metatable.__index(self, key)
	local rootpath = (KuxCoreLibPath or "__Kux-CoreLib__/").."lib/"
	if(require_map[key] and require_map[key] ~="") then rootpath = rootpath .. require_map[key] .."/"
	end
	local path = rootpath..key
	--print("KuxCoreLib require "..path)
	local result = require(path)
	assert(type(result)=="table", "require returns not a table. "..path)
	return result
end
function KuxCoreLib_metatable.__newindex()
	error("KuxCoreLib is protected.")
end

KuxCoreLib.utils = {}

---Makes a local class global. With verification.
---@param t table The class to make public
---@param mode nil|"override"|"integrate"|"error" Resolving mode (default: error)
---@return table
function KuxCoreLib.utils.asGlobal(t, mode)
	local function getClassFileName(class)
		--local classTable = getmetatable(class)
		
		for key, value in pairs(class) do
		  if type(value) == "function" then
			local info = debug.getinfo(value, "S")
			if info.source and info.source ~= "=[C]" then
			  return info.source:gsub("@", "")
			end
		  end
		end
		return nil
	end

	local name = t.__class
	--mode = mode or "error"
	mode = "override" -- always override
	if(not name) then error("Invalid class specified! missing '__class'") end
	if(not t.__guid) then error("Invalid class specified! missing '__guid'") end
	local gt = _G[name]
	if gt then
		if gt.__guid == t.__guid then return gt end
		local lines = {}
		for n, v in pairs(gt) do
			if(type(v)=="function") then table.insert(lines,"  "..n.." ("..type(v).." @ "..getClassFileName(gt) or "?"..")")
			elseif(type(v)=="table") then table.insert(lines,"  "..n.." ("..type(v)..")")
			elseif(type(v)=="string") then table.insert(lines,"  "..n.." = \""..v.."\"")
			else table.insert(lines,"  "..n.." = "..tostring(v).."")
			end
		end
		log("A global class '"..name.."' already exists! dump: \n{\n"..table.concat(lines,"\n").."\n}\nResolving mode: "..mode)
		if(mode=="override") then
			--
		elseif(mode=="integrate") then
			print("integrate")
			-- TODO: handle metatables
			-- for k, v in pairs(t) do gt[k] = v end -- integrate in there class
			for k, v in pairs(gt) do t[k]=v end -- integrate in our class			
		elseif(mode=="error") then
			error("A global class '"..name.."' already exist.")
		else
			error("Argument out of range. Name: 'mode', Value: '"..mode.."'")
		end
	end
	_G[name] = t
	return t
end

---Requires all modules as global
function KuxCoreLib.requireAll()
	if(KuxCoreLib.ModInfo.current_stage:match("^data") or KuxCoreLib.ModInfo.current_stage:match("^settings")) then
		require("__Kux-CoreLib__/lib/data/@")
	elseif(KuxCoreLib.ModInfo.current_stage=="control") then
		require("__Kux-CoreLib__/lib/@")
	end
	return KuxCoreLib
end

KuxCoreLib.Data = {}
setmetatable(KuxCoreLib.Data,{
	__index = function (self, key)
		local path = (KuxCoreLibPath or "__Kux-CoreLib__/").."lib/data/"..key
		return require(path)
	end,
	__newindex = function()
		error("KuxCoreLib.Data is protected.")
	end
})

KuxCoreLib.__isInitialized=true
setmetatable(KuxCoreLib,KuxCoreLib_metatable) -- protect KuxCoreLib
--log("Init KuxCoreLib, finished")

return KuxCoreLib
