-- ==========================================
-- 下面是加在 main.lua 最底下的【鸡蛋助手】
-- ==========================================
local TabServerMain = getgenv().SonyTabServerParent -- 拿到外面的服务器标签
if TabServerMain then
    -- 在同一个服务器标签下，建第二个重影框
    local EggModule = TabServerMain:CreateModule("鸡蛋助手", "search", {})
    
    EggModule:CreateButton("🚀 返回基地 (全图寻找鸡蛋)", function()
        local Players = game:GetService("Players")
        local Workspace = game:GetService("Workspace")
        local LocalPlayer = Players.LocalPlayer
        
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local myHrp = char.HumanoidRootPart
        
        if getgenv().SonyWindow then
            getgenv().SonyWindow:Notify({ Title = "返回基地", Content = "正在全图寻找鸡蛋...", Duration = 2 })
        end
        
        local found = false
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") or obj:IsA("BasePart") then
                -- 找名字带 Egg 的实体
                if string.find(string.lower(obj.Name), "egg") and not string.find(string.lower(obj.Name), "template") then
                    local pos = nil
                    if obj:IsA("Model") and obj.PrimaryPart then
                        pos = obj.PrimaryPart.Position
                    elseif obj:IsA("BasePart") then
                        pos = obj.Position
                    end
                    
                    if pos then
                        pcall(function()
                            myHrp.CFrame = CFrame.lookAt(pos + Vector3.new(0, 3, 0), pos)
                            myHrp.Velocity = Vector3.zero
                        end)
                        found = true
                        
                        -- 尝试自动触发拾取
                        for _, child in ipairs(obj:GetDescendants()) do
                            if child:IsA("ProximityPrompt") then
                                pcall(function() fireproximityprompt(child) end)
                            elseif child:IsA("ClickDetector") then
                                pcall(function() fireclickdetector(child) end)
                            end
                        end
                        break
                    end
                end
            end
        end
        
        if getgenv().SonyWindow then
            if found then
                getgenv().SonyWindow:Notify({ Title = "成功", Content = "已瞬移到最近的蛋旁边！", Duration = 3 })
            else
                getgenv().SonyWindow:Notify({ Title = "失败", Content = "没找到实体蛋！", Duration = 3 })
            end
        end
    end)
end
