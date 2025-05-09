local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local viewportX, viewportY = workspace.CurrentCamera.ViewportSize.X, workspace.CurrentCamera.ViewportSize.Y
local VisualLibrary = {
    PositionPoints = {
        Center = Vector2.new(viewportX / 2, viewportY / 2),
        Top = Vector2.new(viewportX / 2, 0),
        Bottom = Vector2.new(viewportX / 2, viewportY),
        Left = Vector2.new(0, viewportY / 2),
        Right = Vector2.new(viewportX, viewportY / 2),
        TopLeft = Vector2.new(0, 0),
        TopRight = Vector2.new(viewportX, 0),
        BottomLeft = Vector2.new(0, viewportY),
        BottomRight = Vector2.new(viewportX, viewportY),
    },
	ActiveVisuals = {},
	TrackedObjects = {},
}

----------------------- Local Functions ----------------------------

local lastFov, lastScale = nil, nil
local cam = workspace.CurrentCamera
local WorldToViewportPoint = cam.WorldToViewportPoint

local function round(number)
    return typeof(number) == "Vector2" and Vector2.new(round(number.X), round(number.Y)) or math.floor(number)
end

local function GetScaleFactor(fov, depth)
    if (fov ~= lastFov) then
        lastScale = math.tan(math.rad(fov * 0.5)) * 2
        lastFov = fov
    end
    return 1 / (depth * lastScale) * 1000
end

local function BrahWth(position)
	local screenPosition, onScreen = WorldToViewportPoint(cam, position)
	return Vector2.new(screenPosition.X, screenPosition.Y), onScreen, screenPosition.Z
end

local function Get2DPosition(worldPosition)
    local position2D, onScreen = game:GetService("Workspace").CurrentCamera:WorldToViewportPoint(worldPosition)
    if onScreen then
        return Vector2.new(position2D.X, position2D.Y)
    else
        return nil
    end
end

local function printTable(tableToPrint, indent)
    indent = indent or 0

    for key, value in pairs(tableToPrint) do
        if type(value) == "table" then
            print(("\t"):rep(indent) .. key .. ": {")
            printTable(value, indent + 1)
            print(("\t"):rep(indent) .. "}")
        else
            print(("\t"):rep(indent) .. key, value)
        end
    end
end

local function drawSkeleton(player, character, color, thickness)
    local lines = {}
    local shouldUpdate = true
    local returnedFuncs = {}

    local function createOrUpdateLine(name)
        local line = lines[name] or Drawing.new("Line")
        line.Visible = false
        line.Color = color or Color3.fromRGB(255, 255, 255)
        line.Thickness = thickness or 1.5
        lines[name] = line
        return line
    end

    local function update()
        local connection

        connection = game:GetService("RunService").RenderStepped:Connect(function()
            if not shouldUpdate then
                connection:Disconnect()
                connection = nil
                return
            end

            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local character_rootpart_3d = character:WaitForChild("HumanoidRootPart").Position
                local character_rootpart_2d = workspace.CurrentCamera:WorldToViewportPoint(character_rootpart_3d)

                if character_rootpart_2d.Z >= 0 then
                    local function worldToViewport(point)
                        return workspace.CurrentCamera:WorldToViewportPoint(point)
                    end

                    local parts
                    if humanoid.RigType == Enum.HumanoidRigType.R15 then
                        parts = {
                            {"HeadToUpperTorso", character.Head, character.UpperTorso},
                            {"UpperTorsoToLeftUpperArm", character.UpperTorso, character.LeftUpperArm},
                            {"LeftUpperArmToLeftLowerArm", character.LeftUpperArm, character.LeftLowerArm},
                            {"UpperTorsoToRightUpperArm", character.UpperTorso, character.RightUpperArm},
                            {"RightUpperArmToRightLowerArm", character.RightUpperArm, character.RightLowerArm},
                            {"UpperTorsoToLowerTorso", character.UpperTorso, character.LowerTorso},
                            {"LowerTorsoToLeftUpperLeg", character.LowerTorso, character.LeftUpperLeg},
                            {"LowerTorsoToRightUpperLeg", character.LowerTorso, character.RightUpperLeg},
                            {"LeftUpperLegToLeftLowerLeg", character.LeftUpperLeg, character.LeftLowerLeg},
                            {"RightUpperLegToRightLowerLeg", character.RightUpperLeg, character.RightLowerLeg},
                        }
                    else
                        parts = {
                            {"HeadToTorso", character.Head, character.Torso},
                            {"TorsoToLeftArm", character.Torso, character["Left Arm"]},
                            {"TorsoToRightArm", character.Torso, character["Right Arm"]},
                            {"TorsoToLeftLeg", character.Torso, character["Left Leg"]},
                            {"TorsoToRightLeg", character.Torso, character["Right Leg"]},
                        }
                    end

                    for _, data in ipairs(parts) do
                        local name, fromPart, toPart = unpack(data)
                        local line = createOrUpdateLine(name)
                        local pos1 = worldToViewport(fromPart.Position)
                        local pos2 = worldToViewport(toPart.Position)

                        if pos1.Z >= 0 and pos2.Z >= 0 then
                            line.Visible = true
                            line.From = Vector2.new(pos1.X, pos1.Y)
                            line.To = Vector2.new(pos2.X, pos2.Y)
                        else
                            line.Visible = false
                        end
                    end
                else
                    for _, line in pairs(lines) do
                        line.Visible = false
                    end
                end
            else
                if player == nil then
                    connection:Disconnect()
                    connection = nil
                    for _, line in pairs(lines) do
                        line.Visible = false
                    end
                end
            end
        end)
    end

    function returnedFuncs.StartTracking(shouldUpdateBool)
        shouldUpdate = shouldUpdateBool
        if shouldUpdateBool then
            update()
        end
    end

    function returnedFuncs.Delete()
        shouldUpdate = false
        for _, line in pairs(lines) do
            line:Remove()
        end
    end

    return returnedFuncs
