local Types = require(script.Parent.Parent.Types)
local MusicSystem = {} :: Types.MusicSystem
local RS = game:GetService("RunService")
local MPS = game:GetService("MarketplaceService")

--> Typed Modules to be Loaded on Mount
local Maid: Types.MaidObject
local Plugin: Plugin
local PluginUI: Types.PluginUI

local MusicWidget: DockWidgetPluginGui

local movingSlider = false

local Settings = {
    snapAmount = 100,
    pixelsFromEdge = 10
}

local imageDictionary = {
    PlayIcon = "rbxassetid://4918373417",
    PauseIcon = "rbxassetid://3192517633",
    Fast_Forward = "rbxassetid://4458820527",
    Fast_Rewind = "rbxassetid://4458823312"
}

local playlist = {
    "rbxassetid://10159111929",
    "rbxassetid://6276207937",
    "rbxassetid://10032693585"
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

local function getCurrentSong(Music: Sound)
    for i, song in pairs(playlist) do
        if Music.SoundId == song then
            return i
        end
    end
end

local function newSong(Music: Sound, currentSong: number, direction: string)
    local newPosition: number
    Music.TimePosition = 0

    if direction == "Backward" then
        if currentSong == 1 then
            newPosition = #playlist
        else
            newPosition = currentSong - 1
        end
    elseif direction == "Forward" then
        if currentSong == #playlist then
            newPosition = 1
        else
            newPosition = currentSong + 1
        end
    end

    Music.SoundId = playlist[newPosition]
end

local function updateTitle(Music: Sound)
    local success, info = pcall(MPS.GetProductInfo, MPS, tonumber(Music.SoundId))

    if success and info.AssetTypeId == Enum.AssetType.Audio then
        MusicWidget.MusicUI.DiscFrame.Settings.Title.Text = info.Name
    end
end

function MusicSystem:Mount()
	--> Load Dependancies
	PluginUI = self:GetSystem("PluginUI")
    Plugin = self.Plugin
    Maid = self.Maid

	MusicWidget = PluginUI:GetWidget("Music")

    local music = Instance.new("Sound")
    music.Name = "Music"
    music.Parent = MusicWidget.MusicUI
    music.SoundId = playlist[1]

    local playing = false
    local debounce_1 = true
    local debounce_2 = true
    local debounce_3 = true
    local cooldown = 0.125

    local slider = MusicWidget.MusicUI.DiscFrame.VolumeSlider.Slider
    local sliderBG = MusicWidget.MusicUI.DiscFrame.VolumeSlider
    local mouse = self.LocalPlayer:GetMouse()

    --> Animate Background
    local info = TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1, false, 0)
	local tween = game:GetService("TweenService"):Create(MusicWidget.MusicUI.Background, info, {Position = UDim2.new(0, -100, 0, 0)})
	tween:Play()

    Maid:Add(music.Ended:Connect(function()
        local currentSong = getCurrentSong(music)
        music:Pause()
        newSong(music, currentSong, "Forward")
        music.TimePosition = 0
        music:Play()
    end))

    Maid:Add(slider.MouseButton1Down:Connect(function()
        movingSlider = true
    end))
     
    Maid:Add(slider.MouseButton1Up:Connect(function()
        movingSlider = false
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
                MusicWidget.MusicUI.DiscFrame.Settings.Play.Image = imageDictionary.PauseIcon
                playing = true
                if music.IsLoaded then
                    music:Resume()
                end
            end
            spinDisc(MusicWidget.MusicUI.DiscFrame.Disc, playing)
            updateTitle(music)
            task.wait(cooldown)
            debounce_1 = true
        end
    end))

    Maid:Add(MusicWidget.MusicUI.DiscFrame.Settings.FF.MouseButton1Click:Connect(function()
        local currentSong = getCurrentSong(music)

        if debounce_2 then
            debounce_2 = false
            newSong(music, currentSong, "Forward")
            updateTitle(music)
            task.wait(cooldown)
            debounce_2 = true
        end
    end))

    Maid:Add(MusicWidget.MusicUI.DiscFrame.Settings.RR.MouseButton1Click:Connect(function()
        local currentSong = getCurrentSong(music)

        if debounce_3 then
            debounce_3 = false
            newSong(music, currentSong, "Backward")
            updateTitle(music)
            task.wait(cooldown)
            debounce_3 = true
        end
    end))

    Maid:Add(mouse.Button1Up:Connect(function()
        movingSlider = false
    end))
     
    Maid:Add(mouse.Move:Connect(function()
        if movingSlider then
            local xOffset = math.floor((mouse.X - sliderBG.AbsolutePosition.X) / Settings.snapAmount + 0.5) * Settings.snapAmount
            local xOffsetClamped = math.clamp(xOffset, Settings.pixelsFromEdge, sliderBG.AbsoluteSize.X - Settings.pixelsFromEdge)
            local sliderPosNew = UDim2.new(0, xOffsetClamped, slider.Position.Y)
        
            slider.Position = sliderPosNew
            
            local roundedAbsSize = math.floor(sliderBG.AbsoluteSize.X / Settings.snapAmount + 0.5) * Settings.snapAmount
            local roundedOffsetClamped = math.floor(xOffsetClamped / Settings.snapAmount + 0.5) * Settings.snapAmount
            
            local sliderValue = roundedOffsetClamped / roundedAbsSize
            
            music.Volume = sliderValue
            MusicWidget.MusicUI.DiscFrame.VolumeSlider.Amount.Text = tostring(sliderValue)
        end
    end))
end

return MusicSystem