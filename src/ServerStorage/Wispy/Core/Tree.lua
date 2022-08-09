local Tree = {}

--[=[
    |> Tree Module

    Local Tree
]=]

function CreateFolder(Name: string, Location: any)
    if Location:FindFirstChild(Name) then
        return Location:FindFirstChild(Name)
    else
        local Folder = Instance.new("Folder")
        Folder.Name = Name
        Folder.Parent = Location
        return Folder
    end
end

--> Create files based on Config.Structure
function Tree:CreateStucture(Structure: any)
    local List = {}

    local function Repeat(Branch, Current)
        for Title, Data in pairs(Branch) do
            if Current:FindFirstChild(Title) == nil or Current[Title]:IsA("Folder") then
                List[Title] = CreateFolder(Title, Current)
            end

            Repeat(Data, Current[Title])
        end
    end

    Repeat(Structure, game)

    return List
end

return Tree