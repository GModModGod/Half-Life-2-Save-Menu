# Half-Life 2 Save Menu

This is the Menu Mods-compatible version of the Half-Life 2 Save Menu addon for Garry's Mod.

This addon enables anyone to access the old Source Engine save and load menus via Options -> Half-Life 2 Save Menu -> Save and Load.

The settings for this addon are also located under Options -> Half-Life 2 Save Menu -> Options.

If you have any old GMod saves from Garry's Mod 12 (or possibly earlier), you can reload them as well.

If you would like to fix level transitions as well, you could download the "Level Transition Fix" addon (found here), or the "Basic Campaign" addon (found here).



To control which entities with certain classes are deleted upon loading, use the following functions in the "GM:Initialize()" hook. (It is not guaranteed to work when placed directly inside a file's source code, as the code can be run before any of these functions are defined.):


HL2SaveSys.AddClassNoSave(class, key, condition) - Adds an entity class to be scheduled for deletion. The "key" argument acts as an identifier. The "condition" argument can either be a boolean (make "true" to delete the entity), or a function with one argument as an entity in question (return "true" to delete and "false" or "nil" to keep the entity).

HL2SaveSys.RemoveClassNoSave(class, key) - Attempts to remove a class blacklist with the specified classname (the "class" argument) and identifier (the "key" argument). Prints an error message if there is no such blacklist.

HL2SaveSys.ClassNoSaveExists(class, key) - Checks if a class blacklist with the specified classname and identifier exists.

HL2SaveSys.GetClassNoSave(class, key) - Attempts to retrieve the function/boolean value of a class blacklist with the specified classname and identifier. Prints an error message if there is no such blacklist.
