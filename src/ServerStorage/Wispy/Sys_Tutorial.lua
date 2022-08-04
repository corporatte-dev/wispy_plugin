----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--| Framework System Development Guide |----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--> First, to improve our development experience we have a type class.
--> This will allow us to have autocorrect on the framework functions!
local Types = require(script.Parent.Types)

--> For now, we are using the Type 'System' as we are creating a new system.
--! In the future, we may want to create our own type for this module to allow 
--! autocorrect in other places around our project.

--? Our own Typed would look like this:
-- local MySystem = {} :: Types.MySystem
local MySystem = {} :: Types.System

--> Lets set up some variables to be populated on mount. Lets add in the PluginUI
--> for instance. Lets also give it the Type of PluginUI (see Types.lua)
local PluginUI: Types.PluginUI

--> First, we have :Mount(). This method is required unless the NoMount flag is
-->  set. This will be called once the framework has injected the methods and variables.
--! DON'T call any of the methods listed yourself. They are called by the framework!
function MySystem:Mount()
    print 'Mounted!'

    --> Lets try our maid
    MySystem.Maid:Add()

    --> Lets try pulling a system
    PluginUI = MySystem:GetSystem("PluginUI")
    
    --> Lets try pulling a library.
    local RichText = MySystem:GetLib("RichText") :: Types.RichText
    local RichTextObject = RichText.New()
    RichTextObject:Animate(10)

    --> Try it! Type the line below and notice how we have auto complete without a reference!
    --PluginUI:GetButton("Chat"):SetActive(false)
end

--> But, what if we want some data to load in before we mount? In that case, we would
--> use the :Preload() method. This will be called before ANY Mount method is, allow us 
--> To avoid any nasty race conditions.
--? OPTIONAL!
function MySystem:Preload()
    print 'Called Before Mount!'
end

--> When the plugin deactivates, we may need to call some code to clean up our mess. In 
--> This case, use :OnClose()
--? OPTIONAL!
function MySystem:OnClose()
    print 'Closed!'
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--| Wierd Cases |----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--[[
    There may be a time where we want the system to only preload. See FileSystem for an example of this.
    In that case, we can use the NoMount flag.
]]

--! Uncomment to see it work!
--? MySystem.NoMount = true