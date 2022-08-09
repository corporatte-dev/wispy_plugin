local RunService = game:GetService("RunService")
local StudioService = game:GetService("StudioService")

local Config = require(script.Parent.Config)
local Tree = require(script.Tree)

--[=[
    |> Plugin Core

    This is the plugin framework that handles the plugin's inner workings. Haven't thought of a cool name for
    it yet.
]=]

type Base = {}

local Systems = {}
local Libraries = {}
local Locations = {}
local Core = {}

local LocalUserID = StudioService:GetUserId()
local Player = game.Players:GetPlayerByUserId(LocalUserID) or game.Players.LocalPlayer

--! Flags to prevent system from running when it isn't supposed to.
if Player == nil then
    warn(("[%s] Please turn on Team Create to use this plugin."):format(Config.Name))
    return
end

if RunService:IsRunning() then
    print(("[%s] Disabled during Playtesting."):format(Config.Name))
    return
end

--> Check for Updates
if Config.AssetID then
    task.spawn(function()
        local S, E = pcall(function()
            local Copy = game:GetObjects(("rbxassetid://%i"):format(Config.AssetID))[1]
            local CopyConfig = require(Copy:FindFirstChild("Config"))
    
            if CopyConfig then
                if CopyConfig.Version ~= Config.Version then
                    warn(("[%s] Version %s is Released! Please update in your plugin manager."):format(Config.Name, CopyConfig.Version))
                    --> Do something here?...
                end
            end
    
            CopyConfig = nil
            Copy.Parent = nil
            Copy:Destroy()
        end)
    
        if not S then
            warn(("[%s] An internal error occurred when checking for updates."):format(Config.Name))
            warn(E) --! TEST ONLY
        end
    end)
end

--> Core API to be Injected into Systems and Libraries
function Core:GetSystem(Name: string)
    return Systems[Name]
end

function Core:GetLib(Name: string)
    return Libraries[Name]    
end

function Core:GetFolder(Name: string)
    return Locations[Name]
end

--> Internal Methods
function RegisterModule(Table: any, Module: ModuleScript)
    if not Module:IsA("ModuleScript") then return end
    local Object = require(Module)
    setmetatable(Object, {__index = Core})
    Table[Module.Name] = Object
end

--> Generate project structure (if it doesn't already exist)
Locations = Tree:CreateStucture(Config.Structure)

--> First, we load the libraries as the systems may need to use them.
for _, Library: ModuleScript in ipairs(script.Parent.Library:GetChildren()) do
    RegisterModule(Libraries, Library)
end

--> Next, we load and register the systems.
for _, System: ModuleScript in ipairs(script.Parent.Systems:GetChildren()) do
    RegisterModule(Systems, System)
end

--> Almost there, lets manually inject other globals.
do
    --? Maid Instance
    local Maid = require(script.Parent.Library.Maid)
    Core.Maid = Maid.new()

    Core.Plugin = plugin
    Core.LocalPlayer = Player
    Core.Config = Config
end

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
