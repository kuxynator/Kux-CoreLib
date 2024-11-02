--[[---------------------------------------------------------------------------
	Defines all global variables (used in Kux-CoreLib)
	REQIRE THIS file ONLY ONE TIME in lib/init.lua
--]]---------------------------------------------------------------------------


---@type "factorio"|"local" Gets the current environment
_G.evironment = "factorio"

---@type boolean Gets if the the current environment is factorio
_G.isFactorio = true

---@type boolean Gets if the the current environment is local
_G.isLocal = false

---@type string The path to the local factorio installation
_G.localFactorioPath = _G.localFactorioPath or nil

---@type string The path to the lualib folder
_G.lualibPath = "__core__/lualib/"

---@type boolean Gets if the current factorio version is 1.x
_G.isV1 = false

---@type boolean Gets if the current factorio version is 2.x
_G.isV2 = true

---@type table<string,string> The active mods
_G.mods = _G.mods or {}

if not KuxCoreLibPath or KuxCoreLibPath:match("^__") then
	require(lualibPath.."util") --require("__core__/lualib/")

	if(script) then -- control-stage
		mods = script.active_mods
	end
	isV1 = string.sub(mods["base"], 1, 2) == "1."
	isV2 = string.sub(mods["base"], 1, 2) == "2."
	isV10 = string.sub(mods["base"], 1, 4) == "1.0."
	isV11 = string.sub(mods["base"], 1, 4) == "1.1."
	isV20 = string.sub(mods["base"], 1, 4) == "2.0."
else
	evironment = "local"
	isFactorio = false
	isLocal = true

	--fallback if localFactorioPath is not set
	if not localFactorioPath then
		--_G.localFactorioPath = "E:/Program Files/Factorio/1.1/"
		localFactorioPath = "E:/Program Files/Factorio/2.0/2.0/"
	end
	lualibPath = localFactorioPath.."data/core/lualib/"

	dofile(lualibPath.."util.lua")

	isV1 = false
	isV10 = false
	isV10 = false
	isV2 = true
	isV20 = true

	_G.mods = { --local mock
		["base"] = "2.0.0",
		["Kux-CoreLib"] = "3.0.0"
	}
end


