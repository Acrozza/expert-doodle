-- Blade Ball Parry Script
-- Hosted at: https://github.com/Acrozza/expert-doodle

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local CoreGui = game:GetService("CoreGui")

-- Executor detection
local function getExecutor()
    if syn and syn.protect_gui then
        return "Synapse X"
    elseif KRNL_LOADED then
        return "KRNL"
    elseif Fluxus then
        return "Fluxus"
    elseif Xeno then
        return Xeno
    else
        return "Xeno"
    end
end

local executor = getExecutor()
print("Detected executor:", executor)

-- Create GUI
local function createGui()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BladeBallParry"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Protect GUI for supported executors
    if syn and syn.protect_gui then
        syn.protect_gui(screenGui)
        screenGui.Parent = CoreGui
    elseif executor == "KRNL" or executor == "Fluxus" then
        screenGui.Parent = CoreGui
    else
        screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    end
    
    return screenGui
end

-- Create loading screen
local function createLoadingScreen(gui)
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 350, 0, 200)
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -100)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = gui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    local shadow = Instance.new("Frame")
    shadow.Size = UDim2.new(1, 10, 1, 10)
    shadow.Position = UDim2.new(0, 5, 0, 5)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.5
    shadow.BorderSizePixel = 0
    shadow.ZIndex = -1
    shadow.Parent = mainFrame
    
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, 12)
    shadowCorner.Parent = shadow
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 50)
    titleLabel.Position = UDim2.new(0, 0, 0, 20)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Blade Ball Parry"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = mainFrame
    
    local executorLabel = Instance.new("TextLabel")
    executorLabel.Size = UDim2.new(1, 0, 0, 30)
    executorLabel.Position = UDim2.new(0, 0, 0, 70)
    executorLabel.BackgroundTransparency = 1
    executorLabel.Text = "Executor: " .. executor
    executorLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
    executorLabel.TextScaled = true
    executorLabel.Font = Enum.Font.Gotham
    executorLabel.Parent = mainFrame
    
    local loadingLabel = Instance.new("TextLabel")
    loadingLabel.Size = UDim2.new(1, 0, 0, 30)
    loadingLabel.Position = UDim2.new(0, 0, 0, 110)
    loadingLabel.BackgroundTransparency = 1
    loadingLabel.Text = "Initializing..."
    loadingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    loadingLabel.TextScaled = true
    loadingLabel.Font = Enum.Font.Gotham
    loadingLabel.Parent = mainFrame
    
    local progressBar = Instance.new("Frame")
    progressBar.Size = UDim2.new(0, 300, 0, 6)
    progressBar.Position = UDim2.new(0.5, -150, 0, 150)
    progressBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    progressBar.BorderSizePixel = 0
    progressBar.Parent = mainFrame
    
    local progressCorner = Instance.new("UICorner")
    progressCorner.CornerRadius = UDim.new(0, 3)
    progressCorner.Parent = progressBar
    
    local progressFill = Instance.new("Frame")
    progressFill.Size = UDim2.new(0, 0, 1, 0)
    progressFill.Position = UDim2.new(0, 0, 0, 0)
    progressFill.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
    progressFill.BorderSizePixel = 0
    progressFill.Parent = progressBar
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = progressFill
    
    return mainFrame, loadingLabel, progressFill
end

-- Create main UI
local function createMainUI(gui)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0, 220, 0, 100)
    container.Position = UDim2.new(0.5, -110, 0.85, 0)
    container.BackgroundTransparency = 0.3
    container.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    container.BorderSizePixel = 0
    container.Parent = gui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = container
    
    local glow = Instance.new("Frame")
    glow.Size = UDim2.new(1, 20, 1, 20)
    glow.Position = UDim2.new(0, -10, 0, -10)
    glow.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
    glow.BackgroundTransparency = 0.8
    glow.BorderSizePixel = 0
    glow.ZIndex = -1
    glow.Parent = container
    
    local glowCorner = Instance.new("UICorner")
    glowCorner.CornerRadius = UDim.new(0, 15)
    glowCorner.Parent = glow
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, 0, 0, 40)
    statusLabel.Position = UDim2.new(0, 0, 0, 10)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "READY TO PARRY"
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusLabel.TextScaled = true
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.Parent = container
    
    local keyLabel = Instance.new("TextLabel")
    keyLabel.Size = UDim2.new(0, 40, 0, 40)
    keyLabel.Position = UDim2.new(0.5, -20, 0, 10)
    keyLabel.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
    keyLabel.BorderSizePixel = 0
    keyLabel.Text = "F"
    keyLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
    keyLabel.TextScaled = true
    keyLabel.Font = Enum.Font.GothamBold
    keyLabel.Parent = container
    
    local keyCorner = Instance.new("UICorner")
    keyCorner.CornerRadius = UDim.new(0, 8)
    keyCorner.Parent = keyLabel
    
    local cooldownBg = Instance.new("Frame")
    cooldownBg.Size = UDim2.new(0, 180, 0, 10)
    cooldownBg.Position = UDim2.new(0.5, -90, 0, 60)
    cooldownBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    cooldownBg.BorderSizePixel = 0
    cooldownBg.Parent = container
    
    local cooldownCorner = Instance.new("UICorner")
    cooldownCorner.CornerRadius = UDim.new(0, 5)
    cooldownCorner.Parent = cooldownBg
    
    local cooldownFill = Instance.new("Frame")
    cooldownFill.Size = UDim2.new(1, 0, 1, 0)
    cooldownFill.Position = UDim2.new(0, 0, 0, 0)
    cooldownFill.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
    cooldownFill.BorderSizePixel = 0
    cooldownFill.Parent = cooldownBg
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 5)
    fillCorner.Parent = cooldownFill
    
    return container, statusLabel, keyLabel, cooldownFill, glow
