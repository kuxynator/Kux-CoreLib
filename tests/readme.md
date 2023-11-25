problem with local testing is, that path variables are propritary. 
so all my "__Kux-CoreLib__/lib..." paths are not recognized by code run and I had to come up with a workaround.

The format  "__ModName__" is factorio specific and no tool recognize it.

So I wrote my own testrunner, but hat to prepare all lib files with a dynamic path like:
  require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")
which is ugly 😉
KuxCoreLibPath is nil at runtime and "src/" at test time.