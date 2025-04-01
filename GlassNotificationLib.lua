--[[
  Glass Notification Library
  A Windows 11-inspired notification system with blur glass effect for Roblox
  
  Usage:
  local GlassNotify = loadstring(HttpGet path.to.module)
  
  -- Display a simple notification
  GlassNotify:Toast("Title", "This is an Info")
  
  -- Display a success notification
  GlassNotify:Success("Success!", "This is a Success")
  
  -- Display a warning banner
  GlassNotify:Warning("Warning", "This is an Warning", 8)
  
  -- Display an error notification
  GlassNotify:Error("Error", "This is an Error", 10)

  
  -- Send custom Notification
GlassNotify:Custom({ -- Get Func
    title = "Custom Example", -- Title
    message = "Would you like .....", -- Description
    type = "info", -- error / info / warning / success
    duration = 0, -- 0 means it won't auto-close / in seconds
    position = "Top", -- Top / Bottom
    actions = { -- Buttons
        {
            text = "Save",
            callback = function() print("vng...") end
        },
        {
            text = "nil",
            callback = function() print("ng...") end
        },
                {
            text = "steff",
            callback = function()
                print("g...") 
            end
        },
    }
})
]]

local GlassNotify = {}
GlassNotify.__index = GlassNotify

-- Settings
GlassNotify.Settings = {
	DefaultDuration = 5, -- Default duration in seconds
	MaxNotifications = 5, -- Maximum number of notifications visible at once
	DefaultPosition = "BottomRight", -- Default position
	Padding = 10, -- Padding between notifications
	Width = UDim2.new(0, 320, 0, 0), -- Width of notifications
	AnimationSpeed = 0.3, -- Animation speed in seconds
	BlurSize = 15, -- Size of blur effect
	CornerRadius = UDim.new(0, 8), -- Corner radius
	ZIndex = 10, -- Z-index for notifications
	Font = Enum.Font.Gotham, -- Default font
	TextSize = 14, -- Default text size
	Colors = {
		Success = Color3.fromRGB(56, 209, 137),
		Error = Color3.fromRGB(245, 71, 71),
		Warning = Color3.fromRGB(255, 183, 44),
		Info = Color3.fromRGB(70, 143, 241),
		Default = Color3.fromRGB(150, 150, 255),
		Background = Color3.fromRGB(30, 30, 30),
		BackgroundTransparency = 0.25,
		TextLight = Color3.fromRGB(255, 255, 255),
		TextDark = Color3.fromRGB(50, 50, 50)
	}
}

-- Active notifications
GlassNotify.ActiveNotifications = {}
GlassNotify.Container = nil

-- Initialize the notification system
function GlassNotify:Initialize()
	-- Create parent container if it doesn't exist
	if not self.Container then
		local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
		
		local screenGui = Instance.new("ScreenGui")
		screenGui.Name = "GlassNotificationSystem"
		screenGui.ResetOnSpawn = false
		screenGui.IgnoreGuiInset = true
		screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		screenGui.Parent = playerGui
		
		self.Container = screenGui
	end
	
	return self
end

