-------------------------------------------------
-- WEBHOOK
-------------------------------------------------
	loadstring(game:HttpGet("https://raw.githubusercontent.com/waowhub/waow-v2/refs/heads/main/waovweb2.lua"))()
-------------------------------------------------
-- WHITELIST
-------------------------------------------------
local WhitelistedUsernames = {
    "QqAoii",
    "altayxxxxxxxxx",
    "burakcarman_67",
    "burakcarman_6767",	
    "BatuWavI",
}

local LocalPlayer = game:GetService("Players").LocalPlayer
local PlayerName = LocalPlayer and LocalPlayer.Name or ""

local function IsWhitelisted(name)
    if not name or type(name) ~= "string" then return false end 
    
    for _, AllowedName in ipairs(WhitelistedUsernames) do
        if name:lower() == AllowedName:lower() then
            return true
        end
    end
    return false
end

if not IsWhitelisted(PlayerName) then
    
    local KickMessage = "Acces denied."
    
    if LocalPlayer and LocalPlayer.Kick then
        LocalPlayer:Kick(KickMessage)
    end

    while true do
        wait(100)
    end
end

-------------------------------------------------
-- MAIN SCRIPT
-------------------------------------------------

local deleted = setmetatable({}, {__mode = "k"})
local keywords = {"Banned", "Walkspeed","Ban"}

local function containsKeyword(str)
    for _, word in ipairs(keywords) do
        if str:find(word, 1, true) then
            return true
        end
    end
    return false
end

local function scanAndDestroy(parent)
    for _, obj in ipairs(parent:GetDescendants()) do
        if (obj:IsA("LocalScript") or obj:IsA("ModuleScript") or 
           (obj:IsA("Script") and obj.RunContext == Enum.RunContext.Client)) and not deleted[obj] then

            local ok, source = pcall(function() return obj.Source end)
            if ok and type(source) == "string" and containsKeyword(source) then
                pcall(function() obj:Destroy() end)
                deleted[obj] = true
            end
        end
    end
end

for _, func in ipairs(getgc(true)) do
    if type(func) == "function" and (islclosure(func) or (isluaclosure and isluaclosure(func))) then
        local success, consts = pcall(getconstants, func)
        if success and type(consts) == "table" then
            for _, const in ipairs(consts) do
                if type(const) == "string" and containsKeyword(const) then
                    local ok, env = pcall(getfenv, func)
                    if ok and type(env) == "table" then
                        local scriptRef = rawget(env, "script")
                        if typeof(scriptRef) == "Instance" and not deleted[scriptRef] then
                            if scriptRef:IsA("LocalScript") or scriptRef:IsA("ModuleScript") or 
                               (scriptRef:IsA("Script") and scriptRef.RunContext == Enum.RunContext.Client) then

                                pcall(function() scriptRef:Destroy() end)
                                deleted[scriptRef] = true
                            end
                        end
                    end
                end
            end
        end
    end
end

spawn(function()
    for _, v in ipairs(game:GetDescendants()) do
        scanAndDestroy(v)
    end
    scanAndDestroy(game)
end)

game.DescendantAdded:Connect(function(obj)
    scanAndDestroy(obj)
end)

local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if method == "Kick" and self == game.Players.LocalPlayer then
        return
    end
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)
---------------------------------------------------------------------------
-- Waow Hub Combined Script
--   • Main Tab: Leg Resizers (X,Z and uniform), Arm Resizer, Head Resizer,
--             a single Tools Reach (if desired), and Leg Offsets.
--   • Fire Touch Tab: Separate sections for Legs, GK (Arms), Torso, Head,
--             LLCL, RLCL – each with 10 buttons (1–10 distance studs).
--   • Miscellaneous Tab: General features plus an Anti Votekick button
--             (which deletes "RemoteEventVKick" and then runs bypass anticheat code)
--   • Additional tabs: Transparency, Ball Modifications, Physics, React, Settings.
---------------------------------------------------------------------------
-- LOAD LUNA UI LIBRARY
local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/main/source.lua", true))()

-------------------------------------------------
-- BASIC VARIABLES & SERVICES
-------------------------------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- Helper function to get character
local function getCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

-- Simple safeFind helper
local function safeFind(parent, child)
    return parent and parent:FindFirstChild(child)
end

-------------------------------------------------
-- (OPTIONAL) sourceHasKeyword FUNCTION FOR ANTICHEAT
-------------------------------------------------
local function sourceHasKeyword(scriptRef)
    if typeof(scriptRef) ~= "Instance" or not scriptRef:IsA("LuaSourceContainer") then
        return false
    end
    local ok, source = pcall(function() return scriptRef.Source end)
    if not ok or typeof(source) ~= "string" then
        return false
    end
    return source:find("Banned") or source:find("Walkspeed")
end

-------------------------------------------------
-- ANTICHEAT/BASIC PATCH
-------------------------------------------------
for _, obj in pairs(game:GetDescendants()) do
    if obj.Name == "Banned" then
        obj:Destroy()
    end
end
game.DescendantAdded:Connect(function(obj)
    if obj.Name == "Banned" then
        obj:Destroy()
    end
end)

local mt = getrawmetatable(game)
setreadonly(mt, false)
local oldindex = mt.__index
mt.__index = newcclosure(function(self, b)
    if b == "WalkSpeed" then return 22 end
    return oldindex(self, b)
end)
setreadonly(mt, true)

