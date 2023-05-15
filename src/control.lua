if script.active_mods["gvv"] then require("__gvv__.gvv")() end

--LibPath=""; if global then LibPath="__Kux-CoreLib__/lib/" end

--require "lib/lua"
--require "lib/Log"
--require "lib/Colors"
--require "lib/FlyingText"


-- script.on_nth_tick(1,function(e)
--     script.on_nth_tick(1,next)
--     log("Running tests...")
-- end)

---this global variable is only kown within Kux-CoreLib mod
---@class KuxCoreLibInternal
KuxCoreLibInternal={}


function testFunc()
    print("CoreLib")
end

teextVar = "CoreLib"