-- Classic Roblox Box ESP Script
-- Inspired by Exunys/ESP-Script and wa0101/Roblox-ESP

getgenv().esp = getgenv().esp or {
    enabled = false,
    outlineColor = Color3.fromRGB(255, 255, 255),
    outlineTransparency = 0,
    teamCheck = true
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
    box.Thickness = 2
    box.Filled = false
    box.Visible = false
    box.Color = getgenv().esp.outlineColor
    box.Transparency = getgenv().esp.outlineTransparency
    box.ZIndex = 2
    espObjects[player] = box
end

local function removeBox(player)
    if espObjects[player] then
        espObjects[player]:Remove()
        espObjects[player] = nil
    end
end

local function updateEsp(player)
    local box = espObjects[player]
    if not box then return end

    if not getgenv().esp.enabled then
        box.Visible = false
        return
    end

    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") or not character:FindFirstChild("Humanoid") then
        box.Visible = false
        return
    end

    if getgenv().esp.teamCheck and player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
        box.Visible = false
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
        box.Visible = false
        return
    end
    box.Size = Vector2.new(maxX - minX, maxY - minY)
    box.Position = Vector2.new(minX, minY)
    box.Color = getgenv().esp.outlineColor
    box.Transparency = getgenv().esp.outlineTransparency
    box.Visible = true
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

-- Example usage:
-- getgenv().esp.enabled = true
-- getgenv().esp.outlineColor = Color3.fromRGB(255, 0, 0) -- red box
-- getgenv().esp.teamCheck = false -- show all players 
