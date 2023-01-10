local Types = require(script.Parent.Types)

--[=[
    |> Config file for (cool name for framework here)
]=]

local Config: Types.Config = {
    Name = "Wispy",
    Version = "1.0.1",
    AssetID = 10422380892, -- When published, put new asset ID here.

    --> Here are the locations that our application will use
    --> Chat and Workspace already exist and they are not folders, so they are not registered.
    --| For example, message logs will be created at (game).ServerStorage.Wispy
    Structure = {
        ServerStorage = {
            Wispy = {
                message_logs = {},
                dev_avatars = {}
            }
        },
        
        Workspace = {
            Terrain = {
                cam_avatars = {}
            }
        },

        SoundService = {
            music_folder = {}
        }
    }
}

return Config