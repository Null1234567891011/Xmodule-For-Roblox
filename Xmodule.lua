--[[
	 ___    ___ _____ ______   ________  ________  ___  ___  ___       _______      
	|\  \  /  /|\   _ \  _   \|\   __  \|\   ___ \|\  \|\  \|\  \     |\  ___ \     
	\ \  \/  / | \  \\\__\ \  \ \  \|\  \ \  \_|\ \ \  \\\  \ \  \    \ \   __/|    
	 \ \    / / \ \  \\|__| \  \ \  \\\  \ \  \ \\ \ \  \\\  \ \  \    \ \  \_|/__  
	  /     \/   \ \  \    \ \  \ \  \\\  \ \  \_\\ \ \  \\\  \ \  \____\ \  \_|\ \ 
	 /  /\   \    \ \__\    \ \__\ \_______\ \_______\ \_______\ \_______\ \_______\
	/__/ /\ __\    \|__|     \|__|\|_______|\|_______|\|_______|\|_______|\|_______|
	|__|/ \|__|

	Version: 1.0.3
	Author: Haecker

	Description:
		Executable script that allows you to use “Modules”. Module scripts like Xfile create their own modules, 
		and regular scripts can contact them and call different commands.

	Change Log:
		1.0.0: First Version. Fixed: ...Nothing.
		1.0.1: Tested and fixed some Bugs like "attempt to index 'nil'"
		1.0.2: Built-in modules have been added, with Xpack and Xfile on the list.
				Xpack: allows you to turn Instances into Xpacks. This is useful if you need to copy the game map to your game, copy 
				models, etc.
				
				Xfile: allows you to manage files and folders — create, modify, or delete them as needed. Not all exploits 
				support Xfile, if they do, Xfile will report that your exploit does not support the file system.
		1.0.3: The mechanics of how modules work have been updated. Xmodule now actually creates module scripts, rather than imitating 
			   them. It works simply:
			   
				function createModule creates a module that consists of add, del, ren, duplicate, replace and the module itself 
				where your functions and variables are stored. Xmodule simply returns the module itself and the tools to modify it 
				without affecting Source.

	Functions:
		Initialization Commands:
			Modules.Xmodule.createModule(String: ModuleName): Creates a Module. If it already exist, nothing happens.
			Modules.Xmodule.deleteModule(String: ModuleName): Deletes a Module. If it does not exist, nothing happens.

		For scripts that create modules:
			Modules.Xmodule.{YOUR_MODULE_NAME}.add(Any: element, String: elementName): Adds a function or variable with the specified 
			name that can be accessed or called by another script, only if the name does not already exist in the module.
			Modules.Xmodule.{YOUR_MODULE_NAME}.del(String: elementName): Deletes the function or variable with the specified name from 
			the module.
			Modules.Xmodule.{YOUR_MODULE_NAME}.ren(String: elementName, String: newName): Renames an existing function or variable 
			from elementName to newName, only if elementName exists and newName does not exist in the module.
			Modules.Xmodule.{YOUR_MODULE_NAME}.duplicate(String: elementName, String?: newName): Creates a duplicate of the specified element. 
			If newName is provided and not taken, duplicates under newName; otherwise, duplicates under a generated name like 
			elementNameDuplicate1, elementNameDuplicate2, etc.
			Modules.Xmodule.{YOUR_MODULE_NAME}.replace(String: elementName, Any: newElement): Replaces the existing element with elementName 
			by newElement, only if elementName exists in the module.

		For Users:
			Modules.{YOUR_MODULE_NAME}.{YOUR_FUNC_NAME}(): Calls the specified function. If it does not exist, nothing happens.
			Modules.{YOUR_MODULE_NAME}.{YOUR_VAR_NAME}: Returns the value of the {YOUR_VAR_NAME} variable. If it does not exist, 
			nil returns.
			
		Built-in Modules:
			Xpack:
				packToXpackObjectWithIncludes(obj): Packs a single object into an Xpack object with all its descendants. To unpack, use 
				the unpackXpackObject command.
				packToXpackObject(obj): Packs a single object into an Xpack object without its descendants. To unpack, use the 
				unpackXpackObject command.
				packToXpack(objs): Packs objects into an Xpack object without its descendants. To pack the object(s) use the 
				{Instance1, Instance2...} argument. To unpack use the unpackXpack command.
				packToXpackWithIncludes(objs): Packs objects into an Xpack object with its descendants. To pack the object(s) use 
				the {Instance1, Instance2...} argument. To unpack use the unpackXpack command.
				unpackXpack(Xpack, destination): Extracts the entire Xpack by moving it to destination.
				unpackXpackObject(Xpack, destination): Extracts an Xpack Object in its entirety, moving it to destination.
			Xfile:
				writeFile(path, content): Overwrites the path file with content.
				readFile(path): Returns the contents of the path file.
				isFile(path): Returns true or false checking if path is a file.
				isFolder(path): Returns true or false checking if path is a folder.
				makeFolder(path): Creates a folder with the path as the path argument.
				delFile(path): Deletes the file at the path as at the path argument.
]]

