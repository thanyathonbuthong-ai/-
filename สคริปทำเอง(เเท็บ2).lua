local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local mouse = player:GetMouse() -- ใช้สำหรับเช็คตำแหน่งที่ชี้ (Click TP)
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- === ตัวแปรระบบ ===
-- บิน
local isFlying = false
local goingUp = false
local goingDown = false
local flySpeed = 80
-- วิ่ง
local isSprinting = false
local sprintSpeed = 80
local defaultWalkSpeed = 16
-- Bhop
local bhopEnabled = false
local strafeEnabled = false
local strafeDir = 1
local speedCap = 50
local minCap, maxCap = 20, 200
-- Click TP
local clickTpEnabled = false
-- ล่องหน (เพิ่มใหม่)
local isInvisible = false

-- === สร้าง UI ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CoolHorizontalHub"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

-- ปุ่มเปิด/ปิดหลัก
local menuBtn = Instance.new("TextButton")
menuBtn.Size = UDim2.new(0, 40, 0, 40)
menuBtn.Position = UDim2.new(1, -50, 0.5, -20)
menuBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
menuBtn.TextColor3 = Color3.fromRGB(138, 43, 226)
menuBtn.Text = "⚙"
menuBtn.TextSize = 22
menuBtn.Font = Enum.Font.GothamBold
menuBtn.Parent = screenGui
Instance.new("UICorner", menuBtn).CornerRadius = UDim.new(0, 10)
local menuStroke = Instance.new("UIStroke"); menuStroke.Color = Color3.fromRGB(138, 43, 226); menuStroke.Thickness = 2; menuStroke.Parent = menuBtn

-- กรอบเมนูแนวนอน
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 240, 0, 170)
mainFrame.Position = UDim2.new(1, -290, 0.5, -85)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
mainFrame.Active = true
mainFrame.Visible = false
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
local mainStroke = Instance.new("UIStroke"); mainStroke.Color = Color3.fromRGB(50, 50, 50); mainStroke.Thickness = 1.5; mainStroke.Parent = mainFrame

-- แถบลาก
local dragBar = Instance.new("Frame")
dragBar.Size = UDim2.new(1, 0, 0, 30)
dragBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
dragBar.BorderSizePixel = 0
dragBar.Parent = mainFrame
Instance.new("UICorner", dragBar).CornerRadius = UDim.new(0, 12)
local dragTxt = Instance.new("TextLabel")
dragTxt.Size = UDim2.new(1, 0, 1, 0); dragTxt.BackgroundTransparency = 1
dragTxt.Text = "⬍ ลากเพื่อย้าย"; dragTxt.TextColor3 = Color3.fromRGB(100, 100, 100)
dragTxt.TextSize = 10; dragTxt.Font = Enum.Font.GothamBold; dragTxt.Parent = dragBar

-- ==========================================
-- ระบบ Tab (5 หมวด - ปรับขนาดให้พอดี)
-- ==========================================
local tabFrame = Instance.new("Frame")
tabFrame.Size = UDim2.new(0.94, 0, 0, 25)
tabFrame.Position = UDim2.new(0.03, 0, 0, 34)
tabFrame.BackgroundTransparency = 1
tabFrame.Parent = mainFrame

local flyTab = Instance.new("TextButton")
flyTab.Size = UDim2.new(0.19, 0, 1, 0); flyTab.Position = UDim2.new(0, 0, 0, 0)
flyTab.BackgroundColor3 = Color3.fromRGB(0, 150, 255); flyTab.TextColor3 = Color3.fromRGB(255, 255, 255)
flyTab.Text = "✈️ บิน"; flyTab.TextSize = 9; flyTab.Font = Enum.Font.GothamBold; flyTab.Parent = tabFrame
Instance.new("UICorner", flyTab).CornerRadius = UDim.new(0, 6)

