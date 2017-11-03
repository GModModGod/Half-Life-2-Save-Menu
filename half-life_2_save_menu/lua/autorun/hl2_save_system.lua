
AddCSLuaFile()
AddCSLuaFile("autorun/client/cl_hl2_save_system.lua")

CreateConVar("HL2SaveSys_saveSpawnData", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY})
CreateConVar("HL2SaveSys_overrideSpawning", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY})
CreateConVar("HL2SaveSys_saveLuaTables", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY})

if (not SERVER) then
	local ENT_META = FindMetaTable("Entity")

	if ENT_META then
		local HL2SaveSys_SetNWAngle_Old = ENT_META.SetNWAngle
		local HL2SaveSys_SetNWAngle = HL2SaveSys_SetNWAngle_Old
		
		ENT_META.SetNWAngle = function(self, key, value, ...)
			net.Start("HL2SaveSys_SendNWVar")
			
			net.WriteEntity(self)
			net.WriteString(key)
			net.WriteType(value)
			
			net.SendToServer()
			
			return HL2SaveSys_SetNWAngle(self, key, value, ...)
		end
		
		local HL2SaveSys_SetNWBool_Old = ENT_META.SetNWBool
		local HL2SaveSys_SetNWBool = HL2SaveSys_SetNWBool_Old
		
		ENT_META.SetNWBool = function(self, key, value, ...)
			net.Start("HL2SaveSys_SendNWVar")
			
			net.WriteEntity(self)
			net.WriteString(key)
			net.WriteType(value)
			
			net.SendToServer()
			
			return HL2SaveSys_SetNWBool(self, key, value, ...)
		end
		
		local HL2SaveSys_SetNWEntity_Old = ENT_META.SetNWEntity
		local HL2SaveSys_SetNWEntity = HL2SaveSys_SetNWEntity_Old
		
		ENT_META.SetNWEntity = function(self, key, value, ...)
			net.Start("HL2SaveSys_SendNWVar")
			
			net.WriteEntity(self)
			net.WriteString(key)
			net.WriteType(value)
			
			net.SendToServer()
			
			return HL2SaveSys_SetNWEntity(self, key, value, ...)
		end
		
		local HL2SaveSys_SetNWFloat_Old = ENT_META.SetNWFloat
		local HL2SaveSys_SetNWFloat = HL2SaveSys_SetNWFloat_Old
		
		ENT_META.SetNWFloat = function(self, key, value, ...)
			net.Start("HL2SaveSys_SendNWVar")
			
			net.WriteEntity(self)
			net.WriteString(key)
			net.WriteType(value)
			
			net.SendToServer()
			
			return HL2SaveSys_SetNWFloat(self, key, value, ...)
		end
		
		local HL2SaveSys_SetNWInt_Old = ENT_META.SetNWInt
		local HL2SaveSys_SetNWInt = HL2SaveSys_SetNWInt_Old
		
		ENT_META.SetNWInt = function(self, key, value, ...)
			net.Start("HL2SaveSys_SendNWVar")
			
			net.WriteEntity(self)
			net.WriteString(key)
			net.WriteType(value)
			
			net.SendToServer()
			
			return HL2SaveSys_SetNWInt(self, key, value, ...)
		end
		
		local HL2SaveSys_SetNWString_Old = ENT_META.SetNWString
		local HL2SaveSys_SetNWString = HL2SaveSys_SetNWString_Old
		
		ENT_META.SetNWString = function(self, key, value, ...)
			net.Start("HL2SaveSys_SendNWVar")
			
			net.WriteEntity(self)
			net.WriteString(key)
			net.WriteType(value)
			
			net.SendToServer()
			
			return HL2SaveSys_SetNWString(self, key, value, ...)
		end
		
		local HL2SaveSys_SetNWVector_Old = ENT_META.SetNWVector
		local HL2SaveSys_SetNWVector = HL2SaveSys_SetNWVector_Old
		
		ENT_META.SetNWVector = function(self, key, value, ...)
			net.Start("HL2SaveSys_SendNWVar")
			
			net.WriteEntity(self)
			net.WriteString(key)
			net.WriteType(value)
			
			net.SendToServer()
			
			return HL2SaveSys_SetNWVector(self, key, value, ...)
		end
	end
	
	return
end

util.AddNetworkString("HL2SaveSys_SendNWVar")

HL2SaveSys = {}

local HL2SaveSys_Players = {}

local escChars = {
	{"\a", "a"},
	{"\b", "b"},
	{"\f", "f"},
	{"\n", "n"},
	{"\r", "r"},
	{"\t", "t"},
	{"\v", "v"},
	{"\"", "\""},
	{"\'", "\'"},
}

HL2SaveSys.string = {}

