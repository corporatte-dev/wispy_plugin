local Types = require(script.Parent.Parent.Types)
local FileSystem = {} :: Types.FileSystem 
FileSystem.NoMount = true

--[=[
    |> File System

    Handles creation of Folders in specific places around the app. If you ever want to change these, they are in a single
    place!
]=]

local Locations = {}

function CreateFolder(Name, Location)
    if Location:FindFirstChild(Name) then
        return Location:FindFirstChild(Name)
    else
        local Folder = Instance.new("Folder")
        Folder.Name = Name
        Folder.Parent = Location
        return Folder
    end
end

function FileSystem:Get(Name: string) 
    return Locations[Name]
end

function FileSystem:Preload()
    Locations = {
        WispyChat = CreateFolder("Wispy", game.Chat),
        Messages = CreateFolder("message_logs", game.Chat.Wispy),
        DevAvatars = CreateFolder("dev_avatars", game.Chat.Wispy),
        CamAvatars = CreateFolder("cam_avatars", workspace.Terrain)
    }
end

return FileSystem