local sprintTab = Instance.new("TextButton")
sprintTab.Size = UDim2.new(0.19, 0, 1, 0); sprintTab.Position = UDim2.new(0.20, 0, 0, 0)
sprintTab.BackgroundColor3 = Color3.fromRGB(40, 40, 40); sprintTab.TextColor3 = Color3.fromRGB(150, 150, 150)
sprintTab.Text = "🏃 วิ่ง"; sprintTab.TextSize = 9; sprintTab.Font = Enum.Font.GothamBold; sprintTab.Parent = tabFrame
Instance.new("UICorner", sprintTab).CornerRadius = UDim.new(0, 6)

local bhopTab = Instance.new("TextButton")
bhopTab.Size = UDim2.new(0.19, 0, 1, 0); bhopTab.Position = UDim2.new(0.40, 0, 0, 0)
bhopTab.BackgroundColor3 = Color3.fromRGB(40, 40, 40); bhopTab.TextColor3 = Color3.fromRGB(150, 150, 150)
bhopTab.Text = "🐰 Bhop"; bhopTab.TextSize = 9; bhopTab.Font = Enum.Font.GothamBold; bhopTab.Parent = tabFrame
Instance.new("UICorner", bhopTab).CornerRadius = UDim.new(0, 6)

local tpTab = Instance.new("TextButton")
tpTab.Size = UDim2.new(0.19, 0, 1, 0); tpTab.Position = UDim2.new(0.60, 0, 0, 0)
tpTab.BackgroundColor3 = Color3.fromRGB(40, 40, 40); tpTab.TextColor3 = Color3.fromRGB(150, 150, 150)
tpTab.Text = "🎯 TP"; tpTab.TextSize = 9; tpTab.Font = Enum.Font.GothamBold; tpTab.Parent = tabFrame
Instance.new("UICorner", tpTab).CornerRadius = UDim.new(0, 6)

local invisTab = Instance.new("TextButton") -- เพิ่ม Tab ล่องหน
invisTab.Size = UDim2.new(0.19, 0, 1, 0); invisTab.Position = UDim2.new(0.80, 0, 0, 0)
invisTab.BackgroundColor3 = Color3.fromRGB(40, 40, 40); invisTab.TextColor3 = Color3.fromRGB(150, 150, 150)
invisTab.Text = "👻 ล่องหน"; invisTab.TextSize = 9; invisTab.Font = Enum.Font.GothamBold; invisTab.Parent = tabFrame
Instance.new("UICorner", invisTab).CornerRadius = UDim.new(0, 6)

-- ==========================================
-- หน้าต่างหมวดต่างๆ
-- ==========================================
local function createPage(name)
    local pg = Instance.new("Frame")
    pg.Size = UDim2.new(0.9, 0, 1, -65)
    pg.Position = UDim2.new(0.05, 0, 0, 65)
    pg.BackgroundTransparency = 1
    pg.Name = name
    pg.Parent = mainFrame
    return pg
end

local flyPage = createPage("FlyPage")
local sprintPage = createPage("SprintPage"); sprintPage.Visible = false
local bhopPage = createPage("BhopPage"); bhopPage.Visible = false
local tpPage = createPage("TpPage"); tpPage.Visible = false
local invisPage = createPage("InvisPage"); invisPage.Visible = false -- เพิ่มหน้าล่องหน

-- ========== หมวดบิน ==========
local flyToggleBtn = Instance.new("TextButton")
flyToggleBtn.Size = UDim2.new(0.45, 0, 0, 40); flyToggleBtn.Position = UDim2.new(0, 0, 0, 0)
flyToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20); flyToggleBtn.TextColor3 = Color3.fromRGB(0, 200, 255)
flyToggleBtn.Text = "เปิดบิน"; flyToggleBtn.TextSize = 12; flyToggleBtn.Font = Enum.Font.GothamBold
flyToggleBtn.Parent = flyPage
Instance.new("UICorner", flyToggleBtn).CornerRadius = UDim.new(0, 8)
local ftStroke = Instance.new("UIStroke"); ftStroke.Color = Color3.fromRGB(0, 150, 255); ftStroke.Parent = flyToggleBtn

