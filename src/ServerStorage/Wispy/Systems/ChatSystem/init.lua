local Types = require(script.Parent.Parent.Types)
local ChatSystem = {} :: Types.ChatSystem 
local TS = game:GetService("TextService")

--[=[
	|> Chat System

	Handles chatting and message UI.
]=]

local HTTP = game:GetService("HttpService")
local Util = require(script.Util)

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
	}
}

--> Typed Modules to be Loaded on Mount
local RichText: Types.RichText
local Maid: Types.MaidObject
local Plugin: Plugin
local PluginUI: Types.PluginUI

local MessagesFolder: Folder
local DevAvatarFolder: Folder

local ChatWidget: DockWidgetPluginGui

--> Variables
local RenderedIDs = {} -- [ID] = MessageTemplate
local msg_bundle = {}

--> Internal Methods
function RecalculateBounds(Template: Frame)
	local bounds = TS:GetTextSize(Template.Message.Text, 20, Enum.Font.SourceSans, Vector2.new(Template.Message.AbsoluteSize.X, math.huge))
	Template.Size = UDim2.new(Template.Size.X.Scale, Template.Size.X.Offset, 0, math.clamp(bounds.Y + 40, 60, math.huge))
end

function LoadAvatar(player: string, template)
	local playerData = DevAvatarFolder:FindFirstChild(player)
	local wispData = playerData.Value
	local wisp = script.Parent.Parent.Assets.Characters[wispData]:Clone()
	local hrp = wisp:FindFirstChild("HumanoidRootPart")
	local cam = Instance.new("Camera")
	
	--AvatarSystem:createAvatar(player)

	cam.Parent = template
	template.bg.BackgroundColor3 = Constants.ColorShortcuts[DevAvatarFolder:FindFirstChild(player).Value]
	template.CurrentCamera = cam
	template.Name = "plr_"..player
	cam.CFrame = CFrame.new(hrp.Position + (hrp.CFrame.LookVector * 5), hrp.Position)
	cam.FieldOfView = 30
	wisp.Parent = template
end

