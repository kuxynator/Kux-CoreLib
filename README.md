# Kuxynator's Core Library

Provides core functionality for Kuxynator's mods.

## Public Library
- [Lua](#Lua) - Provides public functions missing in lua
- [String](#String) - Provides string functions
- [Table](#Table) - Provides table functions
- [Assert](#Assert) - Provides messages for assert
- [Color](#ColorConverter) - Provides color conversion
- [Colors](#Colors) - Provides color constants

All other files are internal use only because API not fully tested or work-in-progress. 

### General usage

1. Create the KuxCoreLib variable, which is requiered by all files you include:<br>
```KuxCoreLib = KuxCoreLib or requiere("__Kux-CoreLib__/init")```<br>

2. Init the module globally: <br>
```require(KuxCoreLib.<ModuleName>)```  
```require(KuxCoreLib.Data.<ModuleName>)```

alternatively you can includa all files using:<br>
```require("__Kux-CoreLib__/lib/@")```  
```require("__Kux-CoreLib__/lib/data/@")```

### Lua

- iif
- try/catch/finaly
- switch
- switchp
- safeget
- safeset

### String

Provides string functions

Init: ```require(KuxCoreLib.String)```

- String.concat - Concatenances a string
- String.format - Formats a string (format="%1 %2 ...")
- String.replace - Replaces parts of a string (format="{name}")
- String.print
- String.startsWith - Gets a value indication the string starts with the specifed value.
- String.endsWith - Gets a value indication the string ends with the specifed value.
- String.split - Splits a string.
- String.escape - Escapes a string
- String.pretty - Returns a string that presents the prettified value
- global str - String.pretty with debug formatting
- String.toChars - Return an array with each char from string

### Table

Provides table functions

Init: ```require(KuxCoreLibPath.."Table")```

- Table.getValues - Gets all values.
- Table.getKeys - Gets all keys
- Table.indexOf - Gets the first index of the value
- Table.keyOf - Gets the first key which has the value
- 
- 
- 
- 
- 
- 
- 
- 
- 
- 
- 
- 
- 
- 
- 
- 
- 


### Assert

Provides messages for assert

Init: ```require(KuxCoreLibPath.."Assert")```

Usage: ```assert(Assert.IsNotNil(value))```

- Assert.Argument.IsNotNil
- Assert.Argument.IsNotNilOrEmpty
- Assert.IsEqual
- Assert.IsNotEqual
- Assert.IsReferenceEqual
- Assert.IsTrue
- Assert.IsFalse
- Assert.IsNil
- Assert.IsNilOrFalse
- Assert.IsNotNil
- Assert.IsNotNilOrFalse
- Assert.IsTypeOf
- Assert.IsNotTypeOf
- ...

### ColorConverter
- rgbToHsl - RGB to HSL conversion
- hslToRgb - HSL to RGB conversion
- rgbToHsv - RGB to HSV conversion
- hsvToRgb  HSV to RGB conversion

### Colors

Contains A few color constants.