local udFrame = Instance.new("Frame")
udFrame.Size = UDim2.new(0.5, 0, 0, 40); udFrame.Position = UDim2.new(0.5, 0, 0, 0)
udFrame.BackgroundTransparency = 1; udFrame.Parent = flyPage

local upBtn = Instance.new("TextButton")
upBtn.Size = UDim2.new(0.45, 0, 1, 0); upBtn.Position = UDim2.new(0, 0, 0, 0)
upBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215); upBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
upBtn.Text = "▲"; upBtn.TextSize = 18; upBtn.Font = Enum.Font.GothamBold; upBtn.Parent = udFrame
Instance.new("UICorner", upBtn).CornerRadius = UDim.new(0, 8)

local downBtn = Instance.new("TextButton")
downBtn.Size = UDim2.new(0.45, 0, 1, 0); downBtn.Position = UDim2.new(0.55, 0, 0, 0)
downBtn.BackgroundColor3 = Color3.fromRGB(215, 60, 60); downBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
downBtn.Text = "▼"; downBtn.TextSize = 18; downBtn.Font = Enum.Font.GothamBold; downBtn.Parent = udFrame
Instance.new("UICorner", downBtn).CornerRadius = UDim.new(0, 8)

local flySpeedLbl = Instance.new("TextLabel")
flySpeedLbl.Size = UDim2.new(0.5, 0, 0, 15); flySpeedLbl.Position = UDim2.new(0, 0, 0, 45)
flySpeedLbl.BackgroundTransparency = 1; flySpeedLbl.Text = "SPEED: 80"
flySpeedLbl.TextColor3 = Color3.fromRGB(120, 120, 120); flySpeedLbl.TextSize = 9; flySpeedLbl.Font = Enum.Font.GothamBold
flySpeedLbl.Parent = flyPage

local flyTrack = Instance.new("Frame")
flyTrack.Size = UDim2.new(1, 0, 0, 8); flyTrack.Position = UDim2.new(0, 0, 0, 63)
flyTrack.BackgroundColor3 = Color3.fromRGB(40, 40, 40); flyTrack.Parent = flyPage
Instance.new("UICorner", flyTrack).CornerRadius = UDim.new(0, 10)
local flyThumb = Instance.new("Frame")
flyThumb.Size = UDim2.new(0, 14, 0, 14); flyThumb.Position = UDim2.new(0, 0, 0, -3)
flyThumb.BackgroundColor3 = Color3.fromRGB(0, 200, 255); flyThumb.Parent = flyTrack
Instance.new("UICorner", flyThumb).CornerRadius = UDim.new(1, 0)

-- ========== หมวดวิ่ง ==========
local sprintToggleBtn = Instance.new("TextButton")
sprintToggleBtn.Size = UDim2.new(1, 0, 0, 40); sprintToggleBtn.Position = UDim2.new(0, 0, 0, 0)
sprintToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20); sprintToggleBtn.TextColor3 = Color3.fromRGB(255, 200, 0)
sprintToggleBtn.Text = "เปิดวิ่งเร็ว"; sprintToggleBtn.TextSize = 12; sprintToggleBtn.Font = Enum.Font.GothamBold
sprintToggleBtn.Parent = sprintPage
Instance.new("UICorner", sprintToggleBtn).CornerRadius = UDim.new(0, 8)
local spStroke = Instance.new("UIStroke"); spStroke.Color = Color3.fromRGB(255, 200, 0); spStroke.Parent = sprintToggleBtn

local sprintSpeedLbl = Instance.new("TextLabel")
sprintSpeedLbl.Size = UDim2.new(0.5, 0, 0, 15); sprintSpeedLbl.Position = UDim2.new(0, 0, 0, 45)
sprintSpeedLbl.BackgroundTransparency = 1; sprintSpeedLbl.Text = "SPEED: 80"
sprintSpeedLbl.TextColor3 = Color3.fromRGB(120, 120, 120); sprintSpeedLbl.TextSize = 9; sprintSpeedLbl.Font = Enum.Font.GothamBold
sprintSpeedLbl.Parent = sprintPage

