require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---Provides version functions
---@class KuxCoreLib.Version.static : KuxCoreLib.Class
---@field asGlobal KuxCoreLib.Version.static Provides Version in the global namespace
---<p>NOTE: `Version(1,2,3) == “1.2.3”` gets `false`!! Because Lua is too stupid to implement the __eq operator correctly, and that is completely absurd, especially because all other operators are working</p>
Version = {
    __class  = "KuxCoreLib.Version.static", --> alias: "Version"
	__guid   = "{3F3C2EDA-5537-4643-8A33-6B00A0F42C25}",
	__origin = "Kux-CoreLib/lib/Version.lua",
}
if not KuxCoreLib.__classUtils.ctor(Version) then return self end
---------------------------------------------------------------------------------------------------

---@class KuxCoreLib.Version.Instance.metatable
local mt = {
	__meta = {
		class  = "KuxCoreLib.Version.metatable",
		guid   = "{5f4c32c9-7a77-4de9-92f2-2d83439e433e}",
		origin = Version.__origin,
	}
}

---@class KuxCoreLib.Version.Instance
---@field value string
---@field major integer
---@field minor integer
---@field build integer?
local impl = {}

---------------------------------------------------------------------------------------------------

local String = KuxCoreLib.String


Version.baseVersionGreaterOrEqual1d1 = function ()
	local v = ""
	---@diagnostic disable-next-line: undefined-global
	if mods then v = mods["base"] else v = mods["base"] end
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

---
---@param a string|KuxCoreLib.Version.Instance
---@param b string|KuxCoreLib.Version.Instance
---@return integer
function Version.compare(a, b)
	--local v0 = helpers.compare_versions(versionA, versionB) -->=2.0.55
	local va = splitString(type(a)=="string" and a or a.value)
	local vb = splitString(type(b)=="string" and b or b.value)
	for i = 1, 3, 1 do
		local ax=0
		local bx=0
		if i <= #va then ax = va[i] end
		if i <= #vb then bx = vb[i] end
		if ax<bx then return -1 end
		if ax>bx then return 1 end
	end
	return 0
end

---Compares zwo versions
---@param a string
---@param comp "<"|"<="|"="|"=="|">="|">"|"!="|"~="
---@param b string
---@return boolean
---<p>Because the stupid Lua doesn't do the eq overload correctly, you unfortunately have to specify the operator as a string. Complain to the inventor, not to me!</p>
function Version.comp(a, comp, b)
	if comp == "==" or comp == "=" then return Version.compare(a, b) == 0 end
	if comp == "!=" or comp == "~=" then return Version.compare(a, b) ~= 0 end
	if comp == "<" then return Version.compare(a, b) < 0 end
	if comp == "<=" then return Version.compare(a, b) <= 0 end
	if comp == ">" then return Version.compare(a, b) > 0 end
	if comp == ">=" then return Version.compare(a, b) >= 0 end

	error("Invalid comparison operator: " .. tostring(comp))
end

do
	assert(helpers.compare_versions("1.1.1", "1.1.2")==Version.compare("1.1.1", "1.1.2"))
	assert(helpers.compare_versions("1.1.0", "1.1"  )==Version.compare("1.1.0", "1.1"  ))
	--not supported: assert(helpers.compare_versions("1.0.0", "1"    )==Version.compare("1.0.0", "1"    ))
end

---Creates a new version
---@param major uint16
---@param minor uint16
---@param build uint16
---@return KuxCoreLib.Version.Instance
---@overload fun(version:string):KuxCoreLib.Version.Instance
function Version.new(major, minor, build)
	if type(major)=="string" and type(minor)=="nil" and type(build)=="nil" then return Version.parse(major) end
	self = {
		value = table.concat({major,minor,build},".")
	}
	setmetatable(self,mt)
	return self
end

---Creates a new version from string
---@param s string
---@return KuxCoreLib.Version.Instance
function Version.parse(s)
	local tokens = splitString(s)
	local segments = {0,0,0}
	for i, v in ipairs(tokens) do segments[i]=tonumber(v) end
	segments[2] = segments[2] or 0 -- minor is mandatory
	self = {
		value = table.concat(segments,"."),
	}
	setmetatable(self,mt)
	return self
end

local mt_static = {}
function mt_static.__call(t, v) return Version.parse(v) end
setmetatable(Version,mt_static)

--[ instance ]---------------------------------------------------------------------------------------------------------



--[ instance metatable ]-----------------------------------------------------------------------------------------------

function mt.__index(t, k)
	if k == "major" or k == "minor" or k == "build" then
		local parts = splitString(rawget(t, "value"))
		if k == "major" then return parts[1] or 0 end
		if k == "minor" then return parts[2] or 0 end
		if k == "build" then return parts[3] or 0 end
	end
	error("attemp to read a non existing member "..str(k))
end

function mt.__newindex(t, k, v)
	if k == "major" or k == "minor" or k == "build" then
		local parts = splitString(t.value)
		if k == "major" then parts[1] = v end
		if k == "minor" then parts[2] = v end
		if k == "build" then parts[3] = v end
		t.value = table.concat(parts, ".")
	end
end

function mt.__lt(a, b) return Version.compare(a,b) < 0 end
function mt.__le(a, b) return Version.compare(a,b) <= 0 end
--NOTE __gt __ge are not necessary (just as an explanation for new Lua developers ;-)
function mt.__eq(a, b) return Version.compare(a,b) == 0 end -- FUCKING Lua does not do that if b is a string!
function mt.__tostring(t) return t.value end

-----------------------------------------------------------------------------------------------------------------------

string.toVersion = Version.parse

--[[ workaround FAIL
do -- workaround for Lua's __eq bug BUT bad performance for every string compare :-(
	local string_mt = getmetatable("")
	assert(string_mt==getmetatable("f"), "workaround failed at condition 1")
	local string_eq = string_mt.__eq
	string_mt.__eq = function(a,b)
		if a and getmetatable(a)==mt then return Version.compare(a,b)==0 end
		if b and getmetatable(b)==mt then return Version.compare(a,b)==0 end
		return string_eq and string_eq(a,b) or rawequal(a,b)
	end
	assert(Version("1.2.3")=="1.2.3", "workaround failed at condition 2") <<<<  FAIL: string_mt.__eq never called
end
]]
-----------------------------------------------------------------------------------------------------------------------

KuxCoreLib.__classUtils.finalize(Version)

--[ tests ]-------------------------------------------------------------------------------------------------

local enable_tests = mods["debugadapter"]

if enable_tests then
	local that = KuxCoreLib.require.That
	do
		assert(that.IsEqual(Version.parse("1.2.3").value, "1.2.3") )
		assert(that.IsEqual(Version.new("1.2.3").value, "1.2.3") )
		assert(that.IsEqual(Version.new(1,2,3).value, "1.2.3") )

		assert(that.IsTrue(Version("1.2.3") < Version("2.0.0"), "value") )
		assert(that.IsTrue(Version("1.2.3") > Version("1.0.0"), "value") )
		assert(that.IsTrue(Version("1.2.3") == Version("1.2.3"), "value") )
	end

	do
		assert(that.IsEqual(("1.2.3"):toVersion().value, "1.2.3") )
	end
end

-----------------------------------------------------------------------------------------------------------------------
return Version
