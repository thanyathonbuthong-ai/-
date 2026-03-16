-- [[ 🛡️ GEMINI MASTER HUB V3.6 (ULTIMATE REBORN - FULL INTEGRATED) 🛡️ ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local VIM = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- ลบ UI เก่าป้องกันการซ้อนทับ
if CoreGui:FindFirstChild("GeminiMasterV3_Ultimate") then CoreGui.GeminiMasterV3_Ultimate:Destroy() end

-- [[ 🎨 CONFIG ]] --
local ThemeColor = Color3.fromRGB(0, 255, 255) 
local BgColor = Color3.fromRGB(20, 20, 30)
local SidebarColor = Color3.fromRGB(15, 15, 25)
_G.HealthESP = false 
_G.HighESP = false
_G.TagESP = false
_G.AC = false
_G.RGBEnabled = false -- [ADD NEW]
_G.HomingEnabled = false -- [ADD NEW]

-- Homing Config [ADD NEW]
local _G_HomingSpeed = 400
local _G_TargetDist = 500
local _G_OwnDistance = 20

-- [[ 🏗️ UI SETUP ]] --
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "GeminiMasterV3_Ultimate"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 520, 0, 380)
MainFrame.Position = UDim2.new(0.5, -260, 0.4, -190)
MainFrame.BackgroundColor3 = BgColor
MainFrame.Active = true
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", MainFrame).Color = ThemeColor

-- [[ 🖱️ DRAGGABLE SYSTEM ]] --
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UIS.InputEnded:Connect(function(input) dragging = false end)

-- Sidebar & Page Container
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 140, 1, 0); Sidebar.BackgroundColor3 = SidebarColor
local SidebarLayout = Instance.new("UIListLayout", Sidebar); SidebarLayout.Padding = UDim.new(0, 5); SidebarLayout.HorizontalAlignment = "Center"
Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 10)

local PageContainer = Instance.new("Frame", MainFrame)
PageContainer.Position = UDim2.new(0, 150, 0, 10); PageContainer.Size = UDim2.new(1, -160, 1, -20); PageContainer.BackgroundTransparency = 1

local Pages = {}

-- [[ 🛠️ UI HELPERS ]] --
local function CreateTab(name)
    local Page = Instance.new("ScrollingFrame", PageContainer)
    Page.Size = UDim2.new(1, 0, 1, 0); Page.BackgroundTransparency = 1; Page.Visible = false; Page.ScrollBarThickness = 2; Page.CanvasSize = UDim2.new(0,0,0,0); Page.AutomaticCanvasSize = "Y"
    Instance.new("UIListLayout", Page).Padding = UDim.new(0, 8)
    local TabBtn = Instance.new("TextButton", Sidebar)
    TabBtn.Size = UDim2.new(0.9, 0, 0, 35); TabBtn.Text = name; TabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55); TabBtn.TextColor3 = Color3.new(0.8, 0.8, 0.8); TabBtn.Font = "GothamSemibold"; TabBtn.TextSize = 11
    Instance.new("UICorner", TabBtn)
    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        for _, b in pairs(Sidebar:GetChildren()) do if b:IsA("TextButton") then b.BackgroundColor3 = Color3.fromRGB(40, 40, 55) end end
        Page.Visible = true; TabBtn.BackgroundColor3 = ThemeColor
    end)
    Pages[name] = Page
    return Page
end

local function CreateInput(parent, label, defaultText)
    local F = Instance.new("Frame", parent); F.Size = UDim2.new(1, 0, 0, 40); F.BackgroundTransparency = 1
    local L = Instance.new("TextLabel", F); L.Size = UDim2.new(0.6, 0, 1, 0); L.Text = label; L.TextColor3 = Color3.new(1,1,1); L.BackgroundTransparency = 1; L.TextXAlignment = "Left"; L.Font = "Gotham"
    local T = Instance.new("TextBox", F); T.Size = UDim2.new(0.4, 0, 0.8, 0); T.Position = UDim2.new(0.6, 0, 0.1, 0); T.Text = defaultText; T.BackgroundColor3 = Color3.fromRGB(30,30,30); T.TextColor3 = ThemeColor; Instance.new("UICorner", T)
    return T
end

local function CreateToggle(parent, text, callback)
    local b = Instance.new("TextButton", parent); b.Size = UDim2.new(1, 0, 0, 40); b.Text = text .. ": OFF"; b.BackgroundColor3 = Color3.fromRGB(50,50,50); b.TextColor3 = Color3.new(1,1,1); b.Font = "GothamSemibold"; Instance.new("UICorner", b)
    local on = false
    b.MouseButton1Click:Connect(function()
        on = not on
        b.BackgroundColor3 = on and ThemeColor or Color3.fromRGB(50,50,50)
        b.Text = text .. (on and ": ON" or ": OFF")
        callback(on)
    end)
    return b