local sprintTrack = Instance.new("Frame")
sprintTrack.Size = UDim2.new(1, 0, 0, 8); sprintTrack.Position = UDim2.new(0, 0, 0, 63)
sprintTrack.BackgroundColor3 = Color3.fromRGB(40, 40, 40); sprintTrack.Parent = sprintPage
Instance.new("UICorner", sprintTrack).CornerRadius = UDim.new(0, 10)
local sprintThumb = Instance.new("Frame")
sprintThumb.Size = UDim2.new(0, 14, 0, 14); sprintThumb.Position = UDim2.new(0, 0, 0, -3)
sprintThumb.BackgroundColor3 = Color3.fromRGB(255, 200, 0); sprintThumb.Parent = sprintTrack
Instance.new("UICorner", sprintThumb).CornerRadius = UDim.new(1, 0)

-- ========== หมวด Bhop ==========
local bhopToggleBtn = Instance.new("TextButton")
bhopToggleBtn.Size = UDim2.new(0.45, 0, 0, 35); bhopToggleBtn.Position = UDim2.new(0, 0, 0, 0)
bhopToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20); bhopToggleBtn.TextColor3 = Color3.fromRGB(0, 255, 100)
bhopToggleBtn.Text = "BHOP OFF"; bhopToggleBtn.TextSize = 11; bhopToggleBtn.Font = Enum.Font.GothamBold
bhopToggleBtn.Parent = bhopPage
Instance.new("UICorner", bhopToggleBtn).CornerRadius = UDim.new(0, 8)
local bhStroke = Instance.new("UIStroke"); bhStroke.Color = Color3.fromRGB(60, 60, 60); bhStroke.Parent = bhopToggleBtn

local strafeToggleBtn = Instance.new("TextButton")
strafeToggleBtn.Size = UDim2.new(0.45, 0, 0, 35); strafeToggleBtn.Position = UDim2.new(0.55, 0, 0, 0)
strafeToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20); strafeToggleBtn.TextColor3 = Color3.fromRGB(0, 255, 100)
strafeToggleBtn.Text = "STRAFE OFF"; strafeToggleBtn.TextSize = 11; strafeToggleBtn.Font = Enum.Font.GothamBold
strafeToggleBtn.Parent = bhopPage
Instance.new("UICorner", strafeToggleBtn).CornerRadius = UDim.new(0, 8)
local stStroke = Instance.new("UIStroke"); stStroke.Color = Color3.fromRGB(60, 60, 60); stStroke.Parent = strafeToggleBtn

local bhopLiveLbl = Instance.new("TextLabel")
bhopLiveLbl.Size = UDim2.new(0.5, 0, 0, 15); bhopLiveLbl.Position = UDim2.new(0, 0, 0, 40)
bhopLiveLbl.BackgroundTransparency = 1; bhopLiveLbl.Text = "LIVE: 000"
bhopLiveLbl.TextColor3 = Color3.fromRGB(0, 255, 200); bhopLiveLbl.TextSize = 9; bhopLiveLbl.Font = Enum.Font.GothamBold
bhopLiveLbl.Parent = bhopPage

local bhopCapLbl = Instance.new("TextLabel")
bhopCapLbl.Size = UDim2.new(0.5, 0, 0, 15); bhopCapLbl.Position = UDim2.new(0.5, 0, 0, 40)
bhopCapLbl.BackgroundTransparency = 1; bhopCapLbl.Text = "CAP: 050"
bhopCapLbl.TextColor3 = Color3.fromRGB(255, 100, 100); bhopCapLbl.TextSize = 9; bhopCapLbl.Font = Enum.Font.GothamBold
bhopCapLbl.Parent = bhopPage

