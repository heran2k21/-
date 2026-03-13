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
-- 反挂机功能 - 每2分钟执行一次，模拟真实玩家行为
local function antiAfk(immediate)
    local player = game.Players.LocalPlayer
    local VirtualUser = game:GetService("VirtualUser")
    local runService = game:GetService("RunService")
    local userInputService = game:GetService("UserInputService")
    local tweenService = game:GetService("TweenService")
    
    -- 等待角色加载
    repeat task.wait() until player.Character
    
    -- 如果不是立即执行，先等待第一次
    if not immediate then
        task.wait(120) -- 首次等待2分钟
    end
    
    while getgenv().AntiAfk do
        -- 发送执行通知（只发送一次）
        library:Notify({
            Title = "🔄 反挂机执行",
            Text = "正在模拟玩家活动...",
            Duration = 2
        })
        
        pcall(function()
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                local humanoid = player.Character.Humanoid
                local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                local camera = game:GetService("Workspace").CurrentCamera
                
                if rootPart and camera then
                    -- 保存原始位置和视角
                    local oldPos = rootPart.Position
                    local oldCFrame = camera.CFrame
                    
                    -- 随机选择活动类型（让行为更自然）
                    local activityType = math.random(1, 3)
                    local duration = 3.5 + math.random() * 1.5 -- 3.5-5秒
                    
                    -- 创建更自然的移动和视角转动
                    local startTime = tick()
                    local connection
                    
                    connection = runService.Heartbeat:Connect(function()
                        local elapsed = tick() - startTime
                        if elapsed >= duration then
                            connection:Disconnect()
                            return
                        end
                        
                        -- 模拟玩家输入（最自然的反挂机方式）
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton1(Vector2.new(), camera.CFrame)
                        
                        -- 根据随机选择的活动类型执行不同行为
                        if activityType == 1 then
                            -- 类型1：原地轻微晃动 + 视角转动
                            local swayAmount = math.sin(elapsed * 5) * 0.3
                            rootPart.CFrame = CFrame.new(oldPos + Vector3.new(swayAmount, 0, 0))
                            
                            -- 视角缓慢转动
                            local lookAngle = elapsed * 30 -- 每秒转30度
                            camera.CFrame = CFrame.lookAt(
                                rootPart.Position,
                                rootPart.Position + Vector3.new(math.sin(math.rad(lookAngle)), 0, math.cos(math.rad(lookAngle)))
                            )
                            
                        elseif activityType == 2 then
                            -- 类型2：小范围走动 + 查看周围
                            local moveRadius = 1.5
                            local angle = elapsed * 2
                            local offset = Vector3.new(
                                math.sin(angle) * moveRadius,
                                0,
                                math.cos(angle) * moveRadius
                            )
                            rootPart.CFrame = CFrame.new(oldPos + offset)
                            
                            -- 视角跟随移动方向
                            local lookDir = (rootPart.Position + Vector3.new(math.sin(angle + 1), 0, math.cos(angle + 1)) - rootPart.Position).Unit
                            camera.CFrame = CFrame.lookAt(rootPart.Position, rootPart.Position + lookDir * 10)
                            
                        else
                            -- 类型3：模拟跳跃和转向
                            if elapsed % 2 < 0.2 then
                                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                            end
                            
                            -- 随机转向
                            rootPart.CFrame = CFrame.new(oldPos) * CFrame.Angles(0, math.rad(elapsed * 45), 0)
                            
                            -- 视角上下轻微移动（像在观察）
                            camera.CFrame = CFrame.lookAt(
                                rootPart.Position,
                                rootPart.Position + Vector3.new(0, math.sin(elapsed * 3) * 2, 10)
                            )
                        end
                        
                        -- 模拟按键（WASD随机按）
                        if math.random() < 0.3 then
                            local keys = {Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D}
                            local randomKey = keys[math.random(1, 4)]
                            game:GetService("ContextActionService"):BindAction("AntiAfk", function() end, false, randomKey)
                            task.wait(0.1)
                            game:GetService("ContextActionService"):UnbindAction("AntiAfk")
                        end
                    end)
                    
                    -- 等待活动完成
                    task.wait(duration)
                    
                    -- 平滑地回到原位（使用Tween）
                    if rootPart and camera then
                        local tweenInfo = TweenInfo.new(
                            0.5,
                            Enum.EasingStyle.Quad,
                            Enum.EasingDirection.Out
                        )
                        
                        local goals = {
                            CFrame = CFrame.new(oldPos)
                        }
                        
                        local tween = tweenService:Create(rootPart, tweenInfo, goals)
                        tween:Play()
                        
                        -- 视角慢慢转回
                        task.wait(0.1)
                        camera.CFrame = oldCFrame
                        
                        task.wait(0.4) -- 等待tween完成
                    end
                    
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
MainTab:Toggle("🛡️ 反挂机保护", "AntiAfk", false, function(Value)
    getgenv().AntiAfk = Value
    if Value then
        -- 启动反挂机线程，传入true表示立即执行一次
        coroutine.wrap(function()
            antiAfk(true)
        end)()
        library:Notify({
            Title = "🛡️ 反挂机已开启",
            Text = "保护已激活，每2分钟自动活动",
            Duration = 3
        })
    else
        library:Notify({
            Title = "🛡️ 反挂机关闭",
            Text = "保护已停用",
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
