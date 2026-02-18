-- ================================
--        RAINBOT v5.0
--   by Rain | 40 Features Edition
-- ================================
-- Pasang di: StarterPlayerScripts

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting         = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera      = workspace.CurrentCamera

-- =====================
-- CONFIG
-- =====================
local CFG = {
    AimRange      = 500,
    AimSpeed      = 1,
    SpeedMult     = 3,
    FOVRadius     = 120,
    AlertRange    = 50,
    JumpPower     = 100,
    GetKeyLink    = "https://wa.me/qr/CKNCNG7XBZG5C1",
}

local ValidKeys = {
    ["Key-71818"]    = "normal",
    ["Key-9898"]     = "normal",
    ["Key-9282827"]  = "normal",
    ["Key-82826288"] = "normal",
    ["Key-676767"]   = "esp",
}

-- =====================
-- STATE
-- =====================
local S = {
    espUnlocked = false,
    kills       = 0,
    lockedTarget = nil,
    -- Aimbot
    aimOn = false, wallCheck = true, aimHead = true,
    silentAim = false, smoothAim = false, aimAssist = false,
    -- ESP
    espOn = false, espName = true, espHealth = true, espDist = true,
    -- HUD
    fovOn = false, crosshairOn = false, lockIndOn = false, killCountOn = false,
    alertOn = false, fpsOn = false, pingOn = false, playerListOn = false,
    rainbowNameOn = false,
    -- Movement
    speedOn = false, noclipOn = false, infJumpOn = false,
    flyOn = false, highJumpOn = false, spamJumpOn = false,
    -- World
    fullbrightOn = false, noFogOn = false, timeFreezeOn = false, thirdPersonOn = false,
    -- Weapon
    rapidFireOn = false, noRecoilOn = false, infAmmoOn = false,
    -- Player
    antiAfkOn = false, godModeOn = false, invisOn = false,
    antiKBOn = false, autoHealOn = false,
}

-- =====================
-- WARNA
-- =====================
local CN = {
    bg     = Color3.fromRGB(12, 8, 30),
    panel  = Color3.fromRGB(18, 11, 42),
    accent = Color3.fromRGB(140, 60, 255),
    accent2= Color3.fromRGB(180, 80, 255),
    neon   = Color3.fromRGB(200, 100, 255),
    stroke = Color3.fromRGB(140, 60, 255),
}
local CV = {
    bg     = Color3.fromRGB(18, 13, 2),
    panel  = Color3.fromRGB(32, 22, 4),
    accent = Color3.fromRGB(210, 160, 20),
    accent2= Color3.fromRGB(255, 200, 50),
    neon   = Color3.fromRGB(255, 220, 80),
    stroke = Color3.fromRGB(210, 160, 20),
}
local C = {
    text   = Color3.fromRGB(230, 220, 255),
    sub    = Color3.fromRGB(150, 130, 200),
    green  = Color3.fromRGB(50, 220, 100),
    red    = Color3.fromRGB(220, 60, 60),
    yellow = Color3.fromRGB(255, 210, 50),
    dark   = Color3.fromRGB(8, 5, 20),
    white  = Color3.fromRGB(255, 255, 255),
    orange = Color3.fromRGB(255, 140, 30),
    cyan   = Color3.fromRGB(50, 200, 220),
}

local function TH() return S.espUnlocked and CV or CN end