end

-- [[ 📂 TAB CREATION ]] --
local TabMove = CreateTab("Movement / Fly")
local TabCombat = CreateTab("Combat & RGB") -- [NEW TAB ADDED]
local TabVisual = CreateTab("Visual / ESP")
local TabWarp = CreateTab("Warp Points")
local TabToy  = CreateTab("Toy Spawner")
local TabMisc = CreateTab("Misc / System")

-- --- [[ ⚔️ NEW TAB: COMBAT & RGB ]] --- [ADD NEW SYSTEM]
CreateToggle(TabCombat, "RGB Character", function(v)
    _G.RGBEnabled = v
    if v then
        task.spawn(function()
            while _G.RGBEnabled do
                local color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
                if player.Character then
                    for _, part in pairs(player.Character:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.Color = color
                        elseif part:IsA("Accessory") and part:FindFirstChild("Handle") then
                            part.Handle.Color = color
                        end
                    end
                end
                task.wait(0.05)
            end
        end)
    end
end)

local function GetClosest()
    local target = nil
    local dist = _G_TargetDist
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local d = (player.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
            if d < dist then
                target = v.Character.HumanoidRootPart
                dist = d
            end
        end
    end
    return target
end

workspace.ChildAdded:Connect(function(child)
    if not _G.HomingEnabled then return end
    RunService.Stepped:Wait() 
    if (child:IsA("BasePart") or child:FindFirstChildWhichIsA("BodyMovingStyle")) and player.Character then
        local root = player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local distToMe = (child.Position - root.Position).Magnitude
            if distToMe <= _G_OwnDistance then
                local target = GetClosest()
                if target then
                    child.CanCollide = false 
                    local hb; hb = RunService.Heartbeat:Connect(function()
                        if child.Parent and target and target.Parent and _G.HomingEnabled then
                            local direction = (target.Position - child.Position).Unit
                            if child:IsA("BasePart") then
                                child.Velocity = direction * _G_HomingSpeed
                                child.CFrame = CFrame.lookAt(child.Position, target.Position)
                            end
                            if (child.Position - target.Position).Magnitude < 5 then
                                child.CFrame = target.CFrame
                            end
                        else
                            hb:Disconnect()
                        end
                    end)
                end
            end
        end
    end
end)

CreateToggle(TabCombat, "Auto Kill (Homing)", function(v)
    _G.HomingEnabled = v
end)

-- --- 🕹️ TAB: MOVEMENT (KEEP ORIGINAL) ---
local isFlying, flySpeed, verticalDir = false, 100, 0
local flyBG, flyBV, flyConn
local flySpeedInput = CreateInput(TabMove, "Fly Speed:", "100")
local walkSpeedInput = CreateInput(TabMove, "Walk Speed:", "100")

local FlyFrame = Instance.new("Frame", ScreenGui); FlyFrame.Size = UDim2.new(0, 70, 0, 150); FlyFrame.Position = UDim2.new(0.85, 0, 0.5, -75); FlyFrame.BackgroundTransparency = 1; FlyFrame.Visible = false
local function createArrow(txt, pos, dir)
    local b = Instance.new("TextButton", FlyFrame); b.Size = UDim2.new(1, 0, 0, 70); b.Position = pos; b.Text = txt; b.BackgroundColor3 = Color3.fromRGB(30, 30, 30); b.TextColor3 = ThemeColor; b.TextSize = 30; Instance.new("UICorner", b); Instance.new("UIStroke", b).Color = ThemeColor
    b.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then verticalDir = dir end end)
    b.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then verticalDir = 0 end end)
end
createArrow("▲", UDim2.new(0,0,0,0), 1); createArrow("▼", UDim2.new(0,0,0,80), -1)

CreateToggle(TabMove, "Fly Mode", function(v)
    isFlying = v; FlyFrame.Visible = v; flySpeed = tonumber(flySpeedInput.Text) or 100
    local char = player.Character or player.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    if isFlying then
        hum.PlatformStand = true
        flyBG = Instance.new("BodyGyro", root); flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9); flyBG.CFrame = root.CFrame
        flyBV = Instance.new("BodyVelocity", root); flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9); flyBV.Velocity = Vector3.new(0,0,0)
        flyConn = RunService.RenderStepped:Connect(function()
            flyBV.Velocity = (hum.MoveDirection * flySpeed) + Vector3.new(0, verticalDir * flySpeed, 0)
            flyBG.CFrame = camera.CFrame
        end)
    else
        if flyConn then flyConn:Disconnect() end
        if flyBG then flyBG:Destroy() end
        if flyBV then flyBV:Destroy() end
        hum.PlatformStand = false
    end
