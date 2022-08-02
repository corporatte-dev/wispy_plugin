--[[Corporatte, AvatarModule, Wispy Plugin]]--

local module = {}

local mainScript = script.Parent
local avatar_template = script.Parent.Parent.Assets.UITemplates.CharacterTemplate
local characterFolder = script.Parent.Parent.Assets.Characters

local function customLerp(a, b, c)
	return a + (b - a) * c
end

function updateAvatar(avatar, goal)
	local currentTime = tick()
	local offsets = {
		HMR = Vector3.new(0, -1, 0),
		["Left Arm"] = {Position = Vector3.new(1, -0.5, 1), Orientation = CFrame.Angles(math.rad(-22.13), 0, 0)},
		["Right Arm"] = {Position = Vector3.new(-1, -0.5, 1), Orientation = CFrame.Angles(math.rad(-22.13), 0, 0)},
	}
	
	--Bobble CFrame (HumanoidRootPart)
	local bobbleX = math.cos(currentTime * 10) * 0.25
	local bobbleY = math.abs(math.sin(currentTime * 10)) * 0.25
	local bobbleVector = Vector3.new(bobbleX, bobbleY, 0)
	
	--BodyParts
	avatar.PrimaryPart.CFrame = avatar.PrimaryPart.CFrame:Lerp(goal.CFrame.Position, 0.25)
	avatar["Left Arm"].CFrame = avatar["Left Arm"].CFrame:Lerp(avatar.PrimaryPart.CFrame.Position + offsets["Left Arm"], 0.5)
	avatar["Right Arm"].CFrame = avatar["Right Arm"].CFrame:Lerp(avatar.PrimaryPart.CFrame.Position + offsets["Right Arm"], 0.5)
end

function module.createAvatar(playerName)
	local avatarData = game.Chat.Wispy.dev_avatars[playerName].Value
	local avatar = characterFolder:FindFirstChild(avatarData):Clone()
	
	avatar.Parent = workspace.Camera.cam_avatars
	
	local updateCoro = coroutine.wrap(updateAvatar(avatar, workspace.CurrentCamera))
	
	updateCoro()
end

--Creates the plugin folders and handles the avatar change
function module:Init(avatar_widget, plugin, Maid)
	if not game.Chat.Wispy:FindFirstChild("dev_avatars") or not workspace.Camera:FindFirstChild("cam_avatars") then
		local widget_avatarFolder = Instance.new("Folder", game.Chat.Wispy)
		widget_avatarFolder.Name = "dev_avatars"
		local camera_avatarFolder = Instance.new("Folder", workspace.Camera)
		camera_avatarFolder.Name = "cam_avatars"
	end
	local characters = characterFolder:GetChildren()
	local charValue = Instance.new("StringValue", game.Chat["Wispy"].dev_avatars)
	
	--Just sets the settings when a new player joins the team create and inits the plugin
	charValue.Name = game.Players.LocalPlayer.Name
	charValue.Value = plugin:GetSetting("UserAvatar")
	
	for i, char in pairs(characters) do
		--clones the template and adds it to the list
		local displayChar = char:Clone()
		local button = avatar_template:Clone()
		button.Name = char.Name

		local cam = Instance.new("Camera", button.CharacterViewer)
		button.CharacterViewer.CurrentCamera = cam

		displayChar.Parent = button.CharacterViewer
		cam.CFrame = CFrame.new(displayChar.HumanoidRootPart.Position + Vector3.new(0, 0, 1.5), displayChar.HumanoidRootPart.Position)
		button.Parent = avatar_widget.AvatarUI.CharacterSelector

		Maid:Add(button.MouseButton1Click:Connect(function()
			--Change the character value
			plugin:SetSetting("UserAvatar", displayChar.Name)
			game.Chat.Wispy.dev_avatars:FindFirstChild(game.Players.LocalPlayer.Name).Value = displayChar.Name
			avatar_widget.AvatarUI.Title.Text = "Current Avatar: "..displayChar.Name
		end))
	end
	
	Maid:Add(game.Chat.Wispy.dev_avatars.ChildAdded:Connect(function(child)
		local newChar = child.Value
		module.createAvatar(child.Name)
	end))
end

return module