--!strict

--[=[
    |> Avatar Manager

    Handles creation, state, and deletion of avatar instances.

    Written in ~1 hour so it may be a little scuffed lol
]=]
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--| Dependencies |----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local AvatarObject = require(script.Avatar)
local RunService = game:GetService("RunService")

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--| Type Definitions |----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

type AvatarGroup<T> = {AvatarObject.AvatarInstance}
type AnimationModelGroup<T> = {[string]: Model}

type AvatarManager = {
    AvatarInstances: AvatarGroup,
    AnimationModels: AnimationModelGroup
}

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--| Object Setup |----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local AvatarManager: AvatarManager = {
    AvatarInstances = {},
    AnimationModels = {},
}

--> Entrypoint method.
function AvatarManager:UseAvatar(ViewportFrame: ViewportFrame, PlayerName: string, Animated: boolean?)
    --! Add a check here to seeif the VPF has already been registered.
    
    local Avatar = AvatarObject.new(PlayerName, ViewportFrame, false)

    --! Create your viewport object here in its default, image like state. (Looking at camera)

    --> Use Avatar:SetModel() to tell the system which model will be used WITHIN the viewport frame.

    --> Create a AnimationModel that the 'Mimic' will follow.

    --> Finally, set the avatar to PLAY when on screen.
    _ = Animated ~= nil and Avatar:Play()

end

--> Main Runtime to apply transformations.
--! Hand this over to the maid at some point.
RunService.RenderStepped:Connect(function()
    --? There are ways to optimize this, but it shouldn't be too expensive.
    --? It would be best to have a setting to disable animations in the future. In that case, we would skip the
    --? following lines to keep the image static.


    --> Loop through all avatar AvatarInstances within the AvatarInstances table.
    for _, Avatar in pairs(AvatarManager.AvatarInstances) do

        --! Add a check here in the future to see if the VPF is on screen. We can do this by
        --! Checking its absoltue position relative to the entire chat container.
        --! Roblox may already do this, but I'm not entirely sure.

        --> Validate that animations are enabled.
        if not Avatar.Animated then continue end

        --> Reference the 'Mimic' (Model to 'Mimic' the animation model) created by UseAvatar() 
            --! If it's not set up yet, continue.
        local Mimic = Avatar.Model 
        if not Mimic then continue end

        --> Apply CFrames.
    end 
end)



return AvatarManager
