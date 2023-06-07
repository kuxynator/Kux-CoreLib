if (Version and Version.guid~="{3F3C2EDA-5537-4643-8A33-6B00A0F42C25}") then
    local t = {}
    for name, value in pairs(Version) do table.insert(t,"  "..name.." ("..type(value)..")") end
    log("dump Version: \n{\n"..table.concat(t,"\n").."\n}")
    error("A global Version class already exist.")
end

---Provides version functions
---@class Version
Version = {
    tableName = "Version",
	guid      = "{3F3C2EDA-5537-4643-8A33-6B00A0F42C25}",
	origin    = "Kux-CoreLib/lib/Version.lua",
}

local String = require("__Kux-CoreLib__/lib/String")

Version.baseVersionGreaterOrEqual1d1 = function ()
	local v = ""
	---@diagnostic disable-next-line: undefined-global
	if mods then v = mods["base"] else v = script.active_mods["base"] end
	if String.startsWith(v,"0.") then return false end
	if String.startsWith(v,"1.0") then return false end
	return true
end

local splitString = function (text)
	local list = {}; local pos = 1
	while 1 do
		local first, last = string.find(text, "%.", pos)
		if first then
		    local d = string.sub(text, pos, first-1)
			table.insert(list, tonumber(d))
			pos = last+1
		else
		    local d = string.sub(text, pos)
			table.insert(list, tonumber(d))
		    break
		end
	end
	return list
end

Version.compare = function (versionA, versionB)
	local a = splitString(versionA)
	local b = splitString(versionB)
	for i = 1, 3, 1 do
		local ax=0
		local bx=0
		if i <= #a then ax = a[i] end
		if i <= #b then bx = b[i] end
		if ax<bx then return -1 end
		if ax>bx then return 1 end
	end
	return 0
end

---Creates a new version
---@param major uint16
---@param minor uint16
---@param build uint16
---@return Version
function Version:new(major,minor,build)
	self = {
		majpr=major,
		minor=minor,
		build=build
	}
	return self
end

---Creates a new version from string
---@param s string
---@return Version
function Version:parse(s)
	local tokens = splitString(s)
	self = {
		major=tokens[1],
		minor=tokens[2],
		build=tokens[3]
	}
	return self
end

local this = Version
return this
