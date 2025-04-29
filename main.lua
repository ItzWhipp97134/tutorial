local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

getgenv().esp = {
    enabled = false,
    outlineColor = Color3.fromRGB(255, 255, 255),
    fillColor = Color3.fromRGB(0, 0, 0),
    fillTransparency = 0.5,
    outlineTransparency = 0,
    teamCheck = false
}

local espObjects = {}

local function createBox(player)
    local box = Drawing.new("Square")
    local fill = Drawing.new("Square")
    
    fill.Thickness = 1
    fill.Filled = true
    fill.Visible = false
    fill.ZIndex = 1  
    
    box.Thickness = 2  
    box.Filled = false
    box.Visible = false
    box.ZIndex = 2  
    
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
    
    local hrpPos, hrpOnScreen = Camera:WorldToViewportPoint(hrp.Position)
    if not hrpOnScreen then
        if espObjects[player] then
            espObjects[player].box.Visible = false
            espObjects[player].fill.Visible = false
        end
        return
    end
    
    local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
    local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
    
    local boxHeight = math.max(headPos.Y - legPos.Y, 10)
    local boxWidth = math.max(1000 / hrpPos.Z, 10)
    local boxSize = Vector2.new(boxWidth, boxHeight)
    local boxPosition = Vector2.new(hrpPos.X - boxSize.X / 2, hrpPos.Y - boxSize.Y / 2)
    
    if espObjects[player] then
        espObjects[player].fill.Size = boxSize
        espObjects[player].fill.Position = boxPosition
        espObjects[player].fill.Color = getgenv().esp.fillColor
        espObjects[player].fill.Transparency = getgenv().esp.fillTransparency
        espObjects[player].fill.Visible = true
        
        espObjects[player].box.Size = boxSize
        espObjects[player].box.Position = boxPosition
        espObjects[player].box.Color = getgenv().esp.outlineColor
        espObjects[player].box.Transparency = getgenv().esp.outlineTransparency
        espObjects[player].box.Visible = true
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        createBox(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    removeBox(player)
end)

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        createBox(player)
    end
end

RunService.RenderStepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            updateEsp(player)
        end
    end
end)

game:GetService("CoreGui").ChildRemoved:Connect(function(child)
    if child == script then
        for _, player in ipairs(Players:GetPlayers()) do
            removeBox(player)
        end
    end
end)
