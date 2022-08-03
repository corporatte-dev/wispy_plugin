--[=[
    |> Avatar Class

    The avatar class contains raw data about each avatar rendering instance. It contains a 
    get/set API to easily manipulate this from anywhere in code.

    ! Bear in mind that the core variables are not read-only (as they should be). Avoid setting these variables.
]=]

export type AvatarInstance = {
    PlayerName: string,
    Animated: boolean,
    Viewport: ViewportFrame,
    Model: Model,

    Pause: (self: AvatarInstance) -> nil,
    Play: (self: AvatarInstance) -> nil,

    SetModel: <Model>(self: AvatarInstance, Model: Model) -> nil
}

local Avatar: AvatarInstance = {}
Avatar.__index = Avatar

--> Create a new Avatar Instance
function Avatar.new(PlayerName: string, Viewport: ViewportFrame, Animated: boolean)
    return setmetatable({
        PlayerName = PlayerName,
        Animated = Animated,
        Viewport = Viewport,
        Model = nil,
    }, Avatar) :: AvatarInstance
end

--> Set Animation State
function Avatar:Pause()
    self.Animated = false
end

function Avatar:Play()
    self.Animated = true
end

function Avatar:SetModel(Model: Model)
    self.Model = Model
end



return Avatar