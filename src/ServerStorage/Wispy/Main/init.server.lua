--!strict

--[=[
	|> Wispy Plugin Core

	This script will handle the plugins overall state and setup.

	Developed by Corporatte with assistance from frriend.
	July 30, 2022
]=]

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--| Dependancies |----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local Maid = require(script.Util.Maid).new()
local chatModule = require(script.ChatModule)
local avatarModule = require(script.AvatarModule)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--| Plugin Setup |----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local main_plugin = plugin or getfenv.PluginManager():CreatePlugin()

local toolbar = plugin:CreateToolbar("Wispy")
local muteButton = toolbar:CreateButton("Toggle Sounds", "Decides if you can hear the talking sounds", "rbxassetid://10410245041")
local chatButton = toolbar:CreateButton("Toggle Chat Window", "Opens and closes the chat widget", "rbxassetid://10417191274")
local avatarButton = toolbar:CreateButton("Change Avatar", "Gives you a list of avatars to choose from", "rbxassetid://10417795038")
local clearButton = toolbar:CreateButton("Clear Log", "Wipes all messages from the message log", "rbxassetid://10429312452")

local avatarWidgetInfo = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, false, 300, 350, 300, 350)
local chatWidgetInfo = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Right, false, false, 400, 600, 200, 400)

local avatarWidget = main_plugin:CreateDockWidgetPluginGui("AvatarUI", avatarWidgetInfo)
avatarWidget.Title = "Avatar Menu"
script.Parent.Assets.AvatarUI.Parent = avatarWidget

local chatWidget = main_plugin:CreateDockWidgetPluginGui("ChatUI", chatWidgetInfo)
chatWidget.Title = "Chat Window"
script.Parent.Assets.ChatUI.Parent = chatWidget

--> Ensure that the plugin is usable in script editor mode.
muteButton.ClickableWhenViewportHidden = true
chatButton.ClickableWhenViewportHidden = true
avatarButton.ClickableWhenViewportHidden = true

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--| Get User Preferences |----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local avatar_pref = main_plugin:GetSetting("UserAvatar")
local mute_pref = main_plugin:GetSetting("IsMuted")

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--| Variables |----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local muteToggle = true
local avatarUI_open = false
local chatUI_open = false

--> Create a new folder for the chat system (if it doesn't already exist)
local wispyFolder = game.Chat:FindFirstChild("Wispy") or Instance.new("Folder", game.Chat)
wispyFolder.Name = "Wispy" 

--> Detect if the game is running in studio mode.
if game['Run Service']:IsStudio() and game['Run Service']:IsRunMode() == false then
	avatarModule:Init(avatarWidget, main_plugin, Maid)
	chatModule:Init(chatWidget, main_plugin, Maid)
elseif game['Run Service']:IsRunMode() then
	workspace.Camera:FindFirstChild("cam_avatars"):Destroy()
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--| OnClick Events |----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Maid:Add(muteButton.Click:Connect(function()
	if muteToggle == true then
		muteToggle = false
		main_plugin:SetSetting("IsMuted", false)
		muteButton.Icon = "rbxassetid://10410244824"
	else
		muteToggle = true
		main_plugin:SetSetting("IsMuted", true)
		muteButton.Icon = "rbxassetid://10410245041"
	end
end))

Maid:Add(avatarButton.Click:Connect(function()
	if avatarUI_open == true then
		avatarUI_open = false
		avatarWidget.Enabled = false
	else
		avatarUI_open = true
		avatarWidget.Enabled = true
	end
end))

Maid:Add(chatButton.Click:Connect(function()
	if chatUI_open == true then
		chatUI_open = false
		chatWidget.Enabled = false
	else
		chatUI_open = true
		chatWidget.Enabled = true
	end
end))

Maid:Add(clearButton.Click:Connect(function()
	chatModule:ClearLogs(plugin, chatWidget)
end))

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--| On Plugin Unload |----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Maid:Add(main_plugin.Unloading:Connect(function()
	print('Plugin Unloaded')
	Maid:Clean()
end))