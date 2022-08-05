local Types = require(script.Parent.Parent.Types)
local AvatarSystem = {} :: Types.AvatarSystem

local avatar_template = script.Parent.Parent.Assets.UITemplates.CharacterTemplate
local characterFolder = script.Parent.Parent.Assets.Characters

local ChatSystem: Types.ChatSystem
local PluginUI: Types.PluginUI
local Maid: Types.MaidObject
local Plugin: Plugin
local DevAvatarFolder: Folder
local CamAvatarFolder: Folder

function updateAvatar(avatar, goal)
	--local currentTime = tick()
	local offsets = {
		HMR = Vector3.new(0, -1, 0),
		["Left Arm"] = {Position = CFrame.new(Vector3.new(1, -0.5, 1)), Orientation = CFrame.Angles(math.rad(-22.13), 0, 0)},
		["Right Arm"] = {Position = CFrame.new(Vector3.new(-1, -0.5, 1)), Orientation = CFrame.Angles(math.rad(-22.13), 0, 0)},
	}
	
	--Bobble CFrame (HumanoidRootPart)
	--local bobbleX = math.cos(currentTime * 10) * 0.25
	--local bobbleY = math.abs(math.sin(currentTime * 10)) * 0.25
	--local bobbleVector = Vector3.new(bobbleX, bobbleY, 0)
	
	--BodyParts
	avatar.PrimaryPart.CFrame = avatar.PrimaryPart.CFrame:Lerp(goal.CFrame, 0.75)
	avatar["Left Arm"].CFrame = avatar["Left Arm"].CFrame:Lerp(avatar.PrimaryPart.CFrame + offsets["Left Arm"].Position + offsets["Left Arm"].Orientation, 0.5)
	avatar["Right Arm"].CFrame = avatar["Right Arm"].CFrame:Lerp(avatar.PrimaryPart.CFrame + offsets["Right Arm"].Position + offsets["Right Arm"].Orientation, 0.5)
end

function AvatarSystem:createAvatar(playerName)
	local avatarData = DevAvatarFolder[playerName].Value
	local avatar = characterFolder:FindFirstChild(avatarData):Clone()
	
	avatar.Parent = CamAvatarFolder

	local updateCoro = coroutine.wrap(updateAvatar(avatar, workspace.CurrentCamera))
	
	updateCoro()
end

function AvatarSystem:Mount()
    ChatSystem = self:GetSystem("ChatSystem")
    PluginUI = self:GetSystem("PluginUI")

    local FileSystem = self:GetSystem("FileSystem")

	DevAvatarFolder = FileSystem:Get("DevAvatars")
    CamAvatarFolder = FileSystem:Get("CamAvatars")

    local AvatarWidget = PluginUI:GetWidget("Avatar")
    
    Plugin = self.Plugin
    Maid = self.Maid

	local characters = characterFolder:GetChildren()
	local charValue = DevAvatarFolder:FindFirstChild(game.LocalPlayer.Name) or Instance.new("StringValue")
	charValue.Parent = DevAvatarFolder
	
	--Just sets the settings when a new player joins the team create and inits the plugin
	charValue.Name = game.Players.LocalPlayer.Name
	charValue.Value = Plugin:GetSetting("UserAvatar")
	
	local info = TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1, false, 0)
	local tween = game:GetService("TweenService"):Create(AvatarWidget.AvatarUI.Background, info, {Position = UDim2.new(0, -100, 0, 0)})
	tween:Play()

	for i, char in pairs(characters) do
		--clones the template and adds it to the list
		local displayChar = char:Clone()
		local button = avatar_template:Clone()
		button.Name = char.Name
		button.ZIndex = 2

		local cam = Instance.new("Camera")
		cam.Parent = button.CharacterViewer
		button.CharacterViewer.CurrentCamera = cam
		button.Name = "button_"..i

		displayChar.Parent = button.CharacterViewer
		cam.CFrame = CFrame.new(displayChar.HumanoidRootPart.Position + Vector3.new(0, 0, 1.5), displayChar.HumanoidRootPart.Position)
		button.Parent = AvatarWidget.AvatarUI.CharacterSelector

		Maid:Add(button.MouseButton1Click:Connect(function()
			--Change the character value
			Plugin:SetSetting("UserAvatar", displayChar.Name)
			DevAvatarFolder:FindFirstChild(game.Players.LocalPlayer.Name).Value = displayChar.Name
			AvatarWidget.AvatarUI.Title.Text = "Current Avatar: "..displayChar.Name
		end))
	end
	
	Maid:Add(DevAvatarFolder.ChildAdded:Connect(function(child)
		self:createAvatar(child.Name)
	end))
end

function AvatarSystem:OnClose()
    
end

return AvatarSystem