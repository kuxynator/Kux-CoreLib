if Colors then
    if Colors.__guid == "{E6240471-4450-4C9C-A3D8-43E4284D95E8}" then return Colors end
    error("A global Colors class already exist.")
end

---Color constants
---@class Colors Provides color constants
Colors = {
	__class  = "Colors",
	__guid   = "{E6240471-4450-4C9C-A3D8-43E4284D95E8}",
	__origin = "Kux-CoreLib/lib/Colors.lua",

	white = {r = 1, g = 1, b = 1},
	lightgrey = {r = 0.75, g = 0.75, b = 0.75},
	grey = {r = 0.5, g = 0.5, b = 0.5},
	darkgrey = {r = 0.25, g = 0.25, b = 0.25},
	black = {r = 0, g = 0, b = 0},
	red = {r = 1, g = 0, b = 0},
	green = {r = 0, g = 1, b = 0},
	blue = {r = 0, g = 0, b = 1},
	yellow = {r = 1, g = 1, b = 0},
	orange = {r = 1, g = 0.55, b = 0.1},
	pink = {r = 1, g = 0, b = 1},
	lightred = {r = 1, g = 0.5, b = 0.5},
	lightgreen = {r = 0.5, g = 1, b = 0.5},
	lightblue = {r = 0.5, g = 0.5, b = 1},
	darkred = {r = 0.5, g = 0, b = 0},
	darkgreen = {r = 0, g = 0.5, b = 0},
	darkblue = {r = 0, g = 0, b = 0.5},
	brown = {r = 0.6, g = 0.4, b = 0.1},
	purple = {r = 0.6, g = 0.1, b = 0.6},
	cyan = {r = 0, g = 1, b = 1},
}

return Colors