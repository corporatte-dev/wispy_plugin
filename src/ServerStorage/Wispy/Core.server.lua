--[=[
    |> Plugin Core

    This is the framework that handles the plugin's inner workings.
]=]

type Base = {}

local Systems = {}
local Libraries = {}
local Core = {}

--> Core API to be Injected into Systems and Libraries
function Core:GetSystem(Name: string)
    return Systems[Name]
end

function Core:GetLib(Name: string)
    return Libraries[Name]    
end

--> Internal Methods
function RegisterModule(Table: any, Module: ModuleScript)
    if not Module:IsA("ModuleScript") then return end
    local Object = require(Module)
    setmetatable(Object, {__index = Core})
    Table[Module.Name] = Object
end

--> First, we load the libraries as the systems may need to use them.
for _, Library: ModuleScript in ipairs(script.Parent.Library:GetChildren()) do
    RegisterModule(Libraries, Library)
end

--> Next, we load and register the systems.
for _, System: ModuleScript in ipairs(script.Parent.Systems:GetChildren()) do
    RegisterModule(Systems, System)
end

--> Almost there, lets manually inject other globals.
local Maid = require(script.Parent.Library.Maid)
Core.Maid = Maid.new()

Core.Plugin = plugin

--> Before we finish, we need to call any (optional) preload methods that may be present.
for _, System: any in pairs(Systems) do
    if typeof(System.Preload) == "function" then
        System:Preload()
    end
end
    
--> Finally, we call each system's :Run() method.
for _, System: any in pairs(Systems) do
    if System.NoMount then continue end
    System:Mount()
end

--> When the plugin is unloaded
plugin.Unloading:Connect(function()
    Core.Maid:Clean()

    --> Attempt to call an :OnClose() method within each system. This is optional!
    for _, System: any in pairs(Systems) do
        pcall(function() 
            System:OnClose()
        end)
    end
end)
