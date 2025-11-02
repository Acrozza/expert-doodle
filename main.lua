-- Blade Ball Parry Script - Debug Version
-- Hosted at: https://github.com/Acrozza/expert-doodle

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

-- Get player
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Configuration (more permissive for testing)
local config = {
    ParryKey = Enum.KeyCode.F,
    ParryRange = 20,  -- Increased range
    ParryAngle = 90,  -- Wider angle
    ParryCooldown = 1.0,  -- Shorter cooldown
    ParryForce = 200,  -- Stronger force
    BallNames = {"Ball", "BladeBall", "GameBall", "SwordBall", "Blade"}
}

-- State
local lastParryTime = 0
local isParrying = false

-- Create UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ParryUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local container = Instance.new("Frame")
container.Size = UDim2.new(0, 200, 0, 60)
container.Position = UDim2.new(0.5, -100, 0.85, 0)
container.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
container.BorderSizePixel = 0
container.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = container

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 30)
statusLabel.Position = UDim2.new(0, 0, 0, 5)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "READY TO PARRY"
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.GothamBold
statusLabel.Parent = container

local cooldownBar = Instance.new("Frame")
cooldownBar.Size = UDim2.new(0, 180, 0, 8)
cooldownBar.Position = UDim2.new(0.5, -90, 0, 40)
cooldownBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
cooldownBar.BorderSizePixel = 0
cooldownBar.Parent = container

local cooldownFill = Instance.new("Frame")
cooldownFill.Size = UDim2.new(1, 0, 1, 0)
cooldownFill.Position = UDim2.new(0, 0, 0, 0)
cooldownFill.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
cooldownFill.BorderSizePixel = 0
cooldownFill.Parent = cooldownBar

local barCorner = Instance.new("UICorner")
barCorner.CornerRadius = UDim.new(0, 4)
barCorner.Parent = cooldownBar

local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(0, 4)
fillCorner.Parent = cooldownFill

-- Debug function
local function debugPrint(message)
    print("[Blade Ball Parry] " .. message)
end

-- Find ball with more aggressive search
local function findBall()
    -- First try exact names
    for _, name in ipairs(config.BallNames) do
        local ball = workspace:FindFirstChild(name)
        if ball and ball:IsA("BasePart") then
            debugPrint("Found ball by name: " .. name)
            return ball
        end
    end
    
    -- Then try searching all parts
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local nameLower = obj.Name:lower()
            if nameLower:find("ball") or nameLower:find("blade") then
                debugPrint("Found ball by search: " .. obj.Name)
                return obj
            end
        end
    end
    
    debugPrint("No ball found!")
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

-- Parry function with debug info
local function parry()
    debugPrint("Parry function called")
    
    if tick() - lastParryTime < config.ParryCooldown then
        debugPrint("On cooldown")
        return
    end
    
    if isParrying then
        debugPrint("Already parrying")
        return
    end
    
    isParrying = true
    lastParryTime = tick()
    
    local ball = findBall()
    if not ball then 
        debugPrint("No ball found")
        isParrying = false
        return 
    end
    
    debugPrint("Ball found: " .. ball.Name)
    
    -- Calculate distance and angle
    local distance = (ball.Position - rootPart.Position).Magnitude
    local direction = (ball.Position - rootPart.Position).Unit
    local lookVector = rootPart.CFrame.LookVector
    local angle = math.deg(math.acos(math.clamp(direction:Dot(lookVector), -1, 1)))
    
    debugPrint("Distance: " .. distance .. " Angle: " .. angle)
    
    -- Check if within range and angle
    if distance <= config.ParryRange and angle <= config.ParryAngle then
        debugPrint("Parry conditions met!")
        
        -- Apply force
        local parryDirection = (ball.Position - rootPart.Position).Unit
        ball.Velocity = parryDirection * config.ParryForce
        
        debugPrint("Applied velocity: " .. tostring(ball.Velocity))
        
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
    else
        debugPrint("Parry conditions not met")
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
    debugPrint("Character respawned")
end)

-- Simple notification
local notification = Instance.new("TextLabel")
notification.Size = UDim2.new(0, 250, 0, 40)
notification.Position = UDim2.new(0.5, -125, 0.3, 0)
notification.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
notification.BackgroundTransparency = 0.3
notification.Text = "Blade Ball Parry Ready!"
notification.TextColor3 = Color3.fromRGB(255, 255, 255)
notification.TextScaled = true
notification.Font = Enum.Font.GothamBold
notification.Parent = screenGui

local notifCorner = Instance.new("UICorner")
notifCorner.CornerRadius = UDim.new(0, 8)
notifCorner.Parent = notification

-- Remove notification after 3 seconds
game:GetService("Debris"):AddItem(notification, 3)

debugPrint("Blade Ball Parry script loaded!")

-- Auto-detect ball every 5 seconds
spawn(function()
    while true do
        wait(5)
        local ball = findBall()
        if ball then
            debugPrint("Auto-detected ball: " .. ball.Name)
        end
    end
end)
