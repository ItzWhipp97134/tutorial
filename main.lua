-- Tutorial Box ESP Script
-- Made for educational purposes

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Initialize ESP settings
getgenv().esp = {
    enabled = false,  -- ESP starts disabled
    outlineColor = Color3.fromRGB(255, 255, 255),
    fillColor = Color3.fromRGB(0, 0, 0),
    fillTransparency = 0.5,
    outlineTransparency = 0,
    teamCheck = false
}

-- Store our drawing objects
local espObjects = {}

local function createBox(player)
    -- Create box components
    local box = Drawing.new("Square")
    local fill = Drawing.new("Square")
    
    -- Set default properties for fill
    fill.Thickness = 1
    fill.Filled = true
    fill.Visible = false
    fill.ZIndex = 1  -- Make fill render behind outline
    
    -- Set default properties for outline
    box.Thickness = 2  -- Increased thickness for better visibility
    box.Filled = false
    box.Visible = false
    box.ZIndex = 2  -- Make outline render in front
    
    espObjects[player] = {
        box = box,
        fill = fill
    }
end

local function removeBox(player)
    if espObjects[player] then
        for _, drawing in pairs(espObjects[player]) do
            if drawing then
                drawing:Remove()
            end
        end
        espObjects[player] = nil
    end
end

-- Update ESP for a player
local function updateEsp(player)
    if not getgenv().esp.enabled then
        if espObjects[player] then
            espObjects[player].box.Visible = false
            espObjects[player].fill.Visible = false
        end
        return
    end
    
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") or not character:FindFirstChild("Humanoid") then
        if espObjects[player] then
            espObjects[player].box.Visible = false
            espObjects[player].fill.Visible = false
        end
        return
    end
    
    -- Team Check
    if getgenv().esp.teamCheck and player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
        if espObjects[player] then
            espObjects[player].box.Visible = false
            espObjects[player].fill.Visible = false
        end
        return
    end
    
    -- Get character parts
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local head = character:FindFirstChild("Head")
    
    if not hrp or not head then return end
    
    -- Calculate box size and position
    local hrpPos, hrpOnScreen = Camera:WorldToViewportPoint(hrp.Position)
    if not hrpOnScreen then
        if espObjects[player] then
            espObjects[player].box.Visible = false
            espObjects[player].fill.Visible = false
        end
        return
    end
    
    -- Get character dimensions
    local topPosition = Camera:WorldToViewportPoint((head.CFrame * CFrame.new(0, 1, 0)).Position)
    local bottomPosition = Camera:WorldToViewportPoint((hrp.CFrame * CFrame.new(0, -3.5, 0)).Position)
    local radius = math.abs(topPosition.Y - bottomPosition.Y) / 2
    local size = Vector2.new(radius * 1.5, radius * 2)
    local position = Vector2.new(hrpPos.X - size.X / 2, hrpPos.Y - size.Y / 2)
    
    -- Update ESP objects
    if espObjects[player] then
        -- Update fill
        espObjects[player].fill.Size = size
        espObjects[player].fill.Position = position
        espObjects[player].fill.Color = getgenv().esp.fillColor
        espObjects[player].fill.Transparency = getgenv().esp.fillTransparency
        espObjects[player].fill.Visible = true
        
        -- Update outline
        espObjects[player].box.Size = size
        espObjects[player].box.Position = position
        espObjects[player].box.Color = getgenv().esp.outlineColor
        espObjects[player].box.Transparency = getgenv().esp.outlineTransparency
        espObjects[player].box.Visible = true
    end
end

-- Player handling
Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        createBox(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    removeBox(player)
end)

-- Create boxes for existing players
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        createBox(player)
    end
end

-- Update loop
RunService.RenderStepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            updateEsp(player)
        end
    end
end)

-- Clean up on script end
game:GetService("CoreGui").ChildRemoved:Connect(function(child)
    if child == script then
        for _, player in ipairs(Players:GetPlayers()) do
            removeBox(player)
        end
    end
end)

print("Tutorial Box ESP loaded! Use getgenv().esp to modify settings.")
print("Example: getgenv().esp.enabled = true") 
