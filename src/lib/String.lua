if (String and String.guid~="{0E8BBFAF-73EF-4209-9774-B2CD6A13A296}") then
    local t = {}
    for name, value in pairs(String) do table.insert(t,"  "..name.." ("..type(value)..")") end
    log("dump String: \n{\n"..table.concat(t,"\n").."\n}")
    error("A global String class already exist.")
end

---Provides string functions
---@class String
String = {
    tableName = "String",
	guid      = "{0E8BBFAF-73EF-4209-9774-B2CD6A13A296}",
	origin    = "Kux-CoreLib/lib/String.lua",
}

---Gets or sets the separator for the next concat call. 
String.concatSeparator = "" --alias oneTineConcatSeparator

---Concatenances a string
---@param ... any Values to concatenation
---@return string The concatenanced string
function String.concat(...)
    local result = ""
    local args = {...}
    local c = 0
    for _,v in ipairs(args) do
		if c>1 and String.concatSeparator then result = result .. String.concatSeparator end
    	result = result .. v
        c=c+1
    end
	String.concat_separator = ""
    return result
end
-- TODO concat options. single/block, tables

---Formats a string
---@param format string The format. Placeholders are %1, %2, etc.
---@param ... any The replacement values.
---@return string
function String.format(format, ...)
     -- remarks: we have to do this with a for loop elsewhere nil values are not counted or skipped
     local result = format
    local args = {...}
    local len = #args   
    for i = 1, len, 1 do
        local v=args[i]
        if v == nil then v = "" else v = tostring(v) end
        result = string.gsub(result,"%%"..i, v)
    end
	return result
end

---Replaces parts of a string
---@param format string The format. Placeholder is {name}, where name ist the key in the replacements dictionary.
---@param replacements {[string]:any} The dictionary with the replacement values.
---@return string
function String.replace(format, replacements)
	local result = format
    for k,v in pairs(replacements) do
        if v == nil then v = "" else v = tostring(v) end
		local p = "{"..k.."}"
		result = string.gsub(result, p, v)
    end
    result = string.gsub(result,"{[%w%d_]+}", "") -- fill remaining placeholder with empty string
	return result
end


function String.print(dest, ...)
    dest.print(String.concat(...))
end