-- =====================
-- HELPERS
-- =====================
local function tw(obj, t, props, style)
    return TweenService:Create(obj, TweenInfo.new(t, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
end

local function aC(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 10)
    c.Parent = p
end

local function aS(p, col, th)
    local s = Instance.new("UIStroke")
    s.Color = col
    s.Thickness = th or 2
    s.Parent = p
end

local function mL(par, txt, sz, pos, fnt, col, z)
    local l = Instance.new("TextLabel")
    l.Size = sz
    l.Position = pos
    l.BackgroundTransparency = 1
    l.Text = txt
    l.TextColor3 = col or C.text
    l.TextScaled = true
    l.Font = fnt or Enum.Font.GothamBold
    l.ZIndex = z or 10
    l.Parent = par
    return l
end

-- Toggle switch, returns getter + setter
local function mkToggle(par, x, y, w, h, label, defOn, theme)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(0, w, 0, h)
    row.Position = UDim2.new(0, x, 0, y)
    row.BackgroundColor3 = theme.panel
    row.BorderSizePixel = 0
    row.ZIndex = 12
    row.Parent = par
    aC(row, 8)

    local lbl = mL(row, label, UDim2.new(1, -54, 1, 0), UDim2.new(0, 8, 0, 0), Enum.Font.Gotham, C.text, 13)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextScaled = false
    lbl.TextSize = 11

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(0, 42, 0, 20)
    bg.Position = UDim2.new(1, -48, 0.5, -10)
    bg.BackgroundColor3 = defOn and C.green or Color3.fromRGB(65, 65, 65)
    bg.BorderSizePixel = 0
    bg.ZIndex = 13
    bg.Parent = row
    aC(bg, 10)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = defOn and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
    knob.BackgroundColor3 = C.white
    knob.BorderSizePixel = 0
    knob.ZIndex = 14
    knob.Parent = bg
    aC(knob, 7)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 15
    btn.Parent = bg

    local on = defOn or false
    local function set(v)
        on = v
        tw(bg, 0.15, {BackgroundColor3 = on and C.green or Color3.fromRGB(65, 65, 65)}):Play()
        tw(knob, 0.15, {Position = on and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)}):Play()
    end
    btn.MouseButton1Click:Connect(function() set(not on) end)
    return function() return on end, set
end

-- Section header
local function mkSection(par, title, y)
    local sl = mL(par, title, UDim2.new(1, -8, 0, 14), UDim2.new(0, 4, 0, y),
        Enum.Font.GothamBold, TH().accent2, 12)
    sl.TextXAlignment = Enum.TextXAlignment.Left
    sl.TextScaled = false
    sl.TextSize = 10
    return y + 16
end

-- =====================
-- TEAM CHECK HELPER
-- =====================
local function isSameTeam(player)
    if not player then return false end
    local ok, result = pcall(function()
        return LocalPlayer.Team ~= nil
            and player.Team ~= nil
            and LocalPlayer.Team == player.Team
    end)
    return ok and result or false
end

local function isEnemy(player)
    if player == LocalPlayer then return false end
    -- Jika game pakai team, skip teammates
    if isSameTeam(player) then return false end
    local ec = player.Character
    local eh = ec and ec:FindFirstChild("Humanoid")
    if not eh or eh.Health <= 0 then return false end
    return true
end

-- =====================
-- GUI ROOT
-- =====================
local sg = Instance.new("ScreenGui")
sg.Name = "RainBotGUI"
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.DisplayOrder = 999
sg.Parent = LocalPlayer.PlayerGui

-- =====================
-- NOTIF
-- =====================
local function notif(msg, col)
    task.spawn(function()
        local n = Instance.new("TextLabel")
        n.Size = UDim2.new(0, 270, 0, 30)
        n.AnchorPoint = Vector2.new(0.5, 0)
        n.Position = UDim2.new(0.5, 0, 0, 68)
        n.BackgroundColor3 = C.dark
        n.TextColor3 = col or C.green
        n.Text = msg
        n.TextScaled = false
        n.TextSize = 12
        n.Font = Enum.Font.GothamBold
        n.BorderSizePixel = 0
        n.BackgroundTransparency = 0.15
        n.TextTransparency = 1
        n.ZIndex = 95
        n.Parent = sg
        aC(n, 7)
        aS(n, col or C.green, 1.5)
        tw(n, 0.25, {TextTransparency = 0}):Play()
        task.wait(2.2)
        tw(n, 0.3, {TextTransparency = 1, BackgroundTransparency = 1}):Play()
        task.wait(0.3)
        n:Destroy()
    end)
end

-- =====================
-- HUD OVERLAYS
-- =====================
-- FOV Circle
local fovCircle = Instance.new("Frame")
fovCircle.Size = UDim2.new(0, CFG.FOVRadius * 2, 0, CFG.FOVRadius * 2)
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
fovCircle.BackgroundTransparency = 1
fovCircle.ZIndex = 30
fovCircle.Visible = false
fovCircle.Parent = sg
aC(fovCircle, CFG.FOVRadius)
aS(fovCircle, C.white, 1.5)

-- Crosshair H
local cH = Instance.new("Frame")
cH.Size = UDim2.new(0, 22, 0, 2)
cH.AnchorPoint = Vector2.new(0.5, 0.5)
cH.Position = UDim2.new(0.5, 0, 0.5, 0)
cH.BackgroundColor3 = C.white
cH.BorderSizePixel = 0
cH.ZIndex = 30
cH.Visible = false
cH.Parent = sg

-- Crosshair V
local cV = Instance.new("Frame")
cV.Size = UDim2.new(0, 2, 0, 22)
cV.AnchorPoint = Vector2.new(0.5, 0.5)
cV.Position = UDim2.new(0.5, 0, 0.5, 0)
cV.BackgroundColor3 = C.white
cV.BorderSizePixel = 0
cV.ZIndex = 30
cV.Visible = false
cV.Parent = sg

-- Lock indicator
local lockInd = Instance.new("TextLabel")
lockInd.Size = UDim2.new(0, 170, 0, 26)
lockInd.AnchorPoint = Vector2.new(0.5, 0)
lockInd.Position = UDim2.new(0.5, 0, 0, 130)
lockInd.BackgroundColor3 = C.dark
lockInd.BackgroundTransparency = 0.2
lockInd.TextColor3 = C.sub
lockInd.Text = "🎯 NO TARGET"
lockInd.TextScaled = false
lockInd.TextSize = 11
lockInd.Font = Enum.Font.GothamBold
lockInd.BorderSizePixel = 0
lockInd.ZIndex = 30
lockInd.Visible = false
lockInd.Parent = sg
aC(lockInd, 6)
aS(lockInd, C.sub, 1.5)

-- Kill counter
local killF = Instance.new("Frame")
killF.Size = UDim2.new(0, 100, 0, 26)
killF.Position = UDim2.new(0, 8, 0, 130)
killF.BackgroundColor3 = C.dark
killF.BackgroundTransparency = 0.2
killF.BorderSizePixel = 0
killF.ZIndex = 30
killF.Visible = false
killF.Parent = sg
aC(killF, 6)
aS(killF, C.red, 1.5)
local killLbl = mL(killF, "☠ Kills: 0", UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), Enum.Font.GothamBold, C.red, 31)
killLbl.TextScaled = false
killLbl.TextSize = 11

-- FPS HUD
local fpsHud = Instance.new("TextLabel")
fpsHud.Size = UDim2.new(0, 90, 0, 26)
fpsHud.Position = UDim2.new(1, -98, 0, 96)
fpsHud.BackgroundColor3 = C.dark
fpsHud.BackgroundTransparency = 0.2
fpsHud.TextColor3 = C.green
fpsHud.Text = "FPS: --"
fpsHud.TextScaled = false
fpsHud.TextSize = 11
fpsHud.Font = Enum.Font.GothamBold
fpsHud.BorderSizePixel = 0
fpsHud.ZIndex = 30
fpsHud.Visible = false
fpsHud.Parent = sg
aC(fpsHud, 6)
aS(fpsHud, C.green, 1.5)

-- Ping HUD
local pingHud = Instance.new("TextLabel")
pingHud.Size = UDim2.new(0, 90, 0, 26)
pingHud.Position = UDim2.new(1, -98, 0, 130)
pingHud.BackgroundColor3 = C.dark
pingHud.BackgroundTransparency = 0.2
pingHud.TextColor3 = C.cyan
pingHud.Text = "Ping: --"
pingHud.TextScaled = false
pingHud.TextSize = 11
pingHud.Font = Enum.Font.GothamBold
pingHud.BorderSizePixel = 0
pingHud.ZIndex = 30
pingHud.Visible = false
pingHud.Parent = sg
aC(pingHud, 6)
aS(pingHud, C.cyan, 1.5)

-- =====================
-- LOADING SCREEN
-- =====================
local loadBg = Instance.new("Frame")
loadBg.Size = UDim2.new(1, 0, 1, 0)
loadBg.BackgroundColor3 = C.dark
loadBg.BorderSizePixel = 0
loadBg.ZIndex = 100
loadBg.Parent = sg

local lFrame = Instance.new("Frame")
lFrame.Size = UDim2.new(0, 300, 0, 205)
lFrame.AnchorPoint = Vector2.new(0.5, 0.5)
lFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
lFrame.BackgroundColor3 = CN.panel
lFrame.BorderSizePixel = 0
lFrame.ZIndex = 101
lFrame.Parent = loadBg
aC(lFrame, 18)
aS(lFrame, CN.accent, 2)

local lTitle = mL(lFrame, "🌧 RainBot v5.0", UDim2.new(1, 0, 0, 42), UDim2.new(0, 0, 0, 8),
    Enum.Font.GothamBold, CN.neon, 102)
mL(lFrame, "by Rain", UDim2.new(1, 0, 0, 18), UDim2.new(0, 0, 0, 48), Enum.Font.Gotham, C.sub, 102)

local lClip = mL(lFrame,
    "📋 Link disalin! Buka Chrome → paste link\n→ WA → minta key ke developer.",
    UDim2.new(0.9, 0, 0, 40), UDim2.new(0.05, 0, 0, 70), Enum.Font.Gotham, C.yellow, 102)
lClip.TextScaled = false
lClip.TextSize = 12
lClip.TextWrapped = true

