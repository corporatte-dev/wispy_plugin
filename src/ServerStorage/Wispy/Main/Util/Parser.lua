--!strict

--[=[
    |> Markdown Parser

    Parses markdown within a string to be displayed via RichText. 

    frriend | 8/2/22
]=]

local MarkdownParser = {}

local Tokens = {
    ["*"] = "i",
    ["**"] = "b"
}

function MarkdownParser:Parse(Input: string)
    local CompletedIndices = {}

    local function FindClosing(Origin: number, MatchTo: string)

        --> Loop through the remainder of the string
        for First, Last in utf8.graphemes(Input:sub(Origin, Input:len())) do
            local Character = Input:sub(First, Last)

            if Character == MatchTo then
               return First 
            end
        end
    end

    --> First, loop through each grapheme in the string.
    for First, Last in utf8.graphemes(Input) do
        local Character = Input:sub(First, Last)

        if Tokens[Character] then
            local Start = FindClosing(First, Character)

            if Start then
                --> We have a closing tag. Lets check and make sure its not directly next to the opening tag.

                print 'woo'
            end
        end
    end
end



return MarkdownParser