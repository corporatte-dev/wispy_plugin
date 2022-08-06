local character = script.Parent

for i, part in pairs(character:GetDescendants()) do
    if part:IsA("BasePart") then 
        part.Transparency = 1 
    end
    if part:IsA("ParticleEmitter") then
         part.Enabled = false
    end
end