function HL2SaveSys.string.LevelPush(str, numLevels, noOuterQuotes)
	local numLevels_new = numLevels
	
	if (not numLevels_new) then
		numLevels_new = 1
	end
	
	local newString = ("" .. str)
	
	for i = 1, numLevels_new do
		newString = string.Replace(newString, "\\", "\\\\")
		
		for k, v in pairs(escChars) do
			newString = string.Replace(newString, v[1], ("\\" .. v[2]))
		end
		
		if (not noOuterQuotes) then
			newString = ("\"" .. newString .. "\"")
		end
	end
	
	return newString
end

function HL2SaveSys.string.LevelPop(str, numLevels)
	local numLevels_new = numLevels
	
	if (not numLevels_new) then
		numLevels_new = 1
	end
	
	local newString = ("" .. str)
	
	for i = 1, numLevels_new do
		for k, v in pairs(escChars) do
			newString = string.gsub(newString, "^[\"\']", "")
			newString = string.gsub(newString, ("([^\\])" .. string.PatternSafe(v[1])), "%1")
			newString = string.Replace(newString, ("\\" .. v[2]), v[1])
		end
		
		newString = string.Replace(newString, "\\\\", "\\")
	end
	
	return newString
end

local HL2SaveSys_ValidTypes_Old = {
	["angle"] = true,
	["boolean"] = true,
	["entity"] = true,
	["nil"] = true,
	["no value"] = true,
	["number"] = true,
	["player"] = true,
	["string"] = true,
	["vector"] = true
}

local HL2SaveSys_ValidTypes = {
	["angle"] = true,
	["boolean"] = true,
	["entity"] = true,
	["nil"] = true,
	["no value"] = true,
	["number"] = true,
	["player"] = true,
	["string"] = true,
	["table"] = true,
	["vector"] = true
}

function HL2SaveSys.string.AppendValues(str, ...)
	local vals = {...}
	
	for k, v in ipairs(vals) do
		str = str .. tostring(v) .. ";"
	end
	
	return str
end

