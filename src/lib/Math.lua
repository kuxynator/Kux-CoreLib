require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")
if(KuxCoreLib.__modules.Math) then return KuxCoreLib.__modules.Math end

---@class KuxCoreLib.Math : math
local Math = {
	__class  = "Math",
	__guid   = "69c90373-797d-406a-8e75-1150f74d2792",
	__origin = "Kux-CoreLib/lib/ModInfo.lua"
}
KuxCoreLib.__modules.Math = Math
setmetatable(Math,{__this=math})

function Math.sgn(x)
    if x > 0 then return 1
    elseif x < 0 then return -1
	else return 0 end
end

---------------------------------------------------------------------------------------------------

---Provides Math in the global namespace
---@return KuxCoreLib.Math
function Math.asGlobal() return KuxCoreLib.utils.asGlobal(Math) end

return Math