--[=[
    |> Plugin Core
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
    local Object = require(Module)
    setmetatable(Object, {__index = Core})
    Table[Module.Name] = Object
end

--> First, we load the libraries as the systems may need to use them.
for _, Library: ModuleScript in ipairs(script.Parent.Libraries:GetChildren()) do
    RegisterModule(Libraries, Library)
end

--> Next, we load and register the systems.
for _, System: ModuleScript in ipairs(script.Parent.Systems:GetChildren()) do
    RegisterModule(Systems, System)
end

--> Almost there, lets manually inject other globals.
local Maid = require(script.Parent.Utilities.Maid)
Core.Maid = Maid.new()

Core.Plugin = plugin

--> Finally, we call each system's :Run() method.
for _, System: any in pairs(Systems) do
    System:Run()
end

--> When the plugin is unloaded
plugin.Unloading:Connect(function()
    Maid:Clean()
end)
