
local Material = loadstring(game:HttpGet("https://raw.githubusercontent.com/heran2k21/-/refs/heads/main/%E6%B5%8B%E8%AF%95UI"))()

-- 创建主标签页
local MainTab = library:CreateTab("主要")
local OtherTab = library:CreateTab("其他")
local ContactTab = library:CreateTab("联系")

-- 联系标签页的按钮
ContactTab:Button("添加Wechat", function()
    setclipboard("heran01227")
    toclipboard("heran01227")
    library:Notify({
        Title = "复制成功",
        Text = "微信号已复制到剪贴板",
        Duration = 3
    })
end)

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

-- 添加一些其他功能到"其他"标签页
OtherTab:Button("获取所有蛋名称", function()
    local eggList = ""
    for i, eggName in pairs(Egg) do
        eggList = eggList .. eggName .. "\n"
    end
    setclipboard(eggList)
    library:Notify({
        Title = "复制成功",
        Text = "蛋列表已复制到剪贴板",
        Duration = 3
    })
end)

OtherTab:Button("获取所有区域名称", function()
    local areaList = ""
    for i, areaName in pairs(Area) do
        areaList = areaList .. areaName .. "\n"
    end
    setclipboard(areaList)
    library:Notify({
        Title = "复制成功",
        Text = "区域列表已复制到剪贴板",
        Duration = 3
    })
end)

-- 添加一个重置所有开关的按钮
OtherTab:Button("关闭所有功能", function()
    getgenv().CollectCoins = false
    getgenv().BuyEggs = false
    getgenv().OpenHiddenEggs = false
    getgenv().ClaimRewards = false
    
    -- 更新UI开关状态
    library.flags["CollectCoins"]:SetState(false)
    library.flags["BuyEggs"]:SetState(false)
    library.flags["OpenHiddenEggs"]:SetState(false)
    library.flags["ClaimRewards"]:SetState(false)
    
    library:Notify({
        Title = "已关闭",
        Text = "所有自动功能已关闭",
        Duration = 2
    })
end)

-- 添加版本信息
local VersionLabel = Instance.new("TextLabel")
VersionLabel.Parent = MainTab[1]  -- MainTab[1] 是 ScrollingFrame
VersionLabel.Size = UDim2.new(0, 312, 0, 20)
VersionLabel.BackgroundTransparency = 1
VersionLabel.Text = "收集所有宠物丨By:Heran  v1.0"
VersionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
VersionLabel.TextSize = 12
VersionLabel.Font = Enum.Font.Gotham