---Gets a value indication the string starts with the specifed value.
---@param s? string The string.
---@param compare string
---@param nonCaseSensitive? boolean
---@return boolean # true: the string starts with specifed value; elsewhere false.
function String.startsWith(s, compare, nonCaseSensitive)
    --TODO: write test
    if s == nil then return false end
    if type(s) ~= "string" or type(compare) ~= "string" then return false end
    if nonCaseSensitive then s = s:lower(); compare = compare:lower() end
    if #compare > #s then return false end
    if #compare == #s then return s == compare end
	return string.sub(s,1,#compare)==compare
end

---Gets a value indication the string ends with the specifed value.
---@param s? string The string.
---@param compare string
---@param nonCaseSensitive? boolean
---@return boolean # true: the string ends with specifed value; elsewhere false.
function String.endsWith(s, compare, nonCaseSensitive)
    --TODO: write test
    if s == nil then return false end
    if type(s) ~= "string" or type(compare) ~= "string" then return false end
    if nonCaseSensitive then s = s:lower(); compare = compare:lower() end
    if #compare > #s then return false end
    if #compare == #s then return s == compare end
    return string.sub(s, -#compare) == compare
end

function String.contains(s, compare, nonCaseSensitive)
    if s == nil then return false end
    if type(s) ~= "string" or type(compare) ~= "string" then return false end
    if nonCaseSensitive then s = s:lower(); compare = compare:lower() end
    if #compare > #s then return false end
    if #compare == #s then return s == compare end
	return string.find(s,compare)
end

---Splits a string.
---@param inputString string The string to split
---@param separator string The separator (string or pattern)
---@return table # A table with the parts
---example: stringSplit("Foo, Bar, Boo", ",%s*") returns the table {"Foo", "Bar", "Boo"}
function String.split(inputString, separator)
	if separator == nil then separator = "%s" end
	local t={}
	local i=1
	for str in string.gmatch(inputString, "([^"..separator.."]+)") do
		t[i] = str
		i = i + 1
	end
	return t
end

---Escapes a string
---@param s string
---@return string
function String.escape(s)
    local r = string.gsub(s,'[%-%.%+%[%]%(%)%$%^%%%?%*]','%%%1')
    return r
end

-----------------------------
---@class StringPrettyOptions Options for String.pretty
---@field printTableRefs boolean
---@field recursive boolean
---@field maxLevel integer
---@field showNil boolean
---@field useQuotes boolean
-----------------------------

---prettystr_core
---@param v any
---@param indentLevel integer
---@param options StringPrettyOptions
---@return string
local function prettystr_core(v,indentLevel,options)
    local type_v = type(v)
	if "nil" == type_v then
		if options.showNil then return "!NIL" else return "" end
	elseif "string" == type_v  then
        if not options.useQuotes then return v end
        -- use clever delimiters according to content:
        -- enclose with single quotes if string contains ", but no '
        if v:find('"', 1, true) and not v:find("'", 1, true) then
            return "'" .. v .. "'"
        end
        -- use double quotes otherwise, escape embedded "
        return '"' .. v:gsub('"', '\\"') .. '"'

    elseif "table" == type_v then
        --if v.__class__ then
        --    return string.gsub( tostring(v), 'table', v.__class__ )
        --end
        -- return M.private._table_tostring(v, indentLevel, printTableRefs, cycleDetectTable)
		return "@Table"
        -- TODO 
    elseif "number" == type_v then
        -- eliminate differences in formatting between various Lua versions
        if v ~= v then return "#NaN" end -- "not a number"
        if v == math.huge then return "#Inf" end -- "infinite"
        if v == -math.huge then return "-#Inf" end
        -- if _VERSION == "Lua 5.3" then
        --     local i = math.tointeger(v)
        --     if i then
        --         return tostring(i)
        --     end
        -- end
    end

    return tostring(v)
end

---Returns a string that presents the prettified value
---@param v any
---@param options? StringPrettyOptions
---@return string
function String.pretty(v, options)
    options = options or {}
	options = {
        printTableRefs = options.printTableRefs or false,
        recursive = options.recursive or false,
        maxLevel = options.maxLevel or 1024,
        showNil = options.showNil or false,
---@diagnostic disable-next-line: undefined-field
        cycleDetectTable = options.cycleDetectTable or {},
    }
    return prettystr_core(v,0,options)
end

---Returns a string representing the value for display purposes (nil=>"")
---@diagnostic disable-next-line: lowercase-global
prettystr = String.pretty -- make globally available

if str~=nil and not __G_str then error("str() already defined!") end
---Returns a string representing the value for debug purposes (nil=>!NIL, "string in quotes")
---@diagnostic disable-next-line: lowercase-global
function str(v) return prettystr_core(v,0,{showNil=true, useQuotes=true, cycleDetectTable={}, printTableRefs=false, recursive=false, maxLevel=0}) end
__G_str=true

---Return an array with each char from string
---@param s string
---@return string[]
---If you only want to iterate, use:<br>
---for v in string.gmatch(s,".") do .. end
function String.toChars(s)
    local result={}
    for v in string.gmatch(s,".") do
        table.insert(result,v)
    end
    return result
end

---Checks if a string is nil or  empty.
---@tparam string s The string to be checked.
---@treturn bool Returns true if the string is nil empty, false otherwise.
function String.isNilOrEmpty(s)
    return s == nil or string.len(s) == 0
end

---Checks if a string is nil, empty or consists only of whitespace characters.
---@tparam string s The string to be checked.
---@treturn bool Returns true if the string is nil or contains only whitespace characters, false otherwise.
function String.isNilOrWhitespace(s)
    return s == nil or string.len(s) == 0 or string.match(s, "^%s*$")
end

function String.repeatN (s, count, separator) return string.rep(s,count,separator) end



return String