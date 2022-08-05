local Defer = {} 
Defer.__index = Defer

--[=[
    |> Defered Callback System

    most likely wont be used beyond a quick fix

    defer may not be the best name lol.

    This system will call the function only if no updates were given in a span of X seconds.
]=]

function Defer.new(Callback: (any) -> any, Timeout: number)
    local New = {
        Count = 0,
        Callback = Callback,
        Timeout = Timeout * 10,
        Reset = false,
        Alive = true
    }

    task.spawn(function()
        while New.Alive do
            if New.Reset then
                New.Count = 0
                New.Reset = false
            end

            task.wait(0.1)
            if New.Count <= New.Timeout then
                New.Count += 1
            end

            if New.Count == New.Timeout then
                Callback()
            end
        end
    end)

    return setmetatable(New, Defer)
end

function Defer:Call()
    self.Reset = true
end

function Defer:Clean()
    self.Alive = false
    self = nil
end


return Defer