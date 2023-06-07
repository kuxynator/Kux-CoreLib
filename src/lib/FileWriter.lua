require("__Kux-CoreLib__/lib/Assert")

--from Kux-ModExport
--usage:
--[[
    local w = FileWriter.create("active_mods.txt", 1)
	for name, version in pairs(game.active_mods) do
		if excludeModeExport and name == script.mod_name then goto continue end
		w.writeString(name.."\r\n")
		::continue::
	end
]]
---@class FileWriter
FileWriter = {}

FileWriter.flagAppend = false
FileWriter.file = nil
FileWriter.playerId = nil

---Creates a new FileWriter instance
FileWriter.create = function(file, playerId)
	assert(Assert.Argument.IsNotNil(file, "file"))
	assert(Assert.Argument.IsNotNil(file, "playerId"))

	local instance = {}
	instance.this = instance

	instance.writeField = function (obj, fieldName)
		game.write_file(FileWriter.file, "\""..fieldName.."\": "..toJsonValue(obj[fieldName]), FileWriter.flagAppend, FileWriter.playerId)
		FileWriter.flagAppend = true
	end
	instance.writeFieldLocalized = function (obj, fieldName)
		game.write_file(FileWriter.file, {"", "\""..fieldName.."\": \"", obj[fieldName], "\""}, FileWriter.flagAppend, FileWriter.playerId)
		FileWriter.flagAppend = true
	end
	instance.writeString = function (s)
		game.write_file(FileWriter.file, s, FileWriter.flagAppend, FileWriter.playerId)
		FileWriter.flagAppend = true
	end
	instance.writeLocalizedString = function (s)
		game.write_file(FileWriter.file, {"", s}, FileWriter.flagAppend, FileWriter.playerId)
		FileWriter.flagAppend = true
	end

	-- TODO create instance
	FileWriter.flagAppend = false
	FileWriter.file = file
	FileWriter.playerId = playerId
	return FileWriter
end

FileWriter.writeField = function (obj, fieldName)
	game.write_file(FileWriter.file, "\""..fieldName.."\": "..toJsonValue(obj[fieldName]) , FileWriter.flagAppend, FileWriter.playerId)
	FileWriter.flagAppend = true
end
FileWriter.writeFieldLocalized = function (obj, fieldName)
	game.write_file(FileWriter.file, {"", "\""..fieldName.."\": \"", obj[fieldName], "\""} , FileWriter.flagAppend, FileWriter.playerId)
	FileWriter.flagAppend = true
end
FileWriter.writeString = function (s)
	game.write_file(FileWriter.file, s, FileWriter.flagAppend, FileWriter.playerId)
	FileWriter.flagAppend = true
end
FileWriter.writeLocalizedString = function (s)
	game.write_file(FileWriter.file, {"", s}, FileWriter.flagAppend, FileWriter.playerId)
	FileWriter.flagAppend = true
end

return FileWriter