end)

CreateToggle(TabMove, "Speed Boost", function(v)
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = v and tonumber(walkSpeedInput.Text) or 16
    end
end)

local plat = Instance.new("Part"); plat.Size = Vector3.new(10, 1, 10); plat.Anchored = true; plat.Transparency = 1
local awConn
CreateToggle(TabMove, "Air Walk", function(v)
    if v then
        local curY = player.Character.HumanoidRootPart.Position.Y - 3.5
        awConn = RunService.RenderStepped:Connect(function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                plat.Parent = workspace
                plat.CFrame = CFrame.new(player.Character.HumanoidRootPart.Position.X, curY, player.Character.HumanoidRootPart.Position.Z)
                if player.Character.Humanoid.Jump then curY = player.Character.HumanoidRootPart.Position.Y - 3.5 end
            end
        end)
    else
        if awConn then awConn:Disconnect() end
        plat.Parent = nil
    end
end)

-- --- 📍 TAB: WARP POINTS (KEEP ORIGINAL) ---
local savedPoints = {}
local visualParts = {}

local function createVisual(pos, index)
    local part = Instance.new("Part")
    part.Size = Vector3.new(1, 1, 1); part.CFrame = pos - Vector3.new(0, 3, 0); part.Anchored = true; part.CanCollide = false; part.Transparency = 1; part.Parent = workspace
    local box = Instance.new("SelectionBox", part); box.Adornee = part; box.Color3 = Color3.fromHSV(math.random(), 1, 1); box.LineThickness = 0.1
    local billboard = Instance.new("BillboardGui", part); billboard.Size = UDim2.new(0, 100, 0, 50); billboard.AlwaysOnTop = true; billboard.ExtentsOffset = Vector3.new(0, 4, 0)
    local label = Instance.new("TextLabel", billboard); label.Size = UDim2.new(1, 0, 1, 0); label.BackgroundTransparency = 1; label.Text = "POINT " .. index; label.TextColor3 = box.Color3; label.Font = "GothamBold"; label.TextSize = 14; label.TextStrokeTransparency = 0
    visualParts[index] = part
end

local function createWarpButton(index)
    local btn = Instance.new("TextButton", TabWarp); btn.Name = "WarpBtn_" .. index; btn.Size = UDim2.new(1, 0, 0, 35); btn.BackgroundColor3 = Color3.fromRGB(45, 45, 60); btn.Text = "Warp to Point " .. index; btn.TextColor3 = Color3.new(1, 1, 1); btn.Font = "Gotham"; Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = savedPoints[index]
        end
    end)
end

local SaveWarpBtn = Instance.new("TextButton", TabWarp); SaveWarpBtn.Size = UDim2.new(1, 0, 0, 45); SaveWarpBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113); SaveWarpBtn.Text = "ADD NEW WARP POINT"; SaveWarpBtn.TextColor3 = Color3.new(1, 1, 1); SaveWarpBtn.Font = "GothamBold"; Instance.new("UICorner", SaveWarpBtn)
local ClearWarpBtn = Instance.new("TextButton", TabWarp); ClearWarpBtn.Size = UDim2.new(1, 0, 0, 35); ClearWarpBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60); ClearWarpBtn.Text = "CLEAR ALL POINTS"; ClearWarpBtn.TextColor3 = Color3.new(1, 1, 1); ClearWarpBtn.Font = "GothamBold"; Instance.new("UICorner", ClearWarpBtn)

SaveWarpBtn.MouseButton1Click:Connect(function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local newIndex = #savedPoints + 1
        savedPoints[newIndex] = player.Character.HumanoidRootPart.CFrame
        createVisual(savedPoints[newIndex], newIndex)
        createWarpButton(newIndex)
    end
end)

ClearWarpBtn.MouseButton1Click:Connect(function()
    for _, v in pairs(visualParts) do v:Destroy() end
    for _, v in pairs(TabWarp:GetChildren()) do if v:IsA("TextButton") and v.Name:find("WarpBtn_") then v:Destroy() end end
    savedPoints = {}; visualParts = {}
end)