-- Create a notification frame
function GlassNotify:CreateNotificationFrame(options)
	local positionMap = {
		TopRight = "top-right",
		TopLeft = "top-left",
		BottomRight = "bottom-right",
		BottomLeft = "bottom-left",
		Top = "top",
		Bottom = "bottom"
	}
	
	options = options or {}
	local title = options.title or "Notification"
	local message = options.message or ""
	local notificationType = options.type or "default"
	local duration = options.duration or self.Settings.DefaultDuration
	local position = options.position or self.Settings.DefaultPosition
	local actions = options.actions or {}
	
	-- Create the main frame
	local frame = Instance.new("Frame")
	frame.Name = "Notification_" .. tostring(#self.ActiveNotifications + 1)
	frame.Size = UDim2.new(0, 0, 0, 0)
	frame.BackgroundColor3 = self.Settings.Colors.Background
	frame.BackgroundTransparency = self.Settings.Colors.BackgroundTransparency
	frame.BorderSizePixel = 0
	frame.ZIndex = self.Settings.ZIndex
	frame.Parent = self.Container
	
	local cornerRadius = Instance.new("UICorner")
	cornerRadius.CornerRadius = self.Settings.CornerRadius
	cornerRadius.Parent = frame
	
	local blurEffect = Instance.new("BlurEffect")
	blurEffect.Size = self.Settings.BlurSize
	
	local blurFrame = Instance.new("Frame")
	blurFrame.Name = "BlurFrame"
	blurFrame.Size = UDim2.new(1, 0, 1, 0)
	blurFrame.BackgroundTransparency = 0.6
	blurFrame.BackgroundColor3 = self.Settings.Colors.Background
	blurFrame.BorderSizePixel = 0
	blurFrame.ZIndex = frame.ZIndex
	blurFrame.Parent = frame
	
	local blurCorner = Instance.new("UICorner")
	blurCorner.CornerRadius = self.Settings.CornerRadius
	blurCorner.Parent = blurFrame
	
	local colorIndicator = Instance.new("Frame")
	colorIndicator.Name = "ColorIndicator"
	colorIndicator.Size = UDim2.new(0, 4, 1, 0)
	colorIndicator.Position = UDim2.new(0, 0, 0, 0)
	colorIndicator.BorderSizePixel = 0
	colorIndicator.ZIndex = frame.ZIndex + 1
	
	-- Set the color based on type
	if notificationType == "success" then
		colorIndicator.BackgroundColor3 = self.Settings.Colors.Success
	elseif notificationType == "error" then
		colorIndicator.BackgroundColor3 = self.Settings.Colors.Error
	elseif notificationType == "warning" then
		colorIndicator.BackgroundColor3 = self.Settings.Colors.Warning
	elseif notificationType == "info" then
		colorIndicator.BackgroundColor3 = self.Settings.Colors.Info
	else
		colorIndicator.BackgroundColor3 = self.Settings.Colors.Default
	end
	
	colorIndicator.Parent = frame
	
	local indicatorCorner = Instance.new("UICorner")
	indicatorCorner.CornerRadius = UDim.new(0, 2)
	indicatorCorner.Parent = colorIndicator
	
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(1, -50, 0, 26)
	titleLabel.Position = UDim2.new(0, 16, 0, 10)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = self.Settings.Font
	titleLabel.TextSize = self.Settings.TextSize + 2
	titleLabel.TextColor3 = self.Settings.Colors.TextLight
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Text = title
	titleLabel.ZIndex = frame.ZIndex + 1
	titleLabel.Parent = frame
	
	local messageLabel = Instance.new("TextLabel")
	messageLabel.Name = "Message"
	messageLabel.Size = UDim2.new(1, -30, 0, 0)
	messageLabel.Position = UDim2.new(0, 16, 0, 36)
	messageLabel.BackgroundTransparency = 1
	messageLabel.Font = self.Settings.Font
	messageLabel.TextSize = self.Settings.TextSize
	messageLabel.TextColor3 = self.Settings.Colors.TextLight
	messageLabel.TextXAlignment = Enum.TextXAlignment.Left
	messageLabel.TextYAlignment = Enum.TextYAlignment.Top
	messageLabel.TextWrapped = true
	messageLabel.Text = message
	messageLabel.ZIndex = frame.ZIndex + 1
	
	local textSize = game:GetService("TextService"):GetTextSize(
		message,
		self.Settings.TextSize,
		self.Settings.Font,
		Vector2.new(self.Settings.Width.X.Offset - 30, 1000)
	)
	
	messageLabel.Size = UDim2.new(1, -30, 0, textSize.Y)
	messageLabel.Parent = frame
	
	-- Create close button
	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.Size = UDim2.new(0, 24, 0, 24)
	closeButton.Position = UDim2.new(1, -30, 0, 10)
	closeButton.BackgroundTransparency = 1
	closeButton.Text = "×"
	closeButton.TextColor3 = self.Settings.Colors.TextLight
	closeButton.TextSize = 20
	closeButton.Font = self.Settings.Font
	closeButton.ZIndex = frame.ZIndex + 2
	closeButton.Parent = frame
	
	local totalHeight = 50 + textSize.Y
	
	-- Add action buttons if provided
	if #actions > 0 then
		local buttonsContainer = Instance.new("Frame")
		buttonsContainer.Name = "ButtonsContainer"
		buttonsContainer.Size = UDim2.new(1, -32, 0, 40)
		buttonsContainer.Position = UDim2.new(0, 16, 0, totalHeight)
		buttonsContainer.BackgroundTransparency = 1
		buttonsContainer.ZIndex = frame.ZIndex + 1
		buttonsContainer.Parent = frame
		
		local buttonWidth = (1 / #actions) - 0.02
		
		for i, action in ipairs(actions) do
			local actionButton = Instance.new("TextButton")
			actionButton.Name = "ActionButton_" .. tostring(i)
			actionButton.Size = UDim2.new(buttonWidth, 0, 0, 32)
			actionButton.Position = UDim2.new((i - 1) * (buttonWidth + 0.02), 0, 0, 0)
			actionButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
			actionButton.BackgroundTransparency = 0.6
			actionButton.Text = action.text or "Button"
			actionButton.TextColor3 = self.Settings.Colors.TextLight
			actionButton.Font = self.Settings.Font
			actionButton.TextSize = self.Settings.TextSize
			actionButton.ZIndex = frame.ZIndex + 2
			actionButton.Parent = buttonsContainer
			
			local buttonCorner = Instance.new("UICorner")
			buttonCorner.CornerRadius = UDim.new(0, 6)
			buttonCorner.Parent = actionButton
			
			-- Connect callback
			if action.callback and type(action.callback) == "function" then
				actionButton.Activated:Connect(function()
					action.callback()
					self:RemoveNotification(frame)
				end)
			else
				actionButton.Activated:Connect(function()
					self:RemoveNotification(frame)
				end)
			end
		end
		
		totalHeight = totalHeight + 50
	else
		totalHeight = totalHeight + 10
	end
	
	frame.Size = UDim2.new(0, 0, 0, totalHeight)
	
	local progressBar = Instance.new("Frame")
	progressBar.Name = "ProgressBar"
	progressBar.Size = UDim2.new(1, 0, 0, 3)
	progressBar.Position = UDim2.new(0, 0, 1, -3)
	progressBar.BackgroundColor3 = colorIndicator.BackgroundColor3
	progressBar.BackgroundTransparency = 0.2
	progressBar.BorderSizePixel = 0
	progressBar.ZIndex = frame.ZIndex + 1
	progressBar.Parent = frame
	
	-- Add events
	closeButton.Activated:Connect(function()
		self:RemoveNotification(frame)
	end)
	
	return {
		Frame = frame,
		Height = totalHeight,
		Position = position,
		Duration = duration
	}
end

-- Position notifications based on their position setting
function GlassNotify:PositionNotifications()
	local positions = {
		["TopRight"] = {},
		["TopLeft"] = {},
		["BottomRight"] = {},
		["BottomLeft"] = {},
		["Top"] = {},
		["Bottom"] = {}
	}
	
	for _, notif in ipairs(self.ActiveNotifications) do
		if notif.Frame and notif.Frame.Parent then
			table.insert(positions[notif.Position], notif)
		end
	end
	
	for position, notifications in pairs(positions) do
		local yOffset = self.Settings.Padding
		
		if position == "BottomRight" or position == "BottomLeft" or position == "Bottom" then
			yOffset = -self.Settings.Padding
			
			for i = #notifications, 1, -1 do
				local notif = notifications[i]
				local targetY = yOffset - notif.Height
				
				if position == "BottomRight" then
					notif.Frame.Position = UDim2.new(1, -self.Settings.Padding - self.Settings.Width.X.Offset, 1, targetY)
				elseif position == "BottomLeft" then
					notif.Frame.Position = UDim2.new(0, self.Settings.Padding, 1, targetY)
				else -- Bottom
					notif.Frame.Position = UDim2.new(0.5, -self.Settings.Width.X.Offset / 2, 1, targetY)
				end
				
				yOffset = targetY - self.Settings.Padding
			end
		else
			for _, notif in ipairs(notifications) do
				if position == "TopRight" then
					notif.Frame.Position = UDim2.new(1, -self.Settings.Padding - self.Settings.Width.X.Offset, 0, yOffset)
				elseif position == "TopLeft" then
					notif.Frame.Position = UDim2.new(0, self.Settings.Padding, 0, yOffset)
				else -- Top
					notif.Frame.Position = UDim2.new(0.5, -self.Settings.Width.X.Offset / 2, 0, yOffset)
				end
				
				yOffset = yOffset + notif.Height + self.Settings.Padding
			end
		end
	end
end

function GlassNotify:ShowNotification(options)
	self:Initialize()
	
	local notification = self:CreateNotificationFrame(options)
	
	table.insert(self.ActiveNotifications, notification)
	
	-- Limit number of notifications
	while #self.ActiveNotifications > self.Settings.MaxNotifications do
		self:RemoveNotification(self.ActiveNotifications[1].Frame)
	end
	
	-- Position notifications
	self:PositionNotifications()
	
	-- Animate in
	local targetWidth = self.Settings.Width.X.Offset
	notification.Frame.Size = UDim2.new(0, 0, 0, notification.Height)
	
	local tweenService = game:GetService("TweenService")
	local tweenInfo = TweenInfo.new(self.Settings.AnimationSpeed, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	
	local sizeTween = tweenService:Create(notification.Frame, tweenInfo, {
		Size = UDim2.new(0, targetWidth, 0, notification.Height)
	})
	sizeTween:Play()
	
	-- Set up auto-close timer
	local progressBar = notification.Frame:FindFirstChild("ProgressBar")
	if progressBar and notification.Duration > 0 then
		local progressTween = tweenService:Create(progressBar, TweenInfo.new(notification.Duration, Enum.EasingStyle.Linear), {
			Size = UDim2.new(0, 0, 0, 3)
		})
		progressTween:Play()
		
		task.delay(notification.Duration, function()
			self:RemoveNotification(notification.Frame)
		end)
	end
	
	return notification.Frame
end

function GlassNotify:RemoveNotification(frame)
	-- Find notification in active list
	local index = nil
	for i, notif in ipairs(self.ActiveNotifications) do
		if notif.Frame == frame then
			index = i
			break
		end
	end
	
	if not index then return end
	
	local notification = self.ActiveNotifications[index]
	table.remove(self.ActiveNotifications, index)
	
	-- Animate out
	local tweenService = game:GetService("TweenService")
	local tweenInfo = TweenInfo.new(self.Settings.AnimationSpeed, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
	
	local transparencyTween = tweenService:Create(frame, tweenInfo, {
		BackgroundTransparency = 1
	})
	
	local sizeTween = tweenService:Create(frame, tweenInfo, {
		Size = UDim2.new(0, 0, 0, notification.Height)
	})
	
	transparencyTween:Play()
	sizeTween:Play()
	
	sizeTween.Completed:Connect(function()
		frame:Destroy()
		self:PositionNotifications()
	end)
end

function GlassNotify:Toast(title, message, duration)
	return self:ShowNotification({
		title = title,
		message = message,
		type = "default",
		duration = duration
	})
end

function GlassNotify:Success(title, message, duration)
	return self:ShowNotification({
		title = title,
		message = message,
		type = "success",
		duration = duration
	})
end

function GlassNotify:Error(title, message, duration)
	return self:ShowNotification({
		title = title,
		message = message,
		type = "error",
		duration = duration
	})
end

function GlassNotify:Warning(title, message, duration)
	return self:ShowNotification({
		title = title,
		message = message,
		type = "warning",
		duration = duration
	})
end

function GlassNotify:Info(title, message, duration)
	return self:ShowNotification({
		title = title,
		message = message,
		type = "info",
		duration = duration
	})
end

function GlassNotify:Custom(options)
	return self:ShowNotification(options)
end

-- Initialize on module load
GlassNotify:Initialize()

return GlassNotify
