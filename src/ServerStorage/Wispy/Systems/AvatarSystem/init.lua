local Types = require(script.Parent.Parent.Types)
local AvatarSystem = {} :: Types.AvatarSystem

--[=[
    |> Avatar System


]=]

local RunService = game:GetService("RunService")

--> Locations
local AvatarTemplate = script.Parent.Parent.Assets.UITemplates.CharacterTemplate
local CharacterFolder = script.Parent.Parent.Assets.Characters

--> Variables
local ChatSystem: Types.ChatSystem
local PluginUI: Types.PluginUI
local Maid: Types.MaidObject
local Plugin: Plugin
local DevAvatarFolder: Folder
local CamAvatarFolder: Folder
local AvatarWidget: any
local Model: Types.ModelLibrary

local Avatar: Model

local arm_sens = 0.25

--> Internal Methods
function VisualizeAvatar(playerName)
	if CamAvatarFolder:FindFirstChild("character_"..playerName):FindFirstChild("avatar_"..playerName) then
		local old_avatar = CamAvatarFolder:FindFirstChild("character_"..playerName):FindFirstChild("avatar_"..playerName)
		old_avatar:Destroy()
	end

	local character_folder = CamAvatarFolder:FindFirstChild("character_"..playerName)

	local arm1 = character_folder:FindFirstChild("LeftArm_"..playerName) or script.Parent.Parent.Assets.ArmTemplate:Clone()
	arm1.Name = "LeftArm_"..playerName
	arm1.Parent = character_folder
	arm1.LocalTransparencyModifier = 1
	arm1.Shell.LocalTransparencyModifier = 1

	local arm2 = character_folder:FindFirstChild("RightArm_"..playerName) or script.Parent.Parent.Assets.ArmTemplate:Clone()
	arm2.Name = "RightArm_"..playerName
	arm2.Parent = character_folder
	arm2.LocalTransparencyModifier = 1
	arm2.Shell.LocalTransparencyModifier = 1


	RunService:BindToRenderStep("AvatarRuntime", Enum.RenderPriority.Camera.Value, function()
		if not Avatar then return end

        --local currentTime = tick()
        local offsets = {
            ["Torso"] = {Position = Vector3.new(0, -0.25, 0)},
            ["Left Arm"] = {Position = CFrame.new(Vector3.new(-0.75, -0.25, -0.25))},
            ["Right Arm"] = {Position = CFrame.new(Vector3.new(0.75, -0.25, -0.25))}
        }

																 -- For testing
        local CameraCFrame = game.Workspace.CurrentCamera.CFrame --! + (game.Workspace.CurrentCamera.CFrame.LookVector * 10)

		arm1.Color = Avatar["Left Arm"].Color
		arm2.Color = Avatar["Right Arm"].Color

		-- Due to the use of PivotTo, we would need to seperate the arms from this model. 
        if Avatar.PrimaryPart.CFrame ~= CameraCFrame + offsets.Torso.Position then
            Avatar:PivotTo(CameraCFrame + offsets.Torso.Position)
        end

		-- This if statement will never return true as we are using PivotTo()
		if arm1.CFrame ~= CameraCFrame * offsets["Left Arm"].Position then
			arm1.CFrame = arm1.CFrame:Lerp((CameraCFrame * offsets["Left Arm"].Position), arm_sens)
		end

		if arm2.CFrame ~= CameraCFrame * offsets["Right Arm"].Position then
			arm2.CFrame = arm2.CFrame:Lerp(CameraCFrame * offsets["Right Arm"].Position, arm_sens)
		end
	end)
end

--> Called before :Mount()
function AvatarSystem:Preload()
	DevAvatarFolder = self:GetFolder("dev_avatars")
    CamAvatarFolder = self:GetFolder("cam_avatars")
end

--> Set the current avatar model to display in game.
function AvatarSystem:SetAvatarModel(AvatarModel: Model)
	if Avatar then
		Avatar.Parent = nil
		Avatar:Destroy()
	end

	Model:Sanitize(AvatarModel)
	Avatar = AvatarModel
end

function AvatarSystem:Mount()
    --> Register Systems 
    ChatSystem = self:GetSystem("ChatSystem")
    PluginUI = self:GetSystem("PluginUI")

	local new_folder: Folder = CamAvatarFolder:FindFirstChild("character_"..self.LocalPlayer.Name) or Instance.new("Folder")
	new_folder.Parent = CamAvatarFolder
	new_folder.Name = "character_"..self.LocalPlayer.Name

    --> Widgets
    AvatarWidget = PluginUI:GetWidget("Avatar")

	Model = AvatarSystem:GetLib("Model")

    --> Unpack variables into script scope
    Plugin = self.Plugin
    Maid = self.Maid

    --> Animate Background
    local info = TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1, false, 0)
	local tween = game:GetService("TweenService"):Create(AvatarWidget.AvatarUI.Background, info, {Position = UDim2.new(0, -100, 0, 0)})
	tween:Play()

    --> Create a new Character Value within DevAvatarFolder
	local charValue = DevAvatarFolder:FindFirstChild(self.LocalPlayer.Name) or Instance.new("StringValue")
	charValue.Parent = DevAvatarFolder
	charValue.Name = self.LocalPlayer.Name
	charValue.Value = Plugin:GetSetting("UserAvatar")

    --> Loop through each character model.
    for i, Character in pairs(CharacterFolder:GetChildren()) do
        --! In the future, lets change this to support the avatar system.

        --> clones the template and adds it to the list
		local displayChar = Character:Clone()
		local button = AvatarTemplate:Clone()
		button.Name = Character.Name

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

			local new_avatar: Model = CharacterFolder:FindFirstChild(displayChar.Name):Clone()
			new_avatar.Name = "avatar_"..self.LocalPlayer.Name
			new_avatar.Parent = new_folder
			new_avatar.PrimaryPart.CFrame = workspace.CurrentCamera.CFrame

			for _, Object: Part in ipairs(new_avatar:GetDescendants()) do
				if Object:IsA("BasePart") then
					--! Disabled for Testing
					Object.LocalTransparencyModifier = 1

					if Object.Name == "Left Arm" or Object.Name == "Right Arm" or Object.Name == "LeftArm2" or Object.Name == "RightArm2" then
						Object.Transparency = 1
					end
				end
				if Object:IsA("ParticleEmitter") then
					Object.Enabled = false
				end
			end

			self:SetAvatarModel(new_avatar)
		end))
    end

    --> Update chat and Player list when Dev Avatars Change
    for _, value in pairs(DevAvatarFolder:GetChildren()) do
		Maid:Add(value.Changed:Connect(function()
			ChatSystem:UpdateChat()
			ChatSystem:UpdatePlrList()
		end))
	end

    --> Update the player list when a new player joins.
    Maid:Add(DevAvatarFolder.ChildAdded:Connect(function()
		ChatSystem:UpdatePlrList()
	end))

	VisualizeAvatar(charValue.Name)
end

--> Ran when plugin is stopped.
function AvatarSystem:OnClose()
    RunService:UnbindFromRenderStep("AvatarRuntime")
end

return AvatarSystem