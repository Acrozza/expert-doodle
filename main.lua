-- Blade Ball Parry Script - Xeno Executor Compatible
-- Hosted at: https://github.com/Acrozza/expert-doodle

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

-- Xeno Executor compatibility check
local function isXeno()
    return getexecutorname and getexecutorname():lower():find("xeno") ~= nil
end

-- Player setup
local player = Players.LocalPlayer
if not player then
    player = Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
end

local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Configuration
local config = {
    ParryKey = Enum.KeyCode.F,
    ParryRange = 15,
    ParryAngle = 60,
    ParryCooldown = 1.5,
    ParryForce = 150,
    BallNames = {"Ball", "BladeBall", "GameBall", "SwordBall"}
}

-- State variables
local lastParryTime = 0
local isParrying = false

-- Create UI
local function createUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ParryUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    -- Main container
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0, 200, 0, 60)
    container.Position = UDim2.new(0.5, -100, 0.85, 0)
    container.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    container.BorderSizePixel = 0
    container.Parent = screenGui
    
    -- Rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = container
    
    -- Status label
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, 0, 0, 30)
    statusLabel.Position = UDim2.new(0, 0, 0, 5)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "READY TO PARRY"
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusLabel.TextScaled = true
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.Parent = container
    
    -- Cooldown bar background
    local cooldownBar = Instance.new("Frame")
    cooldownBar.Size = UDim2.new(0, 180, 0, 8)
    cooldownBar.Position = UDim2.new(0.5, -90, 0, 40)
    cooldownBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    cooldownBar.BorderSizePixel = 0
    cooldownBar.Parent = container
    
    -- Cooldown bar fill
    local cooldownFill = Instance.new("Frame")
    cooldownFill.Size = UDim2.new(1, 0, 1, 0)
    cooldownFill.Position = UDim2.new(0, 0, 0, 0)
    cooldownFill.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
    cooldownFill.BorderSizePixel = 0
    cooldownFill.Parent = cooldownBar
    
    -- Rounded corners for bars
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 4)
    barCorner.Parent = cooldownBar
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 4)
    fillCorner.Parent = cooldownFill
    
    return screenGui, statusLabel, cooldownFill
end

-- Create UI elements
local screenGui, statusLabel, cooldownFill = createUI()

-- Find ball
local function findBall()
    for _, name in ipairs(config.BallNames) do
        local ball = workspace:FindFirstChild(name)
        if ball and ball:IsA("BasePart") then
            return ball
        end
    end
    
    -- Try to find any ball-like object
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("ball") or obj.Name:lower():find("blade")) then
            return obj
        end
    end
    
    return nil
end

-- Update UI
local function updateUI()
    local timeSinceParry = tick() - lastParryTime
    local cooldownProgress = math.min(timeSinceParry / config.ParryCooldown, 1)
    
    -- Update cooldown bar
    cooldownFill.Size = UDim2.new(cooldownProgress, 0, 1, 0)
    
    -- Update status text
    if cooldownProgress >= 1 then
        statusLabel.Text = "READY TO PARRY"
        statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        local remaining = math.ceil(config.ParryCooldown - timeSinceParry)
        statusLabel.Text = "COOLDOWN: " .. remaining .. "s"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end

-- Parry function
local function parry()
    if tick() - lastParryTime < config.ParryCooldown or isParrying then return end
    
    isParrying = true
    lastParryTime = tick()
    
    local ball = findBall()
    if not ball then 
        isParrying = false
        return 
    end
    
    -- Calculate distance and angle
    local distance = (ball.Position - rootPart.Position).Magnitude
    local direction = (ball.Position - rootPart.Position).Unit
    local lookVector = rootPart.CFrame.LookVector
    local angle = math.deg(math.acos(math.clamp(direction:Dot(lookVector), -1, 1)))
    
    -- Check if within range and angle
    if distance <= config.ParryRange and angle <= config.ParryAngle then
        -- Apply force
        local parryDirection = (ball.Position - rootPart.Position).Unit
        ball.Velocity = parryDirection * config.ParryForce
        
        -- Visual effect
        local flash = Instance.new("Part")
        flash.Size = Vector3.new(5, 8, 1)
        flash.Color = Color3.fromRGB(255, 255, 200)
        flash.Material = Enum.Material.Neon
        flash.Anchored = true
        flash.CanCollide = false
        flash.CFrame = rootPart.CFrame * CFrame.new(0, 0, -3)
        flash.Parent = workspace
        Debris:AddItem(flash, 0.2)
        
        -- UI feedback
        statusLabel.Text = "PARRIED!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    end
    
    isParrying = false
    updateUI()
end

-- Input handling
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == config.ParryKey then
        parry()
    end
end)

-- Mobile support
UserInputService.TouchTap:Connect(function(_, gameProcessed)
    if not gameProcessed then
        parry()
    end
end)

-- Update UI continuously
RunService.Heartbeat:Connect(updateUI)

-- Handle character respawn
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    rootPart = character:WaitForChild("HumanoidRootPart")
end)

-- Notification
local function showNotification(message)
    local notification = Instance.new("TextLabel")
    notification.Size = UDim2.new(0, 250, 0, 40)
    notification.Position = UDim2.new(0.5, -125, 0.3, 0)
    notification.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    notification.BackgroundTransparency = 0.3
    notification.Text = message
    notification.TextColor3 = Color3.fromRGB(255, 255, 255)
    notification.TextScaled = true
    notification.Font = Enum.Font.GothamBold
    notification.Parent = screenGui

    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0, 8)
    notifCorner.Parent = notification

    Debris:AddItem(notification, 3)
end

-- Show executor-specific notification
if isXeno() then
    showNotification("Blade Ball Parry - Xeno Ready!")
else
    showNotification("Blade Ball Parry Loaded!")
end

print("Blade Ball Parry script loaded successfully!")
