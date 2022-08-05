local Types = require(script.Parent.Parent.Types)
local ChatSystem = {} :: Types.ChatSystem 

--[=[
	|> Chat System

	Handles chatting and message UI.
]=]

local HTTP = game:GetService("HttpService")

--> Constants
local Constants = {
    plugin_ID = 10422380892;
	anim_Folder = script.Parent.Parent.Assets.Animations;
    messageLimit = 200;

	ColorShortcuts = {
		Angel = Color3.fromRGB(255, 255, 255),
		Cooltergiest = Color3.fromRGB(0, 0, 170),
		Dizzey = Color3.fromRGB(85, 170, 0),
		Happy = Color3.fromRGB(255, 255, 0),
		Impy = Color3.fromRGB(170, 0, 0),
		Nekospecter = Color3.fromRGB(255, 170, 0),
		Pupper = Color3.fromRGB(0, 170, 255),
		Robo = Color3.fromRGB(70, 70, 70),
		Spooky = Color3.fromRGB(0, 0, 0),
		Wispy = Color3.fromRGB(170, 85, 255),
		Willow = Color3.fromRGB(191, 118, 191)
	},
}

--> Typed Modules to be Loaded on Mount
local RichText: Types.RichText
local Maid: Types.MaidObject
local AvatarSystem: Types.AvatarSystem
local Plugin: Plugin
local PluginUI: Types.PluginUI

local MessagesFolder: Folder
local DevAvatarFolder: Folder

local ChatWidget: DockWidgetPluginGui

--> Variables
local msg_bundle = {}

--> Internal Methods
local function LoadAvatar(player: string, template)
	local playerData = DevAvatarFolder:FindFirstChild(player)
	local wispData = playerData.Value
	local wisp = script.Parent.Parent.Assets.Characters[wispData]:Clone()
	local hrp = wisp:FindFirstChild("HumanoidRootPart")
	local cam = Instance.new("Camera")
	
	AvatarSystem:createAvatar(player)

	cam.Parent = template
	template.bg.BackgroundColor3 = Constants.ColorShortcuts[DevAvatarFolder:FindFirstChild(player).Value]
	template.CurrentCamera = cam
	template.Name = "plr_"..player
	cam.CFrame = CFrame.new(hrp.Position + (hrp.CFrame.LookVector * 5), hrp.Position)
	cam.FieldOfView = 30
	wisp.Parent = template
end

