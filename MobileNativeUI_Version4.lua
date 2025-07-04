--[[
MobileNativeUI.lua
Mobile-friendly, native Roblox UI library
Supports: draggable window, tabs, button, toggle, slider, input, dropdown, label, section, utilities.
Author: yachiru-1337
--]]

local MobileNativeUI = {}
MobileNativeUI.__index = MobileNativeUI

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

--[[
UTILITIES
--]]

-- Touch/desktop draggable frame
local function makeDraggable(frame, dragArea)
    local dragging, dragStart, startPos

    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragArea.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Add vertical layout and padding
local function addLayout(container, pad)
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, pad or 8)
    padding.PaddingBottom = UDim.new(0, pad or 8)
    padding.PaddingLeft = UDim.new(0, pad or 8)
    padding.PaddingRight = UDim.new(0, pad or 8)
    padding.Parent = container
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    layout.Parent = container
    return layout
end

-- Animate (optional, for visual feedback)
local function animateButton(btn)
    local orig = btn.BackgroundColor3
    local t = TweenService:Create(btn, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.new(1,1,1)})
    t:Play()
    t.Completed:Wait()
    TweenService:Create(btn, TweenInfo.new(0.16, Enum.EasingStyle.Quad), {BackgroundColor3 = orig}):Play()
end

