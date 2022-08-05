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

	avatar.Torso.CFrame = avatar.Torso.CFrame:Lerp(CFrame.new(goal.Position, Vector3.new(goal.LookVector, 0, 0)))

    avatar.Head.CFrame = goal
	avatar["Left Arm"].CFrame = avatar["Left Arm"].CFrame:Lerp(goal + offsets["Left Arm"].Position, 0.75)
	avatar["Right Arm"].CFrame = avatar["Right Arm"].CFrame:Lerp(goal + offsets["Right Arm"].Position, 0.75)
end

--function AvatarSystem:createAvatar(playerName)
--	local avatarData = DevAvatarFolder[playerName].Value
--	local avatar = characterFolder:FindFirstChild(avatarData):Clone()
--end

function AvatarSystem.visualizeAvatar(playerName)
	local avatarData = DevAvatarFolder[playerName].Value
	local avatar = characterFolder:FindFirstChild(avatarData):Clone() or CamAvatarFolder:FindFirstChild("avatar_"..playerName)
	avatar.Name = "avatar_"..playerName
	avatar.Parent = CamAvatarFolder

	local updateCoro = coroutine.wrap(updateAvatar(avatar, workspace.CurrentCamera.CFrame))
	
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
	local charValue = DevAvatarFolder:FindFirstChild(self.LocalPlayer.Name) or Instance.new("StringValue")
	charValue.Parent = DevAvatarFolder
	
	--> Just sets the settings when a new player joins the team create and inits the plugin
	charValue.Name = self.LocalPlayer.Name
	charValue.Value = Plugin:GetSetting("UserAvatar")
	
	local info = TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1, false, 0)
	local tween = game:GetService("TweenService"):Create(AvatarWidget.AvatarUI.Background, info, {Position = UDim2.new(0, -100, 0, 0)})
	tween:Play()

	for i, char in pairs(characters) do
		--> clones the template and adds it to the list
		local displayChar = char:Clone()
		local button = avatar_template:Clone()
		button.Name = char.Name

		local cam = Instance.new("Camera")
		cam.Parent = button.CharacterViewer
		button.CharacterViewer.CurrentCamera = cam
		button.Name = "button_"..i

		displayChar.Parent = button.CharacterViewer
		cam.CFrame = CFrame.new(displayChar.HumanoidRootPart.Position + Vector3.new(0, 0, 1.5), displayChar.HumanoidRootPart.Position)
		button.Parent = AvatarWidget.AvatarUI.CharacterSelector

		Maid:Add(button.MouseButton1Click:Connect(function()
			--> Change the character value
			Plugin:SetSetting("UserAvatar", displayChar.Name)
			DevAvatarFolder:FindFirstChild(self.LocalPlayer.Name).Value = displayChar.Name
			AvatarWidget.AvatarUI.Title.Text = "Current Avatar: "..displayChar.Name
		end))
	end
	
	for i, value in pairs(DevAvatarFolder:GetChildren()) do
		Maid:Add(value.Changed:Connect(function()
			ChatSystem:UpdatePlrList()
		end))
	end

	Maid:Add(DevAvatarFolder.ChildAdded:Connect(function(child)
		--self:visualizeAvatar(child.Name)
		ChatSystem:UpdatePlrList()
	end))
end

function AvatarSystem:OnClose()
    
end

return AvatarSystem