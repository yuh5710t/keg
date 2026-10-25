local flatList = {}
for _, entry in ipairs(tabConfig) do
    if type(entry) == "string" then
        table.insert(flatList, { kind="tab", name=entry, group=nil })
    else
        local gname = entry.name
        local expanded = entry.expanded ~= false
        groupStates[gname] = { expanded = expanded }
        table.insert(flatList, { kind="group", name=gname, expanded=expanded })
        for _, sub in ipairs(entry.items or {}) do
            table.insert(flatList, { kind="tab", name=sub, group=gname })
        end
    end
end

local relayoutMenu
local tabIndexCounter = 0
for i, item in ipairs(flatList) do
    if item.kind == "group" then
        local gBtn = Instance.new("TextButton")
        gBtn.BackgroundTransparency = 1; gBtn.BorderSizePixel = 0
        gBtn.Text = ""; gBtn.AutoButtonColor = false
        gBtn.Size = UDim2.new(0, ITEM_W, 0, GROUP_H)
        gBtn.Position = UDim2.new(0, ITEM_PAD_X, 0, ITEM_START_Y)
        gBtn.ZIndex = Z+5; gBtn.Parent = navScroll
        local arrow = Instance.new("TextLabel")
        arrow.BackgroundTransparency = 1; arrow.Text = item.expanded and "v" or ">"
        arrow.TextColor3 = Theme.TEXT_MUTED; arrow.TextSize = 12
        arrow.Font = Enum.Font.GothamBold; arrow.TextXAlignment = Enum.TextXAlignment.Center
        arrow.Position = UDim2.new(0, 4, 0, 0); arrow.Size = UDim2.new(0, 18, 1, 0)
        arrow.ZIndex = Z+6; arrow.Parent = gBtn
        local glbl = Instance.new("TextLabel")
        glbl.BackgroundTransparency = 1; glbl.Text = item.name
        glbl.TextColor3 = Theme.TEXT_MUTED; glbl.TextSize = 10
        glbl.Font = FONT_MED; glbl.TextXAlignment = Enum.TextXAlignment.Left
        glbl.Position = UDim2.new(0, 26, 0, 0); glbl.Size = UDim2.new(1, -32, 1, 0)
        glbl.ZIndex = Z+6; glbl.Parent = gBtn
        item.arrow = arrow; item.button = gBtn; item.label = glbl
        gBtn.MouseButton1Click:Connect(function()
            local state = groupStates[item.name]
            if not state then return end
            state.expanded = not state.expanded
            item.expanded = state.expanded
            tw(arrow, EASE_SINE, { TextColor3 = state.expanded and Theme.PRIMARY or Theme.TEXT_MUTED })
            arrow.Text = state.expanded and "v" or ">"
            if relayoutMenu then relayoutMenu(true) end
        end)
    else
        tabIndexCounter = tabIndexCounter + 1
        local tabIdx = tabIndexCounter
        local btn=Instance.new("TextButton")
        btn.BackgroundColor3=Theme.WHITE; btn.BackgroundTransparency=1
        btn.BorderSizePixel=0; btn.Text=item.name
        btn.TextColor3=(tabIdx==1) and Theme.PRIMARY_DK or Theme.TEXT_MUTED
        btn.TextSize=cfg.tabSize or 11; btn.Font=FONT_MED
        btn.AutoButtonColor=false; btn.TextXAlignment=Enum.TextXAlignment.Left
        btn.Size=UDim2.new(0,ITEM_W,0,ITEM_H)
        btn.Position=UDim2.new(0,ITEM_PAD_X,0,ITEM_START_Y)
        btn.ZIndex=Z+5; corner(btn,8); btn.Parent=navScroll
        local capture=tabIdx
        btn.MouseButton1Click:Connect(function() selectTab(capture) end)
        tabButtons[tabIdx]=btn
        item.button = btn
        item.tabIdx = tabIdx
    end
