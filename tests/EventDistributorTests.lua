require "tests/setup"
local tests = {name="EventDistributor"}
local ignore = {}
---------------------------------------------------------------------------------------------------

--#region MOCK
script = {}
script.on_event=function (fnc) end
script.on_init=function (fnc) end
script.on_load=function (fnc) end
script.on_nth_tick=function (tick, fnc) end
script.on_configuration_changed=function (fnc) end
--#endregion
KuxCoreLib.ModInfo.current_stage = "control"
local EventDistributor = KuxCoreLib.EventDistributor


function tests.A()


	local count = 0
	local function handler(e)
		count = count + 1
	end

	EventDistributor.register("CUSTOM",handler)
	--EventDistributor.raise("CUSTOM",{})
end

---------------------------------------------------------------------------------------------------
TestRunner.run(tests)