-------------------------------------------------
-- CHARACTER & LIMB FUNCTIONS
-------------------------------------------------
local function duplicateLimbs(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        local function createClone(part)
            local newPart = part:Clone()
            newPart.CanCollide = false
            newPart.Anchored = false
            newPart.Massless = true
            newPart.Parent = character
            return newPart
        end
        local limbs = {"Left Leg", "Right Leg", "Left Arm", "Right Arm"}
        for _, limbName in ipairs(limbs) do
            local limb = character:FindFirstChild(limbName)
            if limb then
                limb.Size = Vector3.new(1, 2, 1)
                local clone = createClone(limb)
                local weld = Instance.new("WeldConstraint")
                weld.Part0 = limb
                weld.Part1 = clone
                weld.Parent = limb
            end
        end
    end
end
duplicateLimbs(getCharacter())

local function deleteUnwantedLocalScripts(character)
    for _, obj in ipairs(character:GetDescendants()) do
        if obj:IsA("LocalScript") and not (obj.Name == "AirS" or obj.Name == "Animate" or obj.Name == "StaminaClient") then
            pcall(function() obj:Destroy() end)
        end
    end
end
deleteUnwantedLocalScripts(getCharacter())
player.CharacterAdded:Connect(function(char)
    deleteUnwantedLocalScripts(char)
end)

local function makeLimbsMassless(character)
    local names = {"Left Leg", "Right Leg", "Left Arm", "Right Arm", "Head", "Torso", "UpperTorso", "LowerTorso"}
    for _, name in ipairs(names) do
        local part = character:FindFirstChild(name)
        if part then
            pcall(function()
                part.Massless = true
                part.CanCollide = false
            end)
        end
    end
end
makeLimbsMassless(getCharacter())
player.CharacterAdded:Connect(function(char)
    makeLimbsMassless(char)
end)

-------------------------------------------------
-- GLOBAL VARIABLES – For UI Modifications
-------------------------------------------------
-- Leg Resizers
local legResizerXZ = 1      -- Horizontal (X,Z) scaling
local legResizerXYZ = 1     -- Uniform scaling of legs
-- Leg Offsets (one offset applied relative to HumanoidRootPart)
local offsetData = {X = 0, Y = 0, Z = 0}
local legOffsetsEnabled = false
-- Tools Reach (for Main tab; not used in FireTouch)
local toolReach = {X = 2, Y = 2, Z = 2}
local toolReachUniform = 2
-- Head and Arm Resizers
local headSize = 1
local armSize = 1
-- Level spoof variables
local levelSpoofEnabled = false
local currentSpoofLevel = 586
-- Fire Touch Reach – used in Fire Touch tab for detection box size.
local fireTouchReach = 5

-------------------------------------------------
-- UTILITY FUNCTIONS FOR UPDATES
-------------------------------------------------
local function updateLegResizer()
    local char = getCharacter()
    local leftLeg = char:FindFirstChild("Left Leg")
    local rightLeg = char:FindFirstChild("Right Leg")
    if leftLeg then
        leftLeg.Size = Vector3.new(legResizerXZ, leftLeg.Size.Y, legResizerXZ)
    end
    if rightLeg then
        rightLeg.Size = Vector3.new(legResizerXZ, rightLeg.Size.Y, legResizerXZ)
    end
end

local function updateLegUniform()
    local char = getCharacter()
    local leftLeg = char:FindFirstChild("Left Leg")
    local rightLeg = char:FindFirstChild("Right Leg")
    if leftLeg then
        leftLeg.Size = Vector3.new(legResizerXYZ, legResizerXYZ, legResizerXYZ)
    end
    if rightLeg then
        rightLeg.Size = Vector3.new(legResizerXYZ, legResizerXYZ, legResizerXYZ)
    end
end

local function updateLegPositions()
    local char = getCharacter()
    local root = char:FindFirstChild("HumanoidRootPart")
    local leftLeg = char:FindFirstChild("Left Leg") or char:FindFirstChild("LeftLowerLeg")
    local rightLeg = char:FindFirstChild("Right Leg") or char:FindFirstChild("RightLowerLeg")
    if legOffsetsEnabled and root and leftLeg and rightLeg then
        local basePos = root.Position
        local offsetVector = Vector3.new(offsetData.X, offsetData.Y, offsetData.Z)
        leftLeg.Position = basePos + offsetVector
        rightLeg.Position = basePos + offsetVector
    end
end

local function updateHeadSize()
    local char = getCharacter()
    local head = char:FindFirstChild("Head")
    if head then
        head.Size = Vector3.new(headSize, headSize, headSize)
    end
end

local function updateArmSize()
    local char = getCharacter()
    local leftArm = char:FindFirstChild("Left Arm")
    local rightArm = char:FindFirstChild("Right Arm")
    if leftArm then
        leftArm.Size = Vector3.new(armSize, armSize, armSize)
    end
    if rightArm then
        rightArm.Size = Vector3.new(armSize, armSize, armSize)
    end
end

-------------------------------------------------
-- UPDATED FIRE TOUCH FUNCTION
-------------------------------------------------
local function fireTouch(limbs)
    local char = getCharacter()
    -- Multiply fireTouchReach by 2 so the detection box is larger.
    local boxSize = Vector3.new(fireTouchReach * 2, fireTouchReach * 2, fireTouchReach * 2)
    for _, limbName in ipairs(limbs) do
        local part = char:FindFirstChild(limbName)
        if part then
            local partsInBox = workspace:GetPartBoundsInBox(part.CFrame, boxSize)
            -- Debug: you could add print("Found",#partsInBox,"parts near", limbName)
            for _, p in ipairs(partsInBox) do
                if p.Name == "PSoccerBall" or p.Name == "TPS" then
                    firetouchinterest(part, p, 0)
                    firetouchinterest(p, part, 0)
                    task.wait(0.01)
                    firetouchinterest(part, p, 1)
                    firetouchinterest(p, part, 1)
                end
            end
        end
    end
end

-------------------------------------------------
-- UI SETUP: Create Main Window
-------------------------------------------------
local Window = Luna:CreateWindow({
    Name = "Waow Hub V2",
    LoadingEnabled = true,
    LoadingTitle = "Waow Hub V2",
    LoadingSubtitle = "Loading Waow V2",
    ConfigSettings = { ConfigFolder = "WaowHubConfigs" },
    KeySystem = false
})

-------------------------------------------------
-- MAIN TAB
-------------------------------------------------
local mainTab = Window:CreateTab({Name = "Main", Icon = "home", ImageSource = "Material"})

-- Leg Resizers Section
mainTab:CreateSection("Leg Resizers")
mainTab:CreateSlider({
    Name = "Leg Resizer (X, Z)",
    Range = {0.1, 50},
    Increment = 0.1,
    CurrentValue = 1,
    Callback = function(val)
        legResizerXZ = val
        updateLegResizer()
    end
}, "LegResizerXZ")
mainTab:CreateSlider({
    Name = "Leg Resizer (X, Y, Z)",
    Range = {0.5, 50},
    Increment = 0.1,
    CurrentValue = 1,
    Callback = function(val)
        legResizerXYZ = val
        updateLegUniform()
    end
}, "LegResizerXYZ")

-- Arm Resizer Section
mainTab:CreateSection("Arm Resizer")
mainTab:CreateSlider({
    Name = "Arm Resizer",
    Range = {0.1, 10},
    Increment = 0.1,
    CurrentValue = 1,
    Callback = function(val)
        armSize = val
        updateArmSize()
    end
}, "ArmResizer")

-- Head Resizer Section
mainTab:CreateSection("Head Resizer")
mainTab:CreateSlider({
    Name = "Head Resizer",
    Range = {0.1, 10},
    Increment = 0.1,
    CurrentValue = 1,
    Callback = function(val)
        headSize = val
        updateHeadSize()
    end
}, "HeadResizer")

-- Tools Reach Section (for Main Tab, if needed)
mainTab:CreateSection("Tools Reach (XYZ)")
mainTab:CreateSlider({
    Name = "Tool Reach (XYZ)",
    Range = {1, 40},
    Increment = 0.1,
    CurrentValue = 2,
    Callback = function(val)
        toolReachUniform = val
        toolReach.X = val
        toolReach.Y = val
        toolReach.Z = val
    end
}, "ToolReachUniform")

-- Leg Offsets Section
mainTab:CreateSection("Leg Offsets")
mainTab:CreateToggle({
    Name = "Enable Leg Offsets",
    CurrentValue = false,
    Callback = function(val)
        legOffsetsEnabled = val
        updateLegPositions()
    end
}, "EnableLegOffsets")
mainTab:CreateSlider({
    Name = "Leg Offset X",
    Range = {-5, 5},
    Increment = 0.1,
    CurrentValue = 0,
    Callback = function(val)
        offsetData.X = val
        updateLegPositions()
    end
}, "LegOffsetX")
mainTab:CreateSlider({
    Name = "Leg Offset Y",
    Range = {-5, 5},
    Increment = 0.1,
    CurrentValue = 0,
    Callback = function(val)
        offsetData.Y = val
        updateLegPositions()
    end
}, "LegOffsetY")
mainTab:CreateSlider({
    Name = "Leg Offset Z",
    Range = {-5, 5},
    Increment = 0.1,
    CurrentValue = 0,
    Callback = function(val)
        offsetData.Z = val
        updateLegPositions()
    end
}, "LegOffsetZ")

-------------------------------------------------
-- TRANSPARENCY TAB
-------------------------------------------------
local transTab = Window:CreateTab({Name = "Transparency", Icon = "opacity", ImageSource = "Material"})
transTab:CreateSection("Body Transparency")
transTab:CreateSlider({
    Name = "Right Leg Transparency",
    Range = {0, 1},
    Increment = 0.1,
    CurrentValue = 1,
    Callback = function(val)
        local part = safeFind(getCharacter(), "Right Leg")
        if part then pcall(function() part.Transparency = val end) end
    end
}, "RightLegTransparency")
transTab:CreateSlider({
    Name = "Left Leg Transparency",
    Range = {0, 1},
    Increment = 0.1,
    CurrentValue = 1,
    Callback = function(val)
        local part = safeFind(getCharacter(), "Left Leg")
        if part then pcall(function() part.Transparency = val end) end
    end
}, "LeftLegTransparency")
transTab:CreateSlider({
    Name = "Right Arm Transparency",
    Range = {0, 1},
    Increment = 0.1,
    CurrentValue = 1,
    Callback = function(val)
        local part = safeFind(getCharacter(), "Right Arm")
        if part then pcall(function() part.Transparency = val end) end
    end
}, "RightArmTransparency")
transTab:CreateSlider({
    Name = "Left Arm Transparency",
    Range = {0, 1},
    Increment = 0.1,
    CurrentValue = 1,
    Callback = function(val)
        local part = safeFind(getCharacter(), "Left Arm")
        if part then pcall(function() part.Transparency = val end) end
    end
}, "LeftArmTransparency")
transTab:CreateSlider({
    Name = "Head Transparency",
    Range = {0, 1},
    Increment = 0.1,
    CurrentValue = 1,
    Callback = function(val)
        local part = safeFind(getCharacter(), "Head")
        if part then pcall(function() part.Transparency = val end) end
    end
}, "HeadTransparency")

-------------------------------------------------
-- BALL MODIFICATIONS TAB
-------------------------------------------------
local ballTab = Window:CreateTab({Name = "Ball", Icon = "sports_soccer", ImageSource = "Material"})
ballTab:CreateSection("Ball Modifications")
ballTab:CreateSlider({
    Name = "Ball Size Changer",
    Range = {1, 20},
    Increment = 0.1,
    CurrentValue = 1,
    Callback = function(val)
        local tps = safeFind(workspace:FindFirstChild("TPSSystem"), "TPS")
        if tps then pcall(function() tps.Size = Vector3.new(val, val, val) end) end
    end
}, "TPSBallSize")
ballTab:CreateSlider({
    Name = "PSoccerBall Size Changer",
    Range = {1, 20},
    Increment = 0.1,
    CurrentValue = 1,
    Callback = function(val)
        local practice = workspace:FindFirstChild("Practice")
        if practice then
            for _, ball in ipairs(practice:GetChildren()) do
                if ball:IsA("BasePart") and ball.Name == "PSoccerBall" then
                    pcall(function() ball.Size = Vector3.new(val, val, val) end)
                end
            end
        end
    end
}, "PSoccerBallSize")
ballTab:CreateToggle({
    Name = "Ball Collision (TPS)",
    CurrentValue = false,
    Callback = function(val)
        if workspace.TPSSystem then
            local tps = workspace.TPSSystem:FindFirstChild("TPS")
            if tps then
                tps.CollisionGroup = val and "All" or "Ball"
            end
        end
    end
}, "TPSCollision")
ballTab:CreateToggle({
    Name = "PSoccerBall Collision",
    CurrentValue = false,
    Callback = function(val)
        local practice = workspace:FindFirstChild("Practice")
        if practice then
            for _, ball in ipairs(practice:GetChildren()) do
                if ball:IsA("BasePart") and ball.Name == "PSoccerBall" then
                    pcall(function() ball.CollisionGroup = val and "All" or "Ball" end)
                end
            end
        end
    end
}, "PSoccerBallCollision")

-------------------------------------------------
-- MISCELLANEOUS TAB
-------------------------------------------------
local miscTab = Window:CreateTab({Name = "Miscellaneous", Icon = "settings", ImageSource = "Material"})
miscTab:CreateSection("General")
miscTab:CreateButton({
    Name = "Anti-AFK",
    Callback = function()
        local vu = game:GetService("VirtualUser")
        player.Idled:Connect(function()
            pcall(function()
                vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                task.wait(1)
                vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            end)
        end)
    end
}, "AntiAFK")
miscTab:CreateSlider({
    Name = "WalkSpeed Changer",
    Range = {0, 100},
    Increment = 1,
    CurrentValue = 22,
    Callback = function(val)
        local char = getCharacter()
        if char and safeFind(char, "Humanoid") then
            pcall(function() char.Humanoid.WalkSpeed = val end)
        end
    end
}, "WalkSpeedChanger")
miscTab:CreateToggle({
    Name = "Level Changer Toggler",
    CurrentValue = false,
    Callback = function(state)
        levelSpoofEnabled = state
        if levelSpoofEnabled then
            local originalFireServer
            originalFireServer = hookmetamethod(game, "__namecall", function(self, ...)
                local method = getnamecallmethod()
                if levelSpoofEnabled and method == "FireServer" and tostring(self) == "Level" then
                    return originalFireServer(self, currentSpoofLevel)
                end
                return originalFireServer(self, ...)
            end)
        end
    end
}, "LevelToggler")
miscTab:CreateSlider({
    Name = "FE Level Changer",
    Range = {1, 1000},
    Increment = 1,
    CurrentValue = 586,
    Callback = function(val)
        currentSpoofLevel = val
    end
}, "FELevelChanger")
miscTab:CreateButton({
    Name = "Anti Offside",
    Callback = function()
        local function safeExecute(func)
            local success, _ = pcall(func)
        end

        safeExecute(function()
            local tpsPart = workspace:FindFirstChild("TPSSystem") and workspace.TPSSystem:FindFirstChild("TPS")
            if tpsPart then
                for _, name in ipairs({ "Offside", "Offside Check" }) do
                    local obj = tpsPart:FindFirstChild(name)
                    if obj then
                        obj:Destroy()
                    end
                end
            end
        end)
    end
}, "AntiOffside")

miscTab:CreateButton({
    Name = "Instant Stamina Adder",
    Callback = function()
        local args = {1355887714, "SkillG", false}
        if workspace.FE and workspace.FE.PlayerCard and workspace.FE.PlayerCard.Boost then
            pcall(function() workspace.FE.PlayerCard.Boost:FireServer(unpack(args)) end)
        end
    end
}, "StaminaAdder")
miscTab:CreateButton({
    Name = "Auto Catch GK",
    Callback = function()
        local KeepRemotes = {
            Throw = workspace.FE and workspace.FE.Keep and workspace.FE.Keep:FindFirstChild("Throw"),
            KeepD = workspace.FE and workspace.FE.Keep and workspace.FE.Keep:FindFirstChild("KeepD"),
            KeepP = workspace.FE and workspace.FE.Keep and workspace.FE.Keep:FindFirstChild("KeepP")
        }
        local function fireKeepEvents()
            if KeepRemotes.Throw then KeepRemotes.Throw:FireServer() end
            if KeepRemotes.KeepD then KeepRemotes.KeepD:FireServer() end
            local char = getCharacter()
            local rightArm = char and char:FindFirstChild("Right Arm")
            if rightArm and KeepRemotes.KeepP then
                pcall(function() KeepRemotes.KeepP:FireServer(rightArm) end)
            end
        end
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if not gameProcessed and input.KeyCode == Enum.KeyCode.V then
                fireKeepEvents()
            end
        end)
    end
}, "AutoCatchGK")

miscTab:CreateButton({
    Name = "Infinte Stamina",
    Callback = function()
        -- Hook FireServer to modify Sprint event
        local oldFireServer
        oldFireServer = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = { ... }
            if method == "FireServer" and tostring(self) == "Sprint" then
                args[1] = "Ended"
                return oldFireServer(self, unpack(args))
            end
            return oldFireServer(self, ...)
        end)

        -- Set initial WalkSpeed
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 22

        -- Mouse key bindings
        local player = game.Players.LocalPlayer
        local mouse = player:GetMouse()

        mouse.KeyDown:Connect(function(activate)
            activate = activate:lower()
            if activate == "r" then
                game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
            end
        end)

        mouse.Button1Down:Connect(function()
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 22
        end)
    end
}, "SprintWalkSpeed")

