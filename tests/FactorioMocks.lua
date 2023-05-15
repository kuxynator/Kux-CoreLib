
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