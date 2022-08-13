local Notify = {
    NotificationDictionary = {
		Warning = {
            ProgressColor = Color3.fromHex("3edc7a"),
            SoundEffect = script.Parent.Parent.Assets.SFX
        },

		Error = {
            ProgressColor = Color3.fromHex("ed5730"),
            SoundEffect = script.Parent.Parent.Assets.SFX
        },

		Standard = {
            ProgressColor = Color3.fromHex("9c65d1"),
            SoundEffect = script.Parent.Parent.Assets.SFX
        },
	}
}
local CoreGUI = game:GetService("CoreGui")
local TextService = game:GetService("TextService")
local Plugin: Plugin

--[=[
    |> Noify Helper

    Boring implementation of notification system.
    
    I really want to make this better in the future, but this is a working prototype.
]=]

local NotifyGUI = CoreGUI:FindFirstChild("WispyNotifications")  
local NotifyTemplate: Frame = script.Parent.Parent.Assets.UITemplates.NotificationTemplate:Clone()

--> If it doesn't exist, lets create it
if not NotifyGUI then
    NotifyGUI = Instance.new("ScreenGui")
    NotifyGUI.Parent = CoreGUI
    NotifyGUI.Name = "WispyNotifications"
end

--> Clear any stuck notifications
NotifyGUI:ClearAllChildren()

NotifyTemplate.Parent = NotifyGUI

local Queue = {}
local QueueRunning = false

function StepQueue(SelfCalled: boolean?)
    if QueueRunning and not SelfCalled then return end
    QueueRunning = true

    local Next = Queue[1]

    if Next then
        Next = table.remove(Queue, 1)

        --> Calc Notification Size
        local Bounds = TextService:GetTextSize(Next[2], 14, Enum.Font.GothamBold, Vector2.new(300, 500))
        NotifyTemplate.Size = UDim2.fromOffset(
            math.clamp((Bounds.X), 0, 300) + 50 + 10,
            math.clamp(Bounds.Y, 30, 500) + 10
        )

        --> Set its Properties
        NotifyTemplate.Emoji.Icon.Image = Next[2]
        NotifyTemplate.Content.Content.Text = Next[3]

        NotifyTemplate.Progress.Value.Size = UDim2.new(1, 0, 0, 3)
        
        for _, key in pairs(Notify.NotificationDictionary) do
            if Next[1] ~= key then
                warn("First Parameter does not correlate to any keys in the dictionary!")
                break
            end
        end

        local NotifySFX = Notify.NotificationDictionary[Next[1]].SoundEffect:Clone()
        NotifyTemplate.Progress.Value.BackgroundColor3 = Notify.NotificationDictionary[Next[1]].ProgressColor

        --> Movement FX
        --! Might add more SFX options, but I don't want to make too many params into :Say()
        if Plugin:GetSetting("IsMuted") == true then
            local SFX = NotifySFX:Clone()
            SFX.Parent = game.SoundService
            game.SoundService:PlayLocalSound(NotifySFX)
            task.wait(SFX.TimeLength)
           SFX:Destroy()
        end
        NotifyTemplate:TweenPosition(UDim2.new(0.5, 0, 0, 5), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
        NotifyTemplate.Progress.Value:TweenSize(UDim2.new(0, 0, 0, 3), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, Next[4] + 0.3, true)
        task.wait(Next[4] + 0.3)
        NotifyTemplate:TweenPosition(UDim2.new(0.5, 0, 0, -NotifyTemplate.Size.Y.Offset - 5), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.2, true)
        task.wait(0.2)

        if Queue[1] then
            StepQueue(true)
        else
            QueueRunning = false
        end
    end
end

function Notify:Say(MessageType: string, Emoji: string,  Text: string, Duration: number?)
    task.spawn(function()
        table.insert(Queue, {MessageType, Emoji, Text, Duration or 2})
        StepQueue()
    end)
end

return Notify