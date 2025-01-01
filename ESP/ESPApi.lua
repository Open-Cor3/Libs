local ESP = {
    Enabled = false,
    Tracers = false,
    Box = false,
    Skeleton = false,
    HealthBar = false,
    TeamCheck = false,
    TeamColor = false,
    TracerColor = Color3.fromRGB(255, 0, 0),
    BoxColor = Color3.fromRGB(255, 0, 0),
    HealthBarColor = Color3.fromRGB(0, 255, 0),
    BoxThickness = 2,
    TracerThickness = 1,
    ShowHealthBar = false,
    ShowSkeleton = false
}

local Players = game:GetService("Players")
local Camera = game:GetService("Workspace").CurrentCamera
local Mouse = Players.LocalPlayer:GetMouse()
local ESPObjects = {}

local function RemoveESP(plr)
    if ESPObjects[plr] then
        for _, obj in pairs(ESPObjects[plr]) do
            if obj and obj.Remove then
                obj:Remove()
            end
        end
        ESPObjects[plr] = nil
    end
end

local function UpdateESP(plr)
    if not ESP.Enabled then return end

    local function DrawESP()
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local rootPos, onScreen = Camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
            if onScreen then
                local headPos = Camera:WorldToViewportPoint(plr.Character.Head.Position)
                local humPos = Camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
                local distance = (Vector2.new(headPos.X, headPos.Y) - Vector2.new(humPos.X, humPos.Y)).Magnitude

                local espObjects = {}

                if ESP.Box then
                    local box = Drawing.new("Quad")
                    box.PointA = Vector2.new(humPos.X + distance, humPos.Y - distance * 2)
                    box.PointB = Vector2.new(humPos.X - distance, humPos.Y - distance * 2)
                    box.PointC = Vector2.new(humPos.X - distance, humPos.Y + distance * 2)
                    box.PointD = Vector2.new(humPos.X + distance, humPos.Y + distance * 2)
                    box.Thickness = ESP.BoxThickness
                    box.Color = ESP.BoxColor
                    box.Visible = ESP.Enabled
                    table.insert(espObjects, box)
                end

                if ESP.Tracers then
                    local tracer = Drawing.new("Line")
                    tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    tracer.To = Vector2.new(humPos.X, humPos.Y + distance * 2)
                    tracer.Thickness = ESP.TracerThickness
                    tracer.Color = ESP.TracerColor
                    tracer.Visible = ESP.Enabled
                    table.insert(espObjects, tracer)
                end

                if ESP.ShowHealthBar then
                    local healthbar = Drawing.new("Line")
                    local healthHeight = distance * (plr.Character.Humanoid.Health / plr.Character.Humanoid.MaxHealth)
                    healthbar.From = Vector2.new(humPos.X - distance - 4, humPos.Y + distance * 2)
                    healthbar.To = Vector2.new(humPos.X - distance - 4, humPos.Y + distance * 2 - healthHeight)
                    healthbar.Thickness = 2
                    healthbar.Color = ESP.HealthBarColor
                    healthbar.Visible = ESP.Enabled
                    table.insert(espObjects, healthbar)
                end

                if ESP.Skeleton then
                    local skeleton = {}
                    skeleton.head = Drawing.new("Line")
                    skeleton.head.From = Vector2.new(headPos.X, headPos.Y)
                    skeleton.head.To = Vector2.new(humPos.X, humPos.Y + distance * 2)
                    skeleton.head.Thickness = 2
                    skeleton.head.Color = ESP.BoxColor
                    skeleton.head.Visible = ESP.Enabled
                    table.insert(espObjects, skeleton.head)

                    skeleton.torso = Drawing.new("Line")
                    skeleton.torso.From = Vector2.new(humPos.X, humPos.Y)
                    skeleton.torso.To = Vector2.new(humPos.X, humPos.Y + distance * 1.5)
                    skeleton.torso.Thickness = 2
                    skeleton.torso.Color = ESP.BoxColor
                    skeleton.torso.Visible = ESP.Enabled
                    table.insert(espObjects, skeleton.torso)

                    skeleton.leftLeg = Drawing.new("Line")
                    skeleton.leftLeg.From = Vector2.new(humPos.X - 5, humPos.Y + distance * 1.5)
                    skeleton.leftLeg.To = Vector2.new(humPos.X - 5, humPos.Y + distance * 2)
                    skeleton.leftLeg.Thickness = 2
                    skeleton.leftLeg.Color = ESP.BoxColor
                    skeleton.leftLeg.Visible = ESP.Enabled
                    table.insert(espObjects, skeleton.leftLeg)

                    skeleton.rightLeg = Drawing.new("Line")
                    skeleton.rightLeg.From = Vector2.new(humPos.X + 5, humPos.Y + distance * 1.5)
                    skeleton.rightLeg.To = Vector2.new(humPos.X + 5, humPos.Y + distance * 2)
                    skeleton.rightLeg.Thickness = 2
                    skeleton.rightLeg.Color = ESP.BoxColor
                    skeleton.rightLeg.Visible = ESP.Enabled
                    table.insert(espObjects, skeleton.rightLeg)
                end

                ESPObjects[plr] = espObjects
            end
        end
    end

    coroutine.wrap(DrawESP)()
end

local function ToggleESP()
    ESP.Enabled = not ESP.Enabled
    for _, plr in pairs(Players:GetPlayers()) do
        if plr.Name ~= Players.LocalPlayer.Name then
            RemoveESP(plr)
            UpdateESP(plr)
        end
    end
end

Players.PlayerAdded:Connect(function(newPlayer)
    if newPlayer.Name ~= Players.LocalPlayer.Name then
        UpdateESP(newPlayer)
    end
end)

Players.PlayerRemoving:Connect(function(leavingPlayer)
    if leavingPlayer.Name ~= Players.LocalPlayer.Name then
        RemoveESP(leavingPlayer)
    end
end)

for _, v in pairs(Players:GetPlayers()) do
    if v.Name ~= Players.LocalPlayer.Name then
        UpdateESP(v)
    end
end

return ESP
