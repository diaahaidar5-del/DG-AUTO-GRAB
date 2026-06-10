local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local grabRadius = 63
local stealDuration = 3
local grabEnabled = true
local stealingObjects = {}
local grabCounter = 0

-- UI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DG_AUTO_GRAB_UI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local bgPanel = Instance.new("Frame")
bgPanel.Name = "BG"
bgPanel.Size = UDim2.new(0, 280, 0, 220)
bgPanel.Position = UDim2.new(0, 15, 0, 15)
bgPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
bgPanel.BorderSizePixel = 0
bgPanel.Parent = screenGui

local bgCorner = Instance.new("UICorner")
bgCorner.CornerRadius = UDim.new(0, 12)
bgCorner.Parent = bgPanel

local bgStroke = Instance.new("UIStroke")
bgStroke.Color = Color3.fromRGB(255, 100, 100)
bgStroke.Thickness = 2
bgStroke.Parent = bgPanel

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -20, 0, 40)
titleText.Position = UDim2.new(0, 10, 0, 10)
titleText.BackgroundTransparency = 1
titleText.TextColor3 = Color3.fromRGB(255, 120, 120)
titleText.TextSize = 22
titleText.Font = Enum.Font.GothamBold
titleText.Text = "⚡ DG AUTO GRAB"
titleText.Parent = bgPanel

local toggleButton = Instance.new("TextButton")
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

local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, -20, 0, 30)
statusText.Position = UDim2.new(0, 10, 0, 110)
statusText.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
statusText.TextColor3 = Color3.fromRGB(100, 255, 100)
statusText.TextSize = 13
statusText.Font = Enum.Font.Gotham
statusText.Text = "✓ Ready"
statusText.BorderSizePixel = 0
statusText.Parent = bgPanel

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 6)
statusCorner.Parent = statusText

local counterText = Instance.new("TextLabel")
counterText.Size = UDim2.new(1, -20, 0, 25)
counterText.Position = UDim2.new(0, 10, 0, 175)
counterText.BackgroundTransparency = 1
counterText.TextColor3 = Color3.fromRGB(255, 150, 150)
counterText.TextSize = 12
counterText.Font = Enum.Font.GothamBold
counterText.Text = "Grabbed: 0"
counterText.Parent = bgPanel

-- GRAB LOGIC
local function grabObject(obj)
    if obj:FindFirstChild("Humanoid") then return false end
    if stealingObjects[obj] then return false end
    if not obj.Parent or not obj:IsDescendantOf(workspace) then return false end
    
    local name = obj.Name
    stealingObjects[obj] = true
    
    -- Weld to hand
    local hand = character:FindFirstChild("RightHand") 
        or character:FindFirstChild("LeftHand")
        or character:FindFirstChild("RightUpperArm")
        or character:FindFirstChild("LeftUpperArm")
        or humanoidRootPart
    
    local success = pcall(function()
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = hand
        weld.Part1 = obj
        weld.Parent = obj
        
        obj.CanCollide = false
        if obj:IsA("BasePart") then
            obj.TopSurface = Enum.SurfaceType.Smooth
            obj.BottomSurface = Enum.SurfaceType.Smooth
        end
    end)
    
    if success then
        grabCounter = grabCounter + 1
        counterText.Text = "Grabbed: " .. grabCounter
        statusText.Text = "✓ Got: " .. name
        stealingObjects[obj] = nil
        return true
    end
    
    stealingObjects[obj] = nil
    return false
end

-- TOGGLE
toggleButton.MouseButton1Click:Connect(function()
    grabEnabled = not grabEnabled
    if grabEnabled then
        toggleButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
        toggleButton.Text = "▶ GRAB: ON"
        statusText.Text = "✓ Ready"
    else
        toggleButton.BackgroundColor3 = Color3.fromRGB(100, 100, 110)
        toggleButton.Text = "⏸ GRAB: OFF"
        statusText.Text = "⏸ Paused"
    end
end)

-- AUTO GRAB LOOP
RunService.Heartbeat:Connect(function()
    if not grabEnabled or not character or not humanoidRootPart then return end
    
    local nearby = workspace:FindPartBoundsInRadius(humanoidRootPart.Position, grabRadius)
    
    for _, obj in pairs(nearby) do
        if obj and obj.Parent and obj.Parent ~= character then
            if not obj.Parent:FindFirstChild("Humanoid") then
                if grabObject(obj) then
                    break
                end
            end
        end
    end
end)

-- CHARACTER RESPAWN
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    stealingObjects = {}
    statusText.Text = "✓ Ready"
end)
