--- The game module.
--- @class StdLib.Game : StdLib.Core
--- @usage local Game = require('__Kux-CoreLib__/stdlib/game')
local Game = {
    __class = 'Game',
    __index = require('__Kux-CoreLib__/stdlib/core') --[[@as StdLib.Core]]
}
setmetatable(Game, Game)
local inspect = _ENV.inspect

--- Return a valid player object from event, index, string, or userdata
--- @param mixed string|number|LuaPlayer|anyevent
--- @return LuaPlayer? #a valid player or nil
function Game.get_player(mixed)
	local type = type(mixed)
    if type == 'table' or type == 'userdata' then
		if mixed["object_name"] and mixed["object_name"]=="LuaPlayer" then
			return mixed.valid and mixed --[[@as LuaPlayer]]
        elseif mixed.player_index then
            return game.get_player(mixed.player_index)
        end
    elseif mixed then
        return game.get_player(mixed--[[@as string|number]])
    end
end

--- Return a valid force object from event, string, or userdata
--- @param mixed string|LuaForce|anyevent
--- @return LuaForce? #a valid force or nil
function Game.get_force(mixed)
	local type = type(mixed)
    if type == 'table' or type == 'userdata' then
        if mixed["object_name"] and mixed["object_name"]=="LuaForce" then
            return mixed and mixed.valid and mixed --[[@as LuaForce]]
        elseif mixed.force then
            return Game.get_force(mixed.force)
        end
    elseif type(mixed) == 'string' then
        local force = game.forces[mixed]
        return (force and force.valid) and force --[[@as LuaForce|nil]]
    end
end

---@param mixed string|LuaSurface|anyevent
---@return LuaSurface?
function Game.get_surface(mixed)
    local type = type(mixed)
    if type == 'table' or type == 'userdata' then
		if mixed["object_name"] and mixed["object_name"]=="LuaSurface" then
            return mixed.valid and mixed --[[@as LuaSurface]]
        elseif mixed.surface then
            return Game.get_surface(mixed.surface)
        end
    elseif mixed then
        local surface = game.surfaces[mixed]
        return surface and surface.valid and surface or nil
    end
end

--- Messages all players currently connected to the game.
--> Offline players are not counted as having received the message.
-- If no players exist msg is stored in the `storage._print_queue` table.
--- @param msg string the message to send to players
--- @param condition (fun(LuaPlayer):boolean)? [opt] the condition to be true for a player to be messaged
--- @return uint #the number of players who received the message.
function Game.print_all(msg, condition)
    local num = 0
    if #game.players > 0 then
        for _, player in pairs(game.players) do
            if condition == nil or select(2, pcall(condition, player)) then
                player.print(msg)
                num = num + 1
            end
        end
        return num
    else
        storage._print_queue = storage._print_queue or {}
        storage._print_queue[#storage._print_queue + 1] = msg
		return 0
    end
end

--- Gets or sets data in the storage variable.
--- @param sub_table string the name of the table to use to store data.
--- @param index any an optional index to use for the sub_table
--- @param key any the key to store the data in
--- @param set boolean? [opt] store the contents of value, when true return previously stored data
--- @param value any when set is true set key to this value, if not set and key is empty store this
--- @return any #the chunk value stored at the key or the previous value
function Game.get_or_set_data(sub_table, index, key, set, value)
    assert(type(sub_table) == 'string', 'sub_table must be a string')
    storage[sub_table] = storage[sub_table] or {}
    local this
    if index then
        storage[sub_table][index] = storage[sub_table][index] or {}
        this = storage[sub_table][index]
    else
        this = storage[sub_table]
    end
    local previous

    if set then
        previous = this[key]
        this[key] = value
        return previous
    elseif not this[key] and value then
        this[key] = value
        return this[key]
    end
    return this[key]
end

function Game.write_mods()
    helpers.write_file('Mods.lua', 'return ' .. inspect(script.active_mods))
end

---@deprecated not implemented --TODO Factorio 2.0
function Game.write_statistics()
    local pre = 'Statistics/' .. game.tick .. '/'
    for _, force in pairs(game.forces) do
        local folder = pre .. force.name .. '/'
        for _, count_type in pairs { 'input_counts', 'output_counts' } do
			---@diagnostic disable: undefined-field
            helpers.write_file(folder .. 'pollution-' .. count_type .. '.json', helpers.table_to_json(game.pollution_statistics[count_type]))
            helpers.write_file(folder .. 'item-' .. count_type .. '.json', helpers.table_to_json(force.item_production_statistics[count_type]))
            helpers.write_file(folder .. 'fluid-' .. count_type .. '.json', helpers.table_to_json(force.fluid_production_statistics[count_type]))
            helpers.write_file(folder .. 'kill-' .. count_type .. '.json', helpers.table_to_json(force.kill_count_statistics[count_type]))
            helpers.write_file(folder .. 'build-' .. count_type .. '.json', helpers.table_to_json(force.entity_build_count_statistics[count_type]))
			---@diagnostic enable: undefined-field
		end
    end
	--TODO implement this
	--game.get_pollution_statistics(x)
end

function Game.write_surfaces()
    helpers.remove_path('surfaces')
    for _, surface in pairs(game.surfaces) do
        helpers.write_file('surfaces/' .. (surface.name or surface.index) .. '.lua', 'return ' .. inspect(surface.map_gen_settings))
    end
end

return Game