local bhopTrack = Instance.new("Frame")
bhopTrack.Size = UDim2.new(1, 0, 0, 8); bhopTrack.Position = UDim2.new(0, 0, 0, 63)
bhopTrack.BackgroundColor3 = Color3.fromRGB(40, 40, 40); bhopTrack.Parent = bhopPage
Instance.new("UICorner", bhopTrack).CornerRadius = UDim.new(0, 10)
local bhopThumb = Instance.new("Frame")
bhopThumb.Size = UDim2.new(0, 14, 0, 14); bhopThumb.Position = UDim2.new(0, 0, 0, -3)
bhopThumb.BackgroundColor3 = Color3.fromRGB(0, 255, 100); bhopThumb.Parent = bhopTrack
Instance.new("UICorner", bhopThumb).CornerRadius = UDim.new(1, 0)

-- ========== หมวด Click TP ==========
local tpToggleBtn = Instance.new("TextButton")
tpToggleBtn.Size = UDim2.new(1, 0, 0, 45); tpToggleBtn.Position = UDim2.new(0, 0, 0, 10)
tpToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20); tpToggleBtn.TextColor3 = Color3.fromRGB(255, 80, 120)
tpToggleBtn.Text = "CLICK TP: OFF"; tpToggleBtn.TextSize = 14; tpToggleBtn.Font = Enum.Font.GothamBold
tpToggleBtn.Parent = tpPage
Instance.new("UICorner", tpToggleBtn).CornerRadius = UDim.new(0, 8)
local tpStroke = Instance.new("UIStroke"); tpStroke.Color = Color3.fromRGB(60, 60, 60); tpStroke.Parent = tpToggleBtn

local tpHintLbl = Instance.new("TextLabel")
tpHintLbl.Size = UDim2.new(1, 0, 0, 20); tpHintLbl.Position = UDim2.new(0, 0, 0, 60)
tpHintLbl.BackgroundTransparency = 1; tpHintLbl.Text = "แตะที่พื้นเพื่อวาป"
tpHintLbl.TextColor3 = Color3.fromRGB(80, 80, 80); tpHintLbl.TextSize = 9; tpHintLbl.Font = Enum.Font.GothamBold
tpHintLbl.Parent = tpPage

-- ========== หมวดล่องหน (เพิ่มใหม่) ==========
local invisToggleBtn = Instance.new("TextButton")
invisToggleBtn.Size = UDim2.new(1, 0, 0, 45); invisToggleBtn.Position = UDim2.new(0, 0, 0, 10)
invisToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20); invisToggleBtn.TextColor3 = Color3.fromRGB(180, 100, 255)
invisToggleBtn.Text = "INVISIBLE: OFF"; invisToggleBtn.TextSize = 14; invisToggleBtn.Font = Enum.Font.GothamBold
invisToggleBtn.Parent = invisPage
Instance.new("UICorner", invisToggleBtn).CornerRadius = UDim.new(0, 8)
local invStroke = Instance.new("UIStroke"); invStroke.Color = Color3.fromRGB(60, 60, 60); invStroke.Parent = invisToggleBtn

local invisHintLbl = Instance.new("TextLabel")
invisHintLbl.Size = UDim2.new(1, 0, 0, 20); invisHintLbl.Position = UDim2.new(0, 0, 0, 60)
invisHintLbl.BackgroundTransparency = 1; invisHintLbl.Text = "ตัวละครจะโปร่งแสง"
invisHintLbl.TextColor3 = Color3.fromRGB(80, 80, 80); invisHintLbl.TextSize = 9; invisHintLbl.Font = Enum.Font.GothamBold
invisHintLbl.Parent = invisPage


-- ==========================================
-- ระบบ Event และ Logic
-- ==========================================

