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
-- 反挂机功能 - 每2分钟执行一次，持续活动3秒以上
local function antiAfk(immediate)
    local player = game.Players.LocalPlayer
    local VirtualUser = game:GetService("VirtualUser")
    local runService = game:GetService("RunService")
    
    -- 等待角色加载
    repeat task.wait() until player.Character
    
    -- 如果不是立即执行，先等待第一次
    if not immediate then
        task.wait(120) -- 首次等待2分钟
    end
    
    while getgenv().AntiAfk do
        pcall(function()
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                local humanoid = player.Character.Humanoid
                local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                local camera = game:GetService("Workspace").CurrentCamera
                
                if rootPart and camera then
                    -- 保存原始位置和视角
                    local oldPos = rootPart.Position
                    local oldCFrame = camera.CFrame
                    
                    -- 开始持续活动（不低于3秒）
                    local startTime = tick()
                    local duration = 4 -- 持续4秒
                    
                    -- 创建移动和视角转动的连接
                    local connection
                    connection = runService.Heartbeat:Connect(function()
                        local elapsed = tick() - startTime
                        if elapsed >= duration then
                            connection:Disconnect()
                            return
                        end
                        
                        -- 模拟虚拟用户活动
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton1(Vector2.new(), camera.CFrame)
                        
                        -- 模拟移动：做圆周运动
                        local angle = (elapsed * 2) % (math.pi * 2) -- 随时间变化的角度
                        local radius = 2 -- 移动半径
                        local offset = Vector3.new(
                            math.sin(angle) * radius,
                            0,
                            math.cos(angle) * radius
                        )
                        rootPart.CFrame = CFrame.new(oldPos + offset)
                        
                        -- 模拟视角转动：让视角跟随移动方向
                        local lookAt = rootPart.Position + Vector3.new(
                            math.sin(angle + math.pi/2) * 10,
                            0,
                            math.cos(angle + math.pi/2) * 10
                        )
                        camera.CFrame = CFrame.lookAt(rootPart.Position, lookAt)
                        
                        -- 模拟按键输入
                        if elapsed % 1 < 0.5 then
                            game:GetService("ContextActionService"):BindAction("AntiAfk", function() end, false, Enum.KeyCode.W)
                        else
                            game:GetService("ContextActionService"):BindAction("AntiAfk", function() end, false, Enum.KeyCode.A)
                        end
                        
                        -- 模拟跳跃动作
                        if elapsed % 2 < 0.1 then
                            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                        end
                    end)
                    
                    -- 等待活动完成
                    task.wait(duration)
                    
                    -- 恢复原始位置
                    rootPart.CFrame = CFrame.new(oldPos)
                    camera.CFrame = oldCFrame
                    
                    -- 清理
                    game:GetService("ContextActionService"):UnbindAction("AntiAfk")
                end
            end
        end)
        
        -- 等待下一次执行
        if getgenv().AntiAfk then
            task.wait(120) -- 等待2分钟
        end
    end
end

-- 在主要标签页添加反挂机开关
MainTab:Toggle("反挂机 (每2分钟，活动4秒)", "AntiAfk", false, function(Value)
    getgenv().AntiAfk = Value
    if Value then
        -- 启动反挂机线程，传入true表示立即执行一次
        coroutine.wrap(function()
            antiAfk(true) -- true表示立即执行
        end)()
        library:Notify({
            Title = "反挂机",
            Text = "已开启，立即执行一次活动\n之后每2分钟自动活动4秒",
            Duration = 4
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
AboutTab:Button("📌 版本：v0.9/Jin定制", function() end)
AboutTab:Button("📅 最后更新：2026年3月14日", function() end)
AboutTab:Button("──────────────────", function() end)
AboutTab:Button("💰 全图收集金币", function() end)
AboutTab:Button("🥚 自动购买蛋", function() end)
AboutTab:Button("🥚 自动打开隐藏蛋", function() end)
AboutTab:Button("📋 自动领取任务奖励", function() end)
AboutTab:Button("📍 场景传送功能", function() end)
AboutTab:Button("⏱️ 反挂机 (每5分钟)", function() end)
AboutTab:Button("──────────────────", function() end)