_G.Modules = _G.Modules or {}
_G.Modules.Xmodule = _G.Modules.Xmodule or {}

local Modules = _G.Modules

local RepSt = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

function Modules.Xmodule.createModule(ModuleName)
	local ok, ModuleName = pcall(tostring, ModuleName)
	if not ok or ModuleName == nil then return end

	if Modules[ModuleName] == nil and not RepSt:FindFirstChild(ModuleName) then
		local ModuleScript = Instance.new("ModuleScript", ModuleName)
		ModuleScript.Name = ModuleName
		ModuleScript.Source = 'local module = {} local tools = {["add"] = function(element, elementName) if elementName ~= nil and typeof(elementName) == "string" and module[elementName] == nil then module[elementName] = element end end, ["del"] = function(elementName) if elementName ~= nil and typeof(elementName) == "string" then module[elementName] = nil end end, ["ren"] = function(elementName, newName) if elementName ~= nil and typeof(elementName) == "string" and module[elementName] ~= nil and module[newName] == nil and newName ~= nil and typeof(newName) == "string" then module[newName] = module[elementName] module[elementName] = nil end end, ["duplicate"] = function(elementName, newName) if elementName ~= nil and typeof(elementName) == "string" and module[elementName] ~= nil and module[newName] == nil and newName ~= nil and typeof(newName) == "string" then module[newName] = module[elementName] elseif elementName ~= nil and typeof(elementName) == "string" and module[elementName] ~= nil then local i = 1 while module[elementName .. "Duplucate" .. tostring(i)] do i += 1 end module[elementName .. "Duplucate" .. tostring(i)] = module[elementName] end end, ["replace"] = function(elementName, newElement) if elementName ~= nil and typeof(elementName) == "string" and module[elementName] ~= nil then module[elementName] = newElement end end} return {module, tools}'
		Modules[ModuleName] = {}
		Modules.Xmodule[ModuleName] = require(ModuleScript)[1]
	end
end

function Modules.Xmodule.deleteModule(ModuleName)
	local ok, ModuleName = pcall(tostring, ModuleName)
	if not ok or ModuleName == nil then return end

	local ModuleScript = RepSt:FindFirstChild(ModuleName)
	if ModuleScript then
		ModuleScript:Destroy()
		Modules[ModuleName] = {}
	end
end

-- Built-in Modules:

-- Xpack
local function SpawnIncludes(Includes, destination)
	for _, XpackObj in pairs(Includes) do
		local obj = Instance.new(XpackObj["ClassName"], destination)
		for key, val in pairs(XpackObj) do
			if key ~= "Includes" then
				pcall(function()
					obj[key] = val
				end)
			else
				SpawnIncludes(val, obj)
			end
		end
	end
end

local function packIncludes(objWithIncludes, XpackObj)
	XpackObj["Includes"] = {}
	for i, Include in pairs(objWithIncludes:GetChildren()) do
		XpackObj["Includes"][i] = {}
		for key, val in pairs(getproperties(Include)) do
			if key ~= "Parent" then
				XpackObj["Includes"][i][key] = val
			end
		end
		packIncludes(Include, XpackObj["Includes"][i])
	end
end

local function packToXpackObjectWithIncludes(objWithIncludes)
	local XpackObj = {}
	if objWithIncludes:IsA("Instance") then
		XpackObj["ClassName"] = objWithIncludes.ClassName
		for key, val in pairs(getproperties(objWithIncludes)) do
			if key ~= "Parent" then
				XpackObj[key] = val
			end
		end
		packIncludes(objWithIncludes, XpackObj)
	end
	return XpackObj
end

