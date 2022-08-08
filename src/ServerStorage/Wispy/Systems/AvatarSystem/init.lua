local RunService = game:GetService("RunService")
local Types = require(script.Parent.Parent.Types)
local AvatarSystem = {} :: Types.AvatarSystem

local avatar_template = script.Parent.Parent.Assets.UITemplates.CharacterTemplate
local characterFolder = script.Parent.Parent.Assets.Characters
local clientScript = script.clientAvatar

local ChatSystem: Types.ChatSystem
local PluginUI: Types.PluginUI
local Maid: Types.MaidObject
local Plugin: Plugin
local DevAvatarFolder: Folder
local CamAvatarFolder: Folder

local Avatar: Model

function updateAvatar()
	if not Avatar then return end

	--local currentTime = tick()
	local offsets = {
		["Torso"] = {Position = Vector3.new(0, -0.5, 0), Rotation = CFrame.Angles(math.rad(-11.067), -math.pi, -0)},
		["Left Arm"] = {Position = Vector3.new(1, -0.5, 1)},
		["Right Arm"] = {Position = Vector3.new(-1, -0.5, 1)}
	}

	local CameraCFrame = game.Workspace.CurrentCamera.CFrame

	if Avatar.PrimaryPart.CFrame ~= CameraCFrame + offsets.Torso.Position then
		Avatar:PivotTo(CameraCFrame + offsets.Torso.Position)
	end
	
	task.wait()
end

function AvatarSystem:createAvatar(playerName)
	local avatarData = DevAvatarFolder[playerName].Value
	local avatar = characterFolder:FindFirstChild(avatarData):Clone()
end

function AvatarSystem:VisualizeAvatar(playerName)
	local avatarData = DevAvatarFolder[playerName].Value
	local new_client = clientScript:Clone()

	if CamAvatarFolder:FindFirstChild("avatar_"..playerName) then

		RunService:UnbindFromRenderStep("AvatarRuntime")

		local old_avatar = CamAvatarFolder:FindFirstChild("avatar_"..playerName)
		old_avatar:Destroy()
	end

	RunService:BindToRenderStep("AvatarRuntime", Enum.RenderPriority.Camera.Value, function()
		updateAvatar()
	end)
end

function AvatarSystem:Preload()
	DevAvatarFolder = self:GetFolder("dev_avatars")
    CamAvatarFolder = self:GetFolder("cam_avatars")

	print(DevAvatarFolder)
end

function AvatarSystem:SetAvatarModel(AvatarModel: Model)
	if Avatar then
		Avatar.Parent = nil
		Avatar:Destroy()
	end

	Avatar = AvatarModel
end

function AvatarSystem:Mount()
	script.clientAvatar.Disabled = true

    ChatSystem = self:GetSystem("ChatSystem")
    PluginUI = self:GetSystem("PluginUI")

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

			local new_avatar: Model = characterFolder:FindFirstChild(displayChar.Name):Clone()
			new_avatar.Name = "avatar_"..self.LocalPlayer.Name
			new_avatar.Parent = CamAvatarFolder
			new_avatar.PrimaryPart.CFrame = workspace.CurrentCamera.CFrame

			for _, Object: Part in ipairs(new_avatar:GetDescendants()) do
				if Object:IsA("BasePart") then
					Object.LocalTransparencyModifier = 1
					print 'ok invis'
				end
			end

			self:SetAvatarModel(new_avatar)

			script.HideModel:FireClient(self.LocalPlayer, new_avatar)
		end))
	end
	
	for i, value in pairs(DevAvatarFolder:GetChildren()) do
		Maid:Add(value.Changed:Connect(function()
			ChatSystem:UpdateChat()
			ChatSystem:UpdatePlrList()
		end))
	end

	Maid:Add(DevAvatarFolder.ChildAdded:Connect(function()
		ChatSystem:UpdatePlrList()
	end))

	self:VisualizeAvatar(charValue.Name)
end

function AvatarSystem:ClearAvatars()

end

function AvatarSystem:OnClose()
	RunService:UnbindFromRenderStep("AvatarRuntime")
	print 'yo'
end

return AvatarSystem