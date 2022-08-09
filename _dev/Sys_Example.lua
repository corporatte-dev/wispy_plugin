----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--| Example System for our plugin. Drag it into Systems to see it work! |----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local Types = require(script.Parent.Parent.Types)
local MySystem = {} :: Types.System

--[=[
    |> MySystem

    This is my awesome system!
]=]

--> References
local PluginUI: Types.PluginUI

--> Variables
local MyRandomNumber: number

--> Expose an API To other systems to allow them to read our random number
function MySystem:GetRandomNumber()
    return MyRandomNumber
end

--> Get a random number before any modules Mount
function MySystem:Preload()
    print('Preparing your random number...')
    MyRandomNumber = Random.new(tick()):NextInteger(1, 100000)

    --! Notice how the wait prevents the plugin from starting immediately.
    task.wait(3)
end

--> Run our main code on mount
function MySystem:Mount()
    --> Print our random number
    print (("Your random number is %i"):format(MyRandomNumber))

    --> Let's watch for additions to the workspace and hand it to the maid
    MySystem.Maid:Add(workspace.DescendantAdded:Connect(function()
        print 'A Child was added, and we are safe from memory leaks!'
    end))

    --> Let's disable the chat button.
    PluginUI = MySystem:GetSystem("PluginUI")
    PluginUI:GetButton("Chat").Enabled = false
end

--> When our plugin gets disabled,
function MySystem:OnClose()
    print 'Our plugin was disabled. :('
end

return MySystem