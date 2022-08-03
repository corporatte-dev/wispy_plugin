local AvatarSystem = {}

local Types = require(script.Parent.Parent.Types)

local ChatSystem: Types.ChatSystem
local Maid: Types.Maid
local Plugin: Plugin

function AvatarSystem:Run()
    ChatSystem = self:GetSystem("ChatSystem")
    Plugin = self.Plugin
    Maid = self.Maid
end

return AvatarSystem