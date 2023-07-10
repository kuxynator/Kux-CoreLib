require "tests.setup"
local tests = {name="GlobalPlayer"}
local ignore = {}
---------------------------------------------------------------------------------------------------
local Global = KuxCoreLib.Global
local GlobalPlayer = KuxCoreLib.GlobalPlayer
local GlobalPlayers = KuxCoreLib.GlobalPlayers

function tests.a()
	--#region Mock
	global = {};
	game = {};  game.players = {}
	game.players[1] = game.players[1] or {index = 1, name = "MockUser1"}
	--#endregion

	local gp=GlobalPlayers[1]
	gp.test1="test1"
	assert(That.IsEqual(global.players[1].test1, "test1"))
end

function tests.frames()
	--#region Mock
	global = {};
	game = {};  game.players = {}
	game.players[1] = game.players[1] or {index = 1, name = "MockUser1"}
	--#endregion

	local gp=GlobalPlayer:new(1,{})
	assert(That.IsNotNil(gp.frames))
end

---------------------------------------------------------------------------------------------------
TestRunner.run(tests)