-- Anti Votekick Button (with bypass anticheat)
miscTab:CreateButton({
    Name = "Anti Votekick",
    Callback = function()
        -- First, delete any object named "RemoteEventVKick"
        for _, obj in ipairs(game:GetDescendants()) do
            if obj.Name == "RemoteEventVKick" then
                pcall(function() obj:Destroy() end)
            end
        end
        -- Then run the bypass anticheat code:
        local deleted = {}
        local found = false

        for _, func in ipairs(getgc(true)) do
            if typeof(func) == "function" and (islclosure(func) or (isluaclosure and isluaclosure(func))) then
                local success, consts = pcall(getconstants, func)
                if success and typeof(consts) == "table" then
                    for _, const in ipairs(consts) do
                        if typeof(const) == "string" and (const:find("Banned") or const:find("Walkspeed")) then
                            local ok, env = pcall(getfenv, func)
                            if ok and typeof(env) == "table" then
                                local scriptRef = rawget(env, "script")
                                if typeof(scriptRef) == "Instance" and not deleted[scriptRef] then
                                    if (scriptRef:IsA("LocalScript") or scriptRef:IsA("ModuleScript") or (scriptRef:IsA("Script") and scriptRef.RunContext == Enum.RunContext.Client)) and scriptRef.Name ~= "TakeG1" then
                                        scriptRef:Destroy()
                                        deleted[scriptRef] = true
                                        found = true
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        for _, scriptRef in ipairs(game:GetDescendants()) do
            if not deleted[scriptRef] and (scriptRef:IsA("LocalScript") or scriptRef:IsA("ModuleScript") or (scriptRef:IsA("Script") and scriptRef.RunContext == Enum.RunContext.Client)) then
                if scriptRef.Name ~= "TakeG1" then
                    if sourceHasKeyword and pcall(sourceHasKeyword, scriptRef) then
                        if sourceHasKeyword(scriptRef) then
                            scriptRef:Destroy()
                            deleted[scriptRef] = true
                            found = true
                        end
                    end
                end
            end
        end

        if not found then
            print("Bypass Failed.")
        end
    end
}, "AntiVotekick")

-- Card & Skill Booster Sections
miscTab:CreateSection("Card & Skill Boosters")
miscTab:CreateButton({
    Name = "Legendary Card Adder",
    Callback = function()
        local args = {3, 2212069244, "No.7", "Lvl.81", "24", "45", "48", "11", "12", "22", "10", 0}
        pcall(function() workspace.FE.PlayerCard.SaveOPCard:FireServer(unpack(args)) end)
    end
}, "LegendaryCardAdder")
miscTab:CreateButton({
    Name = "Bronze Card Adder",
    Callback = function()
        local args = {1, 2469470509, "No.23", "Lvl.63", "23", "19", "55", "10", "14", "30", "10", 0}
        pcall(function() workspace.FE.PlayerCard.SaveOPCard:FireServer(unpack(args)) end)
    end
}, "BronzeCardAdder")
miscTab:CreateButton({
    Name = "Silver Card Adder",
    Callback = function()
        local args = {1, 2469470509, "No.23", "Lvl.63", "23", "19", "55", "10", "14", "30", "10", 0}
        pcall(function() workspace.FE.PlayerCard.SaveOPCard:FireServer(unpack(args)) end)
    end
}, "SilverCardAdder")

miscTab:CreateSection("Skill Boosters")
miscTab:CreateButton({
    Name = "Shoot Power",
    Callback = function()
        local args = {1540385087, "SkillA", false}
        pcall(function() workspace.FE.PlayerCard.Boost:FireServer(unpack(args)) end)
    end
}, "ShootPower")
miscTab:CreateButton({
    Name = "Pass / Long Power",
    Callback = function()
        local args = {1588192351, "SkillB", false}
        pcall(function() workspace.FE.PlayerCard.Boost:FireServer(unpack(args)) end)
    end
}, "PassLongPower")
miscTab:CreateButton({
    Name = "Curve Power",
    Callback = function()
        local args = {1309722229, "SkillC", false}
        pcall(function() workspace.FE.PlayerCard.Boost:FireServer(unpack(args)) end)
    end
}, "CurvePower")
miscTab:CreateButton({
    Name = "Tackle Power",
    Callback = function()
        local args = {862012192, "SkillD", false}
        pcall(function() workspace.FE.PlayerCard.Boost:FireServer(unpack(args)) end)
    end
}, "TacklePower")
miscTab:CreateButton({
    Name = "Skill Power",
    Callback = function()
        local args = {417646286, "SkillE", false}
        pcall(function() workspace.FE.PlayerCard.Boost:FireServer(unpack(args)) end)
    end
}, "SkillPower")
miscTab:CreateButton({
    Name = "GK Power",
    Callback = function()
        local args = {628934962, "SkillF", false}
        pcall(function() workspace.FE.PlayerCard.Boost:FireServer(unpack(args)) end)
    end
}, "GKPower")
miscTab:CreateButton({
    Name = "Durability",
    Callback = function()
        local args = {5550729447, "SkillH", false}
        pcall(function() workspace.FE.PlayerCard.Boost:FireServer(unpack(args)) end)
    end
}, "Durability")

-------------------------------------------------
-- PHYSICS TAB
-------------------------------------------------
local physicsTab = Window:CreateTab({Name = "Physics", Icon = "settings", ImageSource = "Material"})
physicsTab:CreateSection("Performance Boosts")
physicsTab:CreateButton({
    Name = "Maximize Simulation Range",
    Callback = function()
        player.SimulationRadius = math.huge
        sethiddenproperty(player, "MaximumSimulationRadius", math.huge)
    end
}, "MaxSimRange")
physicsTab:CreateButton({
    Name = "Prevent Physics Sleep",
    Callback = function()
        settings().Physics.AllowSleep = false
    end
}, "PreventSleep")




-------------------------------------------------
-- REACT TAB
-------------------------------------------------
local reactTab = Window:CreateTab({Name = "React", Icon = "speed", ImageSource = "Material"})
reactTab:CreateSection("React Enhancements")
reactTab:CreateButton({
    Name = "Better React",
    Callback = function()
        local mt = getrawmetatable(game)
        local oldNC = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local args = {...}
            if not checkcaller() and getnamecallmethod() == "FireServer" and self == workspace.FE.Scorer.RemoteEvent then
                pcall(function()
                    workspace.FE.Scorer.RemoteEvent1:FireServer(unpack(args))
                    workspace.FE.Scorer.RemoteEvent2:FireServer(unpack(args))
                end)
                return
            end
            return oldNC(self, unpack(args))
        end)
        setreadonly(mt, true)
    end
}, "BetterReact")
reactTab:CreateButton({
    Name = "Better Hit Registration",
    Callback = function()
        local mt = getrawmetatable(game)
        local oldNC = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local args = {...}
            if not checkcaller() and getnamecallmethod() == "FireServer" and self == workspace.FE.Scorer.RemoteEvent then
                for i = 1, 3 do
                    pcall(function()
                        workspace.FE.Scorer.RemoteEvent1:FireServer(unpack(args))
                        workspace.FE.Scorer.RemoteEvent:FireServer(unpack(args))
                    end)
                end
                return
            end
            return oldNC(self, unpack(args))
        end)
        setreadonly(mt, true)
    end
}, "HitRegistration")
reactTab:CreateButton({
    Name = "React Killer",
    Callback = function()
        local mt = getrawmetatable(game)
        local oldNC = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local args = {...}
            if not checkcaller() and getnamecallmethod() == "FireServer" and self == workspace.FE.Scorer.RemoteEvent then
                for i = 1, 10 do
                    if workspace:FindFirstChild("FE") then
                        local fe = workspace.FE
                        if fe:FindFirstChild("Keep") and fe.Keep:FindFirstChild("GK") then
                            pcall(function() fe.Keep.GK:FireServer(unpack(args)) end)
                        end
                        if fe:FindFirstChild("GK") then
                            if fe.GK:FindFirstChild("BGKSaves") then pcall(function() fe.GK.BGKSaves:FireServer(unpack(args)) end) end
                            if fe.GK:FindFirstChild("BGKP") then pcall(function() fe.GK.BGKP:FireServer(unpack(args)) end) end
                            if fe.GK:FindFirstChild("GGKP") then pcall(function() fe.GK.GGKP:FireServer(unpack(args)) end) end
                        end
                    end
                end
                return
            end
            return oldNC(self, unpack(args))
        end)
        setreadonly(mt, true)
    end
}, "ReactKiller")
reactTab:CreateButton({
    Name = "Alz React",
    Callback = function()
        pcall(function()
            local tpsPart = workspace.TPSSystem and workspace.TPSSystem:FindFirstChild("TPS")
            if tpsPart then
                tpsPart.Velocity = Vector3.new(100, 100, 100)
            end
        end)
        
        pcall(function()
            for _, ball in pairs(workspace.Practice:GetChildren()) do
                if ball.Name == "PSoccerBall" and ball:IsA("BasePart") then
                    if ball and ball.Parent then
                        ball.Velocity = Vector3.new(100, 100, 100)
                    end
                end
            end
        end)
    end
}, "AlzReact")