local lBarBg = Instance.new("Frame")
lBarBg.Size = UDim2.new(0.85, 0, 0, 7)
lBarBg.Position = UDim2.new(0.075, 0, 0, 122)
lBarBg.BackgroundColor3 = C.dark
lBarBg.BorderSizePixel = 0
lBarBg.ZIndex = 102
lBarBg.Parent = lFrame
aC(lBarBg, 4)

local lBarFill = Instance.new("Frame")
lBarFill.Size = UDim2.new(0, 0, 1, 0)
lBarFill.BackgroundColor3 = CN.accent
lBarFill.BorderSizePixel = 0
lBarFill.ZIndex = 103
lBarFill.Parent = lBarBg
aC(lBarFill, 4)

local lStatus = mL(lFrame, "Starting...", UDim2.new(1, 0, 0, 18), UDim2.new(0, 0, 0, 136),
    Enum.Font.Gotham, C.sub, 102)
lStatus.TextScaled = false
lStatus.TextSize = 11

task.spawn(function()
    local cols = {CN.neon, CN.accent2, CN.accent, CN.accent2}
    local i = 1
    while loadBg.Visible do
        i = (i % #cols) + 1
        tw(lTitle, 0.8, {TextColor3 = cols[i]}):Play()
        task.wait(0.8)
    end
end)

-- =====================
-- KEY POPUP
-- =====================
local function showKey()
    local ov = Instance.new("Frame")
    ov.Size = UDim2.new(1, 0, 1, 0)
    ov.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    ov.BackgroundTransparency = 0.45
    ov.ZIndex = 55
    ov.Parent = sg

    local pp = Instance.new("Frame")
    pp.Size = UDim2.new(0, 300, 0, 0)
    pp.AnchorPoint = Vector2.new(0.5, 0.5)
    pp.Position = UDim2.new(0.5, 0, 0.5, 0)
    pp.BackgroundColor3 = CN.panel
    pp.BorderSizePixel = 0
    pp.ZIndex = 56
    pp.Parent = sg
    aC(pp, 18)
    aS(pp, CN.accent, 2)
    tw(pp, 0.4, {Size = UDim2.new(0, 300, 0, 220)}, Enum.EasingStyle.Back):Play()
    task.wait(0.4)

    mL(pp, "🔑 Masukkan Key", UDim2.new(1, 0, 0, 38), UDim2.new(0, 0, 0, 8),
        Enum.Font.GothamBold, CN.neon, 57)

    local inf = mL(pp, "Belum punya key? Link WA sudah tersalin!\nBuka Chrome → paste → hubungi developer.",
        UDim2.new(0.9, 0, 0, 36), UDim2.new(0.05, 0, 0, 50), Enum.Font.Gotham, C.yellow, 57)
    inf.TextScaled = false
    inf.TextSize = 12
    inf.TextWrapped = true

    local kb = Instance.new("TextBox")
    kb.Size = UDim2.new(0.88, 0, 0, 40)
    kb.Position = UDim2.new(0.06, 0, 0, 94)
    kb.BackgroundColor3 = C.dark
    kb.TextColor3 = C.text
    kb.PlaceholderText = "Masukkan key kamu..."
    kb.PlaceholderColor3 = C.sub
    kb.Text = ""
    kb.TextScaled = true
    kb.Font = Enum.Font.Gotham
    kb.BorderSizePixel = 0
    kb.ZIndex = 57
    kb.Parent = pp
    aC(kb, 10)
    aS(kb, CN.accent, 1)

    local ks = mL(pp, "", UDim2.new(1, 0, 0, 20), UDim2.new(0, 0, 0, 142), Enum.Font.Gotham, C.red, 57)
    ks.TextScaled = false
    ks.TextSize = 12

    local cb = Instance.new("TextButton")
    cb.Size = UDim2.new(0.88, 0, 0, 38)
    cb.Position = UDim2.new(0.06, 0, 0, 172)
    cb.BackgroundColor3 = CN.accent
    cb.TextColor3 = C.white
    cb.Text = "Verifikasi ✓"
    cb.TextScaled = true
    cb.Font = Enum.Font.GothamBold
    cb.BorderSizePixel = 0
    cb.ZIndex = 57
    cb.Parent = pp
    aC(cb, 10)

    cb.MouseButton1Click:Connect(function()
        local kt = ValidKeys[kb.Text]
        if kt then
            S.espUnlocked = (kt == "esp")
            ks.TextColor3 = S.espUnlocked and C.yellow or C.green
            ks.Text = S.espUnlocked and "⭐ VIP Key aktif!" or "✅ Key valid!"
            task.wait(0.8)
            tw(pp, 0.2, {Size = UDim2.new(0, 300, 0, 0)}):Play()
            task.wait(0.25)
            pp:Destroy()
            ov:Destroy()
            task.wait(0.1)
            openMenu()
        else
            ks.Text = "❌ Key tidak valid!"
            ks.TextColor3 = C.red
            kb.Text = ""
            for i = 1, 4 do
                task.wait(0.05) tw(pp, 0.05, {Position = UDim2.new(0.5, 8, 0.5, 0)}):Play()
                task.wait(0.05) tw(pp, 0.05, {Position = UDim2.new(0.5, -8, 0.5, 0)}):Play()
            end
            tw(pp, 0.05, {Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
        end
    end)
end

-- =====================
-- MAIN MENU  (landscape: 580 x 370)
-- =====================
function openMenu()
    local TM    = TH()
    local W     = 580
    local H     = 370
    local SIDE  = 80
    local TITLEH = 36
    -- Column constants untuk content area
    local CAREA_W = W - SIDE - 2
    local COL_W   = math.floor((CAREA_W - 14) / 2)  -- ~240px
    local COL_GAP = 6

    local win = Instance.new("Frame")
    win.Size = UDim2.new(0, 0, 0, 0)
    win.AnchorPoint = Vector2.new(0.5, 0.5)
    win.Position = UDim2.new(0.5, 0, 0.5, 0)
    win.BackgroundColor3 = TM.bg
    win.BorderSizePixel = 0
    win.ZIndex = 10
    win.Parent = sg
    aC(win, 14)
    aS(win, TM.stroke, 2)
    tw(win, 0.45, {Size = UDim2.new(0, W, 0, H)}, Enum.EasingStyle.Back):Play()
    task.wait(0.45)

    -- TITLEBAR
    local tBar = Instance.new("Frame")
    tBar.Size = UDim2.new(1, 0, 0, TITLEH)
    tBar.BackgroundColor3 = TM.panel
    tBar.BorderSizePixel = 0
    tBar.ZIndex = 11
    tBar.Parent = win
    aC(tBar, 14)
    -- fix bottom radius
    local tFix = Instance.new("Frame")
    tFix.Size = UDim2.new(1, 0, 0.5, 0)
    tFix.Position = UDim2.new(0, 0, 0.5, 0)
    tFix.BackgroundColor3 = TM.panel
    tFix.BorderSizePixel = 0
    tFix.ZIndex = 11
    tFix.Parent = tBar

    local tLbl = mL(tBar, "🌧  RainBot v5.0", UDim2.new(0, 200, 1, 0), UDim2.new(0, 10, 0, 0),
        Enum.Font.GothamBold, TM.neon, 12)
    tLbl.TextXAlignment = Enum.TextXAlignment.Left
    tLbl.TextScaled = false
    tLbl.TextSize = 14

    local badge = Instance.new("TextLabel")
    badge.Size = UDim2.new(0, 58, 0, 18)
    badge.Position = UDim2.new(0, 188, 0.5, -9)
    badge.BackgroundColor3 = S.espUnlocked and Color3.fromRGB(40, 28, 4) or Color3.fromRGB(22, 8, 48)
    badge.TextColor3 = S.espUnlocked and C.yellow or C.green
    badge.Text = S.espUnlocked and "⭐ VIP" or "🔑 Normal"
    badge.TextScaled = false
    badge.TextSize = 10
    badge.Font = Enum.Font.GothamBold
    badge.BorderSizePixel = 0
    badge.ZIndex = 12
    badge.Parent = tBar
    aC(badge, 5)

    local uLbl = mL(tBar, "👤 " .. LocalPlayer.Name, UDim2.new(0, 150, 1, 0), UDim2.new(0, 254, 0, 0),
        Enum.Font.Gotham, C.sub, 12)
    uLbl.TextXAlignment = Enum.TextXAlignment.Left
    uLbl.TextScaled = false
    uLbl.TextSize = 11

    local minB = Instance.new("TextButton")
    minB.Size = UDim2.new(0, 22, 0, 18)
    minB.Position = UDim2.new(1, -50, 0.5, -9)
    minB.BackgroundColor3 = TM.accent
    minB.Text = "–"
    minB.TextColor3 = C.white
    minB.TextScaled = true
    minB.Font = Enum.Font.GothamBold
    minB.BorderSizePixel = 0
    minB.ZIndex = 15
    minB.Parent = tBar
    aC(minB, 5)

    local closeB = Instance.new("TextButton")
    closeB.Size = UDim2.new(0, 22, 0, 18)
    closeB.Position = UDim2.new(1, -24, 0.5, -9)
    closeB.BackgroundColor3 = C.red
    closeB.Text = "✕"
    closeB.TextColor3 = C.white
    closeB.TextScaled = true
    closeB.Font = Enum.Font.GothamBold
    closeB.BorderSizePixel = 0
    closeB.ZIndex = 15
    closeB.Parent = tBar
    aC(closeB, 5)

    -- BODY
    local body = Instance.new("Frame")
    body.Size = UDim2.new(1, 0, 1, -TITLEH)
    body.Position = UDim2.new(0, 0, 0, TITLEH)
    body.BackgroundTransparency = 1
    body.ClipsDescendants = true
    body.ZIndex = 10
    body.Parent = win

    -- SIDEBAR
    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, SIDE, 1, 0)
    sidebar.BackgroundColor3 = TM.panel
    sidebar.BorderSizePixel = 0
    sidebar.ZIndex = 11
    sidebar.Parent = body

    local sep = Instance.new("Frame")
    sep.Size = UDim2.new(0, 1, 1, 0)
    sep.Position = UDim2.new(0, SIDE, 0, 0)
    sep.BackgroundColor3 = TM.stroke
    sep.BackgroundTransparency = 0.5
    sep.BorderSizePixel = 0
    sep.ZIndex = 11
    sep.Parent = body

    -- CONTENT AREA
    local cArea = Instance.new("Frame")
    cArea.Size = UDim2.new(0, CAREA_W, 1, -6)
    cArea.Position = UDim2.new(0, SIDE + 2, 0, 3)
    cArea.BackgroundTransparency = 1
    cArea.ZIndex = 11
    cArea.Parent = body

    -- =====================
    -- TAB SYSTEM
    -- =====================
    local tabDefs = {
        {icon = "🏠", label = "Home"},
        {icon = "🎯", label = "Aimbot"},
        {icon = "👁",  label = "Visual"},
        {icon = "⚡",  label = "Move"},
        {icon = "🌍",  label = "World"},
        {icon = "🔫",  label = "Weapon"},
        {icon = "🎨",  label = "Extras"},
    }

    local tabBtns = {}
    local tabFrames = {}
    local activeTab = ""

    for i, td in ipairs(tabDefs) do
        -- Sidebar button
        local tb = Instance.new("TextButton")
        tb.Size = UDim2.new(1, -6, 0, 34)
        tb.Position = UDim2.new(0, 3, 0, (i - 1) * 37 + 4)
        tb.BackgroundColor3 = TM.bg
        tb.BackgroundTransparency = 0.4
        tb.Text = ""
        tb.BorderSizePixel = 0
        tb.ZIndex = 13
        tb.Parent = sidebar
        aC(tb, 7)

        local ic = mL(tb, td.icon, UDim2.new(1, 0, 0, 18), UDim2.new(0, 0, 0, 3),
            Enum.Font.GothamBold, C.sub, 14)
        local sl = mL(tb, td.label, UDim2.new(1, 0, 0, 11), UDim2.new(0, 0, 0, 21),
            Enum.Font.Gotham, C.sub, 14)
        sl.TextScaled = false
        sl.TextSize = 8

        -- Content ScrollingFrame
        local sf = Instance.new("ScrollingFrame")
        sf.Size = UDim2.new(1, 0, 1, 0)
        sf.BackgroundTransparency = 1
        sf.ScrollBarThickness = 3
        sf.CanvasSize = UDim2.new(0, 0, 0, 0)
        sf.ScrollBarImageColor3 = TM.accent
        sf.BorderSizePixel = 0
        sf.ZIndex = 12
        sf.Visible = false
        sf.Parent = cArea

        tabBtns[td.label] = {btn = tb, ic = ic, sl = sl}
        tabFrames[td.label] = sf

        tb.MouseButton1Click:Connect(function()
            -- deactivate all
            for n, t in pairs(tabBtns) do
                tw(t.btn, 0.15, {BackgroundTransparency = 0.4, BackgroundColor3 = TM.bg}):Play()
                tw(t.ic, 0.15, {TextColor3 = C.sub}):Play()
                tw(t.sl, 0.15, {TextColor3 = C.sub}):Play()
                tabFrames[n].Visible = false
            end
            -- activate this
            tw(tb, 0.15, {BackgroundTransparency = 0, BackgroundColor3 = TM.accent}):Play()
            tw(ic, 0.15, {TextColor3 = C.white}):Play()
            tw(sl, 0.15, {TextColor3 = C.white}):Play()
            sf.Visible = true
            activeTab = td.label
        end)
    end

    -- Helper to add 2-column toggle
    local function tog2(sf, col, row, label, defOn)
        local x = col == 0 and 4 or COL_W + COL_GAP + 4
        local y = row * 42 + 4
        return mkToggle(sf, x, y, COL_W, 38, label, defOn, TM)
    end

    -- =====================
    -- 🏠 HOME
    -- =====================
    local hSF = tabFrames["Home"]

    -- Status boxes (live)
    local statDefs = {
        {key = "aimOn",    lbl = "Aimbot",  col = C.red},
        {key = "espOn",    lbl = "ESP",     col = C.green},
        {key = "speedOn",  lbl = "Speed",   col = C.cyan},
        {key = "godModeOn",lbl = "God",     col = C.yellow},
    }
    local statRefs = {}
    local totalStatW = CAREA_W - 8
    local sbW = math.floor(totalStatW / 4) - 3
    for i, sd in ipairs(statDefs) do
        local box = Instance.new("Frame")
        box.Size = UDim2.new(0, sbW, 0, 40)
        box.Position = UDim2.new(0, 4 + (i-1)*(sbW+3), 0, 4)
        box.BackgroundColor3 = TM.panel
        box.BorderSizePixel = 0
        box.ZIndex = 12
        box.Parent = hSF
        aC(box, 8)
        aS(box, sd.col, 1.5)
        local lN = mL(box, sd.lbl, UDim2.new(1,0,0.45,0), UDim2.new(0,0,0,2), Enum.Font.GothamBold, sd.col, 13)
        lN.TextScaled = false lN.TextSize = 10
        local lV = mL(box, "OFF", UDim2.new(1,0,0.5,0), UDim2.new(0,0,0.48,0), Enum.Font.Gotham, C.sub, 13)
        lV.TextScaled = false lV.TextSize = 11
        statRefs[sd.key] = {v = lV, col = sd.col}
    end

    mkSection(hSF, "⚙️  Quick", 50)
    local getFpsQ,_    = tog2(hSF, 0, 1, "📊 FPS Counter",   false)
    local getPingQ,_   = tog2(hSF, 1, 1, "📶 Ping Display",  false)
    local getRbName,_  = tog2(hSF, 0, 2, "🌈 Rainbow Name",  false)
    local getPlList,_  = tog2(hSF, 1, 2, "📋 Player List",   false)
    hSF.CanvasSize = UDim2.new(0, 0, 0, 4 + 3*42 + 50)

    -- =====================
    -- 🎯 AIMBOT
    -- =====================
    local aSF = tabFrames["Aimbot"]
    mkSection(aSF, "🎯  Aimbot", 2)
    local getAim,setAim     = tog2(aSF, 0, 0, "🎯 Aimbot",       false)
    local getWall,_         = tog2(aSF, 1, 0, "🧱 Wall Check",    true)
    local getHead,_         = tog2(aSF, 0, 1, "💀 Aim Kepala",    true)
    local getSilent,_       = tog2(aSF, 1, 1, "🔇 Silent Aim",    false)
    local getSmooth,_       = tog2(aSF, 0, 2, "🌊 Smooth Aim",    false)
    local getAssist,_       = tog2(aSF, 1, 2, "🤝 Aim Assist",    false)
    mkSection(aSF, "🖥️  HUD", 2 + 3*42 + 18)
    local getFov,_          = tog2(aSF, 0, 4, "⭕ FOV Circle",    false)
    local getCross,_        = tog2(aSF, 1, 4, "➕ Crosshair",     false)
    local getLockInd,_      = tog2(aSF, 0, 5, "🔒 Lock Indicator",false)
    local getKillC,_        = tog2(aSF, 1, 5, "☠ Kill Counter",  false)
    aSF.CanvasSize = UDim2.new(0, 0, 0, 4 + 6*42 + 38)

    -- =====================
    -- 👁 VISUAL
    -- =====================
    local vSF = tabFrames["Visual"]
    local getEsp, getName, getHP, getDist = nil, nil, nil, nil

    if S.espUnlocked then
        mkSection(vSF, "👁  ESP", 2)
        getEsp,_    = tog2(vSF, 0, 0, "👁 ESP On/Off",    false)
        getName,_   = tog2(vSF, 1, 0, "🏷 Nama Musuh",    true)
        getHP,_     = tog2(vSF, 0, 1, "❤️ Health Bar",    true)
        getDist,_   = tog2(vSF, 1, 1, "📏 Jarak",          true)
        mkSection(vSF, "🔔  Alert", 2 + 2*42 + 18)
        local getAlrt,_ = tog2(vSF, 0, 3, "🔔 Alert Musuh",  false)
        vSF.CanvasSize = UDim2.new(0, 0, 0, 4 + 4*42 + 36)
        RunService.Heartbeat:Connect(function()
            S.espOn     = getEsp()
            S.espName   = getName()
            S.espHealth = getHP()
            S.espDist   = getDist()
            S.alertOn   = getAlrt()
        end)
    else
        local lkF = Instance.new("Frame")
        lkF.Size = UDim2.new(1, -10, 0, 110)
        lkF.Position = UDim2.new(0, 5, 0, 5)
        lkF.BackgroundColor3 = TM.panel
        lkF.BorderSizePixel = 0
        lkF.ZIndex = 12
        lkF.Parent = vSF
        aC(lkF, 12)
        aS(lkF, C.red, 1.5)
        mL(lkF, "🔒", UDim2.new(1,0,0,40), UDim2.new(0,0,0,8), Enum.Font.GothamBold, C.red, 13)
        local lt = mL(lkF, "Fitur ini terkunci.", UDim2.new(1,0,0,22), UDim2.new(0,0,0,50), Enum.Font.GothamBold, C.red, 13)
        lt.TextScaled = false lt.TextSize = 13
        local ls = mL(lkF, "Hubungi developer untuk akses.", UDim2.new(0.9,0,0,18), UDim2.new(0.05,0,0,75), Enum.Font.Gotham, C.sub, 13)
        ls.TextScaled = false ls.TextSize = 11
        vSF.CanvasSize = UDim2.new(0, 0, 0, 120)
        S.espOn = false
    end

    -- =====================
    -- ⚡ MOVEMENT
    -- =====================
    local mSF = tabFrames["Move"]
    mkSection(mSF, "⚡  Movement", 2)
    local getSpeed,_     = tog2(mSF, 0, 0, "💨 Speedhack",     false)
    local getNoclip,_    = tog2(mSF, 1, 0, "👻 Noclip",        false)
    local getInfJump,_   = tog2(mSF, 0, 1, "🦘 Infinite Jump", false)
    local getFly,_       = tog2(mSF, 1, 1, "🕊️ Fly",          false)
    local getHighJump,_  = tog2(mSF, 0, 2, "🚀 High Jump",     false)
    local getSpamJump,_  = tog2(mSF, 1, 2, "🐸 Spam Jump",     false)
    mSF.CanvasSize = UDim2.new(0, 0, 0, 4 + 3*42 + 20)

    -- =====================
    -- 🌍 WORLD
    -- =====================
    local wSF = tabFrames["World"]
    mkSection(wSF, "🌍  World", 2)
    local getFullbright,_ = tog2(wSF, 0, 0, "☀️ Fullbright",   false)
    local getNoFog,_      = tog2(wSF, 1, 0, "🌫️ No Fog",       false)
    local getTimeF,_      = tog2(wSF, 0, 1, "⏱️ Freeze Time",  false)
    local getThirdP,_     = tog2(wSF, 1, 1, "📷 Third Person", false)
    wSF.CanvasSize = UDim2.new(0, 0, 0, 4 + 2*42 + 20)

    -- =====================
    -- 🔫 WEAPON
    -- =====================
    local wpSF = tabFrames["Weapon"]
    mkSection(wpSF, "🔫  Weapon", 2)
    local getRapid,_    = tog2(wpSF, 0, 0, "🔥 Rapid Fire",   false)
    local getNoRecoil,_ = tog2(wpSF, 1, 0, "🎯 No Recoil",    false)
    local getInfAmmo,_  = tog2(wpSF, 0, 1, "♾ Inf Ammo",     false)
    wpSF.CanvasSize = UDim2.new(0, 0, 0, 4 + 2*42 + 20)

    -- =====================
    -- 🎨 EXTRAS
    -- =====================
    local eSF = tabFrames["Extras"]
    mkSection(eSF, "🎨  Extras", 2)
    local getAntiAfk,_  = tog2(eSF, 0, 0, "🤖 Anti-AFK",        false)
    local getGod,_      = tog2(eSF, 1, 0, "🛡️ God Mode",        false)
    local getInvis,_    = tog2(eSF, 0, 1, "👁️ Invisible",       false)
    local getAntiKB,_   = tog2(eSF, 1, 1, "🗿 Anti-Knockback",  false)
    local getAutoHeal,_ = tog2(eSF, 0, 2, "💊 Auto Heal",        false)
    eSF.CanvasSize = UDim2.new(0, 0, 0, 4 + 3*42 + 20)

    -- Activate first tab
    tabBtns["Home"].btn.MouseButton1Click:Fire()

    -- =====================
    -- HEARTBEAT — sync semua state
    -- =====================
    RunService.Heartbeat:Connect(function()
        if not win.Parent then return end

        -- Aimbot
        S.aimOn      = getAim()
        S.wallCheck  = getWall()
        S.aimHead    = getHead()
        S.silentAim  = getSilent()
        S.smoothAim  = getSmooth()
        S.aimAssist  = getAssist()
        -- HUD
        S.fovOn       = getFov()
        S.crosshairOn = getCross()
        S.lockIndOn   = getLockInd()
        S.killCountOn = getKillC()
        S.fpsOn       = getFpsQ()
        S.pingOn      = getPingQ()
        S.rainbowNameOn = getRbName()
        S.playerListOn  = getPlList()
        -- Movement
        S.speedOn    = getSpeed()
        S.noclipOn   = getNoclip()
        S.infJumpOn  = getInfJump()
        S.flyOn      = getFly()
        S.highJumpOn = getHighJump()
        S.spamJumpOn = getSpamJump()
        -- World
        S.fullbrightOn  = getFullbright()
        S.noFogOn       = getNoFog()
        S.timeFreezeOn  = getTimeF()
        S.thirdPersonOn = getThirdP()
        -- Weapon
        S.rapidFireOn  = getRapid()
        S.noRecoilOn   = getNoRecoil()
        S.infAmmoOn    = getInfAmmo()
        -- Extras
        S.antiAfkOn  = getAntiAfk()
        S.godModeOn  = getGod()
        S.invisOn    = getInvis()
        S.antiKBOn   = getAntiKB()
        S.autoHealOn = getAutoHeal()

        -- HUD visibility
        fovCircle.Visible = S.fovOn
        cH.Visible        = S.crosshairOn
        cV.Visible        = S.crosshairOn
        lockInd.Visible   = S.lockIndOn
        killF.Visible     = S.killCountOn
        fpsHud.Visible    = S.fpsOn
        pingHud.Visible   = S.pingOn

        -- Status boxes
        local keyMap = {aimOn=S.aimOn, espOn=S.espOn, speedOn=S.speedOn, godModeOn=S.godModeOn}
        for k, ref in pairs(statRefs) do
            ref.v.Text      = keyMap[k] and "ON" or "OFF"
            ref.v.TextColor3 = keyMap[k] and ref.col or C.sub
        end

        -- Kill counter label
        killLbl.Text = "☠ Kills: " .. S.kills

        -- Lock indicator
        if S.lockIndOn then
            if S.lockedTarget then
                lockInd.Text = "🎯 " .. S.lockedTarget.Name
                lockInd.TextColor3 = C.red
            else
                lockInd.Text = "🎯 NO TARGET"
                lockInd.TextColor3 = C.sub
            end
        end

        -- CHARACTER shortcuts
        local ch  = LocalPlayer.Character
        local hum = ch and ch:FindFirstChild("Humanoid")
        local rp  = ch and ch:FindFirstChild("HumanoidRootPart")

        -- SPEEDHACK
        if hum then
            if S.speedOn then
                hum.WalkSpeed = CFG.SpeedMult * 16
            elseif not S.noclipOn then
                if hum.WalkSpeed ~= 16 then hum.WalkSpeed = 16 end
            end
        end

        -- NOCLIP
        if S.noclipOn and ch then
            for _, p in pairs(ch:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
            if hum then hum.WalkSpeed = S.speedOn and CFG.SpeedMult*16 or 24 end
        end

        -- HIGH JUMP
        if hum then
            if S.highJumpOn then hum.JumpPower = CFG.JumpPower
            elseif hum.JumpPower ~= 50 and not S.infJumpOn then hum.JumpPower = 50 end
        end

        -- GOD MODE
        if S.godModeOn and hum then hum.Health = hum.MaxHealth end

        -- AUTO HEAL (30% threshold)
        if S.autoHealOn and hum and not S.godModeOn then
            if hum.Health < hum.MaxHealth * 0.3 then
                hum.Health = math.min(hum.Health + 1, hum.MaxHealth)
            end
        end

        -- ANTI KNOCKBACK
        if S.antiKBOn and rp then
            rp.AssemblyLinearVelocity = Vector3.new(0, rp.AssemblyLinearVelocity.Y, 0)
        end

        -- INVISIBLE
        if ch then
            for _, p in pairs(ch:GetDescendants()) do
                if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                    p.LocalTransparencyModifier = S.invisOn and 1 or 0
                end
            end
        end

        -- FULLBRIGHT
        if S.fullbrightOn then
            Lighting.Brightness = 2
            Lighting.FogEnd     = 100000
            Lighting.FogStart   = 99999
        elseif S.noFogOn then
            Lighting.FogEnd   = 100000
            Lighting.FogStart = 99999
        end

        -- TIME FREEZE
        if S.timeFreezeOn then Lighting.ClockTime = 14 end

        -- THIRD PERSON
        if S.thirdPersonOn then
            Camera.CameraType = Enum.CameraType.Attach
        else
            if Camera.CameraType == Enum.CameraType.Attach then
                Camera.CameraType = Enum.CameraType.Custom
            end
        end

        -- RAINBOW NAME
        if S.rainbowNameOn then
            local hue = (tick() * 0.3) % 1
            local rc  = Color3.fromHSV(hue, 1, 1)
            if ch then
                local head = ch:FindFirstChild("Head")
                if head then
                    for _, bb in pairs(head:GetChildren()) do
                        if bb:IsA("BillboardGui") then
                            for _, lbl in pairs(bb:GetDescendants()) do
                                if lbl:IsA("TextLabel") then lbl.TextColor3 = rc end
                            end
                        end
                    end
                end
            end
        end

        -- FLY
        if S.flyOn and ch and hum and rp then
            hum.PlatformStand = true
            local dir = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir + Vector3.new(0, -1, 0) end
            rp.AssemblyLinearVelocity = Camera.CFrame.LookVector * 60 + dir * 40
        elseif not S.flyOn and hum then
            if hum.PlatformStand then hum.PlatformStand = false end
        end

        -- ANTI AFK
        if S.antiAfkOn then
            if not _G["RainAfk"] then
                _G["RainAfk"] = true
                task.spawn(function()
                    while S.antiAfkOn do
                        task.wait(55)
                        if S.antiAfkOn then
                            pcall(function()
                                local vu = game:GetService("VirtualUser")
                                vu:CaptureController()
                                vu:ClickButton2(Vector2.new())
                            end)
                        end
                    end
                    _G["RainAfk"] = nil
                end)
            end
        end
    end)

    -- INFINITE JUMP
    local ijConn = nil
    RunService.Heartbeat:Connect(function()
        if S.infJumpOn then
            if not ijConn then
                ijConn = UserInputService.JumpRequest:Connect(function()
                    if S.infJumpOn then
                        local c = LocalPlayer.Character
                        local h = c and c:FindFirstChild("Humanoid")
                        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
                    end
                end)
            end
        else
            if ijConn then ijConn:Disconnect() ijConn = nil end
        end
    end)

    -- SPAM JUMP
    task.spawn(function()
        while true do
            task.wait(0.1)
            if S.spamJumpOn then
                local c = LocalPlayer.Character
                local h = c and c:FindFirstChild("Humanoid")
                if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
        end
    end)

    -- FPS COUNTER
    task.spawn(function()
        local last = tick() local frames = 0 local conn
        conn = RunService.RenderStepped:Connect(function()
            if not win.Parent then conn:Disconnect() return end
            frames += 1
            local now = tick()
            if now - last >= 0.5 then
                if S.fpsOn then
                    local fps = math.floor(frames / (now - last))
                    fpsHud.Text = "FPS: " .. fps
                    fpsHud.TextColor3 = fps >= 50 and C.green or fps >= 30 and C.yellow or C.red
                end
                frames = 0 last = now
            end
        end)
    end)

    -- PING COUNTER
    task.spawn(function()
        while true do
            task.wait(2)
            if S.pingOn then
                local ok, ping = pcall(function() return math.floor(LocalPlayer:GetNetworkPing() * 1000) end)
                if ok then
                    pingHud.Text = "Ping: " .. ping .. "ms"
                    pingHud.TextColor3 = ping < 80 and C.green or ping < 150 and C.yellow or C.red
                end
            end
        end
    end)

    -- KILL COUNTER
    local lastHPs = {}
    RunService.Heartbeat:Connect(function()
        if not S.killCountOn then return end
        for _, p in ipairs(Players:GetPlayers()) do
            if p == LocalPlayer then continue end
            local ec = p.Character
            local eh = ec and ec:FindFirstChild("Humanoid")
            if eh then
                local prev = lastHPs[p.Name] or eh.Health
                if prev > 0 and eh.Health <= 0 then
                    S.kills += 1
                    notif("☠ " .. p.Name .. " killed! (" .. S.kills .. ")", C.red)
                end
                lastHPs[p.Name] = eh.Health
            end
        end
    end)
    Players.PlayerRemoving:Connect(function(p) lastHPs[p.Name] = nil end)

    -- ALERT MUSUH DEKAT
    task.spawn(function()
        while true do
            task.wait(2.5)
            if S.alertOn then
                local ch = LocalPlayer.Character
                local rp = ch and ch:FindFirstChild("HumanoidRootPart")
                if rp then
                    for _, p in ipairs(Players:GetPlayers()) do
                        if not isEnemy(p) then continue end
                        local er = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                        if er then
                            local d = (rp.Position - er.Position).Magnitude
                            if d < CFG.AlertRange then
                                if not _G["RainAlert_"..p.Name] or tick() - _G["RainAlert_"..p.Name] > 5 then
                                    _G["RainAlert_"..p.Name] = tick()
                                    notif("⚠️ " .. p.Name .. " dekat! " .. math.floor(d) .. "m", C.orange)
                                end
                            end
                        end
                    end
                end
            end
        end
    end)

    -- DRAG
    local dg, ds, wp = false, nil, nil
    tBar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            dg = true ds = i.Position wp = win.Position
            i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dg = false end end)
        end
    end)
    tBar.InputChanged:Connect(function(i)
        if dg and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMove) then
            local d = i.Position - ds
            win.Position = UDim2.new(wp.X.Scale, wp.X.Offset + d.X, wp.Y.Scale, wp.Y.Offset + d.Y)
        end
    end)

    -- MINIMIZE
    local isMini = false
    minB.MouseButton1Click:Connect(function()
        isMini = not isMini
        if isMini then
            tw(win, 0.25, {Size = UDim2.new(0, W, 0, TITLEH)}):Play()
            task.wait(0.25)
            body.Visible = false
        else
            body.Visible = true
            tw(win, 0.35, {Size = UDim2.new(0, W, 0, H)}, Enum.EasingStyle.Back):Play()
        end
    end)

    -- CLOSE
    closeB.MouseButton1Click:Connect(function()
        tw(win, 0.25, {Size = UDim2.new(0, W, 0, 0)}):Play()
        task.wait(0.3)
        win:Destroy()
    end)
