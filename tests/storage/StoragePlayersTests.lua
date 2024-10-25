require "tests.setup"
local tests = {name="StoragePlayer"}
local ignore = {}
---------------------------------------------------------------------------------------------------
local Storage = KuxCoreLib.Storage
local StoragePlayer = KuxCoreLib.StoragePlayer
local StoragePlayers = KuxCoreLib.StoragePlayers

function tests.a()
	--#region Mock
	storage = {};
	game = {};  game.players = {}
	game.players[1] = game.players[1] or {index = 1, name = "MockUser1"}
	--#endregion

	local gp=StoragePlayers[1]
	gp.test1="test1"
	assert(That.IsEqual(storage.players[1].test1, "test1"))
end

function tests.frames()
	--#region Mock
	storage = {};
	game = {};  game.players = {}
	game.players[1] = game.players[1] or {index = 1, name = "MockUser1"}
	--#endregion

	local gp=StoragePlayer:new(1,{})
	assert(That.IsNotNil(gp.frames))
end

---------------------------------------------------------------------------------------------------
TestRunner.run(tests)