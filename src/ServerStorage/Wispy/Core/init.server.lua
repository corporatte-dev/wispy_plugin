local RunService = game:GetService("RunService")
local StudioService = game:GetService("StudioService")

local Config = require(script.Parent.Config)
local Notify = require(script.Notify)
local Tree = require(script.Tree)
local Maid = require(script.Maid)

--[=[
    |> Plugin Core

    This is the plugin framework that handles the plugin's inner workings. Haven't thought of a cool name for
    it yet.
]=]

local Core = {}
local Systems = {}
local Libraries = {}
local Locations = {}

local IconTemplates = {
    WarningIcon = "rbxassetid://10573766832",
    ErrorIcon = "rbxassetid://10573764025",
    StandardIcon = "rbxassetid://10573754579"
}

--! Prevent Plugin from Working in RunMode
if RunService:IsRunning() then
    Notify:Say("Error", IconTemplates.ErrorIcon, "Wispy disabled during playtesting.", 4)
    return
end

--! Attempt to grab local player. If we cant, we are not in team create.
local LocalUserID = StudioService:GetUserId()
local Player = game.Players:GetPlayerByUserId(LocalUserID) or game.Players.LocalPlayer
if Player == nil then
    Notify:Say("Error", IconTemplates.ErrorIcon, "Wispy can only be used in Team Create! Please enable Team Create to use this plugin.", 4, Core.Plugin:GetSetting("IsMuted"))
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
                    local Version = CopyConfig.Version
                    Notify:Say("Error", IconTemplates.StandardIcon, ("Version %s of %s is Released! Please update in your plugin manager."):format(Version, Config.Name), 3, Core.Plugin:GetSetting("IsMuted"))
                    --> Do something here?...
                end
            end
    
            CopyConfig = nil
            Copy.Parent = nil
            Copy:Destroy()
        end)
    
        if not S then
            Notify:Say("Error", IconTemplates.ErrorIcon, "An internal error occurred when checking for wispy updates!", 3, Core.Plugin:GetSetting("IsMuted"))
            warn(E) 
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

function Core:Notify(Text: string, Emoji: string?, Duration: number?)
    Notify:Say("Standard", Emoji or IconTemplates.StandardIcon, Text, Duration, Core.Plugin:GetSetting("IsMuted"))
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
Core.Maid:Add(plugin.Unloading:Connect(function()
    Core.Maid:Clean()

    --> Attempt to call an :OnClose() method within each system. This is optional!
    for _, System: any in pairs(Systems) do
        if typeof(System.OnClose) == "function" then
            System:OnClose()
        end
    end
end))

--> Let our end user know that the plugin is ready to go.
Notify:Say("Standard", IconTemplates.StandardIcon, ("Wispy is setup and ready to go!"), 3, Core.Plugin:GetSetting("IsMuted"))