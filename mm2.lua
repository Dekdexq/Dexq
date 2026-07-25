repeat wait() until game:IsLoaded()task.wait(10) 
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

pcall(function()
    game.StarterGui:SetCore("SendNotification", {
        Title = "Dexq Script",
        Text = "By Dexq",
        Icon = "rbxassetid://6034287525",
        Duration = 5
    })
end)

local DefaultConfig = {
    AutoFarm = true,
    AutoClaim = true,
    Noclip = true,
    Speed = 90,
    Target = 40,
    Dwell = 2,
    BoostFPS = true,
    BlackScreen = true,
    AntiAFK = true
}

if type(_G.Config) ~= "table" then
    _G.Config = DefaultConfig
else
    for k, v in pairs(DefaultConfig) do
        if _G.Config[k] == nil then
            _G.Config[k] = v
        end
    end
end

local isRunning = true

if _G.Config.AntiAFK then
    local VirtualUser = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end

if _G.Config.BoostFPS then
    pcall(function() setfpscap(15) end)
    local Lighting = game:GetService("Lighting")
    local Terrain = workspace:FindFirstChildOfClass('Terrain')
    
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.ShadowSoftness = 0
    pcall(function() Lighting:ClearAllChildren() end)
    
    if Terrain then
        pcall(function() Terrain:Clear() end)
    end
    
    local function optimizePart(v)
        if v:IsA("Decal") or v:IsA("Texture") or v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Sparkles") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Atmosphere") or v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("SunRaysEffect") or v:IsA("SpotLight") or v:IsA("PointLight") or v:IsA("SurfaceLight") then
            v:Destroy()
        elseif v:IsA("BasePart") then
            v.Material = Enum.Material.SmoothPlastic
            v.Reflectance = 0
            v.CastShadow = false
            if v.Name ~= "HumanoidRootPart" and not string.find(string.lower(v.Name), "coin") then
                v.Transparency = 1
            end
        end
    end
    
    for _, v in pairs(workspace:GetDescendants()) do
        pcall(optimizePart, v)
    end
    for _, v in pairs(Lighting:GetDescendants()) do
        pcall(optimizePart, v)
    end
    
    workspace.DescendantAdded:Connect(function(v)
        pcall(optimizePart, v)
    end)
    
    pcall(function()
        local char = game:GetService("Players").LocalPlayer.Character
        if char then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("CharacterMesh") then
                    v:Destroy()
                elseif v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                    v.Transparency = 1
                end
            end
        end
    end)
end

if _G.Config.BlackScreen then
    local renderingEnabled = false
    pcall(function()
        RunService:Set3dRenderingEnabled(renderingEnabled)
    end)
    local blackScreen = Instance.new("ScreenGui")
    blackScreen.Name = "BlackScreen"
    blackScreen.IgnoreGuiInset = true
    blackScreen.ResetOnSpawn = false
    blackScreen.DisplayOrder = -9999
    
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = Color3.new(0, 0, 0)
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.Parent = blackScreen
    
    pcall(function()
        blackScreen.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end)
    
    local UserInputService = game:GetService("UserInputService")
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.LeftControl then
            blackScreen.Enabled = not blackScreen.Enabled
            renderingEnabled = not renderingEnabled
            pcall(function()
                RunService:Set3dRenderingEnabled(renderingEnabled)
            end)
        end
    end)
end

RunService.Stepped:Connect(function()
    if _G.Config.Noclip then
        local char = LocalPlayer.Character
        if char then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") and v.CanCollide then
                    v.CanCollide = false
                end
            end
        end
    end
end)

local function isRoundActive()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    local char = LocalPlayer.Character
    if not pg or not pg:FindFirstChild("MainGUI") or not char or not char:FindFirstChild("HumanoidRootPart") then return false end
    
    local gameUI = pg.MainGUI:FindFirstChild("Game")
    local spectateUI = pg.MainGUI:FindFirstChild("Spectate")
    
    if not gameUI or not gameUI.Visible then return false end
    if spectateUI and spectateUI.Visible then return false end
    
    local lobby = workspace:FindFirstChild("Lobby")
    if lobby then
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        local ignoreList = {}
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character then table.insert(ignoreList, p.Character) end
        end
        rayParams.FilterDescendantsInstances = ignoreList
        
        local hrp = char.HumanoidRootPart
        local rayResult = workspace:Raycast(hrp.Position, Vector3.new(0, -1000, 0), rayParams)
        if rayResult and rayResult.Instance then
            if rayResult.Instance:IsDescendantOf(lobby) then
                return false
            end
        end
    end
    return true
