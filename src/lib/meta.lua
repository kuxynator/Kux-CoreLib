---@meta

-- -@class LuaObject: userdata

---@class object : LuaObject, {[string]:any}

---@alias KuxCoreLib.BasicTable table<string|number|boolean|KuxCoreLib.BasicTable>

---@alias KuxCoreLib.Tags table<string, string|number|boolean|KuxCoreLib.BasicTable>

-- -@alias LocalisedString string | table<string, (boolean | number | string | LocalisedString)?>
-- -@diagnostic disable-next-line: duplicate-doc-alias
-- -@alias LocalisedString string | table<string, (boolean | number | string)?>


-- -@alias LocalizableString string | table<string | boolean | number | LuaObject | LocalizableString>

-- -@alias LocalizableString (string)|(number)|(boolean)|(LuaObject)|(nil)|((LocalizableString)[])
---@alias LocalizableString (string)|(number)|(boolean)|(userdata)|(nil)|((LocalizableString)[])

--WORKAROUND
---@diagnostic disable-next-line: duplicate-doc-alias
---@alias LocalisedString any


---@alias PlayerName string
---@alias PlayerIndex integer
---@alias ForceName string
---@alias ForceIndex integer
---@alias InterfaceName string
-- -@alias ItemName string
-- -@alias EntityName string
-- -@alias SurfaceName string
---@alias GameTick integer
-- -@alias QualityName string
---@alias ElemKey string A composite string from "<type>/<name>" equals a sprite path
---@alias ElemQualityKey string A composite string from "<type>/<name>/<quality>"
---@alias UnitNumber integer