local Material = loadstring(game:HttpGet("https://raw.githubusercontent.com/heran2k21/-/refs/heads/main/%E6%B5%8B%E8%AF%95UI"))()

-- 创建主标签页
local MainTab = library:CreateTab("主要")
local AboutTab = library:CreateTab("关于")

-- 获取所有蛋
local Egg = {}
for i, v in pairs(game:GetService("Workspace").EggShops:GetChildren()) do
    if v:IsA "Model" then
        if not table.find(Egg, tostring(v)) then
            table.insert(Egg, tostring(v))
        end
    end
end

-- 获取所有区域
local Area = {}
for i, v in pairs(game:GetService("Workspace").Areas:GetChildren()) do
    if v:IsA "Part" then
        table.insert(Area, tostring(v))
    end
end

-- 获取最近金币的函数
local function getClosestCoin()
    local dist, thing = math.huge
    for i, v in next, game:GetService("Workspace").Drops:GetChildren() do
        if v:IsA("Model") then
            local mag = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - v.Base.Position).magnitude
            if mag < dist then
                dist = mag
                thing = v
            end
        end
    end
    return thing
end

-- 全图收集金币开关
MainTab:Toggle("全图收集金币", "CollectCoins", false, function(Value)
    getgenv().CollectCoins = Value
    while getgenv().CollectCoins do 
        task.wait()
        pcall(function()
            local coin = getClosestCoin()
            if coin then
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = coin.Base.CFrame
            end
        end)
    end
end)

-- 蛋选择下拉菜单
MainTab:Dropdown("选择蛋", "SelectedEgg", Egg, function(Value)
    getgenv().egg = Value
end)

-- 获取最近蛋的函数
local function getClosestEgg()
    local dist, thing = math.huge
    for i, v in next, game:GetService("Workspace").EggShops:GetChildren() do
        if v:IsA("Model") and v.Name == getgenv().egg then
            local mag = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - v.ProxPart.Position).magnitude
            if mag < dist then
                dist = mag
                thing = v
            end
        end
    end
    return thing
end

-- 买蛋开关
MainTab:Toggle("买蛋", "BuyEggs", false, function(Value)
    getgenv().BuyEggs = Value
    while getgenv().BuyEggs do 
        task.wait()
        local egg = getClosestEgg()
        if egg then
            local args = {
                [1] = egg.Rarity.Value
            }
            game:GetService("ReplicatedStorage").Remotes.BuyEgg:FireServer(unpack(args))
        end
    end
end)

-- 打开隐藏蛋开关
MainTab:Toggle("打开隐藏蛋", "OpenHiddenEggs", false, function(Value)
    getgenv().OpenHiddenEggs = Value
    while getgenv().OpenHiddenEggs do 
        task.wait()
        for i,v in pairs(game:GetService("Workspace").HiddenEggs:GetDescendants()) do
            if v:IsA("TouchTransmitter") then
                firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, v.Parent, 0)
                wait()
                firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, v.Parent, 1)
            end
        end
    end
end)

-- 自动领取任务奖励开关
MainTab:Toggle("自动领取任务奖励", "ClaimRewards", false, function(Value)
    getgenv().ClaimRewards = Value
    while getgenv().ClaimRewards do 
        task.wait()
        game:GetService("ReplicatedStorage").Remotes.ClaimQuestReward:FireServer()
    end
end)

-- 场景选择下拉菜单
MainTab:Dropdown("选择场景", "SelectedArea", Area, function(Value)
    getgenv().area = Value
end)

-- 传送按钮
MainTab:Button("传送至", function()
    if getgenv().area then
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game:GetService("Workspace").Areas[getgenv().area].CFrame
        library:Notify({
            Title = "传送成功",
            Text = "已传送到 " .. getgenv().area,
            Duration = 2
        })
    else
        library:Notify({
            Title = "提示",
            Text = "请先选择要传送的场景",
            Duration = 2
        })
    end
end)

-- 反挂机功能 - 每5分钟执行一次
local function antiAfk()
    local player = game.Players.LocalPlayer
    
    -- 等待角色加载
    repeat task.wait() until player.Character
    
    while getgenv().AntiAfk do
        task.wait(300) -- 300秒 = 5分钟执行一次
        
        pcall(function()
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                local humanoid = player.Character.Humanoid
                
                -- 执行跳跃动作
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end

-- 在主要标签页添加反挂机开关
MainTab:Toggle("反挂机 (每5分钟跳跃)", "AntiAfk", false, function(Value)
    getgenv().AntiAfk = Value
    if Value then
        -- 启动反挂机线程
        coroutine.wrap(antiAfk)()
        library:Notify({
            Title = "反挂机",
            Text = "已开启，每5分钟自动跳跃一次",
            Duration = 3
        })
    else
        library:Notify({
            Title = "反挂机",
            Text = "已关闭",
            Duration = 2
        })
    end
end)

-- 使用按钮来显示关于信息（移除了联系方式）
AboutTab:Button("📦 脚本名称：收集所有宠物", function() end)
AboutTab:Button("👤 作者：Heran", function() end)
AboutTab:Button("📌 版本：v0.81/Jin定制", function() end)
AboutTab:Button("📅 最后更新：2026年3月8日", function() end)
AboutTab:Button("──────────────────", function() end)
AboutTab:Button("💰 全图收集金币", function() end)
AboutTab:Button("🥚 自动购买蛋", function() end)
AboutTab:Button("🥚 自动打开隐藏蛋", function() end)
AboutTab:Button("📋 自动领取任务奖励", function() end)
AboutTab:Button("📍 场景传送功能", function() end)
AboutTab:Button("⏱️ 反挂机 (每5分钟)", function() end)
AboutTab:Button("──────────────────", function() end)