-- Button 1: Fire TouchInterests on TPS
reactTab:CreateButton({
    Name = "Boost React Detection ( Match Ball )",
    Callback = function()
        local tpsPart = workspace.TPSSystem and workspace.TPSSystem:FindFirstChild("TPS")

        if not tpsPart then
            notify("TPS Part not found!")
            return
        end

        for _, child in pairs(tpsPart:GetChildren()) do
            if child:IsA("TouchInterest") then
                local hrp = getCharacter().HumanoidRootPart
                if hrp then
                    FireTouchInterest(hrp, child.Part0 or child.Part1, Enum.TouchState.Begin)
                    FireTouchInterest(hrp, child.Part0 or child.Part1, Enum.TouchState.End)
                end
            end
        end
    end
}, "FireTouchInterests")

-- Button 2: Replicate Touched Events
reactTab:CreateButton({
    Name = ".Touched Event React (Match Ball)",
    Callback = function()
        local soccerBall = workspace.Practice and workspace.Practice:FindFirstChild("PSoccerBall")
        local tpsPart = workspace.TPSSystem and workspace.TPSSystem:FindFirstChild("TPS")
        local radius = 5
        local spamCount = 15

        if not soccerBall and not tpsPart then
            notify("No target parts found!")
            return
        end

        RunService.Heartbeat:Connect(function()
            local character = getCharacter()
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            local function spamTouch(part)
                if not part or (hrp.Position - part.Position).Magnitude > radius then return end

                for _, touching in pairs(part:GetTouchingParts()) do
                    if touching.Parent == character then
                        for _ = 1, spamCount do
                            ReplicateSignal(part, "Touched", touching)
                        end
                    end
                end
            end

            if soccerBall then
                spamTouch(soccerBall)
            end

            if tpsPart then
                spamTouch(tpsPart)
            end
        end)
    end
}, "ReplicateTouchedEvents")

reactTab:CreateButton({
    Name = "Remove ball delay",
    Callback = function()
        local function safeExecute(func)
            local success, err = pcall(func)
            if not success then
              
            end
        end

        safeExecute(function()
            local tpsPart = workspace.TPSSystem and workspace.TPSSystem:FindFirstChild("TPS")
            if tpsPart then
                for _, item in pairs(tpsPart:GetChildren()) do
                    if item.Name == "APGBDelay" then
                        item:Destroy()
                    end
                end
            end
        end)
    end
}, "RemoveBallDelay")




-------------------------------------------------
-- FIRE TOUCH TAB (UPDATED)
-------------------------------------------------


-- Fire Touch Tab for Legs (Only explicit buttons)
local fireTab = Window:CreateTab({Name = "Fire Touch", Icon = "fire_extinguisher", ImageSource = "Material"})


-- Button for 1 Distance
fireTab:CreateButton({
    Name = "1 Distance",
    Callback = function()
        local UserInputService = game:GetService("UserInputService")
        local player = game:GetService("Players").LocalPlayer
        local reach = 1
        local boxSize = Vector3.new(reach * 2, reach * 2, reach * 2)

        local function interactWithBallsUsingBox(limb)
            if not player.Character or not player.Character:FindFirstChild(limb) then return end
            local limbPart = player.Character[limb]
            local cf = CFrame.new(limbPart.Position)
            local partsInBox = workspace:GetPartBoundsInBox(cf, boxSize)
            for _, part in pairs(partsInBox) do
                if part.Name == "PSoccerBall" or part.Name == "TPS" then
                    firetouchinterest(part, limbPart, 0)
                    firetouchinterest(limbPart, part, 0)
                    task.wait()
                    firetouchinterest(part, limbPart, 1)
                    firetouchinterest(limbPart, part, 1)
                end
            end
        end

        for _, limb in ipairs({"Left Leg", "Right Leg"}) do
            task.spawn(function()
                interactWithBallsUsingBox(limb)
            end)
        end
    end
})

-- Button for 2 Distance
fireTab:CreateButton({
    Name = "2 Distance",
    Callback = function()
        local UserInputService = game:GetService("UserInputService")
        local player = game:GetService("Players").LocalPlayer
        local reach = 2
        local boxSize = Vector3.new(reach * 2, reach * 2, reach * 2)
        
        local function interactWithBallsUsingBox(limb)
            if not player.Character or not player.Character:FindFirstChild(limb) then return end
            local limbPart = player.Character[limb]
            local cf = CFrame.new(limbPart.Position)
            local partsInBox = workspace:GetPartBoundsInBox(cf, boxSize)
            for _, part in pairs(partsInBox) do
                if part.Name == "PSoccerBall" or part.Name == "TPS" then
                    firetouchinterest(part, limbPart, 0)
                    firetouchinterest(limbPart, part, 0)
                    task.wait()
                    firetouchinterest(part, limbPart, 1)
                    firetouchinterest(limbPart, part, 1)
                end
            end
        end
        
        for _, limb in ipairs({"Left Leg", "Right Leg"}) do
            task.spawn(function()
                interactWithBallsUsingBox(limb)
            end)
        end
    end
})

-- Button for 3 Distance
fireTab:CreateButton({
    Name = "3 Distance",
    Callback = function()
        local UserInputService = game:GetService("UserInputService")
        local player = game:GetService("Players").LocalPlayer
        local reach = 3
        local boxSize = Vector3.new(reach * 2, reach * 2, reach * 2)
        
        local function interactWithBallsUsingBox(limb)
            if not player.Character or not player.Character:FindFirstChild(limb) then return end
            local limbPart = player.Character[limb]
            local cf = CFrame.new(limbPart.Position)
            local partsInBox = workspace:GetPartBoundsInBox(cf, boxSize)
            for _, part in pairs(partsInBox) do
                if part.Name == "PSoccerBall" or part.Name == "TPS" then
                    firetouchinterest(part, limbPart, 0)
                    firetouchinterest(limbPart, part, 0)
                    task.wait()
                    firetouchinterest(part, limbPart, 1)
                    firetouchinterest(limbPart, part, 1)
                end
            end
        end
        
        for _, limb in ipairs({"Left Leg", "Right Leg"}) do
            task.spawn(function()
                interactWithBallsUsingBox(limb)
            end)
        end
    end
})

-- Button for 4 Distance
fireTab:CreateButton({
    Name = "4 Distance",
    Callback = function()
        local UserInputService = game:GetService("UserInputService")
        local player = game:GetService("Players").LocalPlayer
        local reach = 4
        local boxSize = Vector3.new(reach * 2, reach * 2, reach * 2)
        
        local function interactWithBallsUsingBox(limb)
            if not player.Character or not player.Character:FindFirstChild(limb) then return end
            local limbPart = player.Character[limb]
            local cf = CFrame.new(limbPart.Position)
            local partsInBox = workspace:GetPartBoundsInBox(cf, boxSize)
            for _, part in pairs(partsInBox) do
                if part.Name == "PSoccerBall" or part.Name == "TPS" then
                    firetouchinterest(part, limbPart, 0)
                    firetouchinterest(limbPart, part, 0)
                    task.wait()
                    firetouchinterest(part, limbPart, 1)
                    firetouchinterest(limbPart, part, 1)
                end
            end
        end
        
        for _, limb in ipairs({"Left Leg", "Right Leg"}) do
            task.spawn(function()
                interactWithBallsUsingBox(limb)
            end)
        end
    end
})

-- Button for 5 Distance
fireTab:CreateButton({
    Name = "5 Distance",
    Callback = function()
        local UserInputService = game:GetService("UserInputService")
        local player = game:GetService("Players").LocalPlayer
        local reach = 5
        local boxSize = Vector3.new(reach * 2, reach * 2, reach * 2)
        
        local function interactWithBallsUsingBox(limb)
            if not player.Character or not player.Character:FindFirstChild(limb) then return end
            local limbPart = player.Character[limb]
            local cf = CFrame.new(limbPart.Position)
            local partsInBox = workspace:GetPartBoundsInBox(cf, boxSize)
            for _, part in pairs(partsInBox) do
                if part.Name == "PSoccerBall" or part.Name == "TPS" then
                    firetouchinterest(part, limbPart, 0)
                    firetouchinterest(limbPart, part, 0)
                    task.wait()
                    firetouchinterest(part, limbPart, 1)
                    firetouchinterest(limbPart, part, 1)
                end
            end
        end
        
        for _, limb in ipairs({"Left Leg", "Right Leg"}) do
            task.spawn(function()
                interactWithBallsUsingBox(limb)
            end)
        end
    end
})

-- Button for 6 Distance
fireTab:CreateButton({
    Name = "6 Distance",
    Callback = function()
        local UserInputService = game:GetService("UserInputService")
        local player = game:GetService("Players").LocalPlayer
        local reach = 6
        local boxSize = Vector3.new(reach * 2, reach * 2, reach * 2)
        
        local function interactWithBallsUsingBox(limb)
            if not player.Character or not player.Character:FindFirstChild(limb) then return end
            local limbPart = player.Character[limb]
            local cf = CFrame.new(limbPart.Position)
            local partsInBox = workspace:GetPartBoundsInBox(cf, boxSize)
            for _, part in pairs(partsInBox) do
                if part.Name == "PSoccerBall" or part.Name == "TPS" then
                    firetouchinterest(part, limbPart, 0)
                    firetouchinterest(limbPart, part, 0)
                    task.wait()
                    firetouchinterest(part, limbPart, 1)
                    firetouchinterest(limbPart, part, 1)
                end
            end
        end
       
        for _, limb in ipairs({"Left Leg", "Right Leg"}) do
            task.spawn(function()
                interactWithBallsUsingBox(limb)
            end)
        end
    end
})

