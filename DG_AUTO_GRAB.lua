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
local grabCounter = 0
local currentGrabProgress = 0

-- Create Main GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DG_AUTO_GRAB_UI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Main Panel with gradient effect
local mainPanel = Instance.new("Frame")
mainPanel.Name = "MainPanel"
mainPanel.Size = UDim2.new(0, 350, 0, 280)
mainPanel.Position = UDim2.new(0, 20, 0, 20)
mainPanel.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
mainPanel.BorderSizePixel = 0
mainPanel.Parent = screenGui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 15)
panelCorner.Parent = mainPanel

local panelStroke = Instance.new("UIStroke")
panelStroke.Color = Color3.fromRGB(255, 100, 100)
panelStroke.Thickness = 3
panelStroke.Parent = mainPanel

-- Title with animation
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, -20, 0, 50)
titleLabel.Position = UDim2.new(0, 10, 0, 10)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
titleLabel.TextSize = 28
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = "⚡ DG AUTO STEAL"
titleLabel.Parent = mainPanel

-- Toggle Button with hover effect
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleBtn"
toggleButton.Size = UDim2.new(1, -20, 0, 50)
toggleButton.Position = UDim2.new(0, 10, 0, 70)
toggleButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextSize = 18
toggleButton.Font = Enum.Font.GothamBold
toggleButton.Text = "▶ START STEALING"
toggleButton.BorderSizePixel = 0
toggleButton.AutoButtonColor = false
toggleButton.Parent = mainPanel

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 10)
btnCorner.Parent = toggleButton

-- Status display
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "Status"
statusLabel.Size = UDim2.new(1, -20, 0, 30)
statusLabel.Position = UDim2.new(0, 10, 0, 130)
statusLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
statusLabel.TextSize = 14
statusLabel.Font = Enum.Font.Gotham
statusLabel.Text = "✓ Ready to steal"
statusLabel.BorderSizePixel = 0
statusLabel.Parent = mainPanel

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 8)
statusCorner.Parent = statusLabel

-- Counter
local counterLabel = Instance.new("TextLabel")
counterLabel.Name = "Counter"
counterLabel.Size = UDim2.new(1, -20, 0, 25)
counterLabel.Position = UDim2.new(0, 10, 0, 170)
counterLabel.BackgroundTransparency = 1
counterLabel.TextColor3 = Color3.fromRGB(255, 150, 150)
counterLabel.TextSize = 14
counterLabel.Font = Enum.Font.GothamBold
counterLabel.Text = "Items Stolen: 0"
counterLabel.Parent = mainPanel

-- PROGRESS BAR AT BOTTOM
local progressBarBg = Instance.new("Frame")
progressBarBg.Name = "ProgressBarBg"
progressBarBg.Size = UDim2.new(1, -20, 0, 20)
progressBarBg.Position = UDim2.new(0, 10, 0, 250)
progressBarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
progressBarBg.BorderSizePixel = 0
progressBarBg.Parent = mainPanel

local progressCorner = Instance.new("UICorner")
progressCorner.CornerRadius = UDim.new(0, 6)
progressCorner.Parent = progressBarBg

-- Actual progress fill
local progressBar = Instance.new("Frame")
progressBar.Name = "ProgressBar"
progressBar.Size = UDim2.new(0, 0, 1, 0)
progressBar.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
progressBar.BorderSizePixel = 0
progressBar.Parent = progressBarBg

local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(0, 6)
fillCorner.Parent = progressBar

-- Progress text
local progressText = Instance.new("TextLabel")
progressText.Name = "ProgressText"
progressText.Size = UDim2.new(1, 0, 1, 0)
progressText.BackgroundTransparency = 1
progressText.TextColor3 = Color3.fromRGB(255, 255, 255)
progressText.TextSize = 12
progressText.Font = Enum.Font.GothamBold
progressText.Text = "0%"
progressText.ZIndex = 2
progressText.Parent = progressBarBg

-- Hover effects
local function onMouseEnter()
    if grabEnabled then
        toggleButton.BackgroundColor3 = Color3.fromRGB(255, 120, 120)
    end
end

local function onMouseLeave()
    if grabEnabled then
        toggleButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    end
end

toggleButton.MouseEnter:Connect(onMouseEnter)
toggleButton.MouseLeave:Connect(onMouseLeave)

-- Toggle functionality
toggleButton.MouseButton1Click:Connect(function()
    grabEnabled = not grabEnabled
    if grabEnabled then
        toggleButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
        toggleButton.Text = "▶ START STEALING"
        statusLabel.Text = "✓ Ready to steal"
    else
        toggleButton.BackgroundColor3 = Color3.fromRGB(100, 100, 110)
        toggleButton.Text = "⏸ STEALING PAUSED"
        statusLabel.Text = "⏸ Paused"
    end
end)

-- Main grab function
local function stealObject(obj)
    if obj:FindFirstChild("Humanoid") then return false end
    if stealingObjects[obj] then return false end
    if not obj.Parent or not obj:IsDescendantOf(workspace) then return false end
    
    local name = obj.Name
    local startTime = tick()
    stealingObjects[obj] = true
    
    local grabConnection
    grabConnection = RunService.Heartbeat:Connect(function()
        if not obj.Parent or not obj:IsDescendantOf(workspace) then
            grabConnection:Disconnect()
            stealingObjects[obj] = nil
            return
        end
        
        local elapsed = tick() - startTime
        local progress = math.min(elapsed / stealDuration, 1)
        currentGrabProgress = progress
        
        -- Update progress bar
        progressBar.Size = UDim2.new(progress, 0, 1, 0)
        progressText.Text = math.floor(progress * 100) .. "%"
        
        if progress >= 1 then
            grabConnection:Disconnect()
            
            -- Weld to hand
            local hand = character:FindFirstChild("RightHand") 
                or character:FindFirstChild("LeftHand")
                or character:FindFirstChild("RightUpperArm")
                or character:FindFirstChild("LeftUpperArm")
                or humanoidRootPart
            
            pcall(function()
                local weld = Instance.new("WeldConstraint")
                weld.Part0 = hand
                weld.Part1 = obj
                weld.Parent = obj
                obj.CanCollide = false
            end)
            
            grabCounter = grabCounter + 1
            counterLabel.Text = "Items Stolen: " .. grabCounter
            statusLabel.Text = "✓ Stole: " .. name
            progressBar.Size = UDim2.new(0, 0, 1, 0)
            progressText.Text = "0%"
            stealingObjects[obj] = nil
        end
    end)
    
    return true
end

-- Auto grab loop
RunService.Heartbeat:Connect(function()
    if not grabEnabled or not character or not humanoidRootPart then return end
    
    local nearby = workspace:FindPartBoundsInRadius(humanoidRootPart.Position, grabRadius)
    
    for _, obj in pairs(nearby) do
        if obj and obj.Parent and obj.Parent ~= character then
            if not obj.Parent:FindFirstChild("Humanoid") then
                if stealObject(obj) then
                    break
                end
            end
        end
    end
end)

-- Character respawn
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    stealingObjects = {}
    statusLabel.Text = "✓ Ready to steal"
    progressBar.Size = UDim2.new(0, 0, 1, 0)
    progressText.Text = "0%"
end)