end

local function UpdateTrackedVisuals()
    for _, visualObj in ipairs(VisualLibrary.ActiveVisuals) do
        local trackedObject = visualObj.TrackingInfo.Object
        local Type = visualObj.Type
        if trackedObject and Type then
            if typeof(trackedObject) == "Instance" then
                if trackedObject:IsA("Player") then
                    local character = trackedObject.Character
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        local rootPart = character:FindFirstChild("HumanoidRootPart")
                        local position2D = Get2DPosition(rootPart.Position)
                        if position2D then
                            if Type == "Line" then
                                if visualObj.TrackingInfo.Position then
                                    local pos = VisualLibrary:getPositionPoints(trackedObject)
                                    if pos then
                                        visualObj.Object.To = pos[visualObj.TrackingInfo.Position]
                                    end
                                else
                                    visualObj.Object.To = position2D
                                end
                            else
                                if visualObj.TrackingInfo.Position then
                                    local pos = VisualLibrary:getPositionPoints(trackedObject)
                                    if pos then
                                        visualObj.Object.Position = pos[visualObj.TrackingInfo.Position]
                                    end
                                else
                                    visualObj.Object.Position = position2D
                                end
                            end
                            visualObj.Object.Visible = true
                        else
                            visualObj.Object.Visible = false
                        end
                    end
                elseif trackedObject:IsA("Model") then
                    local humanoid = trackedObject:FindFirstChild("Humanoid")
                    if humanoid and humanoid.Parent and humanoid.Parent:FindFirstChild("HumanoidRootPart") then
                        local rootPart = humanoid.Parent:FindFirstChild("HumanoidRootPart")
                        local position2D = Get2DPosition(rootPart.Position)
                        if position2D then
                            if Type == "Line" then
                                if visualObj.TrackingInfo.Position then
                                    local pos = VisualLibrary:getPositionPoints(game.Players:GetPlayerFromCharacter(trackedObject))
                                    if pos then
                                        visualObj.Object.To = pos[visualObj.TrackingInfo.Position]
                                    end
                                else
                                    visualObj.Object.To = position2D
                                end
                            else
                                if visualObj.TrackingInfo.Position then
                                    local pos = VisualLibrary:getPositionPoints(trackedObject)
                                    if pos then
                                        visualObj.Object.Position = pos[visualObj.TrackingInfo.Position]
                                    end
                                else
                                    visualObj.Object.Position = position2D
                                end
                            end
                            visualObj.Object.Visible = true
                        else
                            visualObj.Object.Visible = false
                        end
                    end
                elseif trackedObject:IsA("BasePart") then
                    local position2D = Get2DPosition(trackedObject.Position)
                    if position2D then
                        if Type == "Line" then
                            visualObj.Object.To = position2D
                        else
                            if visualObj.TrackingInfo.Position then
                                local pos = VisualLibrary:getPositionPoints(trackedObject)
                                if pos then
                                    visualObj.Object.Position = pos[visualObj.TrackingInfo.Position]
                                end
                            else
                                visualObj.Object.Position = position2D
                            end
                        end
                        visualObj.Object.Visible = true
                    else
                        visualObj.Object.Visible = false
                    end
                end
            end
        end
    end
