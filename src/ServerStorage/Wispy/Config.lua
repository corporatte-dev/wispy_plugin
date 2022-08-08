local Types = require(script.Parent.Types)

--[=[
    |> Config file for (cool name for framework here)
]=]

local Config: Types.Config = {
    Name = "Wispy",
    Version = "1.0.0",
    AssetID = 10487121830, -- When published, put new asset ID here.

    --> Core will create these folders on launch.
    Locations = {
        Wispy = game.Chat,
        message_logs = game.Chat.Wispy,
        dev_avatars = game.Chat.Wispy,
        cam_avatars = workspace.Terrain
    }
}   

return Config