function ChatSystem:CreateMessage(text: string, isMuted: boolean?)
	isMuted = isMuted or false

	local author = self.LocalPlayer
	local filtered

	pcall(function()
		filtered = game:GetService("TextService"):FilterStringAsync(text, author.UserId)
		filtered = filtered:GetNonChatStringForBroadcastAsync()
	end)

	if not filtered then return end

	local messageTemplate = script.Parent.Parent.Assets.UITemplates.RecentMessageTemplate:Clone()
	local messageContainer = ChatWidget.ChatUI.MessageContainer
	messageTemplate.Parent = messageContainer
	messageTemplate.Author.Text = author.Name
	
	messageTemplate.Author.TextColor3 = Constants.ColorShortcuts[DevAvatarFolder:FindFirstChild(author.Name).Value]
	LoadAvatar(author.Name, messageTemplate.Viewport)
	local textObject = RichText:New(messageTemplate.TextBox, filtered)

	messageContainer.CanvasSize = UDim2.new(0, 0, 0, messageContainer.UIListLayout.AbsoluteContentSize.Y)
	messageContainer.CanvasPosition = Vector2.new(0, messageContainer.UIListLayout.AbsoluteContentSize.Y)
	textObject:Animate(true)
	task.wait(#filtered / 100)

	messageTemplate:Destroy()
	Util:CreateRecord(filtered)

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
	local messageContainer: Frame = ChatWidget.ChatUI.MessageContainer

	--[[
		| Here is my rough draft of the UpdateChat() method.

		TODO: Change the object deletion to be handled on child remove, not every time the chat updates.
			--| If we have 1000s of messages, this search can get real expensive real quick.

		TODO: Consider creating a library for these avatar images so they auto-update on avatar change.
	]]

	--> Remove non-active messages
	--! Can be a-lot more efficient. This is ONLY to get it working for the demo.
	for ID, Template in pairs(RenderedIDs) do
		if Util:FindID(ID) then continue end

		if Template then
			Template.Parent = nil
			Template:Destroy()
		end
	end

	--> remakes the messages from the message logs
	for _, message in pairs(MessagesFolder:GetChildren()) do

		--> Get the message's ID
		local MessageID = message:GetAttribute("MessageID") 

		--> If it doesn't exist, skip this entry.
		if not MessageID then continue end

		--> If the object has already been rendered, re-calculate it's bounds.
		if RenderedIDs[MessageID] ~= nil then
			RecalculateBounds(RenderedIDs[MessageID])
			continue
		end

		--> Await author and Timestamp
		local Author = message:WaitForChild("author", 1)
		local Timestamp = message:WaitForChild("timestamp", 1)

		--> If either are not present, continue.
		if not Author then continue end
		if not Timestamp then continue end

		--> Create the message template
		local messageTemplate = script.Parent.Parent.Assets.UITemplates.MessageTemplate:Clone()
		local player = message:WaitForChild("author").Value
		--local timestamp = message:WaitForChild("timestamp").Value

		--> Remove newlines (may not want in cirtain scenarios) and set our text.
		messageTemplate.Message.Text = message.Value:gsub("\n", "")
		messageTemplate.Parent = messageContainer

		--> Calculate size of message template with the current text.
		RecalculateBounds(messageTemplate)

		messageTemplate.Author.Text = player
		--messageTemplate.Timestamp.Text = os.date("%c", timestamp)
		messageTemplate.Author.TextColor3 = Constants.ColorShortcuts[DevAvatarFolder:FindFirstChild(player).Value]

		--! Pretty bad but it works. Please fix this in the future lmao
		messageTemplate.Viewport.Player.Image = game.Players:GetUserThumbnailAsync(game.Players:GetUserIdFromNameAsync(Author.Value), Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size180x180)

		LoadAvatar(player, messageTemplate.Viewport)


		--> Add the messageTemplate to our local RenderedIDs table.
		RenderedIDs[MessageID] = messageTemplate
	end

	--> Finally, update the canvas size and position when all updates are performed. 
	messageContainer.CanvasSize = UDim2.new(0, 0, 0, messageContainer.UIListLayout.AbsoluteContentSize.Y)
	messageContainer.CanvasPosition = Vector2.new(0, messageContainer.UIListLayout.AbsoluteContentSize.Y)
end

--> Main method to 'Kick off' the modules functionality.
function ChatSystem:Mount()
	--> Grant Util access to Core Methods
	setmetatable(Util, {__index = self})

	--> Load Dependancies
	PluginUI = self:GetSystem("PluginUI")
	RichText = self:GetLib("RichText")
    Plugin = self.Plugin
    Maid = self.Maid

	MessagesFolder = self:GetFolder("message_logs")
	DevAvatarFolder = self:GetFolder("dev_avatars")

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
		self:CreateMessage(ChatWidget.ChatUI.ChatBox.ChatBox2.Input.Text)
		ChatWidget.ChatUI.ChatBox.ChatBox2.Input.Text = ""
		ChatWidget.ChatUI.ChatBox.ChatBox2.Input:CaptureFocus()
	end))
	
	Maid:Add(MessagesFolder.ChildAdded:Connect(function(msg)
		self:UpdateChat()

		local Author = msg:WaitForChild("author", 3)
		if Author and Author.Value ~= self.LocalPlayer.Name then
			self:Notify(("%s sent a message!"):format(Author.Value), ChatSystem.NotifIconTemplates.StandardIcon, 2)	
		end
	end))
	
	Maid:Add(MessagesFolder.ChildRemoved:Connect(function()
		self:UpdateChat()
	end))

	local FadeUI = ChatWidget.ChatUI.Fade

	--> Maybe one day canvas groups will be released :/
	task.delay(1, function()
		local FadeTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local FadeTween = game:GetService("TweenService"):Create(FadeUI, FadeTweenInfo, {GroupTransparency = 1})
		FadeTween:Play()

		for _, Object in ipairs(FadeUI:GetDescendants()) do
			if Object:IsA("TextLabel") then
				FadeTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				FadeTween = game:GetService("TweenService"):Create(Object, FadeTweenInfo, {TextTransparency = 1})
				FadeTween:Play()
			end
		end
	end)
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
		local msgTable = {Message = msg.Value, Author = msg.author.Value}
		if i < Constants.messageLimit then
			table.insert(msg_bundle, msgTable)
		end
	end
	
	local settingPackage = HTTP:JSONEncode(msg_bundle)
	self.Plugin:SetSetting(game.PlaceId.."_messages", settingPackage)
	table.clear(msg_bundle)
end

return ChatSystem