-- สลับหมวด Tab (อัปเดตให้รองรับ 5 หมวด)
local function switchTab(tab)
    flyPage.Visible = (tab == "fly")
    sprintPage.Visible = (tab == "sprint")
    bhopPage.Visible = (tab == "bhop")
    tpPage.Visible = (tab == "tp")
    invisPage.Visible = (tab == "invis") -- เพิ่ม
    
    flyTab.BackgroundColor3 = Color3.fromRGB(40, 40, 40); flyTab.TextColor3 = Color3.fromRGB(150, 150, 150)
    sprintTab.BackgroundColor3 = Color3.fromRGB(40, 40, 40); sprintTab.TextColor3 = Color3.fromRGB(150, 150, 150)
    bhopTab.BackgroundColor3 = Color3.fromRGB(40, 40, 40); bhopTab.TextColor3 = Color3.fromRGB(150, 150, 150)
    tpTab.BackgroundColor3 = Color3.fromRGB(40, 40, 40); tpTab.TextColor3 = Color3.fromRGB(150, 150, 150)
    invisTab.BackgroundColor3 = Color3.fromRGB(40, 40, 40); invisTab.TextColor3 = Color3.fromRGB(150, 150, 150) -- เพิ่ม
    
    if tab == "fly" then flyTab.BackgroundColor3 = Color3.fromRGB(0, 150, 255); flyTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    elseif tab == "sprint" then sprintTab.BackgroundColor3 = Color3.fromRGB(255, 200, 0); sprintTab.TextColor3 = Color3.fromRGB(0, 0, 0)
    elseif tab == "bhop" then bhopTab.BackgroundColor3 = Color3.fromRGB(0, 255, 100); bhopTab.TextColor3 = Color3.fromRGB(0, 0, 0)
    elseif tab == "tp" then tpTab.BackgroundColor3 = Color3.fromRGB(255, 50, 100); tpTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    elseif tab == "invis" then invisTab.BackgroundColor3 = Color3.fromRGB(180, 100, 255); invisTab.TextColor3 = Color3.fromRGB(255, 255, 255) end -- เพิ่ม
end
flyTab.MouseButton1Click:Connect(function() switchTab("fly") end)
sprintTab.MouseButton1Click:Connect(function() switchTab("sprint") end)
bhopTab.MouseButton1Click:Connect(function() switchTab("bhop") end)
tpTab.MouseButton1Click:Connect(function() switchTab("tp") end)
invisTab.MouseButton1Click:Connect(function() switchTab("invis") end) -- เพิ่ม

-- เปิดปิดเมนู
menuBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
    menuBtn.Text = mainFrame.Visible and "✕" or "⚙"
end)

-- เปิดปิดบิน
flyToggleBtn.MouseButton1Click:Connect(function()
    isFlying = not isFlying
    flyToggleBtn.Text = isFlying and "หยุดบิน" or "เปิดบิน"
    ftStroke.Color = isFlying and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(0, 150, 255)
    flyToggleBtn.TextColor3 = isFlying and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(0, 200, 255)
    if isFlying then humanoid.ChangeState(Enum.HumanoidStateType.Freefall)
    else hrp.AssemblyLinearVelocity = Vector3.new(0,0,0); humanoid.ChangeState(Enum.HumanoidStateType.GettingUp); goingUp = false; goingDown = false end
end)

-- เปิดปิดวิ่ง
sprintToggleBtn.MouseButton1Click:Connect(function()
    isSprinting = not isSprinting
    sprintToggleBtn.Text = isSprinting and "หยุดวิ่งเร็ว" or "เปิดวิ่งเร็ว"
    spStroke.Color = isSprinting and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(255, 200, 0)
    sprintToggleBtn.TextColor3 = isSprinting and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(255, 200, 0)
    humanoid.WalkSpeed = isSprinting and sprintSpeed or defaultWalkSpeed
end)

-- เปิดปิด Bhop & Strafe
bhopToggleBtn.MouseButton1Click:Connect(function()
    bhopEnabled = not bhopEnabled
    bhopToggleBtn.Text = bhopEnabled and "BHOP ON" or "BHOP OFF"
    bhopToggleBtn.TextColor3 = bhopEnabled and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(150, 150, 150)
    bhStroke.Color = bhopEnabled and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(60, 60, 60)
end)
strafeToggleBtn.MouseButton1Click:Connect(function()
    strafeEnabled = not strafeEnabled
    strafeToggleBtn.Text = strafeEnabled and "STRAFE ON" or "STRAFE OFF"
    strafeToggleBtn.TextColor3 = strafeEnabled and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(150, 150, 150)
    stStroke.Color = strafeEnabled and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(60, 60, 60)
end)

