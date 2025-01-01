local Aimbot = {
    Enabled = false,
    Key = Enum.UserInputType.MouseButton2,
    Players = false,
    PlayerPart = 'Head',
    FriendlyPlayers = {},
    TeamCheck = false,
    AliveCheck = false,
    VisibilityCheck = false,
    Smoothing = 0,
    SmoothingMethod = 0,
    Offset = {0, 0},
    FOV = 200,
    ShowFOV = false,
    CustomParts = {},
    FOVCircleColor = Color3.fromRGB(255, 255, 255)
}

local UserInputService = game:service'UserInputService'
local Players = game:service'Players'
local RunService = game:service'RunService'
local plr = game:service'Players'.LocalPlayer
local mouse = plr:GetMouse()
local keypressed = false
local fovcircle = Drawing.new('Circle')
fovcircle.Filled = false
fovcircle.Thickness = 1

Aimbot.GetClosestPart = function()
    local target
    local parts = {}

    for i, v in pairs(Aimbot.CustomParts) do
        if v:IsA'Part' or v:IsA'BasePart' or v:IsA'MeshPart' then
            table.insert(parts, v)
        end
    end
    
    if Aimbot.Players == true then
        for i, v in pairs(Players:GetPlayers()) do
            if not table.find(Aimbot.FriendlyPlayers, v.Name) and v.Name ~= plr.Name then
                if Aimbot.AliveCheck and v.Character and v.Character:FindFirstChildWhichIsA'Humanoid' and v.Character:FindFirstChildWhichIsA'Humanoid'.Health < 1 then
                    continue
                end
                if Aimbot.TeamCheck and v.TeamColor == plr.TeamColor then
                    continue
                end
                if v.Character and v.Character:FindFirstChild(Aimbot.PlayerPart) then
                    local part = v.Character[Aimbot.PlayerPart]
                    if Aimbot.VisibilityCheck then
                        local params = RaycastParams.new()
                        params.FilterType = Enum.RaycastFilterType.Blacklist
                        params.IgnoreWater = true
                        params.FilterDescendantsInstances = {part.Parent, plr.Character}
                        local raycast = workspace:Raycast(workspace.CurrentCamera.CFrame.p, (part.CFrame.p - workspace.Camera.CFrame.p), params)
                        if raycast then
                            continue
                        end
                    end
                    table.insert(parts, v.Character[Aimbot.PlayerPart])
                end
            end
        end
    end
    
    for i, v in pairs(parts) do
        local pos = workspace.CurrentCamera:WorldToScreenPoint(v.CFrame.p)
        local distance = (Vector2.new(pos.X, pos.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
        if distance <= Aimbot.FOV and pos.Z >= 0 then
            if not target then
                target = {Part = v, Position = pos, Distance = distance}
            else
                if distance < target.Distance then
                    target = {Part = v, Position = pos, Distance = distance}
                end       
            end
        end
    end

    return target
end

Aimbot.Aim = function(x, y, smooth)
    if not smooth then
        smooth = Aimbot.Smoothing
    end
    if Aimbot.SmoothingMethod == 0 then
        mousemoverel((x + Aimbot.Offset[1] - mouse.X) / (5 * (smooth + 1)), (y + Aimbot.Offset[2] - mouse.Y) / (5 * (smooth + 1)))
    else
        mousemoverel((x + Aimbot.Offset[1] - mouse.X) / (smooth + 1), (y + Aimbot.Offset[2] - mouse.Y) / (smooth + 1))
    end
end

UserInputService.InputBegan:Connect(function(input)
    if not Aimbot.Key then return end
    if UserInputService:GetFocusedTextBox() then
        return
    end
    if input.KeyCode == Aimbot.Key or input.UserInputType == Aimbot.Key then
        keypressed = true
    end 
end)

UserInputService.InputEnded:Connect(function(input)
    if not Aimbot.Key then return end
    if UserInputService:GetFocusedTextBox() then
        return
    end
    if input.KeyCode == Aimbot.Key or input.UserInputType == Aimbot.Key then
        keypressed = false
    end 
end)

RunService.RenderStepped:Connect(function() 
    fovcircle.Visible = Aimbot.ShowFOV
    fovcircle.Color = Aimbot.FOVCircleColor
    fovcircle.Radius = Aimbot.FOV
    fovcircle.Position = Vector2.new(mouse.X + Aimbot.Offset[1], mouse.Y + 35 + Aimbot.Offset[2])
end)

RunService.RenderStepped:Connect(function()
    if Aimbot.Enabled and keypressed then
        local part = Aimbot.GetClosestPart()
        if part then
            Aimbot.Aim(part.Position.X, part.Position.Y, Aimbot.Smoothing)
        end
    end
end)

print("Running OPENCORE AimbotAPI.lua Vers 1.0")

return Aimbot
