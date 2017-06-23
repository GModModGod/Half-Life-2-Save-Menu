
AddCSLuaFile("autorun/client/cl_hl2_save_system.lua")

CreateConVar("HL2SaveSys_saveSpawnData", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY})
CreateConVar("HL2SaveSys_overrideSpawning", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY})

if (not SERVER) then return end

local HL2SaveSys_ClassBlacklist = {
	["physical_bullet"] = {
		["basic_campaign"] = true
	},
	["env_projectedtexture"] = {
		["basic_campaign"] = function(ent)
			if ent:GetNWBool("TPF_IsFlashlight", false) then
				return true
			end
			
			return false
		end
	},
}

HL2SaveSys = {}

function HL2SaveSys.AddClassNoSave(class, key, condition)
	if (not HL2SaveSys_ClassBlacklist[class]) then
		HL2SaveSys_ClassBlacklist[class] = {}
	end
	
	if (HL2SaveSys_ClassBlacklist[class][key] == nil) then
		HL2SaveSys_ClassBlacklist[class][key] = condition
	else
		print("Half-Life 2 Save System - Cannot add save exclusion. A save exclusion with the same name already exists.")
		
		return
	end
end

function HL2SaveSys.RemoveClassNoSave(class, key)
	if (not HL2SaveSys_ClassBlacklist[class]) then
		print("Half-Life 2 Save System - Cannot remove save exclusion. A save exclusion under this class does not exist.")
		
		return
	elseif (HL2SaveSys_ClassBlacklist[class][key] == nil) then
		print("Half-Life 2 Save System - Cannot remove save exclusion. A save exclusion under this key does not exist.")
		
		return
	end
	
	HL2SaveSys_ClassBlacklist[class][key] = nil
	
	if (#HL2SaveSys_ClassBlacklist[class] <= 0) then
		HL2SaveSys_ClassBlacklist[class] = nil
	end
end

function HL2SaveSys.ClassNoSaveExists(class, key)
	if (not HL2SaveSys_ClassBlacklist[class]) then
		return true
	elseif (HL2SaveSys_ClassBlacklist[class][key] == nil) then
		return true
	end
	
	return false
end

function HL2SaveSys.GetClassNoSave(class, key)
	if (not HL2SaveSys_ClassBlacklist[class]) then
		print("Half-Life 2 Save System - Cannot get save exclusion. A save exclusion under this class does not exist.")
		
		return
	elseif (HL2SaveSys_ClassBlacklist[class][key] == nil) then
		print("Half-Life 2 Save System - Cannot get save exclusion. A save exclusion under this key does not exist.")
	end
	
	return HL2SaveSys_ClassBlacklist[class][key]
end

local HL2SaveSys_CanSpawn = true

local HL2SaveSys_LoadedPlayerData
local HL2SaveSys_SavedPlayerData = {}
local HL2SaveSys_CrouchingPlayers = {}
local HL2SaveSys_ExcludedEnts = {}

local function SaveGame(save)
	if (GetConVarNumber("HL2SaveSys_saveSpawnData") != 0) then
		local playerTable = HL2SaveSys_SavedPlayerData
		save:StartBlock("HL2SaveSys")
		
		save:WriteString(game.GetMap())
		
		local excludedEnts = {}
		
		for k, v in pairs(ents.GetAll()) do
			if ((not v:IsWorld()) and (not v:IsPlayer())) then
				if v:IsValid() then
					local class = v:GetClass()
					
					if HL2SaveSys_ClassBlacklist[class] then
						local whitelist = true
						
						for i, j in pairs(HL2SaveSys_ClassBlacklist[class]) do
							if j then
								if isfunction(j) then
									if j(v) then
										whitelist = false
										
										break
									end
								else
									whitelist = false
									
									break
								end
							end
						end
						
						if (not whitelist) then
							table.insert(excludedEnts, (#excludedEnts + 1), v:EntIndex())
						end
					end
				end
			end
		end
		
		save:StartBlock("ExcludedEnts")
		
		save:WriteInt(#excludedEnts)
		
		for k, v in pairs(excludedEnts) do
			save:StartBlock("ExcludedEnt_" .. k)
			
			save:WriteInt(v)
			
			save:EndBlock()
		end
		
		save:EndBlock()
		
		save:StartBlock("Players")
		
		local numPlayers = 0
		
		for k, v in ipairs(playerTable) do
			numPlayers = numPlayers + 1
		end
		
		save:WriteInt(numPlayers)
		
		for k, v in ipairs(playerTable) do
			save:StartBlock("Player_" .. k)
			
			save:WriteVector(v.Pos)
			save:WriteAngle(v.EyeAngles)
			save:WriteVector(v.Velocity)
			save:WriteFloat(v.Health)
			save:WriteFloat(v.Armor)
			
			if v.ActiveWeapon then
				save:WriteBool(true)
				save:WriteString(v.ActiveWeapon)
			else
				save:WriteBool(false)
			end
			
			if v.PrevWeapon then
				save:WriteBool(true)
				save:WriteString(v.PrevWeapon)
			else
				save:WriteBool(false)
			end
			
			save:WriteEntity(v.Vehicle)
			save:WriteBool(v.Crouching)
			save:WriteBool(v.FlashlightIsOn)
			
			save:StartBlock("Weapons")
			
			local numWeapons = 0
			
			for j, wep in pairs(v.Weapons) do
				numWeapons = numWeapons + 1
			end
			
			save:WriteInt(numWeapons)
			
			for j, wep in pairs(v.Weapons) do
				save:StartBlock("Weapon_" .. j)
				
				save:WriteString(wep.Class)
				save:WriteInt(wep.PrimAmmoType)
				save:WriteInt(wep.SecAmmoType)
				save:WriteFloat(wep.Clip1)
				save:WriteFloat(wep.Clip2)
				
				save:EndBlock()
			end
			
			save:EndBlock()
			
			save:StartBlock("Ammo")
			
			local numAmmo = 0
			
			for j, wep in pairs(v.Ammo) do
				numAmmo = numWeapons + 1
			end
			
			save:WriteInt(numAmmo)
			
			for j, amm in pairs(v.Ammo) do
				save:StartBlock("AmmoType_" .. j)
				
				save:WriteString(amm.Type)
				save:WriteFloat(amm.Count)
				
				save:EndBlock()
			end
			
			save:EndBlock()
			
			save:EndBlock()
		end
		
		save:EndBlock()
		
		save:EndBlock()
	end
end

local function RestoreGame(save)
	if (GetConVarNumber("HL2SaveSys_overrideSpawning") != 0) then
		local name = save:StartBlock()
		
		if (name == "HL2SaveSys") then
			local playerTable = {}
			
			playerTable.Map = save:ReadString()
			
			local excludedEnts = {}
			
			save:StartBlock()
			
			local excludedEntCount = save:ReadInt()
			
			for i = 1, excludedEntCount do
				save:StartBlock()
				
				local currEntID = save:ReadInt()
				
				save:EndBlock()
				
				excludedEnts[currEntID] = true
			end
			
			save:EndBlock()
			
			HL2SaveSys_ExcludedEnts = excludedEnts
			
			save:StartBlock()
			
			local playerCount = save:ReadInt()
			
			for i = 1, playerCount do
				local saveTable = {}
				
				save:StartBlock()
				
				saveTable.Pos = save:ReadVector()
				saveTable.EyeAngles = save:ReadAngle()
				saveTable.Velocity = save:ReadVector()
				saveTable.Health = save:ReadFloat()
				saveTable.Armor = save:ReadFloat()
				
				if save:ReadBool() then
					saveTable.ActiveWeapon = save:ReadString()
				end
				
				if save:ReadBool() then
					saveTable.PrevWeapon = save:ReadString()
				end
				
				saveTable.Vehicle = save:ReadEntity()
				saveTable.Crouching = save:ReadBool()
				saveTable.FlashlightIsOn = save:ReadBool()
				
				local plyWeapons = {}
				
				save:StartBlock()
				
				local weaponCount = save:ReadInt()
				
				for j = 1, weaponCount do
					local weaponTable = {}
					
					save:StartBlock()
					
					weaponTable.Class = save:ReadString()
					weaponTable.PrimAmmoType = save:ReadInt()
					weaponTable.SecAmmoType = save:ReadInt()
					weaponTable.Clip1 = save:ReadFloat()
					weaponTable.Clip2 = save:ReadFloat()
					
					save:EndBlock()
					
					table.insert(plyWeapons, weaponTable)
				end
				
				save:EndBlock()
				
				saveTable.Weapons = plyWeapons
				
				local plyAmmo = {}
				
				save:StartBlock()
				
				local ammoTypeCount = save:ReadInt()
				
				for j = 1, ammoTypeCount do
					local ammoTable = {}
					
					save:StartBlock()
					
					ammoTable.Type = save:ReadString()
					ammoTable.Count = save:ReadFloat()
					
					save:EndBlock()
					
					table.insert(plyAmmo, ammoTable)
				end
				
				save:EndBlock()
				
				saveTable.Ammo = plyAmmo
				
				save:EndBlock()
				
				table.insert(playerTable, saveTable)
			end
			
			HL2SaveSys_LoadedPlayerData = playerTable
			HL2SaveSys_SavedPlayerData = playerTable
			
			save:EndBlock()
		end
		
		save:EndBlock()
	end
end

local function PlayerPostThink(ply)
	if (GetConVarNumber("HL2SaveSys_saveSpawnData") != 0) then
		if (HL2SaveSys_SavedPlayerData and ply:Alive()) then
			local playerID
			
			local currPlayerID = 1
			for k, v in ipairs(player.GetAll()) do
				if (v == ply) then
					playerID = currPlayerID
					break
				end
				
				currPlayerID = currPlayerID + 1
			end
			
			if playerID then
				local saveTable = {}
				
				saveTable.Pos = ply:GetPos()
				saveTable.EyeAngles = ply:EyeAngles()
				saveTable.Velocity = ply:GetVelocity()
				saveTable.Health = ply:Health()
				saveTable.Armor = ply:Armor()
				
				if ply:GetActiveWeapon():IsValid() then
					saveTable.ActiveWeapon = ply:GetActiveWeapon():GetClass()
				end
				
				if ply.HL2SaveSys_PrevWeapon then
					saveTable.PrevWeapon = ply.HL2SaveSys_PrevWeapon
				end
				
				saveTable.Vehicle = ply:GetVehicle()
				saveTable.Crouching = ply:Crouching()
				saveTable.FlashlightIsOn = ply:FlashlightIsOn()
				
				local plyWeapons = ply:GetWeapons()
				
				saveTable.Weapons = {}
				saveTable.Ammo = {}
				
				for j, wep in pairs(plyWeapons) do
					local currWeaponTable = {}
					
					currWeaponTable.Class = wep:GetClass()
					
					currWeaponTable.PrimAmmoType = wep:GetPrimaryAmmoType()
					currWeaponTable.SecAmmoType = wep:GetSecondaryAmmoType()
					
					currWeaponTable.Clip1 = wep:Clip1()
					currWeaponTable.Clip2 = wep:Clip2()
					
					local currPrimAmmo = {}
					
					currPrimAmmo.Type = currWeaponTable.PrimAmmoType
					currPrimAmmo.Count = ply:GetAmmoCount(currWeaponTable.PrimAmmoType)
					
					local currSecAmmo = {}
					
					currSecAmmo.Type = currWeaponTable.SecAmmoType
					currSecAmmo.Count = ply:GetAmmoCount(currWeaponTable.SecAmmoType)
					
					table.insert(saveTable.Weapons, currWeaponTable)
					table.insert(saveTable.Ammo, currPrimAmmo)
					table.insert(saveTable.Ammo, currSecAmmo)
				end
				
				HL2SaveSys_SavedPlayerData[playerID] = saveTable
			end
		else
			HL2SaveSys_SavedPlayerData = {}
		end
	end
end

local function Think()
	if HL2SaveSys_CanSpawn then
		if (GetConVarNumber("HL2SaveSys_overrideSpawning") != 0) then
			local playerTable = HL2SaveSys_LoadedPlayerData
			
			if playerTable then
				if (playerTable.Map == game.GetMap()) then
					local currPlayerID = 1
					
					for playerID, ply in ipairs(player.GetAll()) do
						local saveTable = playerTable[currPlayerID]
						
						if saveTable then
							ply:SetPos(saveTable.Pos)
							ply:SetEyeAngles(saveTable.EyeAngles)
							ply:SetVelocity(saveTable.Velocity)
							ply:SetHealth(saveTable.Health)
							ply:SetArmor(saveTable.Armor)
							
							local playerVehicle = saveTable.Vehicle
							
							if playerVehicle:IsValid() then
								if (ply:GetVehicle() != playerVehicle) then
									ply:EnterVehicle(playerVehicle)
								end
							else
								if ply:InVehicle() then
									ply:ExitVehicle()
								end
							end
							
							if saveTable.Crouching then
								HL2SaveSys_CrouchingPlayers[playerID] = true
							end
							
							if saveTable.FlashlightIsOn then
								if (not ply:FlashlightIsOn()) then
									ply:Flashlight(true)
								end
							else
								if ply:FlashlightIsOn() then
									ply:Flashlight(false)
								end
							end
							
							ply:StripWeapons()
							
							for j, wep in pairs(saveTable.Weapons) do
								local currWeapon = ply:Give(wep.Class, true)
								
								currWeapon:SetClip1(wep.Clip1)
								currWeapon:SetClip2(wep.Clip2)
							end
							
							for j, ammo in pairs(saveTable.Ammo) do
								ply:SetAmmo(ammo.Count, ammo.Type)
							end
							
							if saveTable.PrevWeapon then
								ply:SelectWeapon(saveTable.PrevWeapon)
							end
							
							if saveTable.ActiveWeapon then
								ply:SelectWeapon(saveTable.ActiveWeapon)
							end
							
							if saveTable.PrevWeapon then
								ply.HL2SaveSys_PrevWeapon = saveTable.PrevWeapon
							end
						end
						
						currPlayerID = currPlayerID + 1
					end
				else
					local currPlayerID = 1
					
					for playerID, ply in ipairs(player.GetAll()) do
						local saveTable = playerTable[currPlayerID]
						
						if saveTable then
							ply:SetHealth(saveTable.Health)
							ply:SetArmor(saveTable.Armor)
							
							local playerVehicle = saveTable.Vehicle
							
							if playerVehicle:IsValid() then
								if (ply:GetVehicle() != playerVehicle) then
									ply:EnterVehicle(playerVehicle)
								end
							else
								if ply:InVehicle() then
									ply:ExitVehicle()
								end
							end
							
							if saveTable.Crouching then
								HL2SaveSys_CrouchingPlayers[playerID] = true
							end
							
							if saveTable.FlashlightIsOn then
								if (not ply:FlashlightIsOn()) then
									ply:Flashlight(true)
								end
							else
								if ply:FlashlightIsOn() then
									ply:Flashlight(false)
								end
							end
							
							ply:StripWeapons()
							
							for j, wep in pairs(saveTable.Weapons) do
								local currWeapon = ply:Give(wep.Class, true)
								
								currWeapon:SetClip1(wep.Clip1)
								currWeapon:SetClip2(wep.Clip2)
							end
							
							for j, ammo in pairs(saveTable.Ammo) do
								ply:SetAmmo(ammo.Count, ammo.Type)
							end
							
							if saveTable.PrevWeapon then
								ply:SelectWeapon(saveTable.PrevWeapon)
							end
							
							if saveTable.ActiveWeapon then
								ply:SelectWeapon(saveTable.ActiveWeapon)
							end
							
							if saveTable.PrevWeapon then
								ply.HL2SaveSys_PrevWeapon = saveTable.PrevWeapon
							end
						end
						
						currPlayerID = currPlayerID + 1
					end
				end
			end
			
			excludedEnts = HL2SaveSys_ExcludedEnts
			
			for k, v in pairs(excludedEnts) do
				if v then
					local ent = ents.GetByIndex(k)
					
					if ((not ent:IsWorld()) and (not ent:IsPlayer())) then
						if ent:IsValid() then
							local class = ent:GetClass()
							
							if HL2SaveSys_ClassBlacklist[class] then
								local whitelist = true
								
								for i, j in pairs(HL2SaveSys_ClassBlacklist[class]) do
									if j then
										if isfunction(j) then
											if j(ent) then
												whitelist = false
												
												break
											end
										else
											whitelist = false
											
											break
										end
									end
								end
								
								if (not whitelist) then
									v:Remove()
								end
							end
						end
					end
				end
			end
		end
		
		HL2SaveSys_ExcludedEnts = {}
		
		HL2SaveSys_CanSpawn = false
	end
end

local function PlayerTick(ply, move)
	local playerID = 1
	
	for k, v in pairs(player.GetAll()) do
		if (v == ply) then
			playerID = k
			break
		end
	end
	
	if HL2SaveSys_CrouchingPlayers[playerID] then
		if (not move:KeyDown(IN_DUCK)) then
			move:AddKey(IN_DUCK)
		end
		
		HL2SaveSys_CrouchingPlayers[playerID] = nil
	end
end

local function VehicleMove(ply, vehicle, move)
	local playerID = 1
	
	for k, v in pairs(player.GetAll()) do
		if (v == ply) then
			playerID = k
			break
		end
	end
	
	HL2SaveSys_CrouchingPlayers[playerID] = nil
end

local function PlayerSwitchWeapon(ply, oldWeapon, newWeapon)
	if oldWeapon:IsValid() then
		ply.HL2SaveSys_PrevWeapon = oldWeapon:GetClass()
	end
end

saverestore.AddSaveHook("HL2SaveSys_Save", SaveGame)
saverestore.AddRestoreHook("HL2SaveSys_Save", RestoreGame)

hook.Add("PlayerPostThink", "HL2SaveSys_PlayerPostThink", PlayerPostThink)
hook.Add("Think", "HL2SaveSys_Think", Think)
hook.Add("PlayerTick", "HL2SaveSys_PlayerTick", PlayerTick)
hook.Add("VehicleMove", "HL2SaveSys_VehicleMove", VehicleMove)
hook.Add("PlayerSwitchWeapon", "HL2SaveSys_PlayerSwitchWeapon", PlayerSwitchWeapon)