-- --- 👁️ TAB: VISUAL / ESP (KEEP ORIGINAL) ---
local function SetupHealth(p)
    if p == player then return end
    local function createUI(char)
        local hum = char:WaitForChild("Humanoid", 20); local head = char:WaitForChild("Head", 20)
        if not hum or not head then return end
        if head:FindFirstChild("RealHealth") then head.RealHealth:Destroy() end
        local billboard = Instance.new("BillboardGui", head); billboard.Name = "RealHealth"; billboard.Size = UDim2.new(4, 0, 1.5, 0); billboard.StudsOffset = Vector3.new(0, 3, 0); billboard.AlwaysOnTop = true; billboard.Enabled = _G.HealthESP
        local bg = Instance.new("Frame", billboard); bg.Size = UDim2.new(1, 0, 0.4, 0); bg.BackgroundColor3 = Color3.new(0, 0, 0); bg.BackgroundTransparency = 0.5
        local bar = Instance.new("Frame", bg); bar.Size = UDim2.new(hum.Health / hum.MaxHealth, 0, 1, 0); bar.BackgroundColor3 = Color3.fromRGB(0, 255, 0); bar.BorderSizePixel = 0
        local text = Instance.new("TextLabel", billboard); text.Size = UDim2.new(1, 0, 0.6, 0); text.Position = UDim2.new(0, 0, -0.7, 0); text.BackgroundTransparency = 1; text.TextColor3 = Color3.new(1,1,1); text.TextSize = 14; text.Text = math.floor(hum.Health) .. " / " .. math.floor(hum.MaxHealth)
        hum.HealthChanged:Connect(function(hp) if not char:IsDescendantOf(workspace) then return end; bar.Size = UDim2.new(math.clamp(hp/hum.MaxHealth, 0, 1), 0, 1, 0); text.Text = math.floor(hp) .. " / " .. math.floor(hum.MaxHealth) end)
    end
    if p.Character then createUI(p.Character) end; p.CharacterAdded:Connect(createUI)
end

CreateToggle(TabVisual, "Highlight ESP", function(v) _G.HighESP = v end)
CreateToggle(TabVisual, "Distance ESP", function(v) _G.TagESP = v end)
CreateToggle(TabVisual, "Health Bar ESP", function(v) 
    _G.HealthESP = v 
    for _, p in pairs(Players:GetPlayers()) do if p.Character and p.Character:FindFirstChild("Head") then local gui = p.Character.Head:FindFirstChild("RealHealth") if gui then gui.Enabled = v end end end
end)

for _, p in pairs(Players:GetPlayers()) do SetupHealth(p) end
Players.PlayerAdded:Connect(SetupHealth)

