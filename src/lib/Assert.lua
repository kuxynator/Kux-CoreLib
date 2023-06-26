if Assert then
    if Assert.__guid == "{4AEB03A1-6391-4209-9856-D421B8914857}" then return Assert end
    error("A global Assert class already exist.")
end

---@class Assert Provides messages for assert
---Usage: assert(Assert...) <br>
---This is because to show the correct position in code. <br>
---Each Assert functions returns (true, nil) or (false, message).
Assert = {
    __class  = "Assert",
	__guid   = "{4AEB03A1-6391-4209-9856-D421B8914857}",
	__origin = "Kux-CoreLib/lib/Assert.lua",

    ---@class Assert.Not
    Not = {},
    ---@class Assert.Argument
    Argument = {},
    ---@class Assert.Table
    Table = {
        ---@class Assert.Table.Not
        Not = {}
    },
    ---@class Assert.Array
    Array = {},
    ---@class Assert.Disctionary
    Disctionary = {},
    ---@class Assert.String
    String = {
        ---@class Assert.String.Not
        Not = {}
    }
}
-- to avoid circular references, the class MUST be defined before require other modules
KuxCoreLib = KuxCoreLib or require("__Kux_CoreLib__/init")
require(KuxCoreLib.Table)

---raises an error if value is nil
---@param name string
---@param message? string
function Assert.Argument.IsNotNil(value, name, message)
    if value then return true end
    message = message or ("Argument must not be nil! Name='{name}'")
    message = message:gsub("{name}",name)
    return false, message
end

---raises an error if value is nil or empty
---@param name string
---@param message? string
function Assert.Argument.IsNotNilOrEmpty(value, name, message)
    if value~=nil and value ~="" then return true end
    message = message or ("Argument must not be nil or empty! Name='{name}'")
    message = message:gsub("{name}",name)
    return false, message
end

function Assert.IsEqual(value, expected)
    if value==expected then return true end
    if type(value) == type(expected) then
        if type(value)=="table" then
            if Table.isEqual(value,expected) then return true end
        end
    else
        return false, ("Types are not eqal. Expected: "..type(expected).." but was "..type(value))
    end
    if value==nil then value="nil" end
    if expected==nil then expected="nil" end
    return false, ("Values are not eqal. Expected: "..tostring(expected).." but was "..tostring(value))
end

function Assert.IsNotEqual(value, expected, name)
    name = name or "Value"
    if value~=expected then return true end
    if type(value) ~= type(expected) then return true end
    if type(value)=="table" then
        if not Table.isEqual(value,expected) then return true end
    end
    if value==nil then value="nil" end
    if expected==nil then expected="nil" end
    return false, (name.." is equal to "..tostring(value)..", but not equal was expected.")
end

function Assert.IsReferenceEqual(value, expected)
    if value==expected then return true end
    if value==nil then value="nil" end
    if expected==nil then expected="nil" end
    return false, ("Value reference are not eqal.")
end

---IsTrue
---@param value any
---@param name? string
---@return boolean
---@return string?
function Assert.IsTrue(value,name)
    name = name or "Value"
    if value==true then return true end
    if value==nil then value="nil" end
    return false, (name.." is not true. Expected: true but was "..tostring(value))
end

---IsFalse
---@param value any
---@param name? string
---@return boolean
---@return string?
function Assert.IsFalse(value,name)
    name = name or "Value"
    if value==false then return true end
    if value==nil then value="nil" end
    return false, (name.." is not false. Expected: false but was "..tostring(value))
end

---IsNil
---@param value any
---@param name? string
---@return boolean
---@return string?
function Assert.IsNil(value, name)
    name = name or "Value"
    if value==nil then return true end
    return false, (name.." is not nil. but was "..tostring(value))
end

---IsNilOrFalse
---@param value any
---@param name? string
---@return boolean
---@return string?
function Assert.IsNilOrFalse(value, name)
    name = name or "Value"
    if value==nil or value==false then return true end
    return false, (name.." is "..tostring(value)..". But nil or false was expected.")
end

---IsNotNil
---@param value any
---@param name? string
---@return boolean
---@return string?
function Assert.IsNotNil(value, name)
    name = name or "Value"
    if value~=nil then return true end
    return false, (name.." is nil. but not nil was expected")
end

---Is Not Nil And Not False. same condition as in "if not variable then"
---@param value any
---@param name? string
---@return boolean
---@return string?
function Assert.IsNotNilOrFalse(value,name)
    name = name or "Value"
    if value~=nil and value ~= false then return true end
    return false, (name.." is "..tostring(value)..". but not nil and not false was expected")
end

---IsTypeOf
---@param value any
---@param expected string Expected type
---| "nil"
---| "number"
---| "string"
---| "boolean"
---| "table"
---| "function"
---| "thread"
---| "userdata"
---@return boolean
---@return string?
function Assert.IsTypeOf(value, expected)
    if type(value)==expected then return true end
    return false, ("Value are not type of "..expected.." but was type of "..type(value))
end

---IsNotTypeOf
---@param value any
---@param notExpected string unexpected type
---| "nil"
---| "number"
---| "string"
---| "boolean"
---| "table"
---| "function"
---| "thread"
---| "userdata"
---@return boolean
---@return string?
function Assert.IsNotTypeOf(value, notExpected)
    if type(value)~=notExpected then return true end
    return false, ("Value is type of "..notExpected..".")
end

-------------------------------------------------------------------------------
--#region Assert.Table

function Assert.Table.Contains(t, value)
    if t==nil then return false, ("Value is nil") end
    if type(t)~="table" then return false, ("Value ist not a table") end
    for _, v in pairs(t) do
        if v==value then return true end
    end
    return false, ("Table not contains the value.")
end