local function packToXpackObject(obj)
	local XpackObj = {}
	if obj:IsA("Instance") then
		XpackObj["ClassName"] = obj.ClassName
		for key, val in pairs(getproperties(obj)) do
			if key ~= "Parent" then
				XpackObj[key] = val
			end
		end
	end
	return XpackObj
end

local function packToXpack(objs)
	local Xpack = {}
	for i, objWithIncludes in pairs(objs) do
		Xpack[i] = packToXpackObject(objWithIncludes)
	end
	return Xpack
end

local function packToXpackWithIncludes(objsWithIncludes)
	local Xpack = {}
	for i, objWithIncludes in pairs(objsWithIncludes) do
		Xpack[i] = packToXpackObjectWithIncludes(objWithIncludes)
	end
	return Xpack
end

local function unpackXpack(Xpack, destination)
	for _, XpackObj in pairs(Xpack) do
		local obj = Instance.new(XpackObj["ClassName"], destination)
		for key, val in pairs(XpackObj) do
			if key ~= "Includes" then
				pcall(function()
					obj[key] = val
				end)
			else
				SpawnIncludes(val, obj)
			end
		end
	end
end

local function unpackXpackObject(XpackObj, destination)
	local obj = Instance.new(XpackObj["ClassName"], destination)
	for key, val in pairs(XpackObj) do
		if key ~= "Includes" then
			pcall(function()
				obj[key] = val
			end)
		else
			SpawnIncludes(val, obj)
		end
	end
end

Modules.Xmodule.createModule("Xpack")
Modules.Xmodule.Xpack.add(packToXpack, "packToXpack")
Modules.Xmodule.Xpack.add(packToXpackWithIncludes, "packToXpackWithIncludes")
Modules.Xmodule.Xpack.add(packToXpackObject, "packToXpackObject")
Modules.Xmodule.Xpack.add(packToXpackObjectWithIncludes, "packToXpackObjectWithIncludes")
Modules.Xmodule.Xpack.add(unpackXpack, "unpackXpack")
Modules.Xmodule.Xpack.add(unpackXpackObject, "unpackXpackObject")

-- Xfile
Modules.Xmodule.createModule("Xfile")
Modules.Xmodule.Xfile.add(function(path, content)
	if writefile then
		writefile(path, content)
	else
		StarterGui:SetCore("SendMessage", {
			Title = "Xfile",
			Message = "Your Exploit doesn't support File System.",
			Button1 = "OK",
			Duration = 5
		})
	end
end, "writeFile")

Modules.Xmodule.Xfile.add(function(path)
	if readfile then
		return readfile(path)
	else
		StarterGui:SetCore("SendMessage", {
			Title = "Xfile",
			Message = "Your Exploit doesn't support File System.",
			Button1 = "OK",
			Duration = 5
		})
		return ""
	end
end, "readFile")

Modules.Xmodule.Xfile.add(function(path)
	if isfile then
		return isfile(path)
	else
		StarterGui:SetCore("SendMessage", {
			Title = "Xfile",
			Message = "Your Exploit doesn't support File System.",
			Button1 = "OK",
			Duration = 5
		})
		return ""
	end
end, "isFile")

Modules.Xmodule.Xfile.add(function(path)
	if isfolder then
		return isfolder(path)
	else
		StarterGui:SetCore("SendMessage", {
			Title = "Xfile",
			Message = "Your Exploit doesn't support File System.",
			Button1 = "OK",
			Duration = 5
		})
		return ""
	end
end, "isFolder")

Modules.Xmodule.Xfile.add(function(path)
	if makefolder then
		makefolder(path)
	else
		StarterGui:SetCore("SendMessage", {
			Title = "Xfile",
			Message = "Your Exploit doesn't support File System.",
			Button1 = "OK",
			Duration = 5
		})
	end
end, "makeFolder")

Modules.Xmodule.Xfile.add(function(path)
	if delfile then
		delfile(path)
	else
		StarterGui:SetCore("SendMessage", {
			Title = "Xfile",
			Message = "Your Exploit doesn't support File System.",
			Button1 = "OK",
			Duration = 5
		})
	end
end, "delFile")

-- Update Modules
while wait() do
	for ModuleName, _ in pairs(Modules) do
		if ModuleName ~= "Xmodule" then
			Modules[ModuleName] = require(RepSt:FindFirstChild(ModuleName))[2] or Modules[ModuleName]
		end
		wait()
	end
end
