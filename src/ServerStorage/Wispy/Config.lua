local Workspace = game:GetService("Workspace")
local Types = require(script.Parent.Types)

--[=[
    |> Config file for (cool name for framework here)
]=]

local Config: Types.Config = {
    Name = "Wispy",
    Version = "1.0.0B",
    AssetID = 10487121830, -- When published, put new asset ID here.

    --> Here are the locations that our application will use
    --> Chat and Workspace already exist and they are not folders, so they are not registered.
    --| For example, message logs will be created at (game).Chat.Wispy
    Structure = {
        Chat = {
            Wispy = {
                message_logs = {},
                dev_avatars = {}
            }
        },
        
        Workspace = {
            Terrain = {
                cam_avatars = {}
            }
        }
    }
}

return Config