function HL2SaveSys.string.ReadValues(str, numVals)
	local vals = {}
	
	for i = 1, numVals do
		local currStr = ""
		local foundEnd = false
		
		while (not foundEnd) do
			local startPos, endPos = string.find(str, "^[^\"\';]*[\"\';]")
			
			if (not startPos) then
				startPos = 1
			end
			
			if (not endPos) then
				endPos = 0
			end
			
			currStr = currStr .. string.sub(str, startPos, endPos)
			
			str = string.sub(str, (endPos + 1))
			
			local endsWithSemi = ((currStr == "") or string.find(currStr, ";$"))
			local startsWithDQ = string.find(currStr, "^\"")
			local startsWithSQ = ((not startsWithDQ) and string.find(currStr, "^\'"))
			local sufficientLen = (#currStr > 1)
			local endsWithDQ = (sufficientLen and string.find(currStr, "\"$"))
			local endsWithSQ = (sufficientLen and (not endsWithDQ) and string.find(currStr, "\'$"))
			local endsWithSDQ = (sufficientLen and endsWithDQ and string.find(currStr, "\\\"$"))
			local endsWithSSQ = (sufficientLen and endsWithSQ and string.find(currStr, "\\\'$"))
			
			if ((endsWithSemi and (not startsWithDQ) and (not startsWithSQ)) or (endsWithDQ and (not endsWithSDQ) and startsWithDQ) or (endsWithSQ and (not endsWithSSQ) and startsWithSQ) or ((endsWithSDQ or endsWithSSQ) and (not (startsWithDQ or startsWithSQ)))) then
				if endsWithSemi then
					if (currStr != "") then
						currStr = string.sub(currStr, 1, (#currStr - 1))
					end
				else
					if (str != "") then
						str = string.sub(str, 2)
					end
				end
				
				foundEnd = true
			end
		end
		
		table.insert(vals, (#vals + 1), currStr)
	end
	
	return vals, str
end

local HL2SaveSys_SetNWVarFuncs = {
	["angle"] = function(ent, key, value)
		ent:SetNWAngle(key, value)
	end,
	["boolean"] = function(ent, key, value)
		ent:SetNWBool(key, value)
	end,
	["entity"] = function(ent, key, value)
		ent:SetNWEntity(key, value)
	end,
	["player"] = function(ent, key, value)
		ent:SetNWEntity(key, value)
	end,
	["float"] = function(ent, key, value)
		ent:SetNWFloat(key, value)
	end,
	["int"] = function(ent, key, value)
		ent:SetNWInt(key, value)
	end,
	["string"] = function(ent, key, value)
		ent:SetNWString(key, value)
	end,
	["vector"] = function(ent, key, value)
		ent:SetNWVector(key, value)
	end
}

function HL2SaveSys.SetNWVar(ent, key, value)
	local valType = string.lower(type(value))
	
	if (not HL2SaveSys_SetNWVarFuncs[valType]) then
		local errInfo = debug.getinfo(0, "S")
		
		error("[ERROR] " .. errInfo.short_src .. ": Attempted to set a networked variable of an invalid type on an entity.")
		
		return
	end
	
	HL2SaveSys_SetNWVarFuncs[valType](ent, key, value)
end

local HL2SaveSys_WriteTypeFuncs = {
	["angle"] = function(str, val)
		str = HL2SaveSys.string.AppendValues(str, val.p, val.y, val.r)
		
		return str
	end,
	["boolean"] = function(str, val)
		str = HL2SaveSys.string.AppendValues(str, val)
		
		return str
	end,
	["entity"] = function(str, val)
		if (not (val:IsValid() or val:IsWorld())) then
			str = HL2SaveSys.string.AppendValues(str, false, -1)
			
			return str
		end
		
		if (not val:IsPlayer()) then
			str = HL2SaveSys.string.AppendValues(str, false, val:MapCreationID())
		else
			if HL2SaveSys_Players[val] then
				str = HL2SaveSys.string.AppendValues(str, true, HL2SaveSys_Players[val])
			else
				str = HL2SaveSys.string.AppendValues(str, true, -1)
			end
		end
		
		return str
	end,
	["nil"] = function(str, val)
		str = HL2SaveSys.string.AppendValues(str, "nil")
		
		return str
	end,
	["no value"] = function(str, val)
		str = HL2SaveSys.string.AppendValues(str, "no value")
		
		return str
	end,
	["number"] = function(str, val)
		str = HL2SaveSys.string.AppendValues(str, val)
		
		return str
	end,
	["string"] = function(str, val)
		str = HL2SaveSys.string.AppendValues(str, HL2SaveSys.string.LevelPush(tostring(val), 1, false))
		
		return str
	end,
	["vector"] = function(str, val)
		str = HL2SaveSys.string.AppendValues(str, val.x, val.y, val.z)
		
		return str
	end
}

HL2SaveSys_WriteTypeFuncs["player"] = HL2SaveSys_WriteTypeFuncs["entity"]
HL2SaveSys_WriteTypeFuncs["nextbot"] = HL2SaveSys_WriteTypeFuncs["entity"]
HL2SaveSys_WriteTypeFuncs["npc"] = HL2SaveSys_WriteTypeFuncs["entity"]

HL2SaveSys.string.WriteAngle = HL2SaveSys_WriteTypeFuncs["angle"]
HL2SaveSys.string.WriteBool = HL2SaveSys_WriteTypeFuncs["boolean"]
HL2SaveSys.string.WriteEntity = HL2SaveSys_WriteTypeFuncs["entity"]
HL2SaveSys.string.WriteNumber = HL2SaveSys_WriteTypeFuncs["number"]
HL2SaveSys.string.WriteString = HL2SaveSys_WriteTypeFuncs["string"]
HL2SaveSys.string.WriteVector = HL2SaveSys_WriteTypeFuncs["vector"]

local HL2SaveSys_ReadTypeFuncs = {
	["angle"] = function(str)
		local vals, str = HL2SaveSys.string.ReadValues(str, 3)
		
		return Angle(vals[1], vals[2], vals[3]), str
	end,
	["boolean"] = function(str)
		local vals, str = HL2SaveSys.string.ReadValues(str, 1)
		
		return tobool(vals[1]), str
	end,
	["entity"] = function(str)
		local vals, str = HL2SaveSys.string.ReadValues(str, 2)
		
		if (vals[2] == -1) then return NULL, str end
		
		local ent
		
		if (not vals[1]) then
			ent = ents.GetMapCreatedEntity(vals[2])
		elseif HL2SaveSys_Players[vals[2]] then
			ent = HL2SaveSys_Players[vals[2]]
		else
			ent = NULL
		end
		
		if (not ent:IsValid()) then return NULL, str end
		
		return ent, str
	end,
	["nil"] = function(str)
		local vals, str = HL2SaveSys.string.ReadValues(str, 1)
		
		return nil, str
	end,
	["no value"] = function(str)
		local vals, str = HL2SaveSys.string.ReadValues(str, 1)
		
		return nil, str
	end,
	["number"] = function(str)
		local vals, str = HL2SaveSys.string.ReadValues(str, 1)
		
		return tonumber(vals[1]), str
	end,
	["player"] = function(str)
		local vals, str = HL2SaveSys.string.ReadValues(str, 2)
		
		if (vals[2] == -1) then return NULL, str end
		
		local ent
		
		if (not vals[1]) then
			ent = ents.GetMapCreatedEntity(vals[2])
		elseif HL2SaveSys_Players[vals[2]] then
			ent = HL2SaveSys_Players[vals[2]]
		else
			ent = NULL
		end
		
		if (not ent:IsValid()) then return NULL, str end
		
		return ent, str
	end,
	["string"] = function(str)
		local vals, str = HL2SaveSys.string.ReadValues(str, 1)
		
		return HL2SaveSys.string.LevelPop(vals[1], 1), str
	end,
	["vector"] = function(str)
		local vals, str = HL2SaveSys.string.ReadValues(str, 3)
		
		return Vector(vals[1], vals[2], vals[3]), str
	end
}

HL2SaveSys_ReadTypeFuncs["player"] = HL2SaveSys_ReadTypeFuncs["entity"]
HL2SaveSys_ReadTypeFuncs["nextbot"] = HL2SaveSys_ReadTypeFuncs["entity"]
HL2SaveSys_ReadTypeFuncs["npc"] = HL2SaveSys_ReadTypeFuncs["entity"]

HL2SaveSys.string.ReadAngle = HL2SaveSys_ReadTypeFuncs["angle"]
HL2SaveSys.string.ReadBool = HL2SaveSys_ReadTypeFuncs["boolean"]
HL2SaveSys.string.ReadEntity = HL2SaveSys_ReadTypeFuncs["entity"]
HL2SaveSys.string.ReadNumber = HL2SaveSys_ReadTypeFuncs["number"]
HL2SaveSys.string.ReadString = HL2SaveSys_ReadTypeFuncs["string"]
HL2SaveSys.string.ReadVector = HL2SaveSys_ReadTypeFuncs["vector"]

local function HL2SaveSys_IsValidType_Old(value)
	local valType = string.lower(type(value))
	
	if HL2SaveSys_ValidTypes_Old[valType] then
		return true
	end
	
	return false
end

local function HL2SaveSys_WriteType_Old(str, value)
	local valType = string.lower(type(value))
	
	if (not HL2SaveSys_ValidTypes_Old[valType]) then
		local errInfo = debug.getinfo(0, "S")
		
		error("[ERROR] " .. errInfo.short_src .. ": Attempted to write an invalid type.")
		
		return
	end
	
	str = HL2SaveSys.string.AppendValues(str, HL2SaveSys.string.LevelPush(valType, 1, false))
	
	str = HL2SaveSys_WriteTypeFuncs[valType](str, value)
	
	return str
end

local function HL2SaveSys_ReadType_Old(str)
	local preValType, newStr = HL2SaveSys.string.ReadValues(str, 1)
	str = newStr
	local valType = HL2SaveSys.string.LevelPop(preValType[1], 1)
	
	if (not HL2SaveSys_ValidTypes_Old[valType]) then
		local errInfo = debug.getinfo(0, "S")
		
		error("[ERROR] " .. errInfo.short_src .. ": Attempted to read an invalid type.")
		
		return
	end
	
	local newVal, newStr = HL2SaveSys_ReadTypeFuncs[valType](str)
	str = newStr
	
	return newVal, str
end

HL2SaveSys.string.WriteTable = function(str, tab, excludedTabs, tree)
	if (not istable(tab)) then
		local errInfo = debug.getinfo(0, "S")
		
		error("[ERROR] " .. errInfo.short_src .. ": Attempted to write a non-table value as table.")
		
		return
	end
	
	if (not istable(excludedTabs)) then
		excludedTabs = {}
	end
	
	if (not istable(tree)) then
		tree = {}
	end
	
	excludedTabs[tab] = tree
	
	local newTab = {}
	local subTabs = {}
	local exclusions = {}
	local tabCount = 0
	local subTabsCount = 0
	local exclusionsCount = 0
	
	for k, v in pairs(tab) do
		local vIsTable = istable(v)
		
		if (HL2SaveSys_IsValidType_Old(k) and (HL2SaveSys_IsValidType_Old(v) or vIsTable)) then
			local proceed = true
			
			if (vIsTable and excludedTabs[v]) then
				proceed = false
			end
			
			if proceed then
				if (not vIsTable) then
					newTab[k] = v
					tabCount = tabCount + 1
				else
					subTabs[k] = v
					subTabsCount = subTabsCount + 1
				end
			else
				exclusions[k] = excludedTabs[v]
				exclusionsCount = exclusionsCount + 1
			end
		end
	end
	
	str = HL2SaveSys.string.AppendValues(str, tabCount)
	
	for k, v in pairs(newTab) do
		str = HL2SaveSys_WriteType_Old(str, k)
		str = HL2SaveSys_WriteType_Old(str, v)
	end
	
	str = HL2SaveSys.string.AppendValues(str, subTabsCount)
	
	for k, v in pairs(subTabs) do
		str = HL2SaveSys_WriteType_Old(str, k)
		
		table.insert(tree, (#tree + 1), k)
		
		str = HL2SaveSys.string.WriteTable(str, v, excludedTabs, tree)
		
		table.remove(tree, #tree)
	end
	
	str = HL2SaveSys.string.AppendValues(str, exclusionsCount)
	
	for k, v in pairs(exclusions) do
		str = HL2SaveSys_WriteType_Old(str, k)
		
		str = HL2SaveSys.string.AppendValues(str, #v)
		
		for i, j in ipairs(v) do
			str = HL2SaveSys_WriteType_Old(str, j)
		end
	end
	
	return str
end

HL2SaveSys.string.ReadTable = function(str, excludedTabs, tree)
	if (not istable(excludedTabs)) then
		excludedTabs = {}
	end
	
	if (not istable(tree)) then
		tree = {}
	end
	
	local newTab = {}
	
	local preTabCount, newStr = HL2SaveSys.string.ReadValues(str, 1)
	str = newStr
	local tabCount = tonumber(preTabCount[1])
	
	for i = 1, tabCount do
		local k, newStr = HL2SaveSys_ReadType_Old(str)
		str = newStr
		local v, newStr = HL2SaveSys_ReadType_Old(str)
		str = newStr
		
		newTab[k] = v
	end
	
	local preSubTabsCount, newStr = HL2SaveSys.string.ReadValues(str, 1)
	str = newStr
	local subTabsCount = tonumber(preSubTabsCount[1])
	
	for i = 1, subTabsCount do
		local k, newStr = HL2SaveSys_ReadType_Old(str)
		str = newStr
		
		table.insert(tree, (#tree + 1), k)
		
		local newVal, newStr = HL2SaveSys.string.ReadTable(str, excludedTabs, tree)
		str = newStr
		newTab[k] = newVal
		
		table.remove(tree, #tree)
	end
	
	local preExclusionsCount, newStr = HL2SaveSys.string.ReadValues(str, 1)
	str = newStr
	local exclusionsCount = tonumber(preExclusionsCount[1])
	
	for i = 1, exclusionsCount do
		local k, newStr = HL2SaveSys_ReadType_Old(str)
		str = newStr
		
		local preCount = HL2SaveSys.string.ReadValues(str, 1)
		str = newStr
		local count = tonumber(preCount[1])
		
		local oldTree = {}
		
		for j = 1, count do
			local k_old, newStr = HL2SaveSys_ReadType_Old(str)
			str = newStr
			
			table.insert(oldTree, (#oldTree + 1), k_old)
		end
		
		local newTree = {}
		
		for i, j in pairs(tree) do
			newTree[i] = j
		end
		
		table.insert(newTree, (#newTree + 1), k)
		
		table.insert(excludedTabs, (#excludedTabs + 1), {newTree, oldTree})
	end
	
	if (#tree <= 0) then
		for k, v in pairs(excludedTabs) do
			local newVal = newTab
			
			for i, j in ipairs(v[1]) do
				if (i < #v[1]) then
					newVal = newVal[j]
				else
					break
				end
			end
			
			local oldVal = newTab
			
			for i, j in ipairs(v[2]) do
				oldVal = oldVal[j]
			end
			
			newVal[ v[1][ #v[1] ] ] = oldVal
		end
	end
	
	return newTab, str
end

HL2SaveSys_WriteTypeFuncs["table"] = HL2SaveSys.string.WriteTable
HL2SaveSys_ReadTypeFuncs["table"] = HL2SaveSys.string.ReadTable

function HL2SaveSys.IsValidType(value)
	local valType = string.lower(type(value))
	
	if HL2SaveSys_ValidTypes[valType] then
		return true
	end
	
	return false
end

function HL2SaveSys.string.WriteType(str, value)
	local valType = string.lower(type(value))
	
	if (not HL2SaveSys_ValidTypes[valType]) then
		local errInfo = debug.getinfo(0, "S")
		
		error("[ERROR] " .. errInfo.short_src .. ": Attempted to write an invalid type.")
		
		return
	end
	
	str = HL2SaveSys.string.AppendValues(str, HL2SaveSys.string.LevelPush(valType, 1, false))
	
	str = HL2SaveSys_WriteTypeFuncs[valType](str, value)
	
	return str
end

function HL2SaveSys.string.ReadType(str)
	local preValType, newStr = HL2SaveSys.string.ReadValues(str, 1)
	str = newStr
	local valType = HL2SaveSys.string.LevelPop(preValType[1], 1)
	
	if (not HL2SaveSys_ValidTypes[valType]) then
		local errInfo = debug.getinfo(0, "S")
		
		error("[ERROR] " .. errInfo.short_src .. ": Attempted to read an invalid type.")
		
		return
	end
	
	local newVal, newStr = HL2SaveSys_ReadTypeFuncs[valType](str)
	str = newStr
	
	return newVal, str
end

local HL2SaveSys_ClassBlacklist = {
	["env_projectedtexture"] = {
		["hl2_save_system"] = function(ent)
			if ent:GetNWBool("TPF_IsFlashlight", false) then
				return true
			end
			
			return false
		end
	},
}

local HL2SaveSys_Version = 1.2
local HL2SaveSys_VersionAtSave = HL2SaveSys_Version
local HL2SaveSys_CanSetPos = true

local EntNWVarTables = {}

local ENT_META = FindMetaTable("Entity")

if ENT_META then
	local HL2SaveSys_SetPos_Old = ENT_META.SetPos
	local HL2SaveSys_SetPos = HL2SaveSys_SetPos_Old
	
	ENT_META.SetPos = function(self, pos, ...)
		if ((not self:IsValid()) or (not self:IsPlayer())) then return HL2SaveSys_SetPos(self, pos, ...) end
		
		if HL2SaveSys_CanSetPos then
			return HL2SaveSys_SetPos(self, pos, ...)
		end
	end
	
	ENT_META.HL2SaveSys_SetPos_Override = function(self, pos, ...)
		return HL2SaveSys_SetPos(self, pos, ...)
	end
	
	local HL2SaveSys_SetNWAngle_Old = ENT_META.SetNWAngle
	local HL2SaveSys_SetNWAngle = HL2SaveSys_SetNWAngle_Old
	
	ENT_META.SetNWAngle = function(self, key, value, ...)
		local keyType = string.lower(type(key))
		local valType = string.lower(type(value))
		
		if ((keyType == "string") and HL2SaveSys_SetNWVarFuncs[valType]) then
			if (not EntNWVarTables[self]) then
				EntNWVarTables[self] = {}
			end
			
			EntNWVarTables[self][key] = value
		end
		
		return HL2SaveSys_SetNWAngle(self, key, value, ...)
	end
	
	local HL2SaveSys_SetNWBool_Old = ENT_META.SetNWBool
	local HL2SaveSys_SetNWBool = HL2SaveSys_SetNWBool_Old
	
	ENT_META.SetNWBool = function(self, key, value, ...)
		local keyType = string.lower(type(key))
		local valType = string.lower(type(value))
		
		if ((keyType == "string") and HL2SaveSys_SetNWVarFuncs[valType]) then
			if (not EntNWVarTables[self]) then
				EntNWVarTables[self] = {}
			end
			
			EntNWVarTables[self][key] = value
		end
		
		return HL2SaveSys_SetNWBool(self, key, value, ...)
	end
	
	local HL2SaveSys_SetNWEntity_Old = ENT_META.SetNWEntity
	local HL2SaveSys_SetNWEntity = HL2SaveSys_SetNWEntity_Old
	
	ENT_META.SetNWEntity = function(self, key, value, ...)
		local keyType = string.lower(type(key))
		local valType = string.lower(type(value))
		
		if ((keyType == "string") and HL2SaveSys_SetNWVarFuncs[valType]) then
			if (not EntNWVarTables[self]) then
				EntNWVarTables[self] = {}
			end
			
			EntNWVarTables[self][key] = value
		end
		
		return HL2SaveSys_SetNWEntity(self, key, value, ...)
	end
	
	local HL2SaveSys_SetNWFloat_Old = ENT_META.SetNWFloat
	local HL2SaveSys_SetNWFloat = HL2SaveSys_SetNWFloat_Old
	
	ENT_META.SetNWFloat = function(self, key, value, ...)
		local keyType = string.lower(type(key))
		local valType = string.lower(type(value))
		
		if ((keyType == "string") and HL2SaveSys_SetNWVarFuncs[valType]) then
			if (not EntNWVarTables[self]) then
				EntNWVarTables[self] = {}
			end
			
			EntNWVarTables[self][key] = value
		end
		
		return HL2SaveSys_SetNWFloat(self, key, value, ...)
	end
	
	local HL2SaveSys_SetNWInt_Old = ENT_META.SetNWInt
	local HL2SaveSys_SetNWInt = HL2SaveSys_SetNWInt_Old
	
	ENT_META.SetNWInt = function(self, key, value, ...)
		local keyType = string.lower(type(key))
		local valType = string.lower(type(value))
		
		if ((keyType == "string") and HL2SaveSys_SetNWVarFuncs[valType]) then
			if (not EntNWVarTables[self]) then
				EntNWVarTables[self] = {}
			end
			
			EntNWVarTables[self][key] = value
		end
		
		return HL2SaveSys_SetNWInt(self, key, value, ...)
	end
	
	local HL2SaveSys_SetNWString_Old = ENT_META.SetNWString
	local HL2SaveSys_SetNWString = HL2SaveSys_SetNWString_Old
	
	ENT_META.SetNWString = function(self, key, value, ...)
		local keyType = string.lower(type(key))
		local valType = string.lower(type(value))
		
		if ((keyType == "string") and HL2SaveSys_SetNWVarFuncs[valType]) then
			if (not EntNWVarTables[self]) then
				EntNWVarTables[self] = {}
			end
			
			EntNWVarTables[self][key] = value
		end
		
		return HL2SaveSys_SetNWString(self, key, value, ...)
	end
	
	local HL2SaveSys_SetNWVector_Old = ENT_META.SetNWVector
	local HL2SaveSys_SetNWVector = HL2SaveSys_SetNWVector_Old
	
	ENT_META.SetNWVector = function(self, key, value, ...)
		local keyType = string.lower(type(key))
		local valType = string.lower(type(value))
		
		if ((keyType == "string") and HL2SaveSys_SetNWVarFuncs[valType]) then
			if (not EntNWVarTables[self]) then
				EntNWVarTables[self] = {}
			end
			
			EntNWVarTables[self][key] = value
		end
		
		return HL2SaveSys_SetNWVector(self, key, value, ...)
	end
end

net.Receive("HL2SaveSys_SendNWVar", function()
	local self = net.ReadEntity()
	local key = net.ReadString()
	local value = net.ReadType()
	
	if self:IsValid() then
		local keyType = string.lower(type(key))
		local valType = string.lower(type(value))
		
		if ((keyType == "string") and HL2SaveSys_SetNWVarFuncs[valType]) then
			if (not EntNWVarTables[self]) then
				EntNWVarTables[self] = {}
			end
			
			EntNWVarTables[self][key] = value
		end
	end
end)

function HL2SaveSys.GetVersion()
	return (HL2SaveSys_Version + 0)
end

function HL2SaveSys.GetVersionAtSave()
	return (HL2SaveSys_VersionAtSave + 0)
end

function HL2SaveSys.SelectFromVersion(tab, version)
	local value
	
	for k, v in ipairs(tab) do
		if (value == nil) then
			if isnumber(v[2]) then
				if (v[2] >= version) then
					value = v[1]
					
					break
				elseif (k >= #tab) then
					value = v[1]
					
					break
				end
			elseif (TypeID(v[2]) == TypeID(version)) then
				if (v[2] == version) then
					value = v[1]
					
					break
				end
			end
		else
			break
		end
	end
	
	if (value == nil) then
		value = function() end
	end
	
	return value
end

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

local HL2SaveSys_CanSpawn = false

local HL2SaveSys_LoadedPlayerData
local HL2SaveSys_SavedPlayerData = {}
local HL2SaveSys_CrouchingPlayers = {}
local HL2SaveSys_Filename
local HL2SaveSys_ShouldInitialize = false

local function SaveGame(save)
	local map = game.GetMap()
	
	local allEnts = ents.GetAll()
	
	local shouldWriteFile = (GetConVarNumber("HL2SaveSys_saveLuaTables") != 0)
	local filename
	
	if shouldWriteFile then
		if (not file.IsDir("hl2_save_system", "DATA")) then
			file.CreateDir("hl2_save_system")
		end
		
		local files, dirs = file.Find("data/hl2_save_system/*.txt", "GAME")
		local occupiedIDs = {}
		
		for k, v in ipairs(files) do
			if (not dirs[k]) then
				dirs[k] = "data/hl2_save_system"
			end
			
			if (dirs[k] == "data/hl2_save_system") then
				local fullMatch = {string.match(v, (string.PatternSafe(map) .. "__%d+%.txt$"), 1)}
				
				fullMatch = fullMatch[1]
				
				if fullMatch then
					local newMatch = {string.match(fullMatch, "%d+%.txt$", 1)}
					
					newMatch = newMatch[1]
					
					if newMatch then
						newMatch = string.TrimRight(newMatch, ".txt")
						
						local id = tonumber(newMatch)
						
						if id then
							occupiedIDs[id] = true
						end
					end
				end
			end
		end
		
		local fileID = 1
		local foundID = false
		
		while (not foundID) do
			if (not occupiedIDs[fileID]) then
				foundID = true
			else
				fileID = fileID + 1
			end
		end
		
		filename = "hl2_save_system/" .. map .. "__" .. tostring(fileID) .. ".txt"
		
		local fileString = ""
		
		fileString = HL2SaveSys.string.WriteNumber(fileString, #allEnts)
		
		for k, v in ipairs(allEnts) do
			fileString = HL2SaveSys.string.WriteEntity(fileString, v)
			fileString = HL2SaveSys.string.WriteTable(fileString, v:GetTable())
			
			if EntNWVarTables[v] then
				fileString = HL2SaveSys.string.WriteTable(fileString, EntNWVarTables[v])
			else
				fileString = HL2SaveSys.string.WriteTable(fileString, {})
			end
		end
		
		file.Write(filename, fileString)
	end
	
	save:StartBlock("HL2SaveSys")
	
	save:StartBlock("Version")
	
	save:WriteFloat(HL2SaveSys_Version)
	
	save:EndBlock()
	
	save:StartBlock("Filename")
	
	if shouldWriteFile then
		save:WriteBool(true)
		save:WriteString(filename)
	else
		save:WriteBool(false)
	end
	
	save:EndBlock()
	
	if (GetConVarNumber("HL2SaveSys_saveSpawnData") != 0) then
		save:WriteBool(true)
		
		local playerTable = HL2SaveSys_SavedPlayerData
		
		save:WriteString(map)
		
		local entTables = {}
		local excludedEnts = {}
		
		for k, v in ipairs(allEnts) do
			if (v:IsValid() or v:IsWorld()) then
				if ((not v:IsWorld()) and (not v:IsPlayer())) then
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
							table.insert(excludedEnts, (#excludedEnts + 1), v)
						end
					end
				end
			end
		end
		
		save:StartBlock("ExcludedEnts")
		
		save:WriteInt(#excludedEnts)
		
		for k, v in ipairs(excludedEnts) do
			save:StartBlock("ExcludedEnt_" .. k)
			
			save:WriteEntity(v)
			
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
	else
		save:WriteBool(false)
	end
	
	save:EndBlock()
end

local function InitPostEntity()
	if (not HL2SaveSys_ShouldInitialize) then return end
	if (not HL2SaveSys_Filename) then return end
	if (not file.Exists(HL2SaveSys_Filename, "DATA")) then return end
	
	local fileString = file.Read(HL2SaveSys_Filename, "DATA")
	
	if fileString then
		local tabCount, newFileString = HL2SaveSys.string.ReadNumber(fileString)
		fileString = newFileString
		
		for i = 1, tabCount do
			local ent, newFileString = HL2SaveSys.string.ReadEntity(fileString)
			fileString = newFileString
			local entTable, newFileString = HL2SaveSys.string.ReadTable(fileString)
			fileString = newFileString
			local entNWVars, newFileString = HL2SaveSys.string.ReadTable(fileString)
			fileString = newFileString
			
			if (ent:IsValid() or ent:IsWorld()) then
				ent:SetTable(table.Merge(ent:GetTable(), entTable))
				
				for k, v in pairs(entNWVars) do
					HL2SaveSys.SetNWVar(ent, k, v)
				end
			end
		end
	end
	
	HL2SaveSys_Filename = nil
end

local function RestoreGame(save)
	local name = save:StartBlock()
	
	if (name == "HL2SaveSys") then
		save:StartBlock()
		
		local version = save:ReadFloat()
		
		if isnumber(version) then
			HL2SaveSys_VersionAtSave = version
		else
			HL2SaveSys_VersionAtSave = nil
		end
		
		save:EndBlock()
		
		save:StartBlock()
		
		local shouldReadFile = save:ReadBool()
		
		if shouldReadFile then
			HL2SaveSys_Filename = save:ReadString()
		end
		
		save:EndBlock()
		
		HL2SaveSys_ShouldInitialize = true
		
		local overrideSpawning = save:ReadBool()
		
		if overrideSpawning then
			HL2SaveSys_CanSetPos = false
			
			local playerTable = {}
			
			playerTable.Map = save:ReadString()
			
			local excludedEnts = {}
			
			save:StartBlock()
			
			local excludedEntCount = save:ReadInt()
			
			for i = 1, excludedEntCount do
				save:StartBlock()
				
				local entity = save:ReadEntity()
				
				save:EndBlock()
				
				if entity:IsValid() then
					entity:Remove()
				end
			end
			
			save:EndBlock()
			
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
	end
	
	save:EndBlock()
end

local function PlayerInitialSpawn(ply)
	local index = 1
	local foundID = false
	
	while (not foundID) do
		if (not HL2SaveSys_Players[index]) then
			HL2SaveSys_Players[index] = ply
			HL2SaveSys_Players[ply] = index
			
			foundID = true
		else
			index = index + 1
		end
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
		HL2SaveSys_CanSetPos = true
		
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
		end
		
		HL2SaveSys_CanSpawn = false
	end
	
	for k, v in pairs(EntNWVarTables) do
		if (not k:IsValid()) then
			EntNWVarTables[k] = nil
		end
	end
	
	local itemsToDelete = {}
	
	for k, v in pairs(HL2SaveSys_Players) do
		if isnumber(k) then
			if (not v:IsValid()) then
				itemsToDelete[k] = true
				itemsToDelete[v] = true
			end
		end
	end
	
	for k, v in pairs(itemsToDelete) do
		HL2SaveSys_Players[k] = nil
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

local function Restored()
	HL2SaveSys_CanSpawn = true
end

saverestore.AddSaveHook("HL2SaveSys_Save", SaveGame)
saverestore.AddRestoreHook("HL2SaveSys_Save", RestoreGame)

hook.Add("InitPostEntity", "HL2SaveSys_InitPostEntity", InitPostEntity)
hook.Add("PlayerInitialSpawn", "HL2SaveSys_PlayerInitialSpawn", PlayerInitialSpawn)
hook.Add("PlayerPostThink", "HL2SaveSys_PlayerPostThink", PlayerPostThink)
hook.Add("Think", "HL2SaveSys_Think", Think)
hook.Add("PlayerTick", "HL2SaveSys_PlayerTick", PlayerTick)
hook.Add("VehicleMove", "HL2SaveSys_VehicleMove", VehicleMove)
hook.Add("PlayerSwitchWeapon", "HL2SaveSys_PlayerSwitchWeapon", PlayerSwitchWeapon)
hook.Add("Restored", "HL2SaveSys_Restored", Restored)
