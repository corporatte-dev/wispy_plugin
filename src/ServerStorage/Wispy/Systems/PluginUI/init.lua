local Types = require(script.Parent.Parent.Types)
local PluginUI = {} :: Types.PluginUI

--[=[
    |> PluginUI

    Handles the creation and functionality of Plugin Widgets. It supplies an API to other systems
    to get these widgets and buttons for easy access.
]=]


local Buttons = {}
local Widgets = {}
local Toolbar = nil

local muteToggle = true
local avatarUI_open = false
local chatUI_open = false

local Maid: Types.MaidObject
local Plugin: Plugin
local ChatSystem: Types.ChatSystem
local DeferRefresh: Types.DeferObject

--> Internal Functions
function CreateWidget(ID: string, WidgetInfo: DockWidgetPluginGuiInfo, Title: string, UI: ScreenGui)
    local Widget = Plugin:CreateDockWidgetPluginGui(ID, WidgetInfo)
    Widget.Title = Title
    UI.Parent = Widget

    Maid:Add(UI:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        if DeferRefresh then
            DeferRefresh:Call()
        end
    end))
    
    return Widget
end

--> System API
function PluginUI:GetWidget(Name: string)
    return Widgets[Name]
end

function PluginUI:GetButton(Name: string)
    return Buttons[Name]
end

--> Create UIX for Plugin
function PluginUI:Preload()
    Plugin = self.Plugin
    Maid = self.Maid
    Toolbar = Plugin:CreateToolbar("Wispy")
    
    --> Create Buttons
    Buttons = {
        Mute = Toolbar:CreateButton("Toggle Sounds", "Decides if you can hear the talking sounds", "rbxassetid://10410245041"),
        Chat = Toolbar:CreateButton("Toggle Chat Window", "Opens and closes the chat widget", "rbxassetid://10417191274"),
        Avatar = Toolbar:CreateButton("Change Avatar", "Gives you a list of avatars to choose from", "rbxassetid://10417795038"),
        Clear = Toolbar:CreateButton("Clear Log", "Wipes all messages from the message log", "rbxassetid://10429312452")
    }
    
    --> Ensure that the plugin is usable in script editor mode.
    Buttons.Mute.ClickableWhenViewportHidden = true
    Buttons.Chat.ClickableWhenViewportHidden = true
    Buttons.Avatar.ClickableWhenViewportHidden = true
    
    --> Generate Widgets
    Widgets = {
        Avatar = CreateWidget(
            "AvatarUI",
            DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, false, 300, 350, 300, 350),
            "Avatar Menu",
            script.Parent.Parent.Assets.AvatarUI
        ),
    
        Chat = CreateWidget(
            "ChatUI",
            DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Right, false, false, 400, 600, 200, 400),
            "Chat Window",
            script.Parent.Parent.Assets.ChatUI
        )
    }

    Maid:Add(Buttons.Mute.Click:Connect(function()
        if muteToggle == true then
            muteToggle = false
            Plugin:SetSetting("IsMuted", false)
            Buttons.Mute.Icon = "rbxassetid://10410244824"
        else
            muteToggle = true
            Plugin:SetSetting("IsMuted", true)
            Buttons.Mute.Icon = "rbxassetid://10410245041"
        end
    end))
    
    Maid:Add(Buttons.Avatar.Click:Connect(function()
        if avatarUI_open == true then
            avatarUI_open = false
            Widgets.Avatar.Enabled = false
        else
            avatarUI_open = true
            Widgets.Avatar.Enabled = true
        end
    end))
    
    Maid:Add(Buttons.Chat.Click:Connect(function()
        if chatUI_open == true then
            chatUI_open = false
            Widgets.Chat.Enabled = false
        else
            chatUI_open = true
            Widgets.Chat.Enabled = true
        end
    end))
    
    Maid:Add(Buttons.Clear.Click:Connect(function()
        self:GetSystem("ChatSystem"):ClearLogs()
    end))
end
    
function PluginUI:Mount()
    local DeferLib: Types.Defer = self:GetLib("Defer")
    ChatSystem = self:GetSystem("ChatSystem")

    DeferRefresh = DeferLib.new(function()
        print 'refreshed'
        ChatSystem:UpdateChat()
    end, 0.5)
end

function PluginUI:OnClose()
    DeferRefresh:Clean()
end

return PluginUI