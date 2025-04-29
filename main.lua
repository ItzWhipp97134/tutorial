getgenv().esp = getgenv().esp or {
    enabled = false,
    outlineColor = Color3.fromRGB(255, 255, 255),
    fillColor = Color3.fromRGB(0, 0, 0),
    fillTransparency = 1,
    outlineTransparency = 0,
    teamCheck = false
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local espObjects = {}

local function getBoundingBoxCorners(model)
    local cframe, size = model:GetBoundingBox()
    local corners = {}
    for x = -0.5, 0.5, 1 do
        for y = -0.5, 0.5, 1 do
            for z = -0.5, 0.5, 1 do
                local world = cframe * Vector3.new(size.X * x, size.Y * y, size.Z * z)
                table.insert(corners, world)
            end
        end
    end
    return corners
end

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
    espObjects[player] = { box = box, fill = fill }
end

local function removeBox(player)
    if espObjects[player] then
        for _, drawing in pairs(espObjects[player]) do
            if drawing then drawing:Remove() end
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
    local corners = getBoundingBoxCorners(character)
    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    local onScreen = false
    for _, corner in ipairs(corners) do
        local screenPos, visible = Camera:WorldToViewportPoint(corner)
        if visible then
            onScreen = true
            minX = math.min(minX, screenPos.X)
            minY = math.min(minY, screenPos.Y)
            maxX = math.max(maxX, screenPos.X)
            maxY = math.max(maxY, screenPos.Y)
        end
    end
    if not onScreen then
        if espObjects[player] then
            espObjects[player].box.Visible = false
            espObjects[player].fill.Visible = false
        end
        return
    end
    local boxSize = Vector2.new(maxX - minX, maxY - minY)
    local boxPosition = Vector2.new(minX, minY)
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
