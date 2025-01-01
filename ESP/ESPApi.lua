local ESP = {
    Enabled = true,
    Tracers = true,
    Box = true,
    Skeleton = true,
    HealthBar = true,
    TeamCheck = false,
    TeamColor = true,
    TracerColor = Color3.fromRGB(255, 0, 0),
    BoxColor = Color3.fromRGB(255, 0, 0),
    HealthBarColor = Color3.fromRGB(0, 255, 0),
    BoxThickness = 2,
    TracerThickness = 1,
    ShowHealthBar = true,
    ShowSkeleton = true
}

local Players = game:GetService("Players")
local Camera = game:GetService("Workspace").CurrentCamera
local Mouse = Players.LocalPlayer:GetMouse()

local function CreateESP(plr)
    if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then return end

    local espObjects = {}

    local function DrawESP()
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local rootPos, onScreen = Camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
            if onScreen then
                local headPos = Camera:WorldToViewportPoint(plr.Character.Head.Position)
                local humPos = Camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
                local distance = (Vector2.new(headPos.X, headPos.Y) - Vector2.new(humPos.X, humPos.Y)).Magnitude

                if ESP.Box then
                    if not espObjects.Box then
                        espObjects.Box = Drawing.new("Quad")
                    end
                    espObjects.Box.PointA = Vector2.new(humPos.X + distance, humPos.Y - distance * 2)
                    espObjects.Box.PointB = Vector2.new(humPos.X - distance, humPos.Y - distance * 2)
                    espObjects.Box.PointC = Vector2.new(humPos.X - distance, humPos.Y + distance * 2)
                    espObjects.Box.PointD = Vector2.new(humPos.X + distance, humPos.Y + distance * 2)
                    espObjects.Box.Thickness = ESP.BoxThickness
                    espObjects.Box.Color = ESP.BoxColor
                    espObjects.Box.Visible = true
                end

                if ESP.Tracers then
                    if not espObjects.Tracer then
                        espObjects.Tracer = Drawing.new("Line")
                    end
                    espObjects.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    espObjects.Tracer.To = Vector2.new(humPos.X, humPos.Y + distance * 2)
                    espObjects.Tracer.Thickness = ESP.TracerThickness
                    espObjects.Tracer.Color = ESP.TracerColor
                    espObjects.Tracer.Visible = true
                end

                if ESP.ShowHealthBar then
                    if not espObjects.HealthBar then
                        espObjects.HealthBar = Drawing.new("Line")
                    end
                    local healthHeight = distance * (plr.Character.Humanoid.Health / plr.Character.Humanoid.MaxHealth)
                    espObjects.HealthBar.From = Vector2.new(humPos.X - distance - 4, humPos.Y + distance * 2)
                    espObjects.HealthBar.To = Vector2.new(humPos.X - distance - 4, humPos.Y + distance * 2 - healthHeight)
                    espObjects.HealthBar.Thickness = 2
                    espObjects.HealthBar.Color = ESP.HealthBarColor
                    espObjects.HealthBar.Visible = true
                end

                if ESP.Skeleton then
                    if not espObjects.Skeleton then
                        espObjects.Skeleton = {}
                    end

                    local skeleton = espObjects.Skeleton
                    if not skeleton.head then
                        skeleton.head = Drawing.new("Line")
                    end
                    skeleton.head.From = Vector2.new(headPos.X, headPos.Y)
                    skeleton.head.To = Vector2.new(humPos.X, humPos.Y + distance * 2)
                    skeleton.head.Thickness = 2
                    skeleton.head.Color = ESP.BoxColor
                    skeleton.head.Visible = true

                    if not skeleton.torso then
                        skeleton.torso = Drawing.new("Line")
                    end
                    skeleton.torso.From = Vector2.new(humPos.X, humPos.Y)
                    skeleton.torso.To = Vector2.new(humPos.X, humPos.Y + distance * 1.5)
                    skeleton.torso.Thickness = 2
                    skeleton.torso.Color = ESP.BoxColor
                    skeleton.torso.Visible = true

                    if not skeleton.leftLeg then
                        skeleton.leftLeg = Drawing.new("Line")
                    end
                    skeleton.leftLeg.From = Vector2.new(humPos.X - 5, humPos.Y + distance * 1.5)
                    skeleton.leftLeg.To = Vector2.new(humPos.X - 5, humPos.Y + distance * 2)
                    skeleton.leftLeg.Thickness = 2
                    skeleton.leftLeg.Color = ESP.BoxColor
                    skeleton.leftLeg.Visible = true

                    if not skeleton.rightLeg then
                        skeleton.rightLeg = Drawing.new("Line")
                    end
                    skeleton.rightLeg.From = Vector2.new(humPos.X + 5, humPos.Y + distance * 1.5)
                    skeleton.rightLeg.To = Vector2.new(humPos.X + 5, humPos.Y + distance * 2)
                    skeleton.rightLeg.Thickness = 2
                    skeleton.rightLeg.Color = ESP.BoxColor
                    skeleton.rightLeg.Visible = true
                end
            else
                for _, obj in pairs(espObjects) do
                    obj.Visible = false
                end
            end
        end
    end

    game:GetService("RunService").RenderStepped:Connect(DrawESP)
end

for _, v in pairs(Players:GetPlayers()) do
    if v.Name ~= Players.LocalPlayer.Name then
        CreateESP(v)
    end
end

Players.PlayerAdded:Connect(function(newPlayer)
    if newPlayer.Name ~= Players.LocalPlayer.Name then
        CreateESP(newPlayer)
    end
end)
