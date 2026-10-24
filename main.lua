-- ==========================================
-- 巨魔专属 - KEG 力量传奇完整版 (极速加载)
-- ==========================================
local WindUI = loadstring(game:HttpGet("https://cdn.jsdelivr.net/gh/kitten-maomao/cdnUI/WindQW.lua"))()

local VirtualUser = game:GetService("VirtualUser")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- 防挂机
LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)

-- 建立漂亮的原版窗口
local Window = WindUI:CreateWindow({
    Title = "<font color='#FFC0CB'><b>巨魔</b></font>",
    Author = "<font color='#FFC0CB'><b>地利</b></font>",
    Size = UDim2.fromOffset(390, 460),
    Theme = "Dark",
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 165, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 192, 203))
    }),
})

Window:EditOpenButton({
    Title = "<font color='#FFC0CB'><b>巨魔菜单</b></font>",
    Draggable = true,
})

local Tabs = {}
function Tabs:Create(name, icon) return Window:Tab({ Title = name, Icon = icon }) end

-- ================= 锻炼功能 =================
Tabs.Player = Tabs:Create("<font color='#FFC0CB'>锻炼</font>", "dumbbell")
local workType = ""
local autowork = false
local autorebirth = false

Tabs.Player:Dropdown({
    Title = "<font color='#FFC0CB'><b>选择锻炼类型</b></font>",
    Values = { "哑铃", "倒立", "仰卧起坐", "俯卧撑" },
    Callback = function(val) workType = val end
})

Tabs.Player:Toggle({
    Title = "<font color='#FFC0CB'><b>自动锻炼</b></font>",
    Callback = function(state)
        autowork = state
        if state then
            task.spawn(function()
                while autowork do
                    pcall(function()
                        local char = LocalPlayer.Character
                        local backpack = LocalPlayer.Backpack
                        if not char then return end
                        LocalPlayer.muscleEvent:FireServer("rep")
                        local toolName = ""
                        if workType == "哑铃" then toolName = "Weight"
                        elseif workType == "倒立" then toolName = "Handstands"
                        elseif workType == "仰卧起坐" then toolName = "Situps"
                        elseif workType == "俯卧撑" then toolName = "Pushups"
                        end
                        if toolName ~= "" and backpack:FindFirstChild(toolName) then
                            char.Humanoid:EquipTool(backpack[toolName])
                        end
                    end)
                    task.wait()
                end
            end)
        end
    end
})

Tabs.Player:Toggle({
    Title = "<font color='#FFC0CB'><b>自动重生</b></font>",
    Callback = function(state)
        autorebirth = state
        if state then
            task.spawn(function()
                while autorebirth do
                    pcall(function()
                        local rebirthRemote = ReplicatedStorage.rEvents.rebirthRemote
                        if rebirthRemote then
                            rebirthRemote:InvokeServer("rebirthRequest")
                            task.wait(0.5)
                        end
                    end)
                    task.wait(0.1)
                end
            end)
        end
    end
})

-- ================= 传送功能 =================
Tabs.TP = Tabs:Create("<font color='#FFC0CB'>传送</font>", "map-pin")
local points = {
    {"大厅", CFrame.new(2.93, 88.93, 243.94)},
    {"冰霜健身房", CFrame.new(-2623.02, 7.38, -409.07)},
    {"神话健身房", CFrame.new(2250.77, 7.38, 1073.22)},
    {"传奇健身房", CFrame.new(4603.28, 991.53, -3897.86)}
}
for _, p in ipairs(points) do
    Tabs.TP:Button({ Title = "<font color='#FFC0CB'>传送: "..p[1].."</font>", Callback = function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = p[2]
        end
    end })
end

-- ================= 其他功能 =================
Tabs.Other = Tabs:Create("<font color='#FFC0CB'>其他</font>", "settings")
local punstone = false
Tabs.Other:Toggle({ Title = "<font color='#FFC0CB'><b>自动挥拳</b></font>", Callback = function(s) punstone = s end })
task.spawn(function()
    while true do
        if punstone then
            pcall(function()
                LocalPlayer.muscleEvent:FireServer("punch", "leftHand")
                local punch = LocalPlayer.Backpack:FindFirstChild("Punch")
                if punch then LocalPlayer.Character.Humanoid:EquipTool(punch) end
            end)
        end
        task.wait()
    end
end)
