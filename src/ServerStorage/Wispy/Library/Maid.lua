--!strict

--[[
	Simple maid alternative by frriend
]]--

local Maid = {}
Maid.__index = Maid

-- Create a new instance of the maid.
function Maid.new()
	return setmetatable({
		Objects = {}
	}, Maid)
end

-- Hand over a connection for the maid to remember.
function Maid:Add(Event: RBXScriptConnection | Instance)
	if self.Objects ~= nil then
		table.insert(self.Objects, Event)
	else
		warn("Maid: You need to call Maid.new().")
	end
end

-- Clean all connections handed to maid.
function Maid:Clean()
	--! DEBUG ONLY 
	local Record = {
		Instances = 0,
		Events = 0
	}

	for _, Object: RBXScriptConnection | Instance in ipairs(self.Objects) do
		if typeof(Object) == "Instance" then
			Object.Parent = nil
			Object:Destroy()
			Record.Instances += 1
		elseif typeof(Object) == "RBXScriptConnection" then
			Object:Disconnect()
			Record.Events += 1
		end
	end

	--! DEBUG ONLY
	local Output = "Cleaned "
	for Key, Value in pairs(Record) do
		if Value > 0 then
			Output = Output .. (" %i %s,"):format(Value, Key)
		end
	end
	--print(Output:sub(0, Output:len() - 1) .. ".")
end

return Maid