-- เปิดปิด Click TP
tpToggleBtn.MouseButton1Click:Connect(function()
    clickTpEnabled = not clickTpEnabled
    tpToggleBtn.Text = clickTpEnabled and "CLICK TP: ON" or "CLICK TP: OFF"
    tpStroke.Color = clickTpEnabled and Color3.fromRGB(255, 50, 100) or Color3.fromRGB(60, 60, 60)
    tpToggleBtn.TextColor3 = clickTpEnabled and Color3.fromRGB(255, 100, 150) or Color3.fromRGB(255, 80, 120)
end)

-- เปิดปิด ล่องหน (เพิ่มใหม่)
invisToggleBtn.MouseButton1Click:Connect(function()
    isInvisible = not isInvisible
    invisToggleBtn.Text = isInvisible and "INVISIBLE: ON" or "INVISIBLE: OFF"
    invStroke.Color = isInvisible and Color3.fromRGB(180, 100, 255) or Color3.fromRGB(60, 60, 60)
    invisToggleBtn.TextColor3 = isInvisible and Color3.fromRGB(200, 150, 255) or Color3.fromRGB(180, 100, 255)
    
    -- ลออปเปลี่ยนค่า Transparency ของทุกอย่างในตัวละคร
    local char = player.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = isInvisible and 1 or 0
            elseif part:IsA("Decal") then -- ซ่อนหน้าตัวละคร (Face) ด้วย
                part.Transparency = isInvisible and 1 or 0
            end
        end
    end
end)

-- กดค้างขึ้นลง
local function bindHold(btn, dir)
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            if dir == "up" then goingUp = true elseif dir == "down" then goingDown = true end
        end
    end)
    btn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            if dir == "up" then goingUp = false elseif dir == "down" then goingDown = false end
        end
    end)
end
bindHold(upBtn, "up"); bindHold(downBtn, "down")

-- ลาก UI
local dragging = false; local dragStart, startPos
dragBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = mainFrame.Position
    end
end)
dragBar.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + (input.Position - dragStart).X, startPos.Y.Scale, startPos.Y.Offset + (input.Position - dragStart).Y)
    end
end)

-- Slider รวม
local activeSlider = nil
local function updateSlider(input)
    if activeSlider == "fly" then
        local rel = math.clamp((input.Position.X - flyTrack.AbsolutePosition.X) / flyTrack.AbsoluteSize.X, 0, 1)
        flyThumb.Position = UDim2.new(0, rel * (flyTrack.AbsoluteSize.X - flyThumb.AbsoluteSize.X), 0, -3)
        flySpeed = math.max(1, math.floor(rel * 500)); flySpeedLbl.Text = "SPEED: " .. flySpeed
    elseif activeSlider == "sprint" then
        local rel = math.clamp((input.Position.X - sprintTrack.AbsolutePosition.X) / sprintTrack.AbsoluteSize.X, 0, 1)
        sprintThumb.Position = UDim2.new(0, rel * (sprintTrack.AbsoluteSize.X - sprintThumb.AbsoluteSize.X), 0, -3)
        sprintSpeed = math.max(1, math.floor(rel * 500)); sprintSpeedLbl.Text = "SPEED: " .. sprintSpeed
        if isSprinting then humanoid.WalkSpeed = sprintSpeed end
    elseif activeSlider == "bhop" then
        local rel = math.clamp((input.Position.X - bhopTrack.AbsolutePosition.X) / bhopTrack.AbsoluteSize.X, 0, 1)
        bhopThumb.Position = UDim2.new(0, rel * (bhopTrack.AbsoluteSize.X - bhopThumb.AbsoluteSize.X), 0, -3)
        speedCap = math.floor(minCap + (maxCap - minCap) * rel)
        bhopCapLbl.Text = "CAP: " .. string.format("%03d", speedCap)
    end
end

