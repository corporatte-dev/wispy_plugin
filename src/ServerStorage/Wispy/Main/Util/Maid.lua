--!strict

--[[
	Simple maid alternative by frriend
]]--

local Maid = {}
Maid.__index = Maid

-- Create a new instance of the maid.
function Maid.new()
	return setmetatable({
		Events = {}
	}, Maid)
end

-- Hand over a connection for the maid to remember.
function Maid:Add(Event: RBXScriptConnection)
	if self.Events ~= nil then
		table.insert(self.Events, Event)
	else
		warn("Maid: You need to call Maid.new().")
	end
end

-- Clean all connections handed to maid.
function Maid:Clean() 
	print(("Cleaned %i Connections"):format(#self.Events))
	
	for _, Event: RBXScriptConnection in ipairs(self.Events) do
		Event:Disconnect()
	end
end

return Maid
