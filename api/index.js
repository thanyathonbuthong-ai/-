export default function handler(req, res) {
  // === วางสคริปต์ Lua ของคุณไว้ข้างล่างนี้ ===
  const myLuaScript = `
--[[
 .____                  ________ ___.    _____                           __                

 |    |    __ _______   \\_____  \\\\_ |___/ ____\\_ __  ______ ____ _____ _/  |_  ___________ 
 |    |   |  |  \\__  \\   /   |   \\| __ \\   __\\  |  \\/  ___// ___\\\\__  \\   __\\/  _ \\_  __ \\
 |    |___|  |  // __ \\_/    |    \\ \\_\\ \\  | |  |  /\\___ \\\\  \\___ / __ \\|  | (  <_> )  | \\/
 |_______ \\____/(____  /\\_______  /___  /__| |____//____  >\\___  >____  /__|  \\____/|__|   
         \\/          \\/         \\/    \\/                \\/     \\/     \\/                   
          \\_Welcome to LuaObfuscator.com   (Alpha 0.10.9) ~  Much Love, Ferib 
]]--

if _G.InvisScript then
    for _, e in pairs(_G.InvisScript) do e:Disconnect() end
    _G.InvisScript = nil
end

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")

local player    = Players.LocalPlayer
local mouse     = player:GetMouse()
local invisible = false
local bodyParts = {}
local character, humanoid, rootPart

local function setupCharacter()
    character = player.Character or player.CharacterAdded:Wait()
    humanoid  = character:WaitForChild("Humanoid")
    rootPart  = character:WaitForChild("HumanoidRootPart")
    bodyParts = {}
    for _, v in pairs(character:GetDescendants()) do
        if v:IsA("BasePart") and v.Transparency == 0 then
            table.insert(bodyParts, v)
        end
    end
end

local function setInvisible(state)
    invisible = state
    for _, v in pairs(bodyParts) do
        v.Transparency = invisible and 0.5 or 0
    end
end

local function buildGui()
    local existing = player.PlayerGui:FindFirstChild("INVIS_GG")
    if existing then existing:Destroy() end

    local sg = Instance.new("ScreenGui")
    sg.Name = "INVIS_GG"
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local main = Instance.new("Frame", sg)
    main.Size = UDim2.new(0, 110, 0, 52)
    main.Position = UDim2.new(0.5, -55, 0.5, -26)
    main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    main.BorderSizePixel = 0
    main.Active = true
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

    local rainbowStroke = Instance.new("UIStroke", main)
    rainbowStroke.Thickness = 2.5

    local byLbl = Instance.new("TextLabel", main)
    byLbl.Size = UDim2.new(1, 0, 0, 14)
    byLbl.Position = UDim2.new(0, 0, 0, 1)
    byLbl.BackgroundTransparency = 1
    byLbl.Text = "by : GG script"
    byLbl.TextColor3 = Color3.fromRGB(150, 150, 150)
    byLbl.TextSize = 8
    byLbl.Font = Enum.Font.GothamBold

    local btn = Instance.new("TextButton", main)
    btn.Size = UDim2.new(1, -10, 0, 24)
    btn.Position = UDim2.new(0, 5, 0, 15)
    btn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = "Invisible"
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local keyLbl = Instance.new("TextLabel", main)
    keyLbl.Size = UDim2.new(1, 0, 0, 10)
    keyLbl.Position = UDim2.new(0, 0, 1, -11)
    keyLbl.BackgroundTransparency = 1
    keyLbl.Text = "Press G to toggle"
    keyLbl.TextColor3 = Color3.fromRGB(70, 70, 70)
    keyLbl.TextSize = 8
    keyLbl.Font = Enum.Font.Gotham
    keyLbl.TextXAlignment = Enum.TextXAlignment.Center

    sg.Parent = player:WaitForChild("PlayerGui")

    local function updateUI()
        if invisible then
            btn.Text = "Visible"
            btn.BackgroundColor3 = Color3.fromRGB(0, 150, 40)
        else
            btn.Text = "Invisible"
            btn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        end
    end

    btn.MouseButton1Click:Connect(function()
        setInvisible(not invisible)
        updateUI()
    end)

    local hue = 0
    RunService.Heartbeat:Connect(function(dt)
        hue = (hue + dt * 0.5) % 1
        rainbowStroke.Color = Color3.fromHSV(hue, 1, 1)
    end)

    local drag, ds, sp = false, nil, nil
    main.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            drag = true; ds = i.Position; sp = main.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - ds
            main.Position = UDim2.new(
                sp.X.Scale, sp.X.Offset + d.X,
                sp.Y.Scale, sp.Y.Offset + d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end)

    return updateUI
end

setupCharacter()
local updateUI = buildGui()

local events = {}

events[1] = mouse.KeyDown:Connect(function(key)
    if key:lower() == "g" then
        setInvisible(not invisible)
        if updateUI then updateUI() end
    end
end)

events[2] = RunService.Heartbeat:Connect(function()
    if invisible and rootPart and humanoid then
        local cf     = rootPart.CFrame
        local camOff = humanoid.CameraOffset
        rootPart.CFrame = cf * CFrame.new(0, -200000, 0)
        humanoid.CameraOffset = Vector3.new(
            camOff.X, camOff.Y + 200000, camOff.Z)
        RunService.RenderStepped:Wait()
        rootPart.CFrame = cf
        humanoid.CameraOffset = camOff
    end
end)

events[3] = player.CharacterAdded:Connect(function()
    invisible = false
    setupCharacter()
    updateUI = buildGui()
end)

_G.InvisScript = events
print("Invisible Script by GG script loaded")
  `;

  // ส่งค่ากลับไปหาคนเรียกใช้
  res.setHeader('Content-Type', 'text/plain');
  res.status(200).send(myLuaScript);
}
