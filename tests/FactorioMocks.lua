
function log(message)
    print("log: "..message)
end

function table_size(t)
	local c = 0
	for k, v in pairs(t) do c=c+1 end
	return c
end

function toJsonValue(o)
	return "\""..tostring(o).."\"" -- mock only
end

--TODO create defines. require("/lualib/defines.lua")
defines = defines or {}
defines.events = defines.events or {}

defines.direction = defines.direction or {}
defines.direction.north = 0
defines.direction.east = 2
defines.direction.south = 4
defines.direction.west = 6
defines.direction.northeast = 1
defines.direction.southeast = 3
defines.direction.southwest = 5
defines.direction.northwest = 7

data = data or {}
data.raw = data.raw or {}
data.raw.technology = data.raw.technology or {}

serpent = serpent or {}
serpent.block = serpent.block or function () print("serpent not available") end
serpent.line = serpent.line or function () print("serpent not available") end
serpent.dump= serpent.dump or function () print("serpent not available") end