require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")
if(KuxCoreLib.__modules.StringBuilder) then return KuxCoreLib.__modules.StringBuilder end

---DRAFT Provides StringBuilder functions
---@class KuxCoreLib.StringBuilder
local StringBuilder = {
	__class  = "StringBuilder",
	__guid   = "d5b31800-b937-41d3-9ea4-f92de667806a",
	__origin = "Kux-CoreLib/lib/StringBuilder.lua",
}
KuxCoreLib.__modules.StringBuilder = StringBuilder
---------------------------------------------------------------------------------------------------

---Create a new StringBuilder
---@return KuxCoreLib.StringBuilder
function StringBuilder:new()
	return setmetatable({
		lines={}
	},{__index=StringBuilder})
end

---append
---@param s any
function StringBuilder:append(s)
	if(#(self.lines)==0) then
		table.insert(self,s)
	else
		self.lines[#(self.lines)] = self.lines[#(self.lines)]..tostring(s)
	end
end

---appendLine
---@param s any
function StringBuilder:appendLine(s)
	table.insert(self.lines, tostring(s))
end

function StringBuilder:toString()
	return table.concat(self.lines,"\n")
end


---------------------------------------------------------------------------------------------------

---Provides StringBuilder in the global namespace
---@return KuxCoreLib.StringBuilder
function StringBuilder.asGlobal() return KuxCoreLib.utils.asGlobal(StringBuilder) end

return StringBuilder