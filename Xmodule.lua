--[[
	 ___    ___ _____ ______   ________  ________  ___  ___  ___       _______      
	|\  \  /  /|\   _ \  _   \|\   __  \|\   ___ \|\  \|\  \|\  \     |\  ___ \     
	\ \  \/  / | \  \\\__\ \  \ \  \|\  \ \  \_|\ \ \  \\\  \ \  \    \ \   __/|    
	 \ \    / / \ \  \\|__| \  \ \  \\\  \ \  \ \\ \ \  \\\  \ \  \    \ \  \_|/__  
	  /     \/   \ \  \    \ \  \ \  \\\  \ \  \_\\ \ \  \\\  \ \  \____\ \  \_|\ \ 
	 /  /\   \    \ \__\    \ \__\ \_______\ \_______\ \_______\ \_______\ \_______\
	/__/ /\ __\    \|__|     \|__|\|_______|\|_______|\|_______|\|_______|\|_______|
	|__|/ \|__|

	Version: 1.0.2
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

	Functions:
		Initialization Commands:
			Modules.Xmodule.createModule(String: ModuleName): Creates a Module. If it already exist, nothing happens.
			Modules.Xmodule.deleteModule(String: ModuleName): Deletes a Module. If it does not exist, nothing happens.

		For Module Scripts:
			Modules.Xmodule.{YOUR_MODULE_NAME}.add(Any: funcOrVar, String: elementName): Adds a function or variable with the specified 
			name that can be accessed or called by another script.
			Modules.Xmodule.{YOUR_MODULE_NAME}.del(String: elementName): Deletes the function or variable with the specified name from 
			the module. 

		For Scripts:
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

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local event = ReplicatedStorage:FindFirstChild("Xmodule")
local StarterGui = game:GetService("StarterGui")

--Create Xmodule Event
if event == nil then
	event = Instance.new("BindableEvent", ReplicatedStorage)
	event.Name = "Xmodule"
end

function Modules.Xmodule.createModule(ModuleName)
	event:Fire("Modules.Xmodule.createModule(" .. ModuleName .. ")")
	local ok, moduleName = pcall(tostring, ModuleName)
	if not ok or moduleName == nil then return end

	if Modules[moduleName] == nil then
		Modules[moduleName] = {}
		Modules.Xmodule[moduleName] = {}

		local moduleConfig = Modules.Xmodule[moduleName]

		function moduleConfig.add(funcOrVar, elementName)
			print("Modules.Xmodule." .. moduleName .. "." .. "add(" .. funcOrVar .. ", " .. elementName .. ")")
			event:Fire("Modules.Xmodule." .. moduleName .. "." .. "add(" .. funcOrVar .. ", " .. elementName .. ")")
			local ok2, name = pcall(tostring, elementName)
			if not ok2 or name == nil then return end
			Modules[moduleName][name] = funcOrVar
		end

		function moduleConfig.del(elementName)
			event:Fire("Modules.Xmodule." .. moduleName .. "." .. "del(" .. elementName .. ")")
			local ok2, Name = pcall(tostring, elementName)
			if not ok2 or Name == nil then return end
			Modules[moduleName][Name] = nil
		end

		function moduleConfig.ren(elementName, newName)
			event:Fire("Modules.Xmodule." .. moduleName .. "." .. "ren(" .. elementName .. ", " .. newName .. ")")
			local ok2, oldName = pcall(tostring, elementName)
			if not ok2 or oldName == nil then return end

			local ok3, newNameFixed = pcall(tostring, newName)
			if not ok3 or newNameFixed == nil then return end

			if Modules[moduleName][oldName] == nil then return end
			if Modules[moduleName][newNameFixed] ~= nil then return end

			Modules[moduleName][newNameFixed] = Modules[moduleName][oldName]
			Modules[moduleName][oldName] = nil
		end

		function moduleConfig.duplicate(elementName, newName)
			event:Fire("Modules.Xmodule." .. moduleName .. "." .. "duplicate(" .. elementName .. ", " .. newName .. ")")
			local ok2, oldName = pcall(tostring, elementName)
			if not ok2 or oldName == nil then return end

			local ok3, newNameFixed = pcall(tostring, newName)
			if not ok3 or newNameFixed == nil then newNameFixed = oldName .. "Copy" end

			if Modules[moduleName][oldName] == nil then return end
			if Modules[moduleName][newNameFixed] ~= nil then return end

			Modules[moduleName][newNameFixed] = Modules[moduleName][oldName]
		end

		setmetatable(Modules[moduleName], {
			__index = function(t, key)
				local val = rawget(t, key)
				if type(val) == "function" then
					return val
				end

				return val
			end
		})
	end
end

function Modules.Xmodule.deleteModule(ModuleName)
	event:Fire("Modules.Xmodule.deleteModule(" .. ModuleName .. ")")
	local ok, name = pcall(tostring, ModuleName)
	if not ok or name == nil then return end
	if Modules[name] == nil then return end
	Modules[name] = nil
	Modules.Xmodule[name] = nil
end

event.Event:Connect(function(command)
	pcall(function() loadstring(command) end)
end)

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