end

local function safeTween(hrp, targetCFrame)
    if not hrp then return end
    local dist = (hrp.Position - targetCFrame.Position).Magnitude
    local timeToReach = dist / _G.Config.Speed
    if timeToReach < 0.1 then timeToReach = 0.1 end
    
    hrp.Anchored = true
    local tweenInfo = TweenInfo.new(timeToReach, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
    tween:Play()
    tween.Completed:Wait()
    
    hrp.Anchored = false
    hrp.Velocity = Vector3.new(0, 0, 0)
end

local function checkBagFull()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return false end
    local mainGUI = pg:FindFirstChild("MainGUI")
    if not mainGUI then return false end
    local gameUI = mainGUI:FindFirstChild("Game")
    if not gameUI then return false end
    local coinBags = gameUI:FindFirstChild("CoinBags")
    if not coinBags then return false end
    local container = coinBags:FindFirstChild("Container")
    if not container then return false end
    local coin = container:FindFirstChild("Coin")
    if not coin then return false end
    local fullLabel = coin:FindFirstChild("Full")
    if fullLabel and fullLabel.Visible then
        return true
    end
    local currencyFrame = coin:FindFirstChild("CurrencyFrame")
    if currencyFrame then
        local icon = currencyFrame:FindFirstChild("Icon")
        if icon then
            local coinsText = icon:FindFirstChild("Coins")
            if coinsText and coinsText:IsA("TextLabel") then
                local num = tonumber(string.match(coinsText.Text, "%d+"))
                if num and num >= _G.Config.Target then
                    return true
                end
            end
        end
    end
    
    return false
end

local function resetCharacter()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.Health = 0 end 
        char:BreakJoints() 
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(0, -50000, 0)
        end
    end
end

local function checkBagFullAction()
    if checkBagFull() then
        resetCharacter()
        return true
    end
    return false
end

local function autoCollectCoins()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    
    local coinContainer = nil
    for _, mapFolder in pairs(workspace:GetChildren()) do
        local cc = mapFolder:FindFirstChild("CoinContainer")
        if cc then coinContainer = cc break end
    end
    if not coinContainer then
        for _, v in pairs(workspace:GetDescendants()) do
            if v.Name == "CoinContainer" then coinContainer = v break end
        end
    end
    
    local coins = {}
    if coinContainer then
        for _, v in pairs(coinContainer:GetDescendants()) do
            if string.find(string.lower(v.Name), "coin") then
                if v:IsA("BasePart") and v.Transparency < 1 then
                    table.insert(coins, v)
                elseif v:IsA("Model") and v.PrimaryPart then
                    table.insert(coins, v.PrimaryPart)
                end
            end
        end
    end
    
    while #coins > 0 do
        if not isRunning or not isRoundActive() or not _G.Config.AutoFarm then break end
        
        if checkBagFullAction() then return end
        
        local closestCoin = nil
        local closestDist = math.huge
        local closestIndex = nil
        
        for i, coin in ipairs(coins) do
            if coin and coin.Parent and coin.Transparency < 1 then
                local dist = (hrp.Position - coin.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closestCoin = coin
                    closestIndex = i
                end
            end
        end
        
        if not closestCoin then break end
        table.remove(coins, closestIndex)
        
        local coin = closestCoin
        if coin and coin.Parent and coin.Transparency < 1 then
            local targetPos = CFrame.new(coin.Position + Vector3.new(0, 3.5, 0))
            safeTween(hrp, targetPos)
            
            if firetouchinterest then
                firetouchinterest(hrp, coin, 0)
                firetouchinterest(hrp, coin, 1)
            end
            task.wait(_G.Config.Dwell)
            
            if checkBagFullAction() then return end
        end
    end
end

task.spawn(function()
    while isRunning do
        if isRoundActive() then
            if checkBagFullAction() then
                print("Dexq")
                task.wait(2)
            else
                print("Dexq")
                autoCollectCoins()
            end
        else
            print("Dexq")
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.Anchored = false
            end
            task.wait(1)
        end
        task.wait(0.1)
    end
end)

task.spawn(function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local openCrate = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Shop"):WaitForChild("OpenCrate")
    
    while isRunning do
        if _G.Config.AutoClaim then

            task.spawn(function()
                pcall(function()
                    openCrate:InvokeServer("Summer2026Box", "MysteryBox", "SummerKey2026")
                end)
            end)

            task.spawn(function()
                pcall(function()
                    openCrate:InvokeServer("MysteryBox2", "MysteryBox", "Coins")
                end)
            end)
        end
        task.wait(1.5) 
    end
end)
