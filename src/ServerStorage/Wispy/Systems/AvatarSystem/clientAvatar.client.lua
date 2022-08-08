script.Parent.HideModel.OnServerEvent:Connect(function(Model)
    print (Model)

    for i, part in pairs(Model:GetDescendants()) do
        if part:IsA("BasePart") then 
            part.Transparency = 1 
        end
    
        if part:IsA("ParticleEmitter") then
            part.Enabled = false
        end
    end
end)