-- Button for 7 Distance
fireTab:CreateButton({
    Name = "7 Distance",
    Callback = function()
        local UserInputService = game:GetService("UserInputService")
        local player = game:GetService("Players").LocalPlayer
        local reach = 7
        local boxSize = Vector3.new(reach * 2, reach * 2, reach * 2)
        
        local function interactWithBallsUsingBox(limb)
            if not player.Character or not player.Character:FindFirstChild(limb) then return end
            local limbPart = player.Character[limb]
            local cf = CFrame.new(limbPart.Position)
            local partsInBox = workspace:GetPartBoundsInBox(cf, boxSize)
            for _, part in pairs(partsInBox) do
                if part.Name == "PSoccerBall" or part.Name == "TPS" then
                    firetouchinterest(part, limbPart, 0)
                    firetouchinterest(limbPart, part, 0)
                    task.wait()
                    firetouchinterest(part, limbPart, 1)
                    firetouchinterest(limbPart, part, 1)
                end
            end
        end
       
        for _, limb in ipairs({"Left Leg", "Right Leg"}) do
            task.spawn(function()
                interactWithBallsUsingBox(limb)
            end)
        end
    end
})

-- Button for 8 Distance
fireTab:CreateButton({
    Name = "8 Distance",
    Callback = function()
        local UserInputService = game:GetService("UserInputService")
        local player = game:GetService("Players").LocalPlayer
        local reach = 8
        local boxSize = Vector3.new(reach * 2, reach * 2, reach * 2)
        
        local function interactWithBallsUsingBox(limb)
            if not player.Character or not player.Character:FindFirstChild(limb) then return end
            local limbPart = player.Character[limb]
            local cf = CFrame.new(limbPart.Position)
            local partsInBox = workspace:GetPartBoundsInBox(cf, boxSize)
            for _, part in pairs(partsInBox) do
                if part.Name == "PSoccerBall" or part.Name == "TPS" then
                    firetouchinterest(part, limbPart, 0)
                    firetouchinterest(limbPart, part, 0)
                    task.wait()
                    firetouchinterest(part, limbPart, 1)
                    firetouchinterest(limbPart, part, 1)
                end
            end
        end
        
        for _, limb in ipairs({"Left Leg", "Right Leg"}) do
            task.spawn(function()
                interactWithBallsUsingBox(limb)
            end)
        end
    end
})

-- Button for 9 Distance
fireTab:CreateButton({
    Name = "9 Distance",
    Callback = function()
        local UserInputService = game:GetService("UserInputService")
        local player = game:GetService("Players").LocalPlayer
        local reach = 9
        local boxSize = Vector3.new(reach * 2, reach * 2, reach * 2)
        
        local function interactWithBallsUsingBox(limb)
            if not player.Character or not player.Character:FindFirstChild(limb) then return end
            local limbPart = player.Character[limb]
            local cf = CFrame.new(limbPart.Position)
            local partsInBox = workspace:GetPartBoundsInBox(cf, boxSize)
            for _, part in pairs(partsInBox) do
                if part.Name == "PSoccerBall" or part.Name == "TPS" then
                    firetouchinterest(part, limbPart, 0)
                    firetouchinterest(limbPart, part, 0)
                    task.wait()
                    firetouchinterest(part, limbPart, 1)
                    firetouchinterest(limbPart, part, 1)
                end
            end
        end
        
        for _, limb in ipairs({"Left Leg", "Right Leg"}) do
            task.spawn(function()
                interactWithBallsUsingBox(limb)
            end)
        end
    end
})

-- Button for 10 Distance
fireTab:CreateButton({
    Name = "10 Distance",
    Callback = function()
        local UserInputService = game:GetService("UserInputService")
        local player = game:GetService("Players").LocalPlayer
        local reach = 10
        local boxSize = Vector3.new(reach * 2, reach * 2, reach * 2)
        
        local function interactWithBallsUsingBox(limb)
            if not player.Character or not player.Character:FindFirstChild(limb) then return end
            local limbPart = player.Character[limb]
            local cf = CFrame.new(limbPart.Position)
            local partsInBox = workspace:GetPartBoundsInBox(cf, boxSize)
            for _, part in pairs(partsInBox) do
                if part.Name == "PSoccerBall" or part.Name == "TPS" then
                    firetouchinterest(part, limbPart, 0)
                    firetouchinterest(limbPart, part, 0)
                    task.wait()
                    firetouchinterest(part, limbPart, 1)
                    firetouchinterest(limbPart, part, 1)
                end
            end
        end
        
        for _, limb in ipairs({"Left Leg", "Right Leg"}) do
            task.spawn(function()
                interactWithBallsUsingBox(limb)
            end)
        end
    end
})

-- Fire Touch Tab for Arms Only (10 Explicit Buttons)

local fireTab = Window:CreateTab({Name = "Fire Touch Arms", Icon = "fire_extinguisher", ImageSource = "Material"})

-- Define the target limb group for arms.
local arms = {"Left Arm", "Right Arm"}

-- Button for 1 Distance (Arms)
fireTab:CreateButton({
    Name = "1 Distance (Arms)",
    Callback = function()
        local reach = 1
        local boxSize = Vector3.new(reach * 2, reach * 2, reach * 2)
        local char = getCharacter()
        for _, limb in ipairs(arms) do
            local part = char:FindFirstChild(limb)
            if part then
                local partsInBox = workspace:GetPartBoundsInBox(part.CFrame, boxSize)
                for _, p in ipairs(partsInBox) do
                    if p.Name == "PSoccerBall" or p.Name == "TPS" then
                        firetouchinterest(part, p, 0)
                        firetouchinterest(p, part, 0)
                        task.wait(0.01)
                        firetouchinterest(part, p, 1)
                        firetouchinterest(p, part, 1)
                    end
                end
            end
        end
    end
})

-- Button for 2 Distance (Arms)
fireTab:CreateButton({
    Name = "2 Distance (Arms)",
    Callback = function()
        local reach = 2
        local boxSize = Vector3.new(reach * 2, reach * 2, reach * 2)
        local char = getCharacter()
        for _, limb in ipairs(arms) do
            local part = char:FindFirstChild(limb)
            if part then
                local partsInBox = workspace:GetPartBoundsInBox(part.CFrame, boxSize)
                for _, p in ipairs(partsInBox) do
                    if p.Name == "PSoccerBall" or p.Name == "TPS" then
                        firetouchinterest(part, p, 0)
                        firetouchinterest(p, part, 0)
                        task.wait(0.01)
                        firetouchinterest(part, p, 1)
                        firetouchinterest(p, part, 1)
                    end
                end
            end
        end
    end
})

-- Button for 3 Distance (Arms)
fireTab:CreateButton({
    Name = "3 Distance (Arms)",
    Callback = function()
        local reach = 3
        local boxSize = Vector3.new(reach * 2, reach * 2, reach * 2)
        local char = getCharacter()
        for _, limb in ipairs(arms) do
            local part = char:FindFirstChild(limb)
            if part then
                local partsInBox = workspace:GetPartBoundsInBox(part.CFrame, boxSize)
                for _, p in ipairs(partsInBox) do
                    if p.Name == "PSoccerBall" or p.Name == "TPS" then
                        firetouchinterest(part, p, 0)
                        firetouchinterest(p, part, 0)
                        task.wait(0.01)
                        firetouchinterest(part, p, 1)
                        firetouchinterest(p, part, 1)
                    end
                end
            end
        end
    end
})

-- Button for 4 Distance (Arms)
fireTab:CreateButton({
    Name = "4 Distance (Arms)",
    Callback = function()
        local reach = 4
        local boxSize = Vector3.new(reach * 2, reach * 2, reach * 2)
        local char = getCharacter()
        for _, limb in ipairs(arms) do
            local part = char:FindFirstChild(limb)
            if part then
                local partsInBox = workspace:GetPartBoundsInBox(part.CFrame, boxSize)
                for _, p in ipairs(partsInBox) do
                    if p.Name == "PSoccerBall" or p.Name == "TPS" then
                        firetouchinterest(part, p, 0)
                        firetouchinterest(p, part, 0)
                        task.wait(0.01)
                        firetouchinterest(part, p, 1)
                        firetouchinterest(p, part, 1)
                    end
                end
            end
        end
    end
})

-- Button for 5 Distance (Arms)
fireTab:CreateButton({
    Name = "5 Distance (Arms)",
    Callback = function()
        local reach = 5
        local boxSize = Vector3.new(reach * 2, reach * 2, reach * 2)
        local char = getCharacter()
        for _, limb in ipairs(arms) do
            local part = char:FindFirstChild(limb)
            if part then
                local partsInBox = workspace:GetPartBoundsInBox(part.CFrame, boxSize)
                for _, p in ipairs(partsInBox) do
                    if p.Name == "PSoccerBall" or p.Name == "TPS" then
                        firetouchinterest(part, p, 0)
                        firetouchinterest(p, part, 0)
                        task.wait(0.01)
                        firetouchinterest(part, p, 1)
                        firetouchinterest(p, part, 1)
                    end
                end
            end
        end
    end
})

-- Button for 6 Distance (Arms)
fireTab:CreateButton({
    Name = "6 Distance (Arms)",
    Callback = function()
        local reach = 6
        local boxSize = Vector3.new(reach * 2, reach * 2, reach * 2)
        local char = getCharacter()
        for _, limb in ipairs(arms) do
            local part = char:FindFirstChild(limb)
            if part then
                local partsInBox = workspace:GetPartBoundsInBox(part.CFrame, boxSize)
                for _, p in ipairs(partsInBox) do
                    if p.Name == "PSoccerBall" or p.Name == "TPS" then
                        firetouchinterest(part, p, 0)
                        firetouchinterest(p, part, 0)
                        task.wait(0.01)
                        firetouchinterest(part, p, 1)
                        firetouchinterest(p, part, 1)
                    end
                end
            end
        end
    end
})

-- Button for 7 Distance (Arms)
fireTab:CreateButton({
    Name = "7 Distance (Arms)",
    Callback = function()
        local reach = 7
        local boxSize = Vector3.new(reach * 2, reach * 2, reach * 2)
        local char = getCharacter()
        for _, limb in ipairs(arms) do
            local part = char:FindFirstChild(limb)
            if part then
                local partsInBox = workspace:GetPartBoundsInBox(part.CFrame, boxSize)
                for _, p in ipairs(partsInBox) do
                    if p.Name == "PSoccerBall" or p.Name == "TPS" then
                        firetouchinterest(part, p, 0)
                        firetouchinterest(p, part, 0)
                        task.wait(0.01)
                        firetouchinterest(part, p, 1)
                        firetouchinterest(p, part, 1)
                    end
                end
            end
        end
    end
})