end
relayoutMenu = function(animate)
    local y = ITEM_START_Y
    for _, item in ipairs(flatList) do
        if item.kind == "group" then
            item.targetY = y
            y = y + GROUP_H + 2
            if item.button then
                item.button.Visible = true
                if animate then tw(item.button, EASE, { Position = UDim2.new(0, ITEM_PAD_X, 0, item.targetY) })
                else item.button.Position = UDim2.new(0, ITEM_PAD_X, 0, item.targetY) end
            end
        else
            local shouldShow = true
            if item.group then
                local gs = groupStates[item.group]
                if gs and not gs.expanded then shouldShow = false end
            end
            item.targetY = y
            if shouldShow then y = y + ITEM_H + 4 end
            local btn = item.button
            if btn then
                local wasVisible = btn.Visible
                if shouldShow then
                    if not wasVisible then
                        btn.Position = UDim2.new(0, ITEM_PAD_X, 0, item.targetY)
                        btn.Visible = true
                        btn.TextTransparency = 1
                        if animate then tw(btn, EASE, { TextTransparency = 0 })
                        else btn.TextTransparency = 0 end
                    else
                        if animate then
                            tw(btn, EASE, { Position = UDim2.new(0, ITEM_PAD_X, 0, item.targetY), TextTransparency = 0 })
                        else
                            btn.Position = UDim2.new(0, ITEM_PAD_X, 0, item.targetY)
                            btn.TextTransparency = 0
                        end
                    end
                else
                    if wasVisible then
                        if animate then
                            tw(btn, EASE_IN, { TextTransparency = 1 })
                            task.delay(0.18, function()
                                if btn and btn.Parent then
                                    local gs = item.group and groupStates[item.group]
                                    if not (gs and gs.expanded) then
                                        btn.Visible = false
                                        btn.TextTransparency = 0
                                    end
                                end
                            end)
                        else
                            btn.Visible = false
                            btn.TextTransparency = 0
                        end
                    else
                        btn.Visible = false
                    end
                end
            end
        end
    end
    navScroll.CanvasSize = UDim2.new(0, 0, 0, y + 10)
end
relayoutMenu(false)
        pageContainer=Instance.new("Frame")
        pageContainer.BackgroundTransparency=1
        pageContainer.Position=UDim2.new(0,SIDEBAR_W,0,TITLE_H)
        pageContainer.Size=UDim2.new(1,-SIDEBAR_W,1,-TITLE_H)
        pageContainer.ZIndex=Z+3; pageContainer.ClipsDescendants=true; pageContainer.Parent=panel
        for i=1,#tabButtons do
            local p=Instance.new("CanvasGroup")
            p.BackgroundTransparency=1; p.Position=UDim2.new(0,0,0,0)
            p.Size=UDim2.new(1,0,1,0)
            p.GroupTransparency=(i==1) and 0 or 1
            p.Visible=(i==1); p.ZIndex=Z+3
            p.Parent=pageContainer; pages[i]=p
        end
        task.defer(function() task.wait(0.05); selectTab(1,false) end)
    end

    local body
    if hasTabs then body=pageContainer
    else
        body=Instance.new("Frame")
        body.Name="BodyHolder"; body.BackgroundTransparency=1
        body.Position=UDim2.new(0,0,0,TITLE_H); body.Size=UDim2.new(1,0,1,-TITLE_H)
        body.ZIndex=Z+1; body.Parent=panel
    end

    local ownedExternals = {}
    if shadow then table.insert(ownedExternals, shadow) end

    return {
        frame=panel, body=body, titleBar=titleBar, sidebar=sidebar,
        playerBar=playerBar, tabs=pages, selectTab=selectTab,
        panelStroke=panelStroke,
        getCurrentTab=function() return currentTab end,
        toggleMinimize=toggleMinimize,
        setPosition=function(nx,ny) panel.Position=UDim2.new(0,nx,0,ny) end,
        setSize=function(nw,nh) panel.Size=UDim2.new(0,nw,0,nh) end,
        destroy=function()
            tw(panel, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.In),
                { Size = UDim2.new(0, panel.Size.X.Offset * 0.85, 0, panel.Size.Y.Offset * 0.85),
                  Position = UDim2.new(0, panel.Position.X.Offset + panel.Size.X.Offset * 0.075,
                                       0, panel.Position.Y.Offset + panel.Size.Y.Offset * 0.075) })
            tw(panel, TweenInfo.new(0.22), { BackgroundTransparency = 1 })
            task.delay(0.28, function()
                if activeDropdownClose then pcall(activeDropdownClose); activeDropdownClose = nil end
                for _, ext in ipairs(ownedExternals) do pcall(function() if ext and ext.Parent then ext:Destroy() end end) end
                pcall(function() if panel then panel:Destroy() end end)
            end)
        end,
    }
