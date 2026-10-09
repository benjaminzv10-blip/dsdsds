local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local player = Players.LocalPlayer or Players.PlayerAdded:Wait()

task.wait(15)
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")

local Player = Players.LocalPlayer

Player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)
task.wait(15)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RollbackRideAPetGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 240, 0, 180)
MainFrame.Position = UDim2.new(0.5, -120, 0.5, -90)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(80, 120, 255)
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

local TitleBar = Instance.new("TextLabel")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(40, 45, 60)
TitleBar.BorderSizePixel = 0
TitleBar.Text = "Rollback Ride a Pet"
TitleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleBar.TextSize = 16
TitleBar.Font = Enum.Font.GothamBold
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0, 10)
TitleFix.Position = UDim2.new(0, 0, 1, -10)
TitleFix.BackgroundColor3 = Color3.fromRGB(40, 45, 60)
TitleFix.BorderSizePixel = 0
TitleFix.Parent = TitleBar

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0.9, 0, 0, 45)
ToggleButton.Position = UDim2.new(0.05, 0, 0, 55)
ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 200, 80)
ToggleButton.BorderSizePixel = 0
ToggleButton.Text = "Rollback: ON"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 14
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Parent = MainFrame

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = ToggleButton

local RejoinButton = Instance.new("TextButton")
RejoinButton.Name = "RejoinButton"
RejoinButton.Size = UDim2.new(0.9, 0, 0, 45)
RejoinButton.Position = UDim2.new(0.05, 0, 0, 115)
RejoinButton.BackgroundColor3 = Color3.fromRGB(50, 120, 220)
RejoinButton.BorderSizePixel = 0
RejoinButton.Text = "Rejoin Server"
RejoinButton.TextColor3 = Color3.fromRGB(255, 255, 255)
RejoinButton.TextSize = 14
RejoinButton.Font = Enum.Font.GothamBold
RejoinButton.Parent = MainFrame

local RejoinCorner = Instance.new("UICorner")
RejoinCorner.CornerRadius = UDim.new(0, 8)
RejoinCorner.Parent = RejoinButton

local dragging = false
local dragInput, mousePos, framePos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        mousePos = input.Position
        framePos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - mousePos
        MainFrame.Position = UDim2.new(
            framePos.X.Scale, 
            framePos.X.Offset + delta.X, 
            framePos.Y.Scale, 
            framePos.Y.Offset + delta.Y
        )
    end
end)

local rollbackActive = false
local remotesFolder = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Game")
local eventRemote = remotesFolder:WaitForChild("SaveSatchelOrder")
local hatchRemote = remotesFolder:WaitForChild("Hatch")

local function startRollback()
    task.spawn(function()
        while rollbackActive do
            pcall(function()
                eventRemote:FireServer({
                    Hotbar = { "\xFF" },
                    Backpack = { "\255" }
                })
            end)
            task.wait(0.1)
        end
    end)
end

local function setRollbackState(state)
    rollbackActive = state
    if rollbackActive then
        ToggleButton.Text = "Rollback: ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 200, 80)
        startRollback()
    else
        ToggleButton.Text = "Rollback: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end

ToggleButton.MouseButton1Click:Connect(function()
    setRollbackState(not rollbackActive)
end)

RejoinButton.MouseButton1Click:Connect(function()
    TeleportService:Teleport(game.PlaceId, player)
end)

setRollbackState(true)
task.wait(2)

-- ยิง Remote Hatch ไข่ทั้ง 2 ใบ
pcall(function()
    hatchRemote:FireServer({
        ["EggKey"] = "6d3b78fa-fb95-40c3-a534-66efc45268b0"
    })
    
    hatchRemote:FireServer({
        ["EggKey"] = "052bfb16-c9e6-4180-ab34-80748b98064d"
    })

    hatchRemote:FireServer({
        ["EggKey"] = "126c410a-fedb-42cf-8328-78d71fe4d086"
    })

end)

task.wait(8)

local HttpService = game:GetService("HttpService")
local WEBHOOK_URL = "https://discord.com/api/webhooks/1531167060275761243/jPwoiJhKV5Y66crkdNAdFl46bZ3atDcpiSKfXGOiDmHwgk_lgRb22SaFVJZXJ2TGHnG7"

local function sendDiscordWebhook(msg)
    local request = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    if request then
        local payload = HttpService:JSONEncode({
            content = "@everyone " .. msg,
            username = "Pet Checker"
        })
        pcall(function()
            request({
                Url = WEBHOOK_URL,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = payload
            })
        end)
    end
end

local FoundRainbow = false

local function CheckPet(Container)
    if not Container then return end

    for _, v in ipairs(Container:GetChildren()) do
        if string.find(v.Name, "Dragon", 1, true)
        or string.find(v.Name, "Griffin", 1, true)
        or string.find(v.Name, "Snail", 1, true) then

            if v:GetAttribute("SpawnMutation") == "Rainbow" then
                FoundRainbow = true
            end
        end
    end
end

local backpack = player:WaitForChild("Backpack")
CheckPet(backpack)

if player.Character then
    CheckPet(player.Character)
end

if FoundRainbow then
    print("Rainbow = true")
    sendDiscordWebhook("🎉 **พบ Dragon หรือ Griffin สภาพ Rainbow แล้ว!** (Player: " .. player.Name .. ")")
else
    print("Rainbow = false")
    TeleportService:Teleport(game.PlaceId, player)
end