function Assert.Table.Not.Contains(t, value)
    if t==nil then return false, ("Value is nil") end
    if type(t)~="table" then return false, ("Value ist not a table") end
    for _, v in pairs(t) do
        if v==value then return false, ("Table contains the value.") end
    end
    return true
end
--#endregion Assert.Table
-------------------------------------------------------------------------------
--#region Assert.String 

---String IsEqual
---@param s string
---@param compareString string
---@return boolean
---@return string?
function Assert.String.IsEqual(s, compareString)
    if s==nil then return false, ("Value is nil") end
    if type(s)~="string" then return false, ("Value ist not a string") end
    if s==compareString then return true end
    return false, ("String not equal to '"..compareString.."'.")
end

---String Contains
---@param s string
---@param compareString string
---@return boolean
---@return string?
function Assert.String.Contains(s, compareString)
    if s==nil then return false, ("Value is nil") end
    if type(s)~="string" then return false, ("Value ist not a string") end
    if string.match(s,String.escape(compareString)) then return true end
    return false, ("String not contains '"..compareString.."'.")
end

---String StartsWith
---@param s string
---@param compareString string
---@return boolean
---@return string?
function Assert.String.StartsWith(s, compareString)
    if s==nil then return false, ("Value is nil") end
    if type(s)~="string" then return false, ("Value ist not a string") end
    if string.match(s,"^"..String.escape(compareString)) then return true end
    return false, ("String not starts with the '"..compareString.."'.")
end

---String StartsWith
---@param s string
---@param compareString string
---@return boolean
---@return string?
function Assert.String.EndsWith(s, compareString)
    if s==nil then return false, ("Value is nil") end
    if type(s)~="string" then return false, ("Value ist not a string") end
    if string.match(s,String.escape(compareString).."$") then return true end
    return false, ("String not ends with '"..compareString.."'.")
end

---String not StartsWith
---@param s string
---@param compareString string
---@return boolean
---@return string?
function Assert.String.Not.StartsWith(s, compareString)
    if s==nil then return false, ("Value is nil") end
    if type(s)~="string" then return false, ("Value ist not a string") end
    if not string.match(s,"^"..String.escape(compareString)) then return true end
    return false, ("String starts with '"..compareString.."'.")
end

---String not EndsWith
---@param s string
---@param compareString string
---@return boolean
---@return string?
function Assert.String.Not.EndsWith(s, compareString)
    if s==nil then return false, ("Value is nil") end
    if type(s)~="string" then return false, ("Value ist not a string") end
    if not string.match(s,String.escape(compareString).."$") then return true end
    return false, ("String ends with '"..compareString.."'.")
end

---String matches
---@param s string
---@param comparePattern string
---@return boolean
---@return string?
function Assert.String.Matches(s, comparePattern)
    if s==nil then return false, ("Value is nil") end
    if type(s)~="string" then return false, ("Value ist not a string") end
    if string.match(s,comparePattern) then return true end
    return false, ("String not matches with '"..comparePattern.."'.")
end

---String not matches
---@param s string
---@param comparePattern string
---@return boolean
---@return string?
function Assert.String.Not.Matches(s, comparePattern)
    if s==nil then return false, ("Value is nil") end
    if type(s)~="string" then return false, ("Value ist not a string") end
    if not string.match(s,comparePattern) then return true end
    return false, ("String matches with '"..comparePattern.."'.")
end

---String not Contains
---@param s any
---@param compareString any
---@return boolean
---@return string?
function Assert.String.Not.Contains(s, compareString)
    if s==nil then return false, ("Value is nil") end
    if type(s)~="string" then return false, ("Value ist not a string") end
    if not string.match(s,String.escape(compareString)) then return true end
    return false, ("String contains '"..compareString.."'.")
end

---String Contains All
---@param s string
---@param compareStrings string[]
---@return boolean
---@return string?
function Assert.String.ContainsAll(s, compareStrings)
    if s==nil then return false, ("Value is nil") end
    if type(s)~="string" then return false, ("Value ist not a string") end
    for _, cs in ipairs(compareStrings) do
        if not string.match(s,String.escape(cs)) then return false,("String not contains '"..cs.."'.") end
    end
    return true
end

---String Contains Any
---@param s string
---@param compareStrings string[]
---@return boolean
---@return string?
function Assert.String.ContainsAny(s, compareStrings)
    if s==nil then return false, ("Value is nil") end
    if type(s)~="string" then return false, ("Value ist not a string") end
    for _, cs in ipairs(compareStrings) do
        if string.match(s,String.escape(cs)) then return true end
    end
    return false, ("String not contains any")
end

---String not Contains All
---@param s string
---@param compareStrings string[]
---@return boolean
---@return string?
function Assert.String.Not.ContainsAll(s, compareStrings)
    if s==nil then return false, ("Value is nil") end
    if type(s)~="string" then return false, ("Value is not a string") end
    for _, cs in ipairs(compareStrings) do
        if string.match(s,String.escape(cs)) then return false,("String contains '"..cs.."'.") end
    end
    return true
end

--#endregion Assert.String
-------------------------------------------------------------------------------

---Contains
---@param o any
---@param compare any
---@return boolean
---@return string?
function Assert.Contains(o, compare)
    local tt=type(o)
    if tt == "table" then return Assert.Table.Contains(o,compare) end
    if tt == "string" then return Assert.String.Contains(o, compare) end
    error("Contains is not applicable to type of "..tt..".")
end

---Not Contains
---@param o any
---@param compare any
---@return boolean
---@return string?
function Assert.NotContains(o, compare)
    local tt=type(o)
    if tt == "table" then return Assert.Table.Not.Contains(o,compare) end
    if tt == "string" then return Assert.String.Not.Contains(o, compare) end
    error("Contains is not applicable to type of "..tt..".")
end

return Assert