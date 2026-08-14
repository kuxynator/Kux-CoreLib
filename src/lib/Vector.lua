require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---@class KuxCoreLib.Vector.static : KuxCoreLib.Class
---@field asGlobal KuxCoreLib.Vector.static Provides Vector in the global namespace
Vector = {
    __class  = "KuxCoreLib.Vector.static",
	__guid   = "c4d74ac2-ff84-4467-af6d-8ad8a0475d23",
	__origin = "Kux-CoreLib/lib/Vector.lua",
}
if not KuxCoreLib.__classUtils.ctor(Vector) then return self end
---------------------------------------------------------------------------------------------------

---Parses a string containing numbers
---@param s string
---@return Vector.array
local function parseNumbers(s)
    local v = {}
    s = tostring(s or "")
    for n in s:gmatch("[+-]?%d*%.?%d+[eE]?[+-]?%d*") do
        local x = tonumber(n)
        if x ~= nil then
            v[#v + 1] = x
        end
    end
    return v
end

---Adds two 2D vectors component-wise.
---@param p Vector.array
---@param q Vector.array
---@return Vector.array
function Vector.add(p, q)
    return {p[1] + q[1], p[2] + q[2]}
end

---Negates a 2D vector component-wise.
---@param p Vector.array
---@return Vector.array
function Vector.neg(p)
    return {-p[1], -p[2]}
end

---Subtracts the second 2D vector from the first.
---@param p Vector.array
---@param q Vector.array
---@return Vector.array
function Vector.sub(p, q)
    return Vector.add(p, Vector.neg(q))
end

---Multiplies a 2D vector by a scalar.
---@param v Vector.array
---@param s number
---@return Vector.array
function Vector.mul(v, s)
    return {v[1] * s, v[2] * s}
end


---Maps a 2D vector component-wise.
---@param v Vector.array
---@param f function the map function
---@return Vector.array
function Vector.map(v, f)
    return map(v, f) --[[@as Vector.array ]]
end

---Expands a list with 1 or 2 numeric values to a 2D array.
---@param v number[]
---@return Vector.array|nil
function Vector.makeLen2(v)
    if #v == 1 then return {v[1], v[1]} end
    if #v == 2 then return {v[1], v[2]} end
    return nil
end

---Parses a numeric string into a 2D vector.
---@param s string
---@return Vector.array|nil
function Vector.parseXY(s)
    local v = parseNumbers(s)
    if #v == 1 then return {x = v[1], y = v[1]} end
    if #v == 2 then return {x = v[1], y = v[2]} end
    return nil
end

---Converts a numeric array into a 2D vector table.
---@param v Vector.array
---@return Vector.struct|nil
function Vector.array2struct(v)
    if #v == 1 then return {x = v[1], y = v[1]} end
    if #v == 2 then return {x = v[1], y = v[2]} end
    return nil
end

---Converts a 2D vector table into an array.
---@param v Vector.struct
---@return Vector.array
function Vector.struct2array(v)
    return {v.x, v.y}
end

-- ---Converts a 2D vector  into a vector table.
-- ---@param v Vector
-- ---@return Vector.struct|nil
-- function Vector.toStruct(v)
--     if #v == 1 then return {x = v[1], y = v[1]} end
--     if #v == 2 then return {x = v[1], y = v[2]} end
--     return nil
-- end

-- ---Converts a Vector into an 2D vector array.
---@param v Vector
---@return Vector.array
function Vector.toArray(v)
	return { v.x or v[1], v.y or v[2] }
end


local vector_mt = {
    __mul = function(v, n) return Vector.setmetatable({x=v.x*n, y=v.y*n}) end,
    __add = function(v1, v2) return Vector.setmetatable({x=v1.x+v2.x, y=v1.y+v2.y}) end,
    __sub = function(v1, v2) return Vector.setmetatable({x=v1.x-v2.x, y=v1.y-v2.y}) end,
    __div = function(v, n) return Vector.setmetatable({x=v.x/n, y=v.y/n}) end,
    __tostring = function(v) return v.x.."x"..v.y end,
    __index = function(v, k) return k==1 and v.x or k==2 and v.y or rawget(v, k) end,
    __newindex = function(v, k, value)
        if k==1 then v.x=value
        elseif k==2 then v.y=value
        else rawset(v, k, value)
        end
    end,
}
script.register_metatable("KuxCoreLib.Vector", vector_mt)

function Vector.setmetatable(t)
	return setmetatable(t, vector_mt)
end

---------------------------------------------------------------------------------------------------
return Vector

---------------------------------------------------------------------------------------------------
---@class KuxCoreLib.Vector : Vector.struct|{[1]:number, [2]:number}
--- -----------------------
---@field x number
---@field y number
---@field [1] number
---@field [2] number


---@alias Vector.array {[1]: number, [2]: number}