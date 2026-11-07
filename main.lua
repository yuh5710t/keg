--索尼中心 主菜单
local UI_URL = "https://sikon.226618.xyz/moon lua UI源码.lua"

local ok, Library = pcall(function()
    return loadstring(game:HttpGet(UI_URL))()
end)

if not ok or type(Library) ~= "table" then
    warn("UI 库加载失败: " .. tostring(Library))
    return
end

-- 创建主窗口
local Window = Library:CreateWindow({
    Name              = "索尼中心",
    Title             = "索尼中心",
    Version           = "v1.5",
    Theme             = "Nord",
    Backdrop          = true,
    ShowBackdrop      = true,
    GradientAnimation = true,
    ConfigFolder      = "索尼中心",
    SearchTab         = false,
    Visible           = true,
})

-- 创建【服务器】标签
local TabServer = Window:CreateTab("服务器")
-- 你的 UI 库需要先建一个 Module 才能画东西
local PageServer = TabServer:CreateModule("虫子进化", "zap", {})

-- 把窗口和画板存进全局，让你 GitHub 上的源码能拿到
getgenv().SonyWindow = Window
getgenv().SonyPage = PageServer

-- 直接执行你的外链
local success, err = pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/yuh5710t/jhj-hd/main/main.lua"))()
end)

if not success then
    warn("外链加载失败: " .. tostring(err))
    PageServer:CreateButton("❌ 外链加载失败，点我查看原因", function()
        Window:Notify({ Title = "错误", Content = tostring(err), Duration = 5 })
    end)
end

-- 配置页
local TabConfig = Window:CreateTab("配置")
local PageStyle = TabConfig:CreateModule("外观", "palette", {})
PageStyle:CreateButton("隐藏菜单", function() Window:Hide() end)
PageStyle:CreateButton("显示菜单", function() Window:Show() end)
