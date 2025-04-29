# Make sure to drop a ⭐ if you liked the script

## Load the script
```lua
loadstring(game:HttpGet(""))()
```

## Configurable settings
```lua
getgenv().esp = {
    enabled = false, 
    outlineColor = Color3.fromRGB(255, 255, 255),
    fillColor = Color3.fromRGB(0, 0, 0),
    fillTransparency = 1,
    outlineTransparency = 0, 
    teamCheck = false 
}
```
> [!IMPORTANT]
> Script is disabled by default. You must run esp.enabled = true to turn it on.

## Example use of the Script
```lua
loadstring(game:HttpGet(""))() -- load the script
esp.enabled = true
esp.teamcheck = true
esp.fillcolor = Color3.fromRGB(0, 0, 255)
esp.outlinecolor = Color3.fromRGB(255, 255, 0)
```
