--Example for Module Script
loadstring(game:HttpGet("https://raw.githubusercontent.com/Null1234567891011/Xmodule/refs/heads/main/Xmodule.lua")) Modules=_G.Modules

Modules.Xmodule.createModule("HelloWorld")

local function printHW()
  print("Hello, World!")
end

Modules.Xmodule.HelloWorld.add(printHW, "MyFunctionName")

--Example for Script
loadstring(game:HttpGet("https://raw.githubusercontent.com/Null1234567891011/Xmodule/refs/heads/main/Xmodule.lua")) Modules=_G.Modules

Modules.HelloWorld.MyFunctionName()

--Log:
Hello, World!
