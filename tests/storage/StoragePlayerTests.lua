require "tests.setup"
local tests = {name="StoragePlayer"}
local ignore = {}
---------------------------------------------------------------------------------------------------
local StoragePlayer = KuxCoreLib.StoragePlayer

function tests.new_new()
	--#region Mock
	global = {};
	global.players = {}
	game = {};  game.players = {}
	game.players[1] = game.players[1] or {index = 1, name = "MockUser1"}
	--#endregion

	local gp = StoragePlayer:new(1,{foo="default"})

	assert(That.IsEqual(global.players[1].foo,"default"))
end

function tests.new_exist()
	--#region Mock
	global = {};
	global.players = {}
	global.players[1] = {foo="existing"}
	game = {};  game.players = {}
	game.players[1] = game.players[1] or {index = 1, name = "MockUser1"}
	--#endregion

	local gp = StoragePlayer:new(1,{foo="default"})

	assert(That.IsEqual(global.players[1].foo,"existing"))
end

function tests.new_playerNotExist()
	--#region Mock
	global = {};
	global.players = {}	
	game = {};  game.players = {}
	--#endregion

	assert(That.HasError(function () StoragePlayer:new(1,{}) end))
end

---------------------------------------------------------------------------------------------------
TestRunner.run(tests)