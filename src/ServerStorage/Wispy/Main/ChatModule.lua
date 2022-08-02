--!strict
--[[Corporatte, ChatModule, Wispy Plugin]]--

local module = {
	plugin_ID = 10422380892;
	anim_Folder = script.Parent.Parent.Assets.Animations;

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

local HTTP = game:GetService("HttpService")
local richText = require(script.Parent.Util.RichText)

local msg_bundle = {}
local messageLimit = 200

--local renderAvatarLoop = coroutine.create(function(avatar, camera, template)
--	while true do
--		local clonedChar
--		if clonedChar then clonedChar:Destroy() end
--		clonedChar = avatar:Clone()
--		camera.CFrame = CFrame.new(avatar.HumanoidRootPart.Position + (avatar.HumanoidRootPart.CFrame.LookVector * 5), avatar.HumanoidRootPart.Position)
--		clonedChar.Parent = template
--		task.wait()
--	end
--end)

local function LoadAvatar(player, chat_widget, template)
	if chat_widget.ChatUI.PlayerList:FindFirstChild("plr_"..player) then
		--coroutine.yield(renderAvatarLoop)
		chat_widget.ChatUI.PlayerList:FindFirstChild("plr_"..player):Destroy()
	end
	
	local playerData = game.Chat.Wispy.dev_avatars:FindFirstChild(player)
	local wispData = playerData.Value
	local wisp = script.Parent.Parent.Assets.Characters[wispData]:Clone()
	local hrp = wisp:FindFirstChild("HumanoidRootPart")
	local cam = Instance.new("Camera")
	
	cam.Parent = template
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
	auth.Name = author.Name
	
	local newIndex = tostring(#game.Chat["Wispy"].message_logs:GetChildren() + 1)
	str.Name = "message_"..newIndex
	str.Value = filtered
	
	local messageTemplate = script.Parent.Parent.Assets.UITemplates.RecentMessageTemplate:Clone()
	local messageContainer = chat_widget.ChatUI.MessageContainer
	messageTemplate.Parent = messageContainer
	messageTemplate.Author.Text = author.Name
	messageTemplate.Author.TextColor3 = module.ColorShortcuts[game.Chat.Wispy.dev_avatars:FindFirstChild(author.Name).Value]
	local textObject = richText:New(messageTemplate.TextBox, filtered)

	messageContainer.CanvasSize = UDim2.new(0, 0, 0, messageContainer.UIListLayout.AbsoluteContentSize.Y)
	messageContainer.CanvasPosition = Vector2.new(0, 9999)
	textObject:Animate(true)
	task.wait(#filtered / 100)
	
	--if isMuted == false then
	--	local soundClone = script.Parent.Parent.Assets.SFX.TalkSound:Clone()
	--	soundClone.Parent = game.Chat
	--	for i = 1, #filtered, 1 do
	--		game.SoundService:PlayLocalSound(soundClone)
	--		task.wait(0.125)
	--		soundClone.PitchShiftSoundEffect.Octave = math.random(5, 15) / 10
	--	end
	--	soundClone:Destroy()
	--end
	
	str.Parent = game.Chat["Wispy"].message_logs
end

local function updateChat(chat_widget)
	local messageLogs = game.Chat.Wispy.message_logs
	local devAvatars = game.Chat.Wispy.dev_avatars
	--local history = game.Chat.Wispy.CurrentVersion
	local chatContainer = chat_widget.ChatUI.MessageContainer
	local playerList = chat_widget.ChatUI.PlayerList
	
	for i, avatar in pairs(playerList:GetChildren()) do
		if avatar:IsA("ViewportFrame") then
			avatar:Destroy()
		end
	end
	
	for i, UI_msg in pairs(chatContainer:GetChildren()) do
		if UI_msg:IsA("TextLabel") or UI_msg:IsA("Frame") then
			UI_msg:Destroy()
		end
	end
	
	for i, dev_ava in pairs(devAvatars:GetChildren()) do
		local template = script.Parent.Parent.Assets.UITemplates.PlayerTemplate:Clone()
		LoadAvatar(dev_ava.Name, chat_widget, template)
		template.Parent = chat_widget.ChatUI.PlayerList
	end
	
	for i, message in pairs(messageLogs:GetChildren()) do
		local TS = game:GetService("TextService")
		local messageTemplate = script.Parent.Parent.Assets.UITemplates.MessageTemplate:Clone()
		local player = message:GetChildren()[1]
		local messageContainer = chat_widget.ChatUI.MessageContainer
		local sizeY = messageTemplate.AbsoluteSize.Y
		local bounds = TS:GetTextSize(message.Value, 20, Enum.Font.Code, Vector2.new())

		messageTemplate.Message.Text = message.Value
		messageTemplate.Size = UDim2.new(messageTemplate.Size.X.Scale, messageTemplate.Size.X.Offset, 0, bounds.Y + sizeY)
		messageTemplate.Author.Text = player.Name
		messageTemplate.Author.TextColor3 = module.ColorShortcuts[devAvatars:FindFirstChild(player.Name).Value]
		LoadAvatar(player.Name, chat_widget, messageTemplate.Viewport)
		messageTemplate.Parent = messageContainer
		messageContainer.CanvasSize = UDim2.new(0, 0, 0, messageContainer.UIListLayout.AbsoluteContentSize.Y)
		messageContainer.CanvasPosition = Vector2.new(0, 9999)
	end
end

function module:Init(chat_widget, plugin, Maid)
	--local previous_messages = plugin:GetSetting(game.PlaceId.."_messages")
	local msg_Folder = game.Chat.Wispy:FindFirstChild("message_logs") or Instance.new("Folder")
	msg_Folder.Name = "message_logs"
	msg_Folder.Parent = game.Chat.Wispy

	local bg = chat_widget.ChatUI.Background
	local info = TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1, false, 0)
	local tween = game:GetService("TweenService"):Create(bg, info, {Position = UDim2.new(0, -100, 0, 0)})
	tween:Play()	

	if plugin:GetSetting("UserAvatar") ~= nil then
		local template = script.Parent.Parent.Assets.UITemplates.PlayerTemplate:Clone()
		LoadAvatar(game.Players.LocalPlayer.Name, chat_widget, template)
		template.Parent = chat_widget.ChatUI.PlayerList
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
	
	updateChat(chat_widget)
	
	Maid:Add(chat_widget.ChatUI.ChatBox.ChatBox2.Input.FocusLost:Connect(function(enterPressed)
		if not enterPressed then return end
		createMessage(chat_widget, chat_widget.ChatUI.ChatBox.ChatBox2.Input.Text, game.Players.LocalPlayer)
		chat_widget.ChatUI.ChatBox.ChatBox2.Input.Text = ""
		chat_widget.ChatUI.ChatBox.ChatBox2.Input:CaptureFocus()
	end))
	
	Maid:Add(game.Chat.Wispy.dev_avatars.ChildAdded:Connect(function(newValue)
		local template = script.Parent.Parent.Assets.UITemplates.PlayerTemplate:Clone()
		LoadAvatar(newValue.Name, chat_widget, template)
		template.Parent = chat_widget.ChatUI.PlayerList
	end))
	
	Maid:Add(game.Chat.Wispy.dev_avatars.ChildRemoved:Connect(function(oldValue)
		chat_widget.ChatUI.PlayerList:FindFirstChild("plr_"..oldValue.Name):Destroy()
	end))
	
	Maid:Add(game.Chat["Wispy"].message_logs.ChildAdded:Connect(function()
		updateChat(chat_widget)
	end))
	
	Maid:Add(game.Chat["Wispy"].message_logs.ChildRemoved:Connect(function()
		updateChat(chat_widget)
	end))
	
	for i, value in pairs(game.Chat.Wispy.dev_avatars:GetChildren()) do
		value.Changed:Connect(function()
			local template = script.Parent.Parent.Assets.UITemplates.PlayerTemplate:Clone()
			LoadAvatar(value.Name, chat_widget, template)
			template.Parent = chat_widget.ChatUI.PlayerList
		end)
	end
end

function module:ClearLogs(plugin, chat_widget)
	local messageLog = game.Chat["Wispy"].message_logs
	plugin:SetSetting(game.PlaceId.."_messages", "")
	messageLog:ClearAllChildren()
	updateChat(chat_widget)
end

function module:OnStudioClose(plugin)
	local log_folder = game.Chat["Wispy"].message_logs
	local avatar = game.Chat.Wispy.dev_avatars[game.Players.LocalPlayer]
	avatar:Destroy()
	
	for i, msg in pairs(log_folder:GetChildren()) do
		local msgTable = {Message = msg.Value, Author = msg.Author.Value}
		if i < messageLimit then
			table.insert(msg_bundle, msgTable)
		end
	end
	
	local settingPackage = HTTP:JSONEncode(msg_bundle)
	plugin:SetSetting(game.PlaceId.."_messages", settingPackage)
	table.clear(msg_bundle)
end

return module