end

-- =====================
-- LOADING TASK
-- =====================
task.spawn(function()
    local steps = {
        {t = 0.15, text = "Loading core..."},
        {t = 0.35, text = "Menyiapkan aimbot..."},
        {t = 0.55, text = "Menyiapkan ESP..."},
        {t = 0.75, text = "Memuat 40 fitur..."},
        {t = 0.9,  text = "Menyalin link key..."},
        {t = 1.0,  text = "✅ Selesai!"},
    }
    for _, s in ipairs(steps) do
        task.wait(0.5)
        lStatus.Text = s.text
        tw(lBarFill, 0.3, {Size = UDim2.new(s.t, 0, 1, 0)}):Play()
    end
    pcall(function() setclipboard(CFG.GetKeyLink) end)
    task.wait(0.5)
    for _, o in ipairs({loadBg, lFrame, lBarBg, lBarFill}) do
        tw(o, 0.5, {BackgroundTransparency = 1}):Play()
    end
    tw(lTitle, 0.5, {TextTransparency = 1}):Play()
    tw(lClip, 0.5, {TextTransparency = 1}):Play()
    tw(lStatus, 0.5, {TextTransparency = 1}):Play()
    task.wait(0.5)
    loadBg.Visible = false
    task.wait(0.2)
    showKey()
end)

