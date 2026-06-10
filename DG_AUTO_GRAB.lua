local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local grabRadius = 63
local stealDuration = 3
local grabEnabled = true
local stealingObjects = {}
local grabCooldown = 0.5
local lastGrabTime = 0

-- Main Screen GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DG_AUTO_GRAB_UI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Background Panel
local bgPanel = Instance.new("Frame")
bgPanel.Name = "BackgroundPanel"
bgPanel.Size = UDim2.new(0, 280, 0, 220)
bgPanel.Position = UDim2.new(0, 15, 0, 15)
bgPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
bgPanel.BorderSizePixel = 0
bgPanel.Parent = screenGui

local bgCorner = Instance.new("UICorner")
bgCorner.CornerRadius = UDim.new(0, 12)
bgCorner.Parent = bgPanel

-- Add stroke for better look
local bgStroke = Instance.new("UIStroke")
bgStroke.Color = Color3.fromRGB(255, 100, 100)
bgStroke.Thickness = 2
bgStroke.Parent = bgPanel

-- Title
local titleText = Instance.new("TextLabel")
titleText.Name = "Title"
titleText.Size = UDim2.new(1, -20, 0, 40)
titleText.Position = UDim2.new(0, 10, 0, 10)
titleText.BackgroundTransparency = 1
titleText.TextColor3 = Color3.fromRGB(255, 120, 120)
titleText.TextSize = 22
titleText.Font = Enum.Font.GothamBold
titleText.Text = "⚡ DG AUTO GRAB"
titleText.Parent = bgPanel

-- Toggle Button
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(1, -20, 0, 45)
toggleButton.Position = UDim2.new(0, 10, 0, 55)
toggleButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextSize = 16
toggleButton.Font = Enum.Font.GothamBold
toggleButton.Text = "▶ GRAB: ON"
toggleButton.BorderSizePixel = 0
toggleButton.Parent = bgPanel

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleButton

-- Status Text
local statusText = Instance.new("TextLabel")
statusText.Name = "Status"
statusText.Size = UDim2.new(1, -20, 0, 30)
statusText.Position = UDim2.new(0, 10, 0, 110)
statusText.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
statusText.TextColor3 = Color3.fromRGB(100, 255, 100)
statusText.TextSize = 13
statusText.Font = Enum.Font.Gotham
statusText.Text = "✓ Ready to grab"
statusText.BorderSizePixel = 0
statusText.Parent = bgPanel

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 6)
statusCorner.Parent = statusText

-- Radius Display
local radiusText = Instance.new("TextLabel")
radiusText.Name = "Radius"
radiusText.Size = UDim2.new(1, -20, 0, 25)
radiusText.Position = UDim2.new(0, 10, 0, 145)
radiusText.BackgroundTransparency = 1
radiusText.TextColor3 = Color3.fromRGB(200, 200, 200)
radiusText.TextSize = 12
radiusText.Font = Enum.Font.Gotham
radiusText.Text = "Radius: 63 | Duration: 3s"
radiusText.Parent = bgPanel

-- Grab Counter
local counterText = Instance.new("TextLabel")
counterText.Name = "Counter"
counterText.Size = UDim2.new(1, -20, 0, 25)
counterText.Position = UDim2.new(0, 10, 0, 175)
counterText.BackgroundTransparency = 1
counterText.TextColor3 = Color3.fromRGB(255, 150, 150)
counterText.TextSize = 12
counterText.Font = Enum.Font.GothamBold
counterText.Text = "Objects Grabbed: 0"
counterText.Parent = bgPanel

local grabCounter = 0

