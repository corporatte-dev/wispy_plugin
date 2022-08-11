
local Model = {}
local PhysicsService = game:GetService("PhysicsService")

local CollisionGroupName = "Wispy_Ignore_Collide"

--> Attempt to get collision group
local Success, _ = pcall(PhysicsService.GetCollisionGroupId, PhysicsService, CollisionGroupName)

--> If that fails, attempt to create it.
if not Success then
    Success, _ = pcall(PhysicsService.CreateCollisionGroup, PhysicsService, CollisionGroupName)
end

--> Make sure we set the group to ignore all collisions.
if Success then
    PhysicsService:CollisionGroupSetCollidable("Default", CollisionGroupName, false)
else
    CollisionGroupName = "Default"
end

function Model:Sanitize(Container: Folder | Model)
    for _, Object in ipairs(Container:GetDescendants()) do
        if Object:IsA("BasePart") then
            PhysicsService:SetPartCollisionGroup(Object, CollisionGroupName)
            Object.Locked = true
        end
    end
end

return Model