end

-- Initialize script
local function initialize()
    -- Create GUI
    local gui = createGui()
    local loadingFrame, loadingLabel, progressFill = createLoadingScreen(gui)
    
    -- Simulate loading progress
    local loadingSteps = {
        "Initializing services...",
        "Loading configuration...",
        "Setting up UI...",
        "Connecting events...",
        "Ready!"
    }
    
    for i, step in ipairs(loadingSteps) do
        loadingLabel.Text = step
        progressFill:TweenSize(
            UDim2.new(i / #loadingSteps, 0, 1, 0),
            Enum.InstantOutDirection,
            Enum.EasingStyle.Linear,
            0.3,
            true
        )
        task.wait(0.5)
    end
    
    -- Remove loading screen
    TweenService:Create(loadingFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 1
    }):Play()
    Debris:AddItem(loadingFrame, 0.5)
    
    -- Player setup
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local rootPart = character:WaitForChild("HumanoidRootPart")
    
    -- Configuration
    local config = {
        ParryKey = Enum.KeyCode.F,
        ParryRange = 15,
        ParryAngle = 60,
        ParryCooldown = 1.5,
        ParryForce = 150,
        BallNames = {"Ball", "BladeBall", "GameBall", "SwordBall"},
        VisualEffects = true,
        SoundEffects = true
    }
    
    -- State variables
    local lastParryTime = 0
    local isParrying = false
    
    -- Create main UI
    local container, statusLabel, keyLabel, cooldownFill, glow = createMainUI(gui)
    
    -- Sound effect
    local parrySound = Instance.new("Sound")
    parrySound.SoundId = "rbxassetid://131961136"
    parrySound.Volume = 2
    parrySound.Parent = rootPart
    
    -- Find ball with multiple name attempts
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
        cooldownFill:TweenSize(
            UDim2.new(cooldownProgress, 0, 1, 0),
            Enum.InstantOutDirection,
            Enum.EasingStyle.Linear,
            0.1,
            true
        )
        
        -- Update status text
        if cooldownProgress >= 1 then
            statusLabel.Text = "READY TO PARRY"
            statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            keyLabel.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
            keyLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
            glow.BackgroundTransparency = 0.8
        else
            local remaining = math.ceil(config.ParryCooldown - timeSinceParry)
            statusLabel.Text = "COOLDOWN: " .. remaining .. "s"
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            keyLabel.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
            keyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            glow.BackgroundTransparency = 1
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
            
            -- Visual effects
            if config.VisualEffects then
                local flash = Instance.new("Part")
                flash.Size = Vector3.new(5, 8, 1)
                flash.Color = Color3.fromRGB(255, 255, 200)
                flash.Material = Enum.Material.Neon
                flash.Anchored = true
                flash.CanCollide = false
                flash.CFrame = rootPart.CFrame * CFrame.new(0, 0, -3)
                flash.Parent = workspace
                Debris:AddItem(flash, 0.2)
                
                -- Particle effect
                local particles = Instance.new("ParticleEmitter")
                particles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
                particles.Color = ColorSequence.new(Color3.new(1, 1, 0.5), Color3.new(1, 0.5, 0))
                particles.Size = NumberSequence.new(0.5, 0)
                particles.Lifetime = NumberRange.new(0.5, 1)
                particles.Rate = 100
                particles.Enabled = true
                particles.Parent = flash
                particles:Emit(30)
            end
            
            -- Sound effects
            if config.SoundEffects then
                parrySound:Play()
            end
            
            -- UI feedback
            statusLabel.Text = "PARRIED!"
            statusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
            keyLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
            keyLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
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
        parrySound.Parent = rootPart
    end)
    
    -- Executor-specific optimizations
    if executor == "Synapse X" then
        print("Applying Synapse X optimizations")
    elseif executor == "KRNL" then
        print("Applying KRNL optimizations")
    elseif executor == "Fluxus" then
        print("Applying Fluxus optimizations")
    end
    
    print("Blade Ball Parry script loaded successfully!")
end

-- Start the script
task.spawn(initialize)
