local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local grabRadius = 63
local stealDuration = 1.5
local grabEnabled = true
local stealingObjects = {}

-- Main Screen GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DG_AUTO_GRAB_UI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Title Rectangle
local titleFrame = Instance.new("Frame")
titleFrame.Name = "TitleFrame"
titleFrame.Size = UDim2.new(0, 200, 0, 50)
titleFrame.Position = UDim2.new(0, 20, 0, 20)
titleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
titleFrame.BorderSizePixel = 0
titleFrame.Parent = screenGui

-- Add corner radius
local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleFrame

-- Title Text
local titleText = Instance.new("TextLabel")
titleText.Name = "TitleText"
titleText.Size = UDim2.new(1, 0, 1, 0)
titleText.BackgroundTransparency = 1
titleText.TextColor3 = Color3.fromRGB(255, 100, 100)
titleText.TextSize = 20
titleText.Font = Enum.Font.GothamBold
titleText.Text = "DG AUTO GRAB"
titleText.Parent = titleFrame

-- Toggle Button Rectangle
local toggleFrame = Instance.new("Frame")
toggleFrame.Name = "ToggleFrame"
toggleFrame.Size = UDim2.new(0, 200, 0, 45)
toggleFrame.Position = UDim2.new(0, 20, 0, 80)
toggleFrame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
toggleFrame.BorderSizePixel = 0
toggleFrame.Parent = screenGui

-- Button corner
local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleFrame

-- Toggle Button
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(1, 0, 1, 0)
toggleButton.BackgroundTransparency = 1
toggleButton.TextColor3 = Color3.fromRGB(0, 0, 0)
toggleButton.TextSize = 18
toggleButton.Font = Enum.Font.GothamBold
toggleButton.Text = "GRAB: ON"
toggleButton.Parent = toggleFrame

-- Status Rectangle
local statusFrame = Instance.new("Frame")
statusFrame.Name = "StatusFrame"
statusFrame.Size = UDim2.new(0, 200, 0, 35)
statusFrame.Position = UDim2.new(0, 20, 0, 135)
statusFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
statusFrame.BorderSizePixel = 0
statusFrame.Parent = screenGui

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 8)
statusCorner.Parent = statusFrame

local statusText = Instance.new("TextLabel")
statusText.Name = "StatusText"
statusText.Size = UDim2.new(1, 0, 1, 0)
statusText.BackgroundTransparency = 1
statusText.TextColor3 = Color3.fromRGB(100, 255, 100)
statusText.TextSize = 14
statusText.Font = Enum.Font.Gotham
statusText.Text = "Ready"
statusText.Parent = statusFrame

-- Function to create steal bar above object
local function createStealBar(object, targetName)
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Size = UDim2.new(4, 0, 1, 0)
    billboardGui.MaxDistance = 100
    billboardGui.Parent = object
    
    local barFrame = Instance.new("Frame")
    barFrame.Size = UDim2.new(1, 0, 0, 20)
    barFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    barFrame.BorderSizePixel = 0
    barFrame.Parent = billboardGui
    
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 4)
    barCorner.Parent = barFrame
    
    -- Progress bar
    local progressBar = Instance.new("Frame")
    progressBar.Name = "ProgressBar"
    progressBar.Size = UDim2.new(0, 0, 1, 0)
    progressBar.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    progressBar.BorderSizePixel = 0
    progressBar.Parent = barFrame
    
    local progressCorner = Instance.new("UICorner")
    progressCorner.CornerRadius = UDim.new(0, 4)
    progressCorner.Parent = progressBar
    
    -- Name label
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextSize = 12
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Text = targetName
    nameLabel.ZIndex = 2
    nameLabel.Parent = barFrame
    
    return billboardGui, progressBar
end

-- Function to steal object
local function stealObject(object)
    if object:FindFirstChild("Humanoid") then return false end
    if stealingObjects[object] then return false end
    
    local targetName = object.Name
    local billboardGui, progressBar = createStealBar(object, targetName)
    stealingObjects[object] = true
    
    local startTime = tick()
    local connection
    
    connection = RunService.Heartbeat:Connect(function()
        local elapsed = tick() - startTime
        local progress = math.min(elapsed / stealDuration, 1)
        
        progressBar.Size = UDim2.new(progress, 0, 1, 0)
        
        if progress >= 1 then
            connection:Disconnect()
            
            -- Weld object to player
            local hand = character:FindFirstChild("RightHand") or character:FindFirstChild("RightUpperArm") or humanoidRootPart
            local weld = Instance.new("WeldConstraint")
            weld.Part0 = hand
            weld.Part1 = object
            weld.Parent = object
            
            billboardGui:Destroy()
            stealingObjects[object] = nil
            statusText.Text = "Grabbed: " .. targetName
        end
    end)
    
    return true
end

-- Toggle button functionality
toggleButton.MouseButton1Click:Connect(function()
    grabEnabled = not grabEnabled
    if grabEnabled then
        toggleFrame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        toggleButton.Text = "GRAB: ON"
        statusText.Text = "Ready"
    else
        toggleFrame.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        toggleButton.Text = "GRAB: OFF"
        statusText.Text = "Paused"
    end
end)

-- Main grab loop
RunService.Heartbeat:Connect(function()
    if not grabEnabled then return end
    
    local partsInRadius = workspace:FindPartBoundsInRadius(humanoidRootPart.Position, grabRadius)
    
    for _, part in pairs(partsInRadius) do
        if part.Parent ~= character and not part.Parent:FindFirstChild("Humanoid") then
            if stealObject(part) then
                break
            end
        end
    end
end)

-- Handle character respawn
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    stealingObjects = {}
end)
