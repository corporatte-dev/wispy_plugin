local Types = require(script.Parent.Parent.Parent.Types)
local ChatUtil = {} :: Types.System

local RNG = Random.new(tick())

--> Maybe move this to global util if needed elsewhere.
function ChatUtil:CreateID(Digits: number)
    local Number = ""

    for _ = 1, Digits do
        Number ..= RNG:NextInteger(1, 9)
    end
    
    return tonumber(Number)    
end

--> Find an ID in the message list.
function ChatUtil:FindID(ID: number)
    for _, Message: StringValue in ipairs(self:GetFolder("message_logs"):GetChildren()) do
        local Hit = Message:GetAttribute("MessageID") 

        if Hit and Hit == ID then
            return Message
        end
    end

    return nil
end

--> Create a new chat message record and place it in message_logs.
function ChatUtil:CreateRecord(FilteredMessage: string)
    local Message = Instance.new("StringValue")
	local Author = Instance.new("StringValue")
	local Timestamp = Instance.new("NumberValue")
    
    local ID = self:CreateID(8)

    --> Ensure that we don't have duplicates.
    while ChatUtil:FindID(ID) do 
        task.wait()
        ID = self:CreateID(8)
    end

	Message:SetAttribute("MessageID", ID)

	Message.Name = "message_" .. ID
	Message.Value = FilteredMessage

	Author.Name = "author"
	Author.Value = self.LocalPlayer.Name
	
    Timestamp.Name = "timestamp"
	Timestamp.Value = os.time()

    Timestamp.Parent = Message
	Author.Parent = Message

    Message.Parent = self:GetFolder("message_logs")

    return Message
end

return ChatUtil