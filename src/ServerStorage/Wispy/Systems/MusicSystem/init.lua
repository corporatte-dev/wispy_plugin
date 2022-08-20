local Types = require(script.Parent.Parent.Types)
local MusicSystem = {} :: Types.MusicSystem
local RS = game:GetService("RunService")
local MPS = game:GetService("MarketplaceService")

--> Typed Modules to be Loaded on Mount
local Maid: Types.MaidObject
local PluginUI: Types.PluginUI
local MusicFolder: Folder
local MusicWidget: DockWidgetPluginGui

local playlist

local imageDictionary = {
    PlayIcon = "rbxassetid://4918373417",
    PauseIcon = "rbxassetid://3192517633",
    Fast_Forward = "rbxassetid://4458820527",
    Fast_Rewind = "rbxassetid://4458823312"
}

local IconDictionary = {
    WarningIcon = "rbxassetid://10573766832",
    ErrorIcon = "rbxassetid://10573764025",
    StandardIcon = "rbxassetid://10573754579"
}

local function spinDisc(discInstance, toggle)
    if toggle then
        RS:BindToRenderStep("SpinningDisc", Enum.RenderPriority.Camera.Value, function()
            discInstance.Rotation = discInstance.Rotation + 3
        end)
    else
        RS:UnbindFromRenderStep("SpinningDisc")
    end
end

local function newSong(NewValue: string)
    local newEntry = "rbxassetid://"..NewValue
    local sound = Instance.new("StringValue")
    sound.Name = "Entry" .. #MusicFolder:GetChildren()
    sound.Value = newEntry
    sound.Archivable = false
    sound.Parent = MusicFolder
end

local function updatePlaylist()
    playlist = MusicFolder:GetChildren()
end

local function getCurrentSong(Music: Sound)
    for i, song in pairs(MusicFolder:GetChildren()) do
        if Music.SoundId == song.Value then
            return i
        end

        if Music.SoundId == "rbxassetid://142376088" then return 1 end
    end
end

local function changePos(Music: Sound, currentSong: number, direction: string)
    local newPosition: number
    Music.TimePosition = 0

    if direction == "Backward" then
        if currentSong == 1 then
            newPosition = #MusicFolder:GetChildren()
        else
            newPosition = currentSong - 1
        end
    elseif direction == "Forward" then
        if currentSong == #MusicFolder:GetChildren() then
            newPosition = 1
        else
            newPosition = currentSong + 1
        end
    end

    Music.SoundId = MusicFolder:GetChildren()[newPosition].Value
end

local function updateTitle(Music: Sound)
    local index = getCurrentSong(Music)

    if index ~= nil then
        MusicWidget.MusicUI.DiscFrame.Settings.Title.Text = "Current Playlist Position: "..index
    end
end

