
local LoadGameContainer = {
	urls = "asset://garrysmod/html/menu.html#/",
	tag = "LI",
	class = "hl2savemenu_loadgamebuttoncontainer",
	parentClass = "menumods_list1_pos6",
	parentNum = 1,
	content = "",
	attributes = {}
}

local SaveGameContainer = {
	urls = "asset://garrysmod/html/menu.html#/",
	tag = "LI",
	class = "hl2savemenu_savegamebuttoncontainer",
	parentClass = "menumods_list1_pos6",
	parentNum = 1,
	content = "",
	attributes = {},
	show = function()
		return IsInGame()
	end
}

local LoadGame = {
	urls = "asset://garrysmod/html/menu.html#/",
	class = "hl2savemenu_loadgamebutton",
	parentClass = "hl2savemenu_loadgamebuttoncontainer",
	parentNum = 1,
	content = "Load Game",
	onClick = "lua.Run(\"RunGameUICommand(\'OpenLoadGameDialog\')\")",
	attributes = {{"href", "#/"}}
}

local SaveGame = {
	urls = "asset://garrysmod/html/menu.html#/",
	class = "hl2savemenu_savegamebutton",
	parentClass = "hl2savemenu_savegamebuttoncontainer",
	parentNum = 1,
	content = "Save Game",
	onClick = "lua.Run(\"RunGameUICommand(\'OpenSaveGameDialog\')\")",
	attributes = {{"href", "#/"}}
}

menumods.AddElement("HL2SaveMenu_LoadGameButtonContainer", LoadGameContainer)
menumods.AddElement("HL2SaveMenu_SaveGameButtonContainer", SaveGameContainer)

menumods.AddOption("HL2SaveMenu_LoadGameButton", LoadGame, LoadGame.onClick)
menumods.AddOption("HL2SaveMenu_SaveGameButton", SaveGame, SaveGame.onClick)