-- Function to create steal bar above object
local function createStealBar(object, targetName)
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Size = UDim2.new(5, 0, 1.5, 0)
    billboardGui.MaxDistance = 150
    billboardGui.Parent = object
    
    -- Background
    local barFrame = Instance.new("Frame")
    barFrame.Size = UDim2.new(1, 0, 0, 25)
    barFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    barFrame.BorderSizePixel = 0
    barFrame.Parent = billboardGui
    
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 5)
    barCorner.Parent = barFrame
    
    -- Progress bar background
    local progressBackground = Instance.new("Frame")
    progressBackground.Name = "ProgressBg"
    progressBackground.Size = UDim2.new(0.95, 0, 0.6, 0)
    progressBackground.Position = UDim2.new(0.025, 0, 0.2, 0)
    progressBackground.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    progressBackground.BorderSizePixel = 0
    progressBackground.Parent = barFrame
    
    local progBgCorner = Instance.new("UICorner")
    progBgCorner.CornerRadius = UDim.new(0, 3)
    progBgCorner.Parent = progressBackground
    
    -- Progress bar fill
    local progressBar = Instance.new("Frame")
    progressBar.Name = "ProgressBar"
    progressBar.Size = UDim2.new(0, 0, 1, 0)
    progressBar.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    progressBar.BorderSizePixel = 0
    progressBar.Parent = progressBackground
    
    local progCorner = Instance.new("UICorner")
    progCorner.CornerRadius = UDim.new(0, 3)
    progCorner.Parent = progressBar
    
    -- Name label
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0.95, 0, 0.35, 0)
    nameLabel.Position = UDim2.new(0.025, 0, 0.05, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextSize = 11
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Text = targetName
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.ZIndex = 2
    nameLabel.Parent = barFrame
    
    -- Percentage label
    local percentLabel = Instance.new("TextLabel")
    percentLabel.Size = UDim2.new(0.95, 0, 0.35, 0)
    percentLabel.Position = UDim2.new(0.025, 0, 0.05, 0)
    percentLabel.BackgroundTransparency = 1
    percentLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    percentLabel.TextSize = 11
    percentLabel.Font = Enum.Font.GothamBold
    percentLabel.Text = "0%"
    percentLabel.TextXAlignment = Enum.TextXAlignment.Right
    percentLabel.ZIndex = 2
    percentLabel.Parent = barFrame
    
    return billboardGui, progressBar, progressBackground, percentLabel
end

-- Function to steal object
local function stealObject(object)
    if object:FindFirstChild("Humanoid") then return false end
    if stealingObjects[object] then return false end
    if not object.Parent then return false end
    
    local targetName = object.Name
    local billboardGui, progressBar, progressBg, percentLabel = createStealBar(object, targetName)
    stealingObjects[object] = true
    
    local startTime = tick()
    local connection
    
    connection = RunService.Heartbeat:Connect(function()
        if not object.Parent or not billboardGui.Parent then
            connection:Disconnect()
            stealingObjects[object] = nil
            if billboardGui and billboardGui.Parent then
                billboardGui:Destroy()
            end
            return
        end
        
        local elapsed = tick() - startTime
        local progress = math.min(elapsed / stealDuration, 1)
        
        -- Smooth progress bar fill
        progressBar.Size = UDim2.new(progress, 0, 1, 0)
        percentLabel.Text = math.floor(progress * 100) .. "%"
        
        if progress >= 1 then
            connection:Disconnect()
            
            -- Weld object to player hand
            if character and humanoidRootPart then
                local hand = character:FindFirstChild("RightHand") or character:FindFirstChild("RightUpperArm") or humanoidRootPart
                if hand and object and object.Parent then
                    local weld = Instance.new("WeldConstraint")
                    weld.Part0 = hand
                    weld.Part1 = object
                    weld.Parent = object
                    
                    -- Make object not collideable with ground
                    pcall(function()
                        object.CanCollide = false
                    end)
                end
            end
            
            grabCounter = grabCounter + 1
            counterText.Text = "Objects Grabbed: " .. grabCounter
            statusText.Text = "✓ Grabbed: " .. targetName
            
            if billboardGui and billboardGui.Parent then
                billboardGui:Destroy()
            end
            stealingObjects[object] = nil
        end
    end)
    
    return true
end

-- Toggle button functionality
toggleButton.MouseButton1Click:Connect(function()
    grabEnabled = not grabEnabled
    if grabEnabled then
        toggleButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
        toggleButton.Text = "▶ GRAB: ON"
        statusText.Text = "✓ Ready to grab"
        lastGrabTime = 0
    else
        toggleButton.BackgroundColor3 = Color3.fromRGB(100, 100, 110)
        toggleButton.Text = "⏸ GRAB: OFF"
        statusText.Text = "⏸ Paused"
    end
end)

-- Main grab loop - AGGRESSIVE AUTO GRAB
RunService.Heartbeat:Connect(function()
    if not grabEnabled or not character or not humanoidRootPart then return end
    
    -- Check cooldown
    if tick() - lastGrabTime < grabCooldown then return end
    
    local partsInRadius = workspace:FindPartBoundsInRadius(humanoidRootPart.Position, grabRadius)
    
    for _, part in pairs(partsInRadius) do
        if part and part.Parent and part.Parent ~= character then
            -- Don't grab characters
            if not part.Parent:FindFirstChild("Humanoid") then
                -- Try to grab this part
                if stealObject(part) then
                    lastGrabTime = tick()
                    break
                end
            end
        end
    end
end)

-- Handle character respawn
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    stealingObjects = {}
    statusText.Text = "✓ Ready to grab"
    lastGrabTime = 0
end)
