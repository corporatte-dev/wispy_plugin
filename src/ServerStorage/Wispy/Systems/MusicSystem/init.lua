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
    local sound = Instance.new("NumberValue")
    sound.Value = newEntry
    sound.Parent = MusicFolder
end

local function updatePlaylist()
    playlist = MusicFolder:GetChildren()
end

local function getCurrentSong(Music: Sound)
    for i, song in pairs(playlist) do
        if Music.SoundId == song then
            return i
        end
    end
end

local function changePos(Music: Sound, currentSong: number, direction: string)
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

    if success then
        MusicWidget.MusicUI.DiscFrame.Settings.Title.Text = info.Name
    end
end

function MusicSystem:Mount()
	--> Load Dependancies
	PluginUI = self:GetSystem("PluginUI")
    Maid = self.Maid

	MusicWidget = PluginUI:GetWidget("Music")
    MusicFolder = MusicSystem:GetFolder("music_folder")

    local music = Instance.new("Sound")
    music.Name = "Music"
    music.Parent = MusicWidget.MusicUI
    music.SoundId = playlist[1]

    local playing = false
    local debounce_1 = true
    local debounce_2 = true
    local debounce_3 = true
    local cooldown = 0.125

    --> Animate Background
    local info = TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1, false, 0)
	local tween = game:GetService("TweenService"):Create(MusicWidget.MusicUI.Background, info, {Position = UDim2.new(0, -100, 0, 0)})
	tween:Play()

    updatePlaylist()

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
                MusicWidget.MusicUI.DiscFrame.Settings.Play.Image = imageDictionary.PauseIcon
                playing = true
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
        updatePlaylist()
    end))

    Maid:Add(MusicFolder.ChildRemoved:Connect(updatePlaylist))
end

return MusicSystem