function MusicSystem:Mount()
	--> Load Dependancies
	PluginUI = self:GetSystem("PluginUI")
    Maid = self.Maid

	MusicWidget = PluginUI:GetWidget("Music")
    MusicFolder = MusicSystem:GetFolder("music_folder")

    updatePlaylist()

    local mouse = self.LocalPlayer:GetMouse()

    local music = MusicWidget.MusicUI.Music or Instance.new("Sound")
    music.Name = "Music"
    music.Parent = MusicWidget.MusicUI

    local sliderBG = MusicWidget.MusicUI.DiscFrame.SliderBG
    local slider = sliderBG:WaitForChild("Slider")
    local sliderText = sliderBG:WaitForChild("Amount")

    local snapAmount = 100
    local pixelsFromEdge = 5
    local movingSlider = false

    if MusicFolder:GetChildren()[1] ~= nil then
        music.SoundId = MusicFolder:GetChildren()[1].Value
    else
        music.SoundId = ""
    end

    local playing = false
    local debounce_1 = true
    local debounce_2 = true
    local debounce_3 = true
    local cooldown = 0.125

    --> Animate Background
    local info = TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1, false, 0)
	local tween = game:GetService("TweenService"):Create(MusicWidget.MusicUI.Background, info, {Position = UDim2.new(0, -100, 0, 0)})
	tween:Play()

    Maid:Add(music.Ended:Connect(function()
        local currentSong = getCurrentSong(music)
        music:Pause()
        changePos(music, currentSong, "Forward")
        music.TimePosition = 0
        music:Play()
    end))

    Maid:Add(music.Changed:Connect(function()
        updateTitle(music)
    end))

    Maid:Add(MusicWidget.MusicUI.DiscFrame.Settings.Play.MouseButton1Click:Connect(function()
        if debounce_1 then
            debounce_1 = false
            if playing then
                MusicWidget.MusicUI.DiscFrame.Settings.Play.Image = imageDictionary.PlayIcon
                playing = false
                if music.IsLoaded then
                    music:Pause()
                end
            else
                if music.SoundId == "" and MusicFolder:GetChildren()[1] ~= nil then
                    MusicWidget.MusicUI.DiscFrame.Settings.Play.Image = imageDictionary.PauseIcon
                    music.SoundId = MusicFolder:GetChildren()[1].Value
                    playing = true
                elseif music.SoundId == "" and MusicFolder:GetChildren()[1] == nil then
                    MusicSystem:Notify("You need to add song entrys before playing music!", IconDictionary.ErrorIcon, 2)
                elseif music.SoundId ~= "" and MusicFolder:GetChildren()[1] ~= nil then
                    playing = true
                    MusicWidget.MusicUI.DiscFrame.Settings.Play.Image = imageDictionary.PauseIcon
                end
                if music.IsLoaded then
                    music:Resume()
                end
            end
            spinDisc(MusicWidget.MusicUI.DiscFrame.Disc, playing)
            task.wait(cooldown)
            debounce_1 = true
        end
    end))

    Maid:Add(MusicWidget.MusicUI.DiscFrame.Settings.FF.MouseButton1Click:Connect(function()
        local currentSong = getCurrentSong(music)

        if debounce_2 then
            debounce_2 = false
            changePos(music, currentSong, "Forward")
            task.wait(cooldown)
            debounce_2 = true
        end
    end))

    Maid:Add(MusicWidget.MusicUI.DiscFrame.Settings.RR.MouseButton1Click:Connect(function()
        local currentSong = getCurrentSong(music)

        if debounce_3 then
            debounce_3 = false
            changePos(music, currentSong, "Backward")
            task.wait(cooldown)
            debounce_3 = true
        end
    end))

    Maid:Add(MusicWidget.MusicUI.DiscFrame.Settings.SoundBox.FocusLost:Connect(function(enterPressed)
        if not enterPressed then return end
        newSong(MusicWidget.MusicUI.DiscFrame.Settings.SoundBox.Text)
        MusicWidget.MusicUI.DiscFrame.Settings.SoundBox.Text = ""
        MusicSystem:Notify("Music entry has been added!", IconDictionary.StandardIcon, 2)
        updatePlaylist()
    end))

    Maid:Add(slider.MouseButton1Down:Connect(function()
        movingSlider = true
    end))
     
    Maid:Add(slider.MouseButton1Up:Connect(function()
        movingSlider = false
    end))

    Maid:Add(mouse.Button1Up:Connect(function()
        movingSlider = false
    end))

    Maid:Add(mouse.Move:Connect(function()
        if movingSlider then
            local yOffset = math.floor((mouse.Y - sliderBG.AbsolutePosition.Y) / snapAmount + 0.5) * snapAmount
            local yOffsetClamped = math.clamp(yOffset, pixelsFromEdge, sliderBG.AbsoluteSize.Y - pixelsFromEdge)
            
            local sliderPosNew = UDim2.new(slider.Position.X, 0, yOffsetClamped)
            
            slider.Position = sliderPosNew
            
            local roundedAbsSize = math.floor(sliderBG.AbsoluteSize.Y / snapAmount + 0.5) * snapAmount
            local roundedOffsetClamped = math.floor(yOffsetClamped / snapAmount + 0.5) * snapAmount
            
            local sliderValue = roundedOffsetClamped / roundedAbsSize
            
            music.Volume = sliderValue
            sliderText.Text = tostring(sliderValue)
        end
    end))

    Maid:Add(MusicFolder.ChildRemoved:Connect(updatePlaylist))
end

return MusicSystem