-- Brightness Slider
local sliderFrame = Instance.new("Frame", TabVisual); sliderFrame.Size = UDim2.new(1,0,0,10); sliderFrame.BackgroundColor3 = Color3.fromRGB(45,45,45)
local sliderDot = Instance.new("TextButton", sliderFrame); sliderDot.Size = UDim2.new(0,20,2,0); sliderDot.Position = UDim2.new(0,0,-0.5,0); sliderDot.BackgroundColor3 = ThemeColor; sliderDot.Text = ""
Instance.new("UICorner", sliderDot)
local slideDrag = false
sliderDot.MouseButton1Down:Connect(function() slideDrag = true end)
UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then slideDrag = false end end)
UIS.InputChanged:Connect(function(i)
    if slideDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local p = math.clamp((i.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X, 0, 1)
        sliderDot.Position = UDim2.new(p, -10, -0.5, 0)
        Lighting.Brightness = p * 20
    end
end)

-- ESP Loop
RunService.RenderStepped:Connect(function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local hl = p.Character:FindFirstChild("G_HL")
            if _G.HighESP then if not hl then hl = Instance.new("Highlight", p.Character); hl.Name = "G_HL"; hl.FillColor = ThemeColor end elseif hl then hl:Destroy() end
            local head = p.Character:FindFirstChild("Head")
            if head then
                local tag = head:FindFirstChild("G_Tag")
                if _G.TagESP then
                    if not tag then
                        tag = Instance.new("BillboardGui", head); tag.Name = "G_Tag"; tag.Size = UDim2.new(0,100,0,50); tag.StudsOffset = Vector3.new(0,2,0); tag.AlwaysOnTop = true
                        local l = Instance.new("TextLabel", tag); l.Size = UDim2.new(1,0,1,0); l.BackgroundTransparency = 1; l.TextColor3 = Color3.new(1,1,1); l.TextStrokeTransparency = 0; l.Font = "GothamBold"; l.TextSize = 12
                    end
                    local dist = player.Character and math.floor((p.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude) or 0
                    tag.TextLabel.Text = p.Name .. "\n[" .. dist .. "m]"
                elseif tag then tag:Destroy() end
            end
        end
    end
end)

-- --- 📦 TAB: TOY SPAWNER (KEEP ORIGINAL) ---
local function spawnItem(itemName)
    local p = Instance.new("Part", workspace); p.Name = "ToyItem"; p.Position = player.Character.HumanoidRootPart.Position + Vector3.new(0, 10, 0)
    if itemName == "Ball" then p.Shape = "Ball"; p.Size = Vector3.new(10, 10, 10)
    elseif itemName == "Fire" then Instance.new("Fire", p)
    elseif itemName == "Neon" then p.Material = "Neon"; p.Color = Color3.new(1, 0, 1) end
end
local function createToyBtn(txt, item)
    local b = Instance.new("TextButton", TabToy); b.Size = UDim2.new(1, 0, 0, 35); b.Text = txt; b.BackgroundColor3 = Color3.fromRGB(45,45,60); b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() spawnItem(item) end)
end
createToyBtn("เสก: ลูกบอลยักษ์", "Ball"); createToyBtn("เสก: กล่องไฟ", "Fire"); createToyBtn("เสก: เสานีออน", "Neon")
local delBtn = Instance.new("TextButton", TabToy); delBtn.Size = UDim2.new(1, 0, 0, 35); delBtn.Text = "ลบของเล่นทั้งหมด"; delBtn.BackgroundColor3 = Color3.fromRGB(120, 40, 40); delBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", delBtn)
delBtn.MouseButton1Click:Connect(function() for _, v in pairs(workspace:GetChildren()) do if v.Name == "ToyItem" then v:Destroy() end end end)

-- --- 🌀 TAB: MISC / SYSTEM (KEEP ORIGINAL) ---
CreateToggle(TabMisc, "Auto Clicker", function(v) _G.AC = v end)
task.spawn(function()
    while task.wait(0.1) do if _G.AC then VIM:SendMouseButtonEvent(camera.ViewportSize.X/2, camera.ViewportSize.Y/2, 0, true, game, 1); VIM:SendMouseButtonEvent(camera.ViewportSize.X/2, camera.ViewportSize.Y/2, 0, false, game, 1) end end
end)

CreateToggle(TabMisc, "Invisible", function(v)
    local char = player.Character
    if char then for _, part in pairs(char:GetDescendants()) do if part:IsA("BasePart") or part:IsA("Decal") then if part.Name ~= "HumanoidRootPart" then part.Transparency = v and 1 or 0 end end end end
end)

CreateToggle(TabMisc, "FPS Boost", function(v)
    Lighting.GlobalShadows = not v
    for _, v in pairs(game:GetDescendants()) do if v:IsA("Part") or v:IsA("MeshPart") then v.Material = v and Enum.Material.SmoothPlastic or Enum.Material.Plastic end end
end)

local specIndex = 1
local nextBtn = Instance.new("TextButton", TabMisc); nextBtn.Size = UDim2.new(1, 0, 0, 35); nextBtn.Text = "ส่องคนถัดไป"; nextBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255); nextBtn.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", nextBtn)
local stopBtn = Instance.new("TextButton", TabMisc); stopBtn.Size = UDim2.new(1, 0, 0, 35); stopBtn.Text = "ยกเลิก (ดูตัวเอง)"; stopBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50); stopBtn.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", stopBtn)

nextBtn.MouseButton1Click:Connect(function()
    local allPlayers = Players:GetPlayers()
    specIndex = specIndex + 1
    if specIndex > #allPlayers then specIndex = 1 end
    local target = allPlayers[specIndex]
    if target == player then specIndex = specIndex + 1; if specIndex > #allPlayers then specIndex = 1 end; target = allPlayers[specIndex] end
    if target and target.Character and target.Character:FindFirstChild("Humanoid") then
        camera.CameraSubject = target.Character.Humanoid
        nextBtn.Text = "ส่อง: " .. target.DisplayName
    end
end)

stopBtn.MouseButton1Click:Connect(function()
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        camera.CameraSubject = player.Character.Humanoid
        nextBtn.Text = "ส่องคนถัดไป"
    end
end)

-- ปุ่มเปิด/ปิด GEMINI
local Tgl = Instance.new("TextButton", ScreenGui); Tgl.Size = UDim2.new(0, 80, 0, 30); Tgl.Position = UDim2.new(0, 10, 0, 10); Tgl.Text = "GEMINI"; Tgl.BackgroundColor3 = SidebarColor; Tgl.TextColor3 = ThemeColor; Instance.new("UICorner", Tgl); Instance.new("UIStroke", Tgl).Color = ThemeColor
Tgl.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

Pages["Movement / Fly"].Visible = true