end

--------------------- Global Functions ----------------------

function VisualLibrary:CreateVisual(method: string, properties: table)
    local Method = method
    local Properties = properties or {}

    if not Method or not Properties then
        warn("[DY | Visual Library]: Missing 'Method' or 'Properties'")
        return
    end

    local VisualObj = {
        Object = (Method:lower() == "drawing" and Properties.Type:lower() ~= "skeleton") and Drawing.new(Properties.Type or Properties.type) or
                 (Method:lower() == "highlight") and Instance.new("Highlight"),
        TrackingInfo = {
            Object = nil,
            Position = nil
        },
        Type = Properties.Type or Properties.type
    }

    if Method:lower() == "drawing" then
        if VisualObj.Type:lower() ~= "skeleton" then
            for property, value in pairs(Properties) do
                if property ~= "Type" and property ~= "type" then
                    VisualObj.Object[property] = value
                end
            end

            function VisualObj.StartTracking(target, position: string)
                VisualObj.TrackingInfo.Object = target
                VisualObj.TrackingInfo.Position = position or nil
                table.insert(VisualLibrary.TrackedObjects, target)
            end

            function VisualObj.StopTracking()
                if VisualObj.TrackingInfo.Object then
                    for i, obj in ipairs(VisualLibrary.TrackedObjects) do
                        if obj == VisualObj.TrackingInfo.Object then
                            table.remove(VisualLibrary.TrackedObjects, i)
                            VisualObj.TrackingInfo.Object = nil
                            break
                        end
                    end
                end
            end

            function VisualObj:Remove()
                if VisualObj.Object then
                    VisualObj:StopTracking()
                    VisualObj.Object:Remove()
                    VisualObj.Type = nil
                    for i, obj in ipairs(VisualLibrary.ActiveVisuals) do
                        if obj == VisualObj then
                            table.remove(VisualLibrary.ActiveVisuals, i)
                        end
                    end
                end
            end
        else
            local player: Player = Properties.Player
            local color: Color3 = Properties.Color or Color3.fromRGB(255, 255, 255)
            local thickness: number = Properties.Thickness or 1.5

            if player then
                if player.Character then
                    VisualObj.Object = drawSkeleton(player, player.Character, color, thickness)
                    VisualObj.Object:StartTracking(true)
                else
                    warn("[ErrorDetection]: Player Character Not Found")
                    return
                end
            else
                warn("[ErrorDetection]: Player Not Found")
                return
            end

            function VisualObj:StopTracking()
                VisualObj.Object:StartTracking(false)
            end

            function VisualObj:Remove()
                if VisualObj.Object then
                    VisualObj.Object:Delete()
                end
                for i, activeEffect in ipairs(VisualLibrary.ActiveVisuals) do
                    if activeEffect == VisualObj then
                        table.remove(VisualLibrary.ActiveVisuals, i)
                        break
                    end
                end
            end
        end
    elseif method == "Highlight" or method == "highlight" then
        local target = Properties.Target -- Object to highlight
        local color = Properties.Color or Color3.fromRGB(52, 224, 224)
        local transparency = Properties.Transparency or 0.25
        local strokeColor = Properties.StrokeColor or Color3.new(1, 1, 1)
        local outlineTransparency = Properties.OutlineTransparency or 1
    
        if target:IsA("Model") or target:IsA("BasePart") then
            local visualEffect = VisualObj.Object
            visualEffect.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            visualEffect.FillColor = color
            visualEffect.FillTransparency = transparency
            visualEffect.OutlineColor = strokeColor
            visualEffect.OutlineTransparency = outlineTransparency
            visualEffect.Adornee = target
            visualEffect.Parent = target
        else
            warn("Cannot create highlight for unsupported target:", target)
            return nil
        end
    
        function VisualObj.Remove()
            VisualObj.Object:Remove()
            VisualObj.Type = nil
            for i, v in ipairs(VisualLibrary.ActiveVisuals) do
                if v == VisualObj then
                    table.remove(VisualLibrary.ActiveVisuals, i)
                    break
                end
            end
        end
    else
        warn("[DY | Visual Library]: Unsupported 'Method'")
    end

    table.insert(VisualLibrary.ActiveVisuals, VisualObj)
    return VisualObj