end
-- ============ Button ============
local function createButton(parent, cfg)
    local isCard = cfg.layout == "card"
    local W = cfg.w or 120; local H = cfg.h or (isCard and 42 or 34)
    local X = cfg.x or 0; local Y = cfg.y or 0
    local btn = Instance.new("TextButton")
    local customBg = cfg.bgColor; local customTx = cfg.textColor; local customBd = cfg.borderColor
    btn.BackgroundColor3 = customBg or Theme.WHITE; btn.BorderSizePixel = 0
    btn.Text = isCard and "" or (cfg.text or "Button")
    btn.TextColor3 = customTx or Theme.PRIMARY; btn.TextSize = cfg.textSize or 12
    btn.Font = FONT_MED; btn.AutoButtonColor = false
    btn.Position = UDim2.new(0, X, 0, Y); btn.Size = UDim2.new(0, W, 0, H)
    btn.ZIndex = cfg.zIndex or 5; corner(btn, cfg.radius or 6)
    local st = stroke(btn, customBd or Theme.PRIMARY, 1); btn.Parent = parent
    local enabled = cfg.enabled ~= false
    local baseBg = customBg or Theme.WHITE
    local baseTx = customTx or Theme.PRIMARY
    local baseBd = customBd or Theme.PRIMARY
    local iconLabel, titleLabel
    if isCard then
        titleLabel = createLabel(btn, { text = cfg.text or "", x = cfg.paddingLeft or 14, y = 0, w = W - 46, h = H, textSize = cfg.textSize or 12, color = customTx or Theme.TEXT, font = FONT_MED, align = Enum.TextXAlignment.Left, zIndex = 6 })
        iconLabel = createLabel(btn, { text = cfg.icon or ">", x = W - 30, y = 0, w = 20, h = H, textSize = cfg.iconSize or 16, color = cfg.iconColor or Theme.PRIMARY, font = FONT_MED, align = Enum.TextXAlignment.Center, zIndex = 6 })
    end
    if not enabled then
        btn.BackgroundColor3 = Theme.DISABLED_BG
        if not isCard then btn.TextColor3 = Theme.DISABLED_FG end
        st.Color = Theme.BORDER
    end
    if cfg.favoriteId then createStar(btn, cfg.favoriteId, W - 24, 2) end
    if cfg.tooltip then
        btn.MouseEnter:Connect(function()
            local mp = UserInputService:GetMouseLocation()
            showTooltip(btn, cfg.tooltip, mp.X + 12, mp.Y + 12)
        end)
        btn.MouseLeave:Connect(function() hideTooltip() end)
    end
    btn.MouseEnter:Connect(function()
        if not enabled then return end
        tw(btn, EASE_FAST, { BackgroundColor3 = Theme.HOVER_BG, TextColor3 = Theme.PRIMARY_DK, Position = UDim2.new(0, X, 0, Y - 2) })
        tw(st, EASE_FAST, { Color = Theme.PRIMARY_DK })
        if iconLabel then
            tw(iconLabel, EASE_FAST, { TextColor3 = Theme.PRIMARY_DK })
            tw(iconLabel, EASE_SINE, { Position = UDim2.new(0, W - 26, 0, 0) })
        end
    end)    btn.MouseLeave:Connect(function()
        if not enabled then return end
        tw(btn, EASE_BACK, { BackgroundColor3 = baseBg, TextColor3 = baseTx, Position = UDim2.new(0, X, 0, Y) })
        tw(st, EASE, { Color = baseBd })
        if iconLabel then
            tw(iconLabel, EASE, { TextColor3 = baseTx })
            tw(iconLabel, EASE_SINE, { Position = UDim2.new(0, W - 30, 0, 0) })
        end
    end)
    btn.MouseButton1Down:Connect(function()
        if not enabled then return end
        local mx = UserInputService:GetMouseLocation()
        local btnPos = btn.AbsolutePosition
        ripple(btn, mx.X - btnPos.X, mx.Y - btnPos.Y, Theme.PRIMARY)
        tw(btn, EASE_FAST, { BackgroundColor3 = Theme.PRIMARY_DK, TextColor3 = Color3.fromRGB(255,255,255), Position = UDim2.new(0, X, 0, Y) })
        local t1 = TweenService:Create(btn, EASE_FAST, { Size = UDim2.new(0, W * 0.96, 0, H * 0.94) })
        t1.Completed:Connect(function() TweenService:Create(btn, EASE_BACK, { Size = UDim2.new(0, W, 0, H) }):Play() end)
        t1:Play()
    end)
    btn.MouseButton1Up:Connect(function()
        if not enabled then return end
        if btn:IsMouseOver() then
            tw(btn, EASE, { BackgroundColor3 = Theme.HOVER_BG, TextColor3 = Theme.PRIMARY_DK, Position = UDim2.new(0, X, 0, Y - 2) })
        else
            tw(btn, EASE_BACK, { BackgroundColor3 = baseBg, TextColor3 = baseTx, Position = UDim2.new(0, X, 0, Y) })
        end
    end)
    if cfg.onClick and enabled then
        btn.MouseButton1Click:Connect(function() shine(btn); cfg.onClick(btn) end)
    end
    return btn
