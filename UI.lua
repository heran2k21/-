-- 加载Material UI库
local Material = loadstring(game:HttpGet("https://raw.githubusercontent.com/your-repo/material-ui/main/library.lua"))()

-- 创建主窗口
local MainWindow = Material.Load({
    Title = "示例窗口",
    Style = 1,
    SizeX = 400,
    SizeY = 500,
    Theme = "Dark"
})

-- 添加一个标签页
local Tab = MainWindow.New({
    Title = "主标签页",
    Icon = "rbxassetid://1234567890" -- 可选的图标ID
})

-- 添加一个按钮
Tab.Button({
    Text = "点击我",
    Callback = function()
        print("按钮被点击了!")
    end
})

-- 添加一个开关
Tab.Toggle({
    Text = "启用功能",
    Callback = function(Value)
        print("开关状态:", Value)
    end
})

-- 添加一个滑块
Tab.Slider({
    Text = "音量控制",
    Callback = function(Value)
        print("音量设置为:", Value)
    end,
    Min = 0,
    Max = 100,
    Def = 50
})

-- 添加一个下拉菜单
Tab.Dropdown({
    Text = "选择选项",
    Callback = function(Value)
        print("选择了:", Value)
    end,
    Options = {"选项1", "选项2", "选项3"}
})
