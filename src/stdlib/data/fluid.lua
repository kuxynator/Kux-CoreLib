--- Fluid
-- @classmod Data.Fluid

local Data = require('__Kux-CoreLib__/stdlib/data/data')

local Fluid = {
    __class = 'Fluid',
    __index = Data,
}

function Fluid:__call(fluid)
    return self:get(fluid, 'fluid')
end
setmetatable(Fluid, Fluid)

return Fluid