--[[
WINDOW
--]]
function MobileNativeUI:CreateWindow(opt)
    local player = game.Players.LocalPlayer
    assert(player, "Player not found")

    local gui = Instance.new("ScreenGui")
    gui.Name = "MobileNativeUI"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.Parent = player:FindFirstChildOfClass("PlayerGui") or player.PlayerGui

    local win = Instance.new("Frame")
    win.Name = "Window"
    win.Size = UDim2.new(0.94, 0, 0.7, 0)
    win.Position = UDim2.new(0.03, 0, 0.18, 0)
    win.BackgroundColor3 = Color3.fromRGB(32,32,32)
    win.BackgroundTransparency = 0.08
    win.BorderSizePixel = 0
    win.AnchorPoint = Vector2.new(0,0)
    win.Active = true
    win.Parent = gui

    -- Titlebar
    local titlebar = Instance.new("Frame")
    titlebar.Name = "TitleBar"
    titlebar.Size = UDim2.new(1, 0, 0, 40)
    titlebar.BackgroundColor3 = Color3.fromRGB(45,45,45)
    titlebar.BorderSizePixel = 0
    titlebar.Parent = win

    local title = Instance.new("TextLabel")
    title.Text = (opt and opt.Title) or "MobileNativeUI"
    title.Size = UDim2.new(1, -40, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextColor3 = Color3.new(1,1,1)
    title.TextSize = 24
    title.Font = Enum.Font.GothamBold
    title.Parent = titlebar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 40, 1, 0)
    closeBtn.Position = UDim2.new(1, -40, 0, 0)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "✕"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 28
    closeBtn.TextColor3 = Color3.new(1,0.4,0.4)
    closeBtn.Parent = titlebar

    local tabbar = Instance.new("Frame")
    tabbar.Name = "TabBar"
    tabbar.Size = UDim2.new(1,0,0,38)
    tabbar.Position = UDim2.new(0,0,0,40)
    tabbar.BackgroundColor3 = Color3.fromRGB(38,38,38)
    tabbar.BorderSizePixel = 0
    tabbar.Parent = win

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Parent = tabbar

    local tabContents = {}
    local currentTab

    local function switchTab(tabName)
        for name, content in pairs(tabContents) do
            content.Visible = (name == tabName)
        end
        for _, btn in ipairs(tabbar:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.BackgroundColor3 = (btn.Name == tabName) and Color3.fromRGB(48,115,255) or Color3.fromRGB(38,38,38)
                btn.TextColor3 = (btn.Name == tabName) and Color3.new(1,1,1) or Color3.fromRGB(180,180,180)
            end
        end
        currentTab = tabName
    end

    -- API
    local api = {}

    function api:CreateTab(tabName)
        local tabBtn = Instance.new("TextButton")
        tabBtn.Name = tabName
        tabBtn.Size = UDim2.new(0, math.max(100, tabName:len()*12+20), 1, 0)
        tabBtn.BackgroundColor3 = Color3.fromRGB(38,38,38)
        tabBtn.Text = tabName
        tabBtn.Font = Enum.Font.GothamBold
        tabBtn.TextSize = 19
        tabBtn.TextColor3 = Color3.fromRGB(180,180,180)
        tabBtn.AutoButtonColor = true
        tabBtn.Parent = tabbar

        local tabFrame = Instance.new("ScrollingFrame")
        tabFrame.Name = tabName .. "_Content"
        tabFrame.Size = UDim2.new(1,0,1,-78)
        tabFrame.Position = UDim2.new(0,0,0,78)
        tabFrame.CanvasSize = UDim2.new(0,0,1,0)
        tabFrame.BackgroundTransparency = 1
        tabFrame.ScrollBarThickness = 8
        tabFrame.Visible = false
        tabFrame.Parent = win
        addLayout(tabFrame, 12)
        tabContents[tabName] = tabFrame

        tabBtn.MouseButton1Click:Connect(function()
            switchTab(tabName)
        end)

        if not currentTab then
            switchTab(tabName)
        end

        -- Tab API
        local tabAPI = {}

        function tabAPI:Label(text)
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 0, 32)
            label.BackgroundTransparency = 1
            label.Text = text
            label.Font = Enum.Font.Gotham
            label.TextSize = 18
            label.TextColor3 = Color3.new(1,1,1)
            label.TextWrapped = true
            label.Parent = tabFrame
            return label
        end

        function tabAPI:Button(text, callback)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 40)
            btn.BackgroundColor3 = Color3.fromRGB(48, 115, 255)
            btn.Text = text
            btn.Font = Enum.Font.GothamSemibold
            btn.TextSize = 20
            btn.TextColor3 = Color3.new(1,1,1)
            btn.AutoButtonColor = true
            btn.BorderSizePixel = 0
            btn.Parent = tabFrame
            btn.MouseButton1Click:Connect(function()
                animateButton(btn)
                if callback then callback() end
            end)
            return btn
        end

        function tabAPI:Toggle(text, default, callback)
            local state = default or false
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 40)
            btn.BackgroundColor3 = state and Color3.fromRGB(60, 180, 60) or Color3.fromRGB(60, 60, 60)
            btn.Text = text .. ": " .. (state and "ON" or "OFF")
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 20
            btn.TextColor3 = Color3.new(1,1,1)
            btn.AutoButtonColor = true
            btn.BorderSizePixel = 0
            btn.Parent = tabFrame
            btn.MouseButton1Click:Connect(function()
                state = not state
                btn.BackgroundColor3 = state and Color3.fromRGB(60, 180, 60) or Color3.fromRGB(60, 60, 60)
                btn.Text = text .. ": " .. (state and "ON" or "OFF")
                animateButton(btn)
                if callback then callback(state) end
            end)
            return btn
        end

        function tabAPI:Slider(text, min, max, value, callback)
            local holder = Instance.new("Frame")
            holder.Size = UDim2.new(1, 0, 0, 50)
            holder.BackgroundTransparency = 1
            holder.Parent = tabFrame

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 0, 24)
            label.Position = UDim2.new(0, 0, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = string.format("%s: %s", text, tostring(value))
            label.Font = Enum.Font.Gotham
            label.TextSize = 17
            label.TextColor3 = Color3.new(1,1,1)
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = holder

            local sliderFrame = Instance.new("Frame")
            sliderFrame.Size = UDim2.new(1, -20, 0, 18)
            sliderFrame.Position = UDim2.new(0, 10, 0, 26)
            sliderFrame.BackgroundColor3 = Color3.fromRGB(60,60,60)
            sliderFrame.BorderSizePixel = 0
            sliderFrame.Parent = holder

            local knob = Instance.new("Frame")
            knob.Size = UDim2.new(0, 18, 1, 0)
            knob.Position = UDim2.new((value-min)/(max-min), -9, 0, 0)
            knob.BackgroundColor3 = Color3.fromRGB(48, 115, 255)
            knob.BorderSizePixel = 0
            knob.Parent = sliderFrame

            knob.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    local conn; conn = UserInputService.InputChanged:Connect(function(inp)
                        if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
                            local rel = (inp.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X
                            rel = math.clamp(rel, 0, 1)
                            local sliderVal = math.floor((min + (max - min) * rel)*100)/100
                            knob.Position = UDim2.new(rel, -9, 0, 0)
                            label.Text = string.format("%s: %s", text, tostring(sliderVal))
                            if callback then callback(sliderVal) end
                        end
                    end)
                    input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then
                            if conn then conn:Disconnect() end
                        end
                    end)
                end
            end)

            return holder
        end

        function tabAPI:Input(placeholder, callback)
            local box = Instance.new("TextBox")
            box.Size = UDim2.new(1, 0, 0, 38)
            box.BackgroundColor3 = Color3.fromRGB(38,38,38)
            box.Text = ""
            box.PlaceholderText = placeholder or "Type..."
            box.Font = Enum.Font.Gotham
            box.TextSize = 18
            box.TextColor3 = Color3.new(1,1,1)
            box.ClearTextOnFocus = false
            box.Parent = tabFrame
            box.FocusLost:Connect(function(enter)
                if enter and callback then callback(box.Text) end
            end)
            return box
        end

        function tabAPI:Dropdown(text, options, defaultOption, callback)
            local holder = Instance.new("Frame")
            holder.Size = UDim2.new(1, 0, 0, 44)
            holder.BackgroundTransparency = 1
            holder.Parent = tabFrame

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 1, 0)
            btn.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 18
            btn.TextColor3 = Color3.new(1,1,1)
            btn.Text = text .. ": " .. (defaultOption or "Select")
            btn.Parent = holder

            local selected = defaultOption or options[1]
            btn.MouseButton1Click:Connect(function()
                local idx = table.find(options, selected) or 0
                idx = idx % #options + 1
                selected = options[idx]
                btn.Text = text .. ": " .. selected
                animateButton(btn)
                if callback then callback(selected) end
            end)
            return holder
        end

        function tabAPI:Section(text)
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 0, 28)
            label.BackgroundTransparency = 1
            label.TextColor3 = Color3.fromRGB(140,180,255)
            label.Font = Enum.Font.GothamBold
            label.TextSize = 19
            label.Text = text
            label.Parent = tabFrame
            return label
        end

        return tabAPI
    end

    function api:Unload()
        gui:Destroy()
    end

    closeBtn.MouseButton1Click:Connect(function()
        api:Unload()
    end)

    makeDraggable(win, titlebar)

    return api
end

return setmetatable({}, MobileNativeUI)
