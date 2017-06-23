
local function OpenSaveDialog()
	if (not gui.IsGameUIVisible()) then
		gui.ActivateGameUI()
	end
	
	RunConsoleCommand("gamemenucommand", "OpenSaveGameDialog")
end

local function OpenLoadDialog()
	if (not gui.IsGameUIVisible()) then
		gui.ActivateGameUI()
	end
	
	RunConsoleCommand("gamemenucommand", "OpenLoadGameDialog")
end

concommand.Add("HL2SaveSys_saveGame", OpenSaveDialog)
concommand.Add("HL2SaveSys_loadGame", OpenLoadDialog)

function HL2SaveSys_SaveAndLoad(panel)
	panel:Button("Save Game", "HL2SaveSys_saveGame")
	panel:Button("Load Game", "HL2SaveSys_loadGame")
end

function HL2SaveSys_Options(panel)
	panel:Help("Save Player Data enables the saving of players' positions and angles in the map, as well as their weapons and ammunition.")
	panel:CheckBox("Save Player Data", "HL2SaveSys_saveSpawnData")
	
	panel:Help("Override Player Spawning enables the restoration of players' data as mentioned in the above description.")
	panel:CheckBox("Override Player Spawning", "HL2SaveSys_overrideSpawning")
end

function HL2SaveSys_SaveAndLoad_Menu()
	spawnmenu.AddToolMenuOption("Options", "Half-Life 2 Save Menu", "HL2SaveSys_SaveAndLoad", "Save and Load", "", "", HL2SaveSys_SaveAndLoad)
	spawnmenu.AddToolMenuOption("Options", "Half-Life 2 Save Menu", "HL2SaveSys_Options", "Options", "", "", HL2SaveSys_Options)
end

hook.Add("PopulateToolMenu", "HL2SaveSys_SaveAndLoad", HL2SaveSys_SaveAndLoad_Menu)