flyTrack.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then activeSlider = "fly"; updateSlider(input) end end)
sprintTrack.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then activeSlider = "sprint"; updateSlider(input) end end)
bhopTrack.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then activeSlider = "bhop"; updateSlider(input) end end)

UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then activeSlider = nil end end)
UserInputService.InputChanged:Connect(function(input)
    if activeSlider and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then updateSlider(input) end
end)

-- ==========================================
-- Core Loop (รวมบิน วิ่ง Bhop)
-- ==========================================
RunService.RenderStepped:Connect(function()
    character = player.Character
    if not character then return end
    hrp = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")
    humanoid = character:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return end

    -- บิน
    if isFlying then
        local moveDir = humanoid.MoveDirection
        local targetY = 0
        if goingUp then targetY = flySpeed elseif goingDown then targetY = -flySpeed end
        hrp.AssemblyLinearVelocity = Vector3.new(moveDir.X * flySpeed, targetY, moveDir.Z * flySpeed)
    end

    -- Bhop
    if bhopEnabled and not isFlying then
        local vel = hrp.Velocity
        local speed = math.floor(Vector3.new(vel.X, 0, vel.Z).Magnitude)
        bhopLiveLbl.Text = "LIVE: " .. string.format("%03d", speed)
        
        local state = humanoid:GetState()
        if state == Enum.HumanoidStateType.Running or state == Enum.HumanoidStateType.Landed then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            if strafeEnabled then strafeDir = -strafeDir end
        else
            local moveDir = humanoid.MoveDirection
            if moveDir.Magnitude > 0 and speed < speedCap then
                local boost = moveDir * 3
                if strafeEnabled then
                    local right = hrp.CFrame.RightVector * strafeDir
                    boost = boost + right * 3
                    hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(2 * strafeDir), 0)
                end
                hrp.Velocity = Vector3.new(hrp.Velocity.X + boost.X, hrp.Velocity.Y, hrp.Velocity.Z + boost.Z)
            end
        end
    else
        if bhopLiveLbl then bhopLiveLbl.Text = "LIVE: 000" end
    end
end)

-- ==========================================
-- ระบบ Click TP (แก้ไขให้รองรับมือถือ ไม่ชนกับ UI)
-- ==========================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        if not clickTpEnabled then return end
        if isFlying then return end
        
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            if mouse.Target then
                local pos = mouse.Hit.Position
                char:MoveTo(pos + Vector3.new(0, 3, 0))
            end
        end
    end
end)

-- รีเซ็ตเมื่อตาย
player.CharacterAdded:Connect(function(char)
    isFlying = false; isSprinting = false; bhopEnabled = false; strafeEnabled = false; goingUp = false; goingDown = false; clickTpEnabled = false; isInvisible = false -- เพิ่ม isInvisible
    flyToggleBtn.Text = "เปิดบิน"; ftStroke.Color = Color3.fromRGB(0, 150, 255); flyToggleBtn.TextColor3 = Color3.fromRGB(0, 200, 255)
    sprintToggleBtn.Text = "เปิดวิ่งเร็ว"; spStroke.Color = Color3.fromRGB(255, 200, 0); sprintToggleBtn.TextColor3 = Color3.fromRGB(255, 200, 0)
    bhopToggleBtn.Text = "BHOP OFF"; bhStroke.Color = Color3.fromRGB(60, 60, 60); bhopToggleBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    strafeToggleBtn.Text = "STRAFE OFF"; stStroke.Color = Color3.fromRGB(60, 60, 60); strafeToggleBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    tpToggleBtn.Text = "CLICK TP: OFF"; tpStroke.Color = Color3.fromRGB(60, 60, 60); tpToggleBtn.TextColor3 = Color3.fromRGB(255, 80, 120)
    -- เพิ่มรีเซ็ตปุ่มล่องหน
    invisToggleBtn.Text = "INVISIBLE: OFF"; invStroke.Color = Color3.fromRGB(60, 60, 60); invisToggleBtn.TextColor3 = Color3.fromRGB(180, 100, 255)
    char:WaitForChild("Humanoid").WalkSpeed = defaultWalkSpeed
end)