end

function VisualLibrary:GetBoundingBox(obj)
    local position3D
    if typeof(obj) == "Instance" then
        if obj:IsA("Player") then
            local character = obj.Character
            if character then
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                local headPart = character:FindFirstChild("Head")

                if rootPart and headPart then
                    position3D = rootPart.Position
                end
            end
        elseif obj:IsA("Model") then
            if obj:FindFirstChild("Humanoid") then
                local character = obj.Character
                if character then
                    local rootPart = character:FindFirstChild("HumanoidRootPart")
                    local headPart = character:FindFirstChild("Head")
                    if rootPart and headPart then
                        position3D = rootPart.Position
                    end
                end
            end
        elseif obj:IsA("BasePart") then
            position3D = obj.Position
        end
    end
    local torsoPosition, onScreen, depth = BrahWth(position3D)
    local scaleFactor = GetScaleFactor(cam.FieldOfView, depth)
    local size = round(Vector2.new(4 * scaleFactor, 5 * scaleFactor))
    return onScreen, size, round(Vector2.new(torsoPosition.X - (size.X * .5), torsoPosition.Y - (size.Y * .5))), torsoPosition
end

function VisualLibrary:getPositionPoints(player: Player)
    local position: CFrame, size: Vector3 = player.Character:GetBoundingBox()
    local floored_position = position - (size / 2)

    local maxs = (floored_position + size).Position
    local mins = floored_position.Position

    local points = {
        Vector3.new(mins.x, mins.y, mins.z),
        Vector3.new(mins.x, maxs.y, mins.z),
        Vector3.new(maxs.x, maxs.y, mins.z),
        Vector3.new(maxs.x, mins.y, mins.z),
        Vector3.new(maxs.x, maxs.y, maxs.z),
        Vector3.new(mins.x, maxs.y, maxs.z),
        Vector3.new(mins.x, mins.y, maxs.z),
        Vector3.new(maxs.x, mins.y, maxs.z)
    }

    for idx, point: Vector3 in next, points do
        points[idx] = game:GetService("Workspace").Camera:WorldToViewportPoint(point)
    end

    local left = math.huge
    local right = 0
    local top = math.huge
    local bottom = 0

    for idx, point: Vector2 in next, points do
        if (point.X < left) then
            left = point.X
        end

        if (point.X > right) then
            right = point.X
        end

        if (point.Y < top) then
            top = point.Y
        end

        if (point.Y > bottom) then
            bottom = point.Y
        end
    end

    local center = Vector2.new((left + right) / 2, (top + bottom) / 2)

    return {
       ["Left"] = Vector2.new(left, center.Y),
       ["Right"] = Vector2.new(right, center.Y),
       ["Top"] = Vector2.new(center.X, top),
       ["Bottom"] = Vector2.new(center.X, bottom),
       ["TopLeft"] = Vector2.new(left, top),
       ["TopRight"] = Vector2.new(right, top),
       ["BottomLeft"] = Vector2.new(left, bottom),
       ["BottomRight"] = Vector2.new(right, bottom),
       ["Center"] = center
    }
end

local heartbeatLoop
heartbeatLoop = game:GetService("RunService").Heartbeat:Connect(function()
    UpdateTrackedVisuals()
end)

print("Running OPENCORE Mod of https://github.com/GamingScripter/Darkrai-Y/blob/main/Libraries/Visual%20Library/Main ESPApi.lua Vers 1.0")


return VisualLibrary
