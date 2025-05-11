--[[
	 ___    ___ _____ ______   ________  ________  ___  ___  ___       _______      
	|\  \  /  /|\   _ \  _   \|\   __  \|\   ___ \|\  \|\  \|\  \     |\  ___ \     
	\ \  \/  / | \  \\\__\ \  \ \  \|\  \ \  \_|\ \ \  \\\  \ \  \    \ \   __/|    
	 \ \    / / \ \  \\|__| \  \ \  \\\  \ \  \ \\ \ \  \\\  \ \  \    \ \  \_|/__  
	  /     \/   \ \  \    \ \  \ \  \\\  \ \  \_\\ \ \  \\\  \ \  \____\ \  \_|\ \ 
	 /  /\   \    \ \__\    \ \__\ \_______\ \_______\ \_______\ \_______\ \_______\
	/__/ /\ __\    \|__|     \|__|\|_______|\|_______|\|_______|\|_______|\|_______|
	|__|/ \|__|

	Version: 1.0.1
	Author: Haecker

	Description:
		Executable script that allows you to use “Modules”. Module scripts like Xfile create their own modules, 
		and regular scripts can contact them and call different commands.
		WARNING: DO NOT PASTE THIS CODE INTO ROBLOX STUDIO ELSE YOU WILL BE BANNED!
		Yeah, my twink and main Account banned by theese mothe####kers.

	Change Log:
		1.0.0: First Version. Fixed: ...Nothing. Yeah, like Gui - API.
		1.0.1: Tested and fixed some Bugs like "attempt to index 'nil'"

	Functions:
		Initialization Commands:
			Modules.Xmodule.createModule(String: ModuleName): Creates a Module. If it already exist, nothing happens.
			Modules.Xmodule.deleteModule(String: ModuleName): Deletes a Module. If it does not exist, nothing happens.

		For Module Scripts:
			Modules.Xmodule.{YOUR_MODULE_NAME}.add(Any: funcOrVar, String: elementName): Adds a function or variable with the specified name that can be accessed or called by another script.
			Modules.Xmodule.{YOUR_MODULE_NAME}.del(String: elementName): Deletes the function or variable with the specified name from the module. 

		For Scripts:
			Modules.{YOUR_MODULE_NAME}.{YOUR_FUNC_NAME}(): Calls the specified function. If it does not exist, nothing happens.
			Modules.{YOUR_MODULE_NAME}.{YOUR_VAR_NAME}: Returns the value of the {YOUR_VAR_NAME} variable. If it does not exist, nil returns.
]]

_G.Modules = _G.Modules or {}
_G.Modules.Xmodule = _G.Modules.Xmodule or {}

local Modules = _G.Modules

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local event = ReplicatedStorage:FindFirstChild("Xmodule")

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
			
			print(elementName)
			print(moduleName)
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