-- =====================
-- AIMBOT RENDER LOOP
-- =====================
RunService.RenderStepped:Connect(function()
    local ch = LocalPlayer.Character
    local rp = ch and ch:FindFirstChild("HumanoidRootPart")

    if S.aimOn and rp then
        local best, bd = nil, CFG.AimRange
        for _, p in ipairs(Players:GetPlayers()) do
            -- TEAM CHECK: skip jika teammate
            if not isEnemy(p) then continue end
            local ec = p.Character
            local er = ec and ec:FindFirstChild("HumanoidRootPart")
            if not er then continue end

            if S.wallCheck then
                local par = RaycastParams.new()
                par.FilterDescendantsInstances = {ch, ec}
                par.FilterType = Enum.RaycastFilterType.Exclude
                if workspace:Raycast(rp.Position, er.Position - rp.Position, par) then continue end
            end

            local d = (rp.Position - er.Position).Magnitude
            if d < bd then bd = d best = ec end
        end

        S.lockedTarget = best

        if best then
            local ap = (S.aimHead and best:FindFirstChild("Head")) or best:FindFirstChild("HumanoidRootPart")
            if ap then
                local spd = S.silentAim and 0.05 or (S.smoothAim and 0.12 or CFG.AimSpeed)
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, ap.Position), spd)
            end
        end
    else
        S.lockedTarget = nil
    end
