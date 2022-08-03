local ChatSystem = {}

local Types = require(script.Parent.Parent.Types)

local AvatarSystem: Types.AvatarSystem
local Maid: Types.Maid
local Plugin: Plugin

function ChatSystem:Run()
    AvatarSystem = self:GetSystem("AvatarSystem")
    Plugin = self.Plugin
    Maid = self.Maid
end

return ChatSystem