local function createMessage(chat_widget, text: string, author: Player, isMuted: boolean?)
	isMuted = isMuted or false
	local filtered
	pcall(function()
		filtered = game:GetService("TextService"):FilterStringAsync(text, author.UserId)
		filtered = filtered:GetNonChatStringForBroadcastAsync()
	end)
	if not filtered then return end
	
	local str = Instance.new("StringValue")
	local auth = Instance.new("StringValue")
	auth.Parent = str
	
	local newIndex = tostring(#MessagesFolder:GetChildren() + 1)
	str.Name = "message_"..newIndex
	auth.Name = "author"
	str.Value = filtered
	auth.Value = author.Name
	
	local messageTemplate = script.Parent.Parent.Assets.UITemplates.RecentMessageTemplate:Clone()
	local messageContainer = chat_widget.ChatUI.MessageContainer
	messageTemplate.Parent = messageContainer
	messageTemplate.Author.Text = author.Name
	messageTemplate.Author.TextColor3 = Constants.ColorShortcuts[DevAvatarFolder:FindFirstChild(author.Name).Value]
	LoadAvatar(author.Name, messageTemplate.Viewport)
	local textObject = RichText:New(messageTemplate.TextBox, filtered)

	messageContainer.CanvasSize = UDim2.new(0, 0, 0, messageContainer.UIListLayout.AbsoluteContentSize.Y)
	messageContainer.CanvasPosition = Vector2.new(0, 9999)
	textObject:Animate(true)
	task.wait(#filtered / 100)
	
	--if isMuted == false then
	--	local soundClone = script.Parent.Parent.Assets.SFX.TalkSound:Clone()
	--	soundClone.Parent = game.SoundService
	--	for i = 1, #filtered, 1 do
	--		game.SoundService:PlayLocalSound(soundClone)
	--		task.wait(0.125)
	--		soundClone.PitchShiftSoundEffect.Octave = math.random(5, 15) / 10
	--	end
	--	soundClone:Destroy()
	--end
	
	str.Parent = MessagesFolder
end

function ChatSystem:UpdatePlrList()
	local playerList = ChatWidget.ChatUI.PlayerList

	for _, avatar in pairs(playerList:GetChildren()) do
		if avatar:IsA("ViewportFrame") then
			avatar:Destroy()
		end
	end

	for _, dev_ava in pairs(DevAvatarFolder:GetChildren()) do
		local template = script.Parent.Parent.Assets.UITemplates.PlayerTemplate:Clone()
		template.Parent = ChatWidget.ChatUI.PlayerList
		LoadAvatar(dev_ava.Name, template)
	end
end

function ChatSystem:UpdateChat()
	local chatContainer = ChatWidget.ChatUI.MessageContainer
	
	--> clears the whole chat container of messages
	for _, UI_msg in pairs(chatContainer:GetChildren()) do
		if UI_msg:IsA("TextLabel") or UI_msg:IsA("Frame") then
			UI_msg:Destroy()
		end
	end

	--> remakes the messages from the message logs
	for _, message in pairs(MessagesFolder:GetChildren()) do
		local TS = game:GetService("TextService")
		local messageTemplate = script.Parent.Parent.Assets.UITemplates.MessageTemplate:Clone()
		local player = message.author.Value
		local messageContainer: Frame = ChatWidget.ChatUI.MessageContainer

		local Message: Frame = messageTemplate.Message
		messageTemplate.Parent = messageContainer

		--> Calculate the bounds of the text within it's container.
		local bounds = TS:GetTextSize(message.Value, 20, Enum.Font.SourceSans, Vector2.new(Message.AbsoluteSize.X, math.huge))
		
		--> Then, use the Y axis of bounds to calculate the new size for the message template.
		messageTemplate.Size = UDim2.new(messageTemplate.Size.X.Scale, messageTemplate.Size.X.Offset, 0, math.clamp(bounds.Y + 40, 60, math.huge))
		messageTemplate.Message.Text = message.Value
		messageTemplate.Author.Text = player
		messageTemplate.Author.TextColor3 = Constants.ColorShortcuts[DevAvatarFolder:FindFirstChild(player).Value]
		LoadAvatar(player, messageTemplate.Viewport)
		messageContainer.CanvasSize = UDim2.new(0, 0, 0, messageContainer.UIListLayout.AbsoluteContentSize.Y)
		messageContainer.CanvasPosition = Vector2.new(0, math.huge)
	end
end

--> Main method to 'Kick off' the modules functionality.
function ChatSystem:Mount()
	
	--> Load Dependancies
	local FileSystem = self:GetSystem("FileSystem")
	PluginUI = self:GetSystem("PluginUI")
	AvatarSystem = self:GetSystem("AvatarSystem")
	RichText = self:GetLib("RichText")
    Plugin = self.Plugin
    Maid = self.Maid

	MessagesFolder = FileSystem:Get("Messages")
	DevAvatarFolder = FileSystem:Get("DevAvatars")

	ChatWidget = PluginUI:GetWidget("Chat")

	local bg = ChatWidget.ChatUI.Background
	local info = TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1, false, 0)
	local tween = game:GetService("TweenService"):Create(bg, info, {Position = UDim2.new(0, -100, 0, 0)})
	tween:Play()	

	if Plugin:GetSetting("UserAvatar") ~= nil then
		local template = script.Parent.Parent.Assets.UITemplates.PlayerTemplate:Clone()
		LoadAvatar(self.LocalPlayer.Name, template)
		template.Parent = ChatWidget.ChatUI.PlayerList
	end
		
		--loads old messages from past session
		--if previous_messages then
		--	local prev_Bundle = HTTP:JSONDecode(previous_messages)
		--	for i, msg in pairs(prev_Bundle) do
		--		local msgVar = Instance.new("StringValue", msg_Folder)
		--		msgVar.Name = "message_"..i
		--		msgVar.Value = msg.Message
		--		local authorVar = Instance.new("StringValue", msgVar)
		--		authorVar.Name = msg.Author
		--		createMessage(msgVar.Value, authorVar.Name)
		--		if i >= messageLimit then
		--			--if the amount of messages exceeds the limit then delete
		--			table.remove(prev_Bundle, i)
		--		end
		--	end
		--end
	
	self:UpdateChat()
	self:UpdatePlrList()
	
	Maid:Add(ChatWidget.ChatUI.ChatBox.ChatBox2.Input.FocusLost:Connect(function(enterPressed)
		if not enterPressed then return end
		createMessage(ChatWidget, ChatWidget.ChatUI.ChatBox.ChatBox2.Input.Text, self.LocalPlayer)
		ChatWidget.ChatUI.ChatBox.ChatBox2.Input.Text = ""
		ChatWidget.ChatUI.ChatBox.ChatBox2.Input:CaptureFocus()
	end))
	
	Maid:Add(MessagesFolder.ChildAdded:Connect(function()
		self:UpdateChat()
	end))
	
	Maid:Add(MessagesFolder.ChildRemoved:Connect(function()
		self:UpdateChat()
	end))
end

function ChatSystem:ClearLogs()
	Plugin:SetSetting(game.PlaceId.."_messages", "")
	MessagesFolder:ClearAllChildren()
	self:UpdateChat()
end

--> Optional method to clean up when Plugin.Unloading() is called.
function ChatSystem:OnClose()
	local avatar = DevAvatarFolder[self.LocalPlayer.Name]
	avatar:Destroy()
	
	for i, msg in pairs(MessagesFolder:GetChildren()) do
		local msgTable = {Message = msg.Value, Author = msg.Author.Value}
		if i < Constants.messageLimit then
			table.insert(msg_bundle, msgTable)
		end
	end
	
	local settingPackage = HTTP:JSONEncode(msg_bundle)
	self.Plugin:SetSetting(game.PlaceId.."_messages", settingPackage)
	table.clear(msg_bundle)
end

return ChatSystem