end)

-- =====================
-- ESP BILLBOARD LOOP
-- =====================
local espBBs = {}

local function rmESP(name)
    if espBBs[name] then
        pcall(function() espBBs[name]:Destroy() end)
        espBBs[name] = nil
    end
end

RunService.Heartbeat:Connect(function()
    if not S.espUnlocked or not S.espOn then
        for n in pairs(espBBs) do rmESP(n) end
        return
    end

    local active = {}

    for _, p in ipairs(Players:GetPlayers()) do
        -- TEAM CHECK: jangan tampilkan ESP untuk teammate
        if not isEnemy(p) then
            rmESP(p.Name)
            continue
        end

        local ec   = p.Character
        local head = ec and ec:FindFirstChild("Head")
        local eh   = ec and ec:FindFirstChild("Humanoid")
        local er   = ec and ec:FindFirstChild("HumanoidRootPart")

        if not head or not eh or not er or eh.Health <= 0 then
            rmESP(p.Name)
            continue
        end

        active[p.Name] = true

        -- Buat BillboardGui jika belum ada
        local bb = espBBs[p.Name]
        if not bb or not bb.Parent then
            bb = Instance.new("BillboardGui")
            bb.Name = "RainESP_" .. p.Name
            bb.Size = UDim2.new(0, 140, 0, 62)
            bb.StudsOffset = Vector3.new(0, 3, 0)
            bb.AlwaysOnTop = true
            bb.MaxDistance = CFG.AimRange
            bb.Parent = head
            espBBs[p.Name] = bb

            -- Nama
            local nl = Instance.new("TextLabel")
            nl.Name = "NL"
            nl.Size = UDim2.new(1, 0, 0, 24)
            nl.Position = UDim2.new(0, 0, 0, 0)
            nl.BackgroundTransparency = 1
            nl.TextColor3 = Color3.fromRGB(255, 80, 80)
            nl.TextStrokeTransparency = 0
            nl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            nl.Font = Enum.Font.GothamBold
            nl.TextScaled = true
            nl.ZIndex = 5
            nl.Parent = bb

            -- Health BG
            local hBg = Instance.new("Frame")
            hBg.Name = "HBg"
            hBg.Size = UDim2.new(1, 0, 0, 8)
            hBg.Position = UDim2.new(0, 0, 0, 27)
            hBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            hBg.BorderSizePixel = 0
            hBg.ZIndex = 5
            hBg.Parent = bb
            aC(hBg, 3)

            local hF = Instance.new("Frame")
            hF.Name = "HF"
            hF.Size = UDim2.new(1, 0, 1, 0)
            hF.BackgroundColor3 = C.green
            hF.BorderSizePixel = 0
            hF.ZIndex = 6
            hF.Parent = hBg
            aC(hF, 3)

            -- Jarak
            local dl = Instance.new("TextLabel")
            dl.Name = "DL"
            dl.Size = UDim2.new(1, 0, 0, 18)
            dl.Position = UDim2.new(0, 0, 0, 39)
            dl.BackgroundTransparency = 1
            dl.TextColor3 = Color3.fromRGB(180, 180, 255)
            dl.TextStrokeTransparency = 0
            dl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            dl.Font = Enum.Font.Gotham
            dl.TextScaled = true
            dl.ZIndex = 5
            dl.Parent = bb
        end

        -- Update values
        local nl  = bb:FindFirstChild("NL")
        local hBg = bb:FindFirstChild("HBg")
        local hF  = hBg and hBg:FindFirstChild("HF")
        local dl  = bb:FindFirstChild("DL")

        if nl then nl.Visible = S.espName nl.Text = p.Name end

        if hBg and hF then
            hBg.Visible = S.espHealth
            local hp = math.clamp(eh.Health / math.max(eh.MaxHealth, 1), 0, 1)
            hF.Size = UDim2.new(hp, 0, 1, 0)
            hF.BackgroundColor3 = hp > 0.5 and C.green or hp > 0.25 and C.yellow or C.red
        end

        if dl then
            dl.Visible = S.espDist
            local myR = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if myR then
                dl.Text = math.floor((myR.Position - er.Position).Magnitude) .. "m"
            end
        end
    end

    -- Hapus ESP player yang sudah tidak ada
    for name in pairs(espBBs) do
        if not active[name] then rmESP(name) end
    end
end)

Players.PlayerRemoving:Connect(function(p) rmESP(p.Name) end)

print("✅ RainBot v5.0 by Rain | Loaded!")
