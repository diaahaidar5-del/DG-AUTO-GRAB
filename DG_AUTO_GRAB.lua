local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local grabRadius = 20
local grabCooldown = 0.5
local lastGrabTime = 0
local grabEnabled = true

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DG_AUTO_GRAB"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 120, 0, 50)
toggleButton.Position = UDim2.new(0, 10, 0, 10)
toggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
toggleButton.TextColor3 = Color3.fromRGB(0, 0, 0)
toggleButton.TextSize = 18
toggleButton.Font = Enum.Font.GothamBold
toggleButton.Text = "GRAB: ON"
toggleButton.Parent = screenGui

local function grabObject(object)
    if object:FindFirstChild("Humanoid") then return false end
    local hand = character:FindFirstChild("RightHand") or character:FindFirstChild("RightUpperArm") or humanoidRootPart
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = hand
    weld.Part1 = object
    weld.Parent = object
    return true
end

toggleButton.MouseButton1Click:Connect(function()
    grabEnabled = not grabEnabled
    toggleButton.BackgroundColor3 = grabEnabled and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(100, 100, 100)
    toggleButton.Text = grabEnabled and "GRAB: ON" or "GRAB: OFF"
end)

RunService.Heartbeat:Connect(function()
    if not grabEnabled then return end
    if tick() - lastGrabTime < grabCooldown then return end
    for _, part in pairs(workspace:FindPartBoundsInRadius(humanoidRootPart.Position, grabRadius)) do
        if part.Parent ~= character and not part.Parent:FindFirstChild("Humanoid") then
            if grabObject(part) then
                lastGrabTime = tick()
                break
            end
        end
    end
end)

player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
end)