end
-- ============ Toggle ============
local function createToggle(parent, cfg)
    local W, H = cfg.w or 36, cfg.h or 20
    local container = Instance.new("Frame")
    container.BackgroundTransparency=1
    container.Position=UDim2.new(0,cfg.x or 0,0,cfg.y or 0)
    container.Size=UDim2.new(0,W,0,H); container.ZIndex=cfg.zIndex or 5; container.Parent=parent
    local track=Instance.new("Frame")
    track.BackgroundColor3=Theme.TRACK; track.BorderSizePixel=0
    track.Size=UDim2.new(1,0,1,0); corner(track,H/2); track.ZIndex=5; track.Parent=container
    local knobSize=H-4
    local knob=Instance.new("Frame")
    knob.BackgroundColor3=Color3.fromRGB(255,255,255); knob.BorderSizePixel=0
    knob.Size=UDim2.new(0,knobSize,0,knobSize); knob.Position=UDim2.new(0,2,0,2)
    corner(knob,knobSize/2); knob.ZIndex=6; knob.Parent=container
    local ks = Instance.new("Frame")
    ks.BackgroundColor3 = Color3.fromRGB(0,0,0); ks.BackgroundTransparency = 0.85
    ks.BorderSizePixel = 0; ks.Size = UDim2.new(1, 0, 1, 0); ks.Position = UDim2.new(0, 0, 0, 1)
    corner(ks, knobSize/2); ks.ZIndex = 5; ks.Parent = knob
    local state=cfg.value or false; local onChange=cfg.onChange
    local onC = cfg.onColor or Theme.PRIMARY
    local offC = cfg.offColor or Theme.TRACK
    local function apply(animate,elastic)
        local info=animate and (elastic and EASE_ELASTIC or EASE) or EASE_NONE
        tw(track,animate and EASE or EASE_NONE,{BackgroundColor3=state and onC or offC})
        tw(knob,info,{Position=UDim2.new(0,state and (W-knobSize-2) or 2,0,2)})
    end
    apply(false,false)
    local click=Instance.new("TextButton")
    click.BackgroundTransparency=1; click.Text=""; click.AutoButtonColor=false
    click.Size=UDim2.new(1,0,1,0); click.ZIndex=7; click.Parent=container
    click.MouseEnter:Connect(function()
        if not state then tw(track, EASE_FAST, { BackgroundColor3 = Color3.fromRGB(210,214,220) }) end
    end)
    click.MouseLeave:Connect(function()
        if not state then tw(track, EASE, { BackgroundColor3 = offC }) end
    end)
    click.MouseButton1Click:Connect(function()
        state=not state
        tw(container, EASE_FAST, { Size = UDim2.new(0, W - 2, 0, H - 2) })
        task.delay(0.12, function() tw(container, EASE_BACK, { Size = UDim2.new(0, W, 0, H) }) end)
        apply(true,true)
        if onChange then onChange(state) end
    -- 把所有 UI 对象挂载到全局
    _G.ui = {}
    _G.ui.Theme = Theme
    _G.ui.ScreenGui = uiGui
    _G.ui.Ease = { NORMAL=EASE, FAST=EASE_FAST, BACK=EASE_BACK, IN=EASE_IN, SOFT=EASE_SOFT, ELASTIC=EASE_ELASTIC }
    _G.ui.createPanel = function(cfg) cfg=cfg or {}; return createPanel(resolveParent(cfg), cfg) end
    _G.ui.createLabel = function(cfg) cfg=cfg or {}; return createLabel(resolveParent(cfg), cfg) end
    _G.ui.createButton = function(cfg) cfg=cfg or {}; return createButton(resolveParent(cfg), cfg) end
    _G.ui.createToggle = function(cfg) cfg=cfg or {}; return createToggle(resolveParent(cfg), cfg) end
    _G.ui.notify = function(cfg) createToast(cfg or {}) end
    _G.ui.showTooltip = function(target, text, x, y) showTooltip(target, text, x, y) end
    _G.ui.hideTooltip = function() hideTooltip() end
    _G.ui.setFavoriteMode = function(v) setFavoriteMode(v) end
end

-- 运行 UI 库
__lumen_ui_lib()
local ui = _G.ui

-- 获取服务
local Players = game:GetService("Players")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")

-- 欢迎提示
task.delay(0.5, function()
    ui.notify({ type = "success", title = "影月脚本", message = "脚本加载成功", duration = 4 })
end)

-- 核心变量
local espHighlights = {}
local espBillboards = {}
local teamGlowHighlights = {}
local enemyGlowHighlights = {}
local _toggleConns = {}

-- 功能开关处理函数
local function handleFeatureToggle(runCode, enabled)
    if enabled then
        if runCode == "night" then Lighting.Brightness = 2; Lighting.ClockTime = 14
        elseif runCode == "god" then 
            local c = Players.LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then c.Humanoid.MaxHealth = 99999; c.Humanoid.Health = 99999 end
        elseif runCode == "superspeed" then
            local c = Players.LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = 1000 end
        elseif runCode == "invisible" then
            local c = Players.LocalPlayer.Character
            if c then for _, v in ipairs(c:GetDescendants()) do
                if v:IsA("BasePart") then v.Transparency = 0.8 end
            end end
        end
    else
        if runCode == "night" then Lighting.Brightness = 1; Lighting.GlobalShadows = true
        elseif runCode == "superspeed" then
            local c = Players.LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = 16 end
        elseif runCode == "invisible" then
            local c = Players.LocalPlayer.Character
            if c then for _, v in ipairs(c:GetDescendants()) do
                if v:IsA("BasePart") then v.Transparency = 0 end
            end end
        end
    end
end
-- ============ 收集所有功能 ============
local pageContents = {
    ["公告"] = {type = "text"},
    ["通用"] = {
        type = "toggles",
        items = {
            {type = "button", name = "飞行模式", desc = "远程加载飞行脚本", icon = "🕊️", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/refs/heads/main/%E9%A3%9E%E9%A5%BC"},
            {type = "button", name = "传送玩家", desc = "选择玩家传送到旁边", icon = "📬", url = "teleport"},
            {type = "toggle", name = "无敌模式", desc = "免疫伤害（客户端）", icon = "🛡️", code = "god"},
            {type = "toggle", name = "千倍速度", desc = "移动速度1000", icon = "⚡", code = "superspeed"},
            {type = "toggle", name = "隐身模式", desc = "别人看不到你", icon = "👻", code = "invisible"},
            {type = "toggle", name = "夜视功能", desc = "提高黑暗视野亮度", icon = "🔦", code = "night"},
        }
    },
    ["战斗功能"] = {
        type = "toggles",
        items = {
            {type = "toggle", name = "团队高亮", desc = "队友蓝色高亮", icon = "🔵", code = "teamglow"},
            {type = "toggle", name = "敌对高亮", desc = "敌人红色高亮", icon = "🔴", code = "enemyglow"},
        }
    },
}

local TAB_NAMES = {"公告", "通用", "战斗功能"}
local findTabIndex
do
    local m = {}
    for i, n in ipairs(TAB_NAMES) do m[n] = i end
    findTabIndex = function(n) return m[n] end
end

local mainWin
local function closeAll()
    if mainWin then pcall(function() mainWin:destroy() end) end
end

mainWin = ui.createPanel({
    w = 500, h = 340,
    title = "影月脚本",
    tabs = TAB_NAMES,
    sidebarWidth = 100,
    showPlayer = true,
    center = true,
    onClose = function()
        closeAll()
    end,
})

-- ============ 公告页（更新公告版） ============
local function buildAnnouncementPage(page)
    local timeLabel = ui.createLabel({
        parent = page, x = 20, y = 20, w = 340, h = 280,
        text = "", textSize = 12,
        color = Color3.fromRGB(70, 70, 70),
        vAlign = Enum.TextYAlignment.Top, wrapped = true,
    })
    task.spawn(function()
        while mainWin and mainWin.frame and mainWin.frame.Parent do
            pcall(function()
                timeLabel.Text =
                    "【影月脚本·更新公告】\n\n" ..
                    "👤 作者：影月\n" ..
                    "📅 版本：V2.0 稳定版\n" ..
                    "🔥 本次更新：优化了 UI 库，删除了失效功能，调整了界面排版。\n" ..
                    "🎁 本脚本完全免费开源，切勿倒卖！\n" ..
                    "⚠️ 免责声明：本脚本仅供学习交流，使用造成的任何后果由使用者自行承担。\n\n" ..
                    "🎉 感谢您的使用与支持！"
            end)
            task.wait(1)
        end
    end)
end
    end)
    return {container=container,getValue=function() return state end}
end    -- ============ 页面生成 ============
    local CW = 380
    local PAD = 8
    local CARD_H = 42
    local CARD_GAP = 6

    local function makeScrollFrame(parent)
        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.new(1, 0, 1, 0)
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 4
        scroll.ScrollBarImageColor3 = Color3.fromRGB(180, 180, 180)
        scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scroll.Parent = parent
        return scroll
    end

    local function renderItem(scroll, item, pageType, yPos)
        local t = item.type or pageType
        if t == "button" then
            ui.createButton({
                parent = scroll, x = PAD, y = yPos, w = CW, h = CARD_H,
                layout = "card",
                text = (item.icon or "") .. "  " .. (item.name or ""),
                icon = ">", textSize = 11,
                onClick = function()
                    if item.url == "teleport" then
                        -- 传送逻辑
                    elseif item.url then
                        task.spawn(function()
                            pcall(function() loadstring(game:HttpGet(item.url))() end)
                        end)
                    end
                end,
            })
            return yPos + CARD_H + CARD_GAP
        elseif t == "toggle" then
            local card = Instance.new("Frame")
            card.Size = UDim2.new(0, CW, 0, CARD_H)
            card.Position = UDim2.new(0, PAD, 0, yPos)
            card.BackgroundColor3 = Color3.fromRGB(252, 252, 252)
            card.BorderSizePixel = 0
            card.Parent = scroll
            Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)
            ui.createLabel({ parent = card, x = 10, y = 5, w = CW - 60, h = 16, text = (item.icon or "") .. "  " .. (item.name or ""), textSize = 11 })
            ui.createLabel({ parent = card, x = 30, y = 22, w = CW - 80, h = 14, text = item.desc or "", textSize = 9, color = Color3.fromRGB(130, 130, 130) })
            ui.createToggle({
                parent = card, x = CW - 46, y = 11, w = 36, h = 20,
                value = false,
                onChange = function(v) pcall(handleFeatureToggle, item.code, v) end,
            })
            return yPos + CARD_H + CARD_GAP
        end
        return yPos
    end

    for pageName, contentData in pairs(pageContents) do
        local idx = findTabIndex(pageName)
        if idx and mainWin.tabs[idx] then
            local page = mainWin.tabs[idx]
            if pageName == "公告" then
                buildAnnouncementPage(page)
            else
                local scroll = makeScrollFrame(page)
                local yPos = 8
                for _, item in ipairs(contentData.items or {}) do
                    yPos = renderItem(scroll, item, contentData.type, yPos)
                end
            end
        end
    end

    print("[影月脚本 V2.0] 加载完成")
end)