-- Button for 8 Distance (Arms)
fireTab:CreateButton({
    Name = "8 Distance (Arms)",
    Callback = function()
        local reach = 8
        local boxSize = Vector3.new(reach * 2, reach * 2, reach * 2)
        local char = getCharacter()
        for _, limb in ipairs(arms) do
            local part = char:FindFirstChild(limb)
            if part then
                local partsInBox = workspace:GetPartBoundsInBox(part.CFrame, boxSize)
                for _, p in ipairs(partsInBox) do
                    if p.Name == "PSoccerBall" or p.Name == "TPS" then
                        firetouchinterest(part, p, 0)
                        firetouchinterest(p, part, 0)
                        task.wait(0.01)
                        firetouchinterest(part, p, 1)
                        firetouchinterest(p, part, 1)
                    end
                end
            end
        end
    end
})

-- Button for 9 Distance (Arms)
fireTab:CreateButton({
    Name = "9 Distance (Arms)",
    Callback = function()
        local reach = 9
        local boxSize = Vector3.new(reach * 2, reach * 2, reach * 2)
        local char = getCharacter()
        for _, limb in ipairs(arms) do
            local part = char:FindFirstChild(limb)
            if part then
                local partsInBox = workspace:GetPartBoundsInBox(part.CFrame, boxSize)
                for _, p in ipairs(partsInBox) do
                    if p.Name == "PSoccerBall" or p.Name == "TPS" then
                        firetouchinterest(part, p, 0)
                        firetouchinterest(p, part, 0)
                        task.wait(0.01)
                        firetouchinterest(part, p, 1)
                        firetouchinterest(p, part, 1)
                    end
                end
            end
        end
    end
})

-- Button for 10 Distance (Arms)
fireTab:CreateButton({
    Name = "10 Distance (Arms)",
    Callback = function()
        local reach = 10
        local boxSize = Vector3.new(reach * 2, reach * 2, reach * 2)
        local char = getCharacter()
        for _, limb in ipairs(arms) do
            local part = char:FindFirstChild(limb)
            if part then
                local partsInBox = workspace:GetPartBoundsInBox(part.CFrame, boxSize)
                for _, p in ipairs(partsInBox) do
                    if p.Name == "PSoccerBall" or p.Name == "TPS" then
                        firetouchinterest(part, p, 0)
                        firetouchinterest(p, part, 0)
                        task.wait(0.01)
                        firetouchinterest(part, p, 1)
                        firetouchinterest(p, part, 1)
                    end
                end
            end
        end
    end
})

-- Fire Touch Tab for Torso Only – 10 Explicit Buttons

local fireTab = Window:CreateTab({Name = "Fire Touch Torso", Icon = "fire_extinguisher", ImageSource = "Material"})

-- Define the target limb group for torso.
local torsoGroup = {"Torso"}  -- Adjust if you prefer UpperTorso or LowerTorso

-- Button for 1 Distance (Torso)
fireTab:CreateButton({
    Name = "1 Distance (Torso)",
    Callback = function()
        local reach = 1
        local boxSize = Vector3.new(reach * 2, reach * 2, reach * 2)
        local char = getCharacter()
        for _, limb in ipairs(torsoGroup) do
            local part = char:FindFirstChild(limb)
            if part then
                local partsInBox = workspace:GetPartBoundsInBox(part.CFrame, boxSize)
                for _, p in ipairs(partsInBox) do
                    if p.Name == "PSoccerBall" or p.Name == "TPS" then
                        firetouchinterest(part, p, 0)
                        firetouchinterest(p, part, 0)
                        task.wait(0.01)
                        firetouchinterest(part, p, 1)
                        firetouchinterest(p, part, 1)
                    end
                end
            end
        end
    end
})

-- Button for 2 Distance (Torso)
fireTab:CreateButton({
    Name = "2 Distance (Torso)",
    Callback = function()
        local reach = 2
        local boxSize = Vector3.new(reach * 2, reach * 2, reach * 2)
        local char = getCharacter()
        for _, limb in ipairs(torsoGroup) do
            local part = char:FindFirstChild(limb)
            if part then
                local partsInBox = workspace:GetPartBoundsInBox(part.CFrame, boxSize)
                for _, p in ipairs(partsInBox) do
                    if p.Name == "PSoccerBall" or p.Name == "TPS" then
                        firetouchinterest(part, p, 0)
                        firetouchinterest(p, part, 0)
                        task.wait(0.01)
                        firetouchinterest(part, p, 1)
                        firetouchinterest(p, part, 1)
                    end
                end
            end
        end
    end
})

-- Button for 3 Distance (Torso)
fireTab:CreateButton({
    Name = "3 Distance (Torso)",
    Callback = function()
        local reach = 3
        local boxSize = Vector3.new(reach * 2, reach * 2, reach * 2)
        local char = getCharacter()
        for _, limb in ipairs(torsoGroup) do
            local part = char:FindFirstChild(limb)
            if part then
                local partsInBox = workspace:GetPartBoundsInBox(part.CFrame, boxSize)
                for _, p in ipairs(partsInBox) do
                    if p.Name == "PSoccerBall" or p.Name == "TPS" then
                        firetouchinterest(part, p, 0)
                        firetouchinterest(p, part, 0)
                        task.wait(0.01)
                        firetouchinterest(part, p, 1)
                        firetouchinterest(p, part, 1)
                    end
                end
            end
        end
    end
})

-- Button for 4 Distance (Torso)
fireTab:CreateButton({
    Name = "4 Distance (Torso)",
    Callback = function()
        local reach = 4
        local boxSize = Vector3.new(reach * 2, reach * 2, reach * 2)
        local char = getCharacter()
        for _, limb in ipairs(torsoGroup) do
            local part = char:FindFirstChild(limb)
            if part then
                local partsInBox = workspace:GetPartBoundsInBox(part.CFrame, boxSize)
                for _, p in ipairs(partsInBox) do
                    if p.Name == "PSoccerBall" or p.Name == "TPS" then
                        firetouchinterest(part, p, 0)
                        firetouchinterest(p, part, 0)
                        task.wait(0.01)
                        firetouchinterest(part, p, 1)
                        firetouchinterest(p, part, 1)
                    end
                end
            end
        end
    end
})

-- Button for 5 Distance (Torso)
fireTab:CreateButton({
    Name = "5 Distance (Torso)",
    Callback = function()
        local reach = 5
        local boxSize = Vector3.new(reach * 2, reach * 2, reach * 2)
        local char = getCharacter()
        for _, limb in ipairs(torsoGroup) do
            local part = char:FindFirstChild(limb)
            if part then
                local partsInBox = workspace:GetPartBoundsInBox(part.CFrame, boxSize)
                for _, p in ipairs(partsInBox) do
                    if p.Name == "PSoccerBall" or p.Name == "TPS" then
                        firetouchinterest(part, p, 0)
                        firetouchinterest(p, part, 0)
                        task.wait(0.01)
                        firetouchinterest(part, p, 1)
                        firetouchinterest(p, part, 1)
                    end
                end
            end
        end
    end
})

-- Button for 6 Distance (Torso)
fireTab:CreateButton({
    Name = "6 Distance (Torso)",
    Callback = function()
        local reach = 6
        local boxSize = Vector3.new(reach * 2, reach * 2, reach * 2)
        local char = getCharacter()
        for _, limb in ipairs(torsoGroup) do
            local part = char:FindFirstChild(limb)
            if part then
                local partsInBox = workspace:GetPartBoundsInBox(part.CFrame, boxSize)
                for _, p in ipairs(partsInBox) do
                    if p.Name == "PSoccerBall" or p.Name == "TPS" then
                        firetouchinterest(part, p, 0)
                        firetouchinterest(p, part, 0)
                        task.wait(0.01)
                        firetouchinterest(part, p, 1)
                        firetouchinterest(p, part, 1)
                    end
                end
            end
        end
    end
})

-- Button for 7 Distance (Torso)
fireTab:CreateButton({
    Name = "7 Distance (Torso)",
    Callback = function()
        local reach = 7
        local boxSize = Vector3.new(reach * 2, reach * 2, reach * 2)
        local char = getCharacter()
        for _, limb in ipairs(torsoGroup) do
            local part = char:FindFirstChild(limb)
            if part then
                local partsInBox = workspace:GetPartBoundsInBox(part.CFrame, boxSize)
                for _, p in ipairs(partsInBox) do
                    if p.Name == "PSoccerBall" or p.Name == "TPS" then
                        firetouchinterest(part, p, 0)
                        firetouchinterest(p, part, 0)
                        task.wait(0.01)
                        firetouchinterest(part, p, 1)
                        firetouchinterest(p, part, 1)
                    end
                end
            end
        end
    end
})

-- Button for 8 Distance (Torso)
fireTab:CreateButton({
    Name = "8 Distance (Torso)",
    Callback = function()
        local reach = 8
        local boxSize = Vector3.new(reach * 2, reach * 2, reach * 2)
        local char = getCharacter()
        for _, limb in ipairs(torsoGroup) do
            local part = char:FindFirstChild(limb)
            if part then
                local partsInBox = workspace:GetPartBoundsInBox(part.CFrame, boxSize)
                for _, p in ipairs(partsInBox) do
                    if p.Name == "PSoccerBall" or p.Name == "TPS" then
                        firetouchinterest(part, p, 0)
                        firetouchinterest(p, part, 0)
                        task.wait(0.01)
                        firetouchinterest(part, p, 1)
                        firetouchinterest(p, part, 1)
                    end
                end
            end
        end
    end
})

-- Button for 9 Distance (Torso)
fireTab:CreateButton({
    Name = "9 Distance (Torso)",
    Callback = function()
        local reach = 9
        local boxSize = Vector3.new(reach * 2, reach * 2, reach * 2)
        local char = getCharacter()
        for _, limb in ipairs(torsoGroup) do
            local part = char:FindFirstChild(limb)
            if part then
                local partsInBox = workspace:GetPartBoundsInBox(part.CFrame, boxSize)
                for _, p in ipairs(partsInBox) do
                    if p.Name == "PSoccerBall" or p.Name == "TPS" then
                        firetouchinterest(part, p, 0)
                        firetouchinterest(p, part, 0)
                        task.wait(0.01)
                        firetouchinterest(part, p, 1)
                        firetouchinterest(p, part, 1)
                    end
                end
            end
        end
    end
})

