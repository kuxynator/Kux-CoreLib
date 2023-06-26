if Path then
    if Path.__guid == "{6C02BAA4-AA92-4760-95C9-F62C7EF1E373}" then return Path end
    error("A global Path class already exist.")
end

---@class Path
Path = {
	__class  = "Path",
	__guid   = "{6C02BAA4-AA92-4760-95C9-F62C7EF1E373}",
	__origin = "Kux-CoreLib/lib/Path.lua",
}

---Gets the folder name
---@param path string
---@return string
function Path.getFolderName(path)
	-- Remove the separator at the end of the path, if present
	if path:sub(-1) == "/" then
		path = path:sub(1, -2)
	end
	-- Search the last separator in the path
	local lastSeparatorIndex = path:match(".*/()")
	-- Extract the folder path
	local folderName = path:sub(1, lastSeparatorIndex - 1)
	return folderName
end

---Gets the file name fram a path
---@param path string
---@return string
function Path.getFileName(path)
	-- Search the last separator in the path
	local lastSeparatorIndex = path:match(".*/()")
	-- Extract the filename
	local fileName = path:sub(lastSeparatorIndex)
	return fileName
end

function Path.getFileNameWidthoutExtension(path)
	local fn = path
	if(string.find(fn,"/")) then fn = Path.getFileName(path) end

	local lastDotIndex = fn:find(".[^%.]*$")
	if lastDotIndex then
		return fn:sub(1, lastDotIndex - 1)
	else
		return fn
	end
end

function Path.getExtension(path)
	local match = string.match(path, "%.(.*)$")
	return match
end

return Path