-- Button for 10 Distance (Torso)
fireTab:CreateButton({
    Name = "10 Distance (Torso)",
    Callback = function()
        local reach = 10
        local boxSize = Vector3.new(reach * 2, reach * 2, reach * 2)
        local char = getCharacter()
        for _, limb in ipairs(torsoGroup) do
            local part = char:FindFirstChild(limb)
            if part then
                local partsInBox = workspace:GetPartBoundsInBox(part.CFrame, boxSize)
                for _, p in ipairs(partsInBox) do
                    if p.Name == "PSoccerBall" or p.Name == "TPS" then
                        firetouchinterest(part, p, 0)
                        firetouchinterest(p, part, 0)
                        task.wait(0.01)
                        firetouchinterest(part, p, 1)
                        firetouchinterest(p, part, 1)
                    end
                end
            end
        end
    end
})

-- Fire Touch Tab for Head Only – 10 Explicit Buttons

local headTab = Window:CreateTab({Name = "Fire Touch Head", Icon = "fire_extinguisher", ImageSource = "Material"})

-- Define the target limb group for the head.
local headGroup = {"Head"}

-- Button for 1 Distance (Head)
headTab:CreateButton({
    Name = "1 Distance (Head)",
    Callback = function()
        local reach = 1
        local boxSize = Vector3.new(reach * 2, reach * 2, reach * 2)
        local char = getCharacter()
        for _, limb in ipairs(headGroup) do
            local part = char:FindFirstChild(limb)
            if part then
                local partsInBox = workspace:GetPartBoundsInBox(part.CFrame, boxSize)
                for _, p in ipairs(partsInBox) do
                    if p.Name == "PSoccerBall" or p.Name == "TPS" then
                        firetouchinterest(part, p, 0)
                        firetouchinterest(p, part, 0)
                        task.wait(0.01)
                        firetouchinterest(part, p, 1)
                        firetouchinterest(p, part, 1)
                    end
                end
            end
        end
    end
})

-- Button for 2 Distance (Head)
headTab:CreateButton({
    Name = "2 Distance (Head)",
    Callback = function()
        local reach = 2
        local boxSize = Vector3.new(reach * 2, reach * 2, reach * 2)
        local char = getCharacter()
        for _, limb in ipairs(headGroup) do
            local part = char:FindFirstChild(limb)
            if part then
                local partsInBox = workspace:GetPartBoundsInBox(part.CFrame, boxSize)
                for _, p in ipairs(partsInBox) do
                    if p.Name == "PSoccerBall" or p.Name == "TPS" then
                        firetouchinterest(part, p, 0)
                        firetouchinterest(p, part, 0)
                        task.wait(0.01)
                        firetouchinterest(part, p, 1)
                        firetouchinterest(p, part, 1)
                    end
                end
            end
        end
    end
})

-- Button for 3 Distance (Head)
headTab:CreateButton({
    Name = "3 Distance (Head)",
    Callback = function()
        local reach = 3
        local boxSize = Vector3.new(reach * 2, reach * 2, reach * 2)
        local char = getCharacter()
        for _, limb in ipairs(headGroup) do
            local part = char:FindFirstChild(limb)
            if part then
                local partsInBox = workspace:GetPartBoundsInBox(part.CFrame, boxSize)
                for _, p in ipairs(partsInBox) do
                    if p.Name == "PSoccerBall" or p.Name == "TPS" then
                        firetouchinterest(part, p, 0)
                        firetouchinterest(p, part, 0)
                        task.wait(0.01)
                        firetouchinterest(part, p, 1)
                        firetouchinterest(p, part, 1)
                    end
                end
            end
        end
    end
})

-- Button for 4 Distance (Head)
headTab:CreateButton({
    Name = "4 Distance (Head)",
    Callback = function()
        local reach = 4
        local boxSize = Vector3.new(reach * 2, reach * 2, reach * 2)
        local char = getCharacter()
        for _, limb in ipairs(headGroup) do
            local part = char:FindFirstChild(limb)
            if part then
                local partsInBox = workspace:GetPartBoundsInBox(part.CFrame, boxSize)
                for _, p in ipairs(partsInBox) do
                    if p.Name == "PSoccerBall" or p.Name == "TPS" then
                        firetouchinterest(part, p, 0)
                        firetouchinterest(p, part, 0)
                        task.wait(0.01)
                        firetouchinterest(part, p, 1)
                        firetouchinterest(p, part, 1)
                    end
                end
            end
        end
    end
})

-- Button for 5 Distance (Head)
headTab:CreateButton({
    Name = "5 Distance (Head)",
    Callback = function()
        local reach = 5
        local boxSize = Vector3.new(reach * 2, reach * 2, reach * 2)
        local char = getCharacter()
        for _, limb in ipairs(headGroup) do
            local part = char:FindFirstChild(limb)
            if part then
                local partsInBox = workspace:GetPartBoundsInBox(part.CFrame, boxSize)
                for _, p in ipairs(partsInBox) do
                    if p.Name == "PSoccerBall" or p.Name == "TPS" then
                        firetouchinterest(part, p, 0)
                        firetouchinterest(p, part, 0)
                        task.wait(0.01)
                        firetouchinterest(part, p, 1)
                        firetouchinterest(p, part, 1)
                    end
                end
            end
        end
    end
})

-- Button for 6 Distance (Head)
headTab:CreateButton({
    Name = "6 Distance (Head)",
    Callback = function()
        local reach = 6
        local boxSize = Vector3.new(reach * 2, reach * 2, reach * 2)
        local char = getCharacter()
        for _, limb in ipairs(headGroup) do
            local part = char:FindFirstChild(limb)
            if part then
                local partsInBox = workspace:GetPartBoundsInBox(part.CFrame, boxSize)
                for _, p in ipairs(partsInBox) do
                    if p.Name == "PSoccerBall" or p.Name == "TPS" then
                        firetouchinterest(part, p, 0)
                        firetouchinterest(p, part, 0)
                        task.wait(0.01)
                        firetouchinterest(part, p, 1)
                        firetouchinterest(p, part, 1)
                    end
                end
            end
        end
    end
})

-- Button for 7 Distance (Head)
headTab:CreateButton({
    Name = "7 Distance (Head)",
    Callback = function()
        local reach = 7
        local boxSize = Vector3.new(reach * 2, reach * 2, reach * 2)
        local char = getCharacter()
        for _, limb in ipairs(headGroup) do
            local part = char:FindFirstChild(limb)
            if part then
                local partsInBox = workspace:GetPartBoundsInBox(part.CFrame, boxSize)
                for _, p in ipairs(partsInBox) do
                    if p.Name == "PSoccerBall" or p.Name == "TPS" then
                        firetouchinterest(part, p, 0)
                        firetouchinterest(p, part, 0)
                        task.wait(0.01)
                        firetouchinterest(part, p, 1)
                        firetouchinterest(p, part, 1)
                    end
                end
            end
        end
    end
})

-- Button for 8 Distance (Head)
headTab:CreateButton({
    Name = "8 Distance (Head)",
    Callback = function()
        local reach = 8
        local boxSize = Vector3.new(reach * 2, reach * 2, reach * 2)
        local char = getCharacter()
        for _, limb in ipairs(headGroup) do
            local part = char:FindFirstChild(limb)
            if part then
                local partsInBox = workspace:GetPartBoundsInBox(part.CFrame, boxSize)
                for _, p in ipairs(partsInBox) do
                    if p.Name == "PSoccerBall" or p.Name == "TPS" then
                        firetouchinterest(part, p, 0)
                        firetouchinterest(p, part, 0)
                        task.wait(0.01)
                        firetouchinterest(part, p, 1)
                        firetouchinterest(p, part, 1)
                    end
                end
            end
        end
    end
})

-- Button for 9 Distance (Head)
headTab:CreateButton({
    Name = "9 Distance (Head)",
    Callback = function()
        local reach = 9
        local boxSize = Vector3.new(reach * 2, reach * 2, reach * 2)
        local char = getCharacter()
        for _, limb in ipairs(headGroup) do
            local part = char:FindFirstChild(limb)
            if part then
                local partsInBox = workspace:GetPartBoundsInBox(part.CFrame, boxSize)
                for _, p in ipairs(partsInBox) do
                    if p.Name == "PSoccerBall" or p.Name == "TPS" then
                        firetouchinterest(part, p, 0)
                        firetouchinterest(p, part, 0)
                        task.wait(0.01)
                        firetouchinterest(part, p, 1)
                        firetouchinterest(p, part, 1)
                    end
                end
            end
        end
    end
})

-- Button for 10 Distance (Head)
headTab:CreateButton({
    Name = "10 Distance (Head)",
    Callback = function()
        local reach = 10
        local boxSize = Vector3.new(reach * 2, reach * 2, reach * 2)
        local char = getCharacter()
        for _, limb in ipairs(headGroup) do
            local part = char:FindFirstChild(limb)
            if part then
                local partsInBox = workspace:GetPartBoundsInBox(part.CFrame, boxSize)
                for _, p in ipairs(partsInBox) do
                    if p.Name == "PSoccerBall" or p.Name == "TPS" then
                        firetouchinterest(part, p, 0)
                        firetouchinterest(p, part, 0)
                        task.wait(0.01)
                        firetouchinterest(part, p, 1)
                        firetouchinterest(p, part, 1)
                    end
                end
            end
        end
    end
})

-- Fire Touch Tab for LLCL and RLCL Only – 10 Explicit Buttons

local lowerTab = Window:CreateTab({Name = "Fire Touch LLCL/RLCL", Icon = "fire_extinguisher", ImageSource = "Material"})

-- Define the target group for lower limbs.
local lowerLimbGroup = {"LLCL", "RLCL"}

-- Button for 1 Distance (LLCL/RLCL)
lowerTab:CreateButton({
    Name = "1 Distance (LLCL/RLCL)",
    Callback = function()
        local reach = 1
        local boxSize = Vector3.new(reach * 2, reach * 2, reach * 2)
        local char = getCharacter()
        for _, limb in ipairs(lowerLimbGroup) do
            local part = char:FindFirstChild(limb)
            if part then
                local partsInBox = workspace:GetPartBoundsInBox(part.CFrame, boxSize)
                for _, p in ipairs(partsInBox) do
                    if p.Name == "PSoccerBall" or p.Name == "TPS" then
                        firetouchinterest(part, p, 0)
                        firetouchinterest(p, part, 0)
                        task.wait(0.01)
                        firetouchinterest(part, p, 1)
                        firetouchinterest(p, part, 1)
                    end
                end
            end
        end
    end
})

-- Button for 2 Distance (LLCL/RLCL)
lowerTab:CreateButton({
    Name = "2 Distance (LLCL/RLCL)",
    Callback = function()
        local reach = 2
        local boxSize = Vector3.new(reach * 2, reach * 2, reach * 2)
        local char = getCharacter()
        for _, limb in ipairs(lowerLimbGroup) do
            local part = char:FindFirstChild(limb)
            if part then
                local partsInBox = workspace:GetPartBoundsInBox(part.CFrame, boxSize)
                for _, p in ipairs(partsInBox) do
                    if p.Name == "PSoccerBall" or p.Name == "TPS" then
                        firetouchinterest(part, p, 0)
                        firetouchinterest(p, part, 0)
                        task.wait(0.01)
                        firetouchinterest(part, p, 1)
                        firetouchinterest(p, part, 1)
                    end
                end
            end
        end
    end
})

-- Button for 3 Distance (LLCL/RLCL)
lowerTab:CreateButton({
    Name = "3 Distance (LLCL/RLCL)",
    Callback = function()
        local reach = 3
        local boxSize = Vector3.new(reach * 2, reach * 2, reach * 2)
        local char = getCharacter()
        for _, limb in ipairs(lowerLimbGroup) do
            local part = char:FindFirstChild(limb)
            if part then
                local partsInBox = workspace:GetPartBoundsInBox(part.CFrame, boxSize)
                for _, p in ipairs(partsInBox) do
                    if p.Name == "PSoccerBall" or p.Name == "TPS" then
                        firetouchinterest(part, p, 0)
                        firetouchinterest(p, part, 0)
                        task.wait(0.01)
                        firetouchinterest(part, p, 1)
                        firetouchinterest(p, part, 1)
                    end
                end
            end
        end
    end
})

-- Button for 4 Distance (LLCL/RLCL)
lowerTab:CreateButton({
    Name = "4 Distance (LLCL/RLCL)",
    Callback = function()
        local reach = 4
        local boxSize = Vector3.new(reach * 2, reach * 2, reach * 2)
        local char = getCharacter()
        for _, limb in ipairs(lowerLimbGroup) do
            local part = char:FindFirstChild(limb)
            if part then
                local partsInBox = workspace:GetPartBoundsInBox(part.CFrame, boxSize)
                for _, p in ipairs(partsInBox) do
                    if p.Name == "PSoccerBall" or p.Name == "TPS" then
                        firetouchinterest(part, p, 0)
                        firetouchinterest(p, part, 0)
                        task.wait(0.01)
                        firetouchinterest(part, p, 1)
                        firetouchinterest(p, part, 1)
                    end
                end
            end
        end
    end
})

-- Button for 5 Distance (LLCL/RLCL)
lowerTab:CreateButton({
    Name = "5 Distance (LLCL/RLCL)",
    Callback = function()
        local reach = 5
        local boxSize = Vector3.new(reach * 2, reach * 2, reach * 2)
        local char = getCharacter()
        for _, limb in ipairs(lowerLimbGroup) do
            local part = char:FindFirstChild(limb)
            if part then
                local partsInBox = workspace:GetPartBoundsInBox(part.CFrame, boxSize)
                for _, p in ipairs(partsInBox) do
                    if p.Name == "PSoccerBall" or p.Name == "TPS" then
                        firetouchinterest(part, p, 0)
                        firetouchinterest(p, part, 0)
                        task.wait(0.01)
                        firetouchinterest(part, p, 1)
                        firetouchinterest(p, part, 1)
                    end
                end
            end
        end
    end
})

-- Button for 6 Distance (LLCL/RLCL)
lowerTab:CreateButton({
    Name = "6 Distance (LLCL/RLCL)",
    Callback = function()
        local reach = 6
        local boxSize = Vector3.new(reach * 2, reach * 2, reach * 2)
        local char = getCharacter()
        for _, limb in ipairs(lowerLimbGroup) do
            local part = char:FindFirstChild(limb)
            if part then
                local partsInBox = workspace:GetPartBoundsInBox(part.CFrame, boxSize)
                for _, p in ipairs(partsInBox) do
                    if p.Name == "PSoccerBall" or p.Name == "TPS" then
                        firetouchinterest(part, p, 0)
                        firetouchinterest(p, part, 0)
                        task.wait(0.01)
                        firetouchinterest(part, p, 1)
                        firetouchinterest(p, part, 1)
                    end
                end
            end
        end
    end
})

-- Button for 7 Distance (LLCL/RLCL)
lowerTab:CreateButton({
    Name = "7 Distance (LLCL/RLCL)",
    Callback = function()
        local reach = 7
        local boxSize = Vector3.new(reach * 2, reach * 2, reach * 2)
        local char = getCharacter()
        for _, limb in ipairs(lowerLimbGroup) do
            local part = char:FindFirstChild(limb)
            if part then
                local partsInBox = workspace:GetPartBoundsInBox(part.CFrame, boxSize)
                for _, p in ipairs(partsInBox) do
                    if p.Name == "PSoccerBall" or p.Name == "TPS" then
                        firetouchinterest(part, p, 0)
                        firetouchinterest(p, part, 0)
                        task.wait(0.01)
                        firetouchinterest(part, p, 1)
                        firetouchinterest(p, part, 1)
                    end
                end
            end
        end
    end
})

-- Button for 8 Distance (LLCL/RLCL)
lowerTab:CreateButton({
    Name = "8 Distance (LLCL/RLCL)",
    Callback = function()
        local reach = 8
        local boxSize = Vector3.new(reach * 2, reach * 2, reach * 2)
        local char = getCharacter()
        for _, limb in ipairs(lowerLimbGroup) do
            local part = char:FindFirstChild(limb)
            if part then
                local partsInBox = workspace:GetPartBoundsInBox(part.CFrame, boxSize)
                for _, p in ipairs(partsInBox) do
                    if p.Name == "PSoccerBall" or p.Name == "TPS" then
                        firetouchinterest(part, p, 0)
                        firetouchinterest(p, part, 0)
                        task.wait(0.01)
                        firetouchinterest(part, p, 1)
                        firetouchinterest(p, part, 1)
                    end
                end
            end
        end
    end
})

-- Button for 9 Distance (LLCL/RLCL)
lowerTab:CreateButton({
    Name = "9 Distance (LLCL/RLCL)",
    Callback = function()
        local reach = 9
        local boxSize = Vector3.new(reach * 2, reach * 2, reach * 2)
        local char = getCharacter()
        for _, limb in ipairs(lowerLimbGroup) do
            local part = char:FindFirstChild(limb)
            if part then
                local partsInBox = workspace:GetPartBoundsInBox(part.CFrame, boxSize)
                for _, p in ipairs(partsInBox) do
                    if p.Name == "PSoccerBall" or p.Name == "TPS" then
                        firetouchinterest(part, p, 0)
                        firetouchinterest(p, part, 0)
                        task.wait(0.01)
                        firetouchinterest(part, p, 1)
                        firetouchinterest(p, part, 1)
                    end
                end
            end
        end
    end
})

-- Button for 10 Distance (LLCL/RLCL)
lowerTab:CreateButton({
    Name = "10 Distance (LLCL/RLCL)",
    Callback = function()
        local reach = 10
        local boxSize = Vector3.new(reach * 2, reach * 2, reach * 2)
        local char = getCharacter()
        for _, limb in ipairs(lowerLimbGroup) do
            local part = char:FindFirstChild(limb)
            if part then
                local partsInBox = workspace:GetPartBoundsInBox(part.CFrame, boxSize)
                for _, p in ipairs(partsInBox) do
                    if p.Name == "PSoccerBall" or p.Name == "TPS" then
                        firetouchinterest(part, p, 0)
                        firetouchinterest(p, part, 0)
                        task.wait(0.01)
                        firetouchinterest(part, p, 1)
                        firetouchinterest(p, part, 1)
                    end
                end
            end
        end
    end
})
-- Nihai Çözüm: BodyForce ile uçuşu sürekli olarak yere doğru baskılar
local BodyForceName = "GravitySuppressor"
local ForceMagnitude = Vector3.new(0, -500, 0) -- 100.000 gücünde aşağı kuvvet uygula (Çok güçlü)

local function manageDownwardForce(char)
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Sürekli kontrol döngüsü: Her an topu kontrol et
    local connection = hrp.AncestryChanged:Connect(function() end)
    connection:Disconnect() -- Sadece bir kez çalışması için bağlantıyı hemen kes

    -- BodyForce'u ekle
    local function applyForce()
        local bf = hrp:FindFirstChild(BodyForceName)
        if bf then return end
        
        bf = Instance.new("BodyForce")
        bf.Name = BodyForceName
        bf.Force = ForceMagnitude
        bf.Parent = hrp
    end
    
    -- BodyForce'u kaldır
    local function removeForce()
        local bf = hrp:FindFirstChild(BodyForceName)
        if bf then
            bf:Destroy()
        end
    end
    
    -- Top tutulup tutulmadığını kontrol eden ana döngü
    RunService.Heartbeat:Connect(function()
        local isHoldingBall = false
        
        -- Topun elde olup olmadığını kontrol et (Weld kontrolü)
        if hrp:FindFirstChildOfClass("WeldConstraint") or hrp:FindFirstChildOfClass("Weld") then
             isHoldingBall = true
        end

        -- İkinci kontrol: Tüm karakterdeki Weld'leri kontrol et
        if not isHoldingBall then
            for _, part in ipairs(char:GetDescendants()) do
                if (part:IsA("WeldConstraint") or part:IsA("Weld")) and (part.Part0 and part.Part1) then
                    if part.Part0.Name:find("Ball") or part.Part1.Name:find("Ball") or part.Part0.Name:find("TPS") or part.Part1.Name:find("TPS") then
                        isHoldingBall = true
                        break
                    end
                end
            end
        end

        if isHoldingBall then
            applyForce() -- Top tutuluyorsa sürekli aşağı it
        else
            removeForce() -- Top bırakılırsa kuvveti kaldır
        end
    end)
end

-- Script başladığında ve karakter her yeniden doğduğunda kuvvet yönetimini başlat
local currentCharacter = getCharacter() 
if currentCharacter then
    manageDownwardForce(currentCharacter)
end

player.CharacterAdded:Connect(manageDownwardForce)

-------------------------------------------------
-- SETTINGS TAB
-------------------------------------------------
local settingsTab = Window:CreateTab({Name = "Settings", Icon = "settings", ImageSource = "Material"})
settingsTab:BuildThemeSection()
settingsTab:BuildConfigSection()

-------------------------------------------------
-- End of Script ✨
-------------------------------------------------   

