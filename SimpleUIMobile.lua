--[[
    SimpleMobileUI - ImGui-like, mobile-friendly, no dependencies!
    Copyright (c) 2024 RavKyut
    Permission is hereby granted to use, modify, and distribute this code with attribution.

    Features: Window, Button, Toggle, Label, Slider, Dropdown (ComboBox)
    Usage:
        local UI = loadstring(game:HttpGet("RAW_GITHUB_URL_TO_THIS_SCRIPT"))()
        local win = UI:Window("My Menu")
        win:Button("Click Me!", function() print("Clicked!") end)
        win:Toggle("Auto-Farm", function(val) print("Auto-Farm:", val) end)
        win:Label("Status: Ready")
        win:Slider("Value", 1, 100, 50, function(val) print("Slider:", val) end)
        win:Dropdown("Fruit", {"Apple","Banana","Orange"}, function(opt) print("Picked:", opt) end)
]]

local SimpleMobileUI = {}

-- Settings
local WINDOW_WIDTH = 320
local WINDOW_HEIGHT = 420
local BUTTON_HEIGHT = 42
local TOGGLE_HEIGHT = 42
local DROPDOWN_HEIGHT = 42
local FONT = Enum.Font.SourceSansSemibold
local TEXT_SIZE = 22
local PADDING = 10

-- Theme
local COLORS = {
    WindowBg    = Color3.fromRGB(40, 40, 45),
    ButtonBg    = Color3.fromRGB(60, 180, 80),
    ButtonText  = Color3.fromRGB(255,255,255),
    ToggleBg    = Color3.fromRGB(40, 125, 180),
    ToggleOn    = Color3.fromRGB(40,200,100),
    ToggleOff   = Color3.fromRGB(170,40,40),
    LabelText   = Color3.fromRGB(255,255,255),
    TitleBar    = Color3.fromRGB(25, 60, 25),
    DropdownBg  = Color3.fromRGB(60, 60, 65),
    DropdownItemBg = Color3.fromRGB(48, 100, 160),
    DropdownItemText = Color3.fromRGB(255,255,255),
}

function SimpleMobileUI:Window(title)
    -- Main window frame
    local gui = Instance.new("ScreenGui")
    gui.IgnoreGuiInset = true
    gui.Name = "SimpleMobileUI_" .. tostring(math.random(1,9999))
    gui.ResetOnSpawn = false
    gui.Parent = game:GetService("Players").LocalPlayer:FindFirstChildOfClass("PlayerGui")

    -- Drag support
    local dragging, dragStart, dragPos

    -- Root window
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, WINDOW_WIDTH, 0, WINDOW_HEIGHT)
    frame.Position = UDim2.new(0.5, -WINDOW_WIDTH/2, 0.5, -WINDOW_HEIGHT/2)
    frame.BackgroundColor3 = COLORS.WindowBg
    frame.BorderSizePixel = 0
    frame.AnchorPoint = Vector2.new(0.5,0.5)
    frame.Parent = gui

    -- Title bar
    local titleBar = Instance.new("TextButton")
    titleBar.Size = UDim2.new(1,0,0,48)
    titleBar.Position = UDim2.new(0,0,0,0)
    titleBar.BackgroundColor3 = COLORS.TitleBar
    titleBar.Text = title or "Menu"
    titleBar.TextColor3 = Color3.new(1,1,1)
    titleBar.Font = FONT
    titleBar.TextSize = TEXT_SIZE + 2
    titleBar.AutoButtonColor = false
    titleBar.BorderSizePixel = 0
    titleBar.Parent = frame

    -- Window close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.AnchorPoint = Vector2.new(1,0.5)
    closeBtn.Position = UDim2.new(1,-PADDING,0.5,0)
    closeBtn.Size = UDim2.new(0,36,0,36)
    closeBtn.BackgroundColor3 = Color3.fromRGB(180,60,60)
    closeBtn.Text = "X"
    closeBtn.TextSize = TEXT_SIZE
    closeBtn.Font = FONT
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.Parent = titleBar
    closeBtn.AutoButtonColor = false
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)

    -- Drag window
    titleBar.MouseButton1Down:Connect(function(x,y)
        dragging = true
        dragStart = Vector2.new(x,y)
        dragPos = frame.Position
    end)
    titleBar.MouseMoved:Connect(function(x,y)
        if dragging then
            local delta = Vector2.new(x,y) - dragStart
            frame.Position = dragPos + UDim2.new(0,delta.X,0,delta.Y)
        end
    end)
    titleBar.MouseButton1Up:Connect(function()
        dragging = false
    end)

    -- Scrollable contents
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1,0,1,-48)
    scroll.Position = UDim2.new(0,0,0,48)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.CanvasSize = UDim2.new(0,0,0,0)
    scroll.ScrollBarThickness = 8
    scroll.Parent = frame

    -- Layout
    local layout = Instance.new("UIListLayout")
    layout.Parent = scroll
    layout.Padding = UDim.new(0, PADDING)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    -- Helper to update scroll size
    local function updateCanvas()
        wait()
        scroll.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + PADDING)
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)

    -- Widget API
    local windowAPI = {}

    function windowAPI:Button(text, cb)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1,-2*PADDING,0,BUTTON_HEIGHT)
        btn.BackgroundColor3 = COLORS.ButtonBg
        btn.TextColor3 = COLORS.ButtonText
        btn.Text = text
        btn.Font = FONT
        btn.TextSize = TEXT_SIZE
        btn.Parent = scroll
        btn.AutoButtonColor = true
        btn.LayoutOrder = #scroll:GetChildren()
        btn.BorderSizePixel = 0
        btn.MouseButton1Click:Connect(function() if cb then cb() end end)
        return btn
    end

    function windowAPI:Label(text)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1,-2*PADDING,0,TEXT_SIZE+10)
        label.BackgroundTransparency = 1
        label.Text = tostring(text)
        label.TextColor3 = COLORS.LabelText
        label.Font = FONT
        label.TextSize = TEXT_SIZE
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = scroll
        label.LayoutOrder = #scroll:GetChildren()
        return label
    end

    function windowAPI:Toggle(text, cb)
        local state = false
        local holder = Instance.new("Frame")
        holder.Size = UDim2.new(1,-2*PADDING,0,TOGGLE_HEIGHT)
        holder.BackgroundTransparency = 1
        holder.Parent = scroll
        holder.LayoutOrder = #scroll:GetChildren()

        local toggle = Instance.new("TextButton")
        toggle.Size = UDim2.new(0, TOGGLE_HEIGHT, 1, 0)
        toggle.Position = UDim2.new(0,0,0,0)
        toggle.BackgroundColor3 = COLORS.ToggleOff
        toggle.Text = ""
        toggle.Parent = holder
        toggle.AutoButtonColor = true
        toggle.BorderSizePixel = 0

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -TOGGLE_HEIGHT-PADDING, 1, 0)
        label.Position = UDim2.new(0, TOGGLE_HEIGHT+PADDING, 0, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = COLORS.LabelText
        label.Text = text
        label.Font = FONT
        label.TextSize = TEXT_SIZE
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = holder

        toggle.MouseButton1Click:Connect(function()
            state = not state
            toggle.BackgroundColor3 = state and COLORS.ToggleOn or COLORS.ToggleOff
            if cb then cb(state) end
        end)
        return function(v)
            state = v
            toggle.BackgroundColor3 = state and COLORS.ToggleOn or COLORS.ToggleOff
        end
    end

    function windowAPI:Slider(labelText, min, max, default, cb)
        local value = default or min
        local holder = Instance.new("Frame")
        holder.Size = UDim2.new(1,-2*PADDING,0,TOGGLE_HEIGHT)
        holder.BackgroundTransparency = 1
        holder.Parent = scroll
        holder.LayoutOrder = #scroll:GetChildren()

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1,0,0.5,0)
        label.Position = UDim2.new(0,0,0,0)
        label.BackgroundTransparency = 1
        label.Text = labelText .. ": " .. tostring(value)
        label.TextColor3 = COLORS.LabelText
        label.Font = FONT
        label.TextSize = TEXT_SIZE
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = holder

        local slider = Instance.new("TextButton")
        slider.Size = UDim2.new(1,0,0.5,0)
        slider.Position = UDim2.new(0,0,0.5,0)
        slider.BackgroundColor3 = COLORS.ToggleBg
        slider.Text = ""
        slider.Parent = holder
        slider.BorderSizePixel = 0

        -- Visual bar
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((value-min)/(max-min),0,1,0)
        fill.BackgroundColor3 = COLORS.ButtonBg
        fill.BorderSizePixel = 0
        fill.Parent = slider

        local function updateFill()
            fill.Size = UDim2.new((value-min)/(max-min),0,1,0)
        end

        slider.MouseButton1Down:Connect(function(x)
            local mouse = game:GetService("Players").LocalPlayer:GetMouse()
            local con
            con = mouse.Move:Connect(function()
                local relX = math.clamp(mouse.X - slider.AbsolutePosition.X, 0, slider.AbsoluteSize.X)
                local pct = relX / slider.AbsoluteSize.X
                value = math.floor((min + (max-min)*pct)+0.5)
                label.Text = labelText .. ": " .. tostring(value)
                updateFill()
                if cb then cb(value) end
            end)
            slider.MouseButton1Up:Wait()
            if con then con:Disconnect() end
        end)

        updateFill()
        return function(v)
            value = v
            label.Text = labelText .. ": " .. tostring(value)
            updateFill()
        end
    end

    function windowAPI:Dropdown(labelText, options, cb)
        local selected = options[1]
        local holder = Instance.new("Frame")
        holder.Size = UDim2.new(1, -2*PADDING, 0, DROPDOWN_HEIGHT)
        holder.BackgroundTransparency = 1
        holder.Parent = scroll
        holder.LayoutOrder = #scroll:GetChildren()

        local ddBtn = Instance.new("TextButton")
        ddBtn.Size = UDim2.new(1, 0, 1, 0)
        ddBtn.Position = UDim2.new(0,0,0,0)
        ddBtn.BackgroundColor3 = COLORS.DropdownBg
        ddBtn.TextColor3 = COLORS.LabelText
        ddBtn.Text = labelText .. ": " .. tostring(selected)
        ddBtn.Font = FONT
        ddBtn.TextSize = TEXT_SIZE
        ddBtn.Parent = holder
        ddBtn.AutoButtonColor = true
        ddBtn.BorderSizePixel = 0

        local dropFrame = Instance.new("Frame")
        dropFrame.Size = UDim2.new(1,0,0,#options*DROPDOWN_HEIGHT)
        dropFrame.Position = UDim2.new(0,0,1,0)
        dropFrame.BackgroundColor3 = COLORS.DropdownBg
        dropFrame.Visible = false
        dropFrame.BorderSizePixel = 0
        dropFrame.Parent = holder

        local dropLayout = Instance.new("UIListLayout")
        dropLayout.Parent = dropFrame
        dropLayout.Padding = UDim.new(0,0)
        dropLayout.SortOrder = Enum.SortOrder.LayoutOrder

        for i, opt in ipairs(options) do
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1,0,0,DROPDOWN_HEIGHT)
            b.BackgroundColor3 = COLORS.DropdownItemBg
            b.TextColor3 = COLORS.DropdownItemText
            b.Text = tostring(opt)
            b.Font = FONT
            b.TextSize = TEXT_SIZE
            b.AutoButtonColor = true
            b.BorderSizePixel = 0
            b.Parent = dropFrame
            b.MouseButton1Click:Connect(function()
                selected = opt
                ddBtn.Text = labelText .. ": " .. tostring(selected)
                dropFrame.Visible = false
                if cb then cb(selected) end
            end)
        end

        ddBtn.MouseButton1Click:Connect(function()
            dropFrame.Visible = not dropFrame.Visible
        end)

        -- Hide dropdown if click outside
        local UIS = game:GetService("UserInputService")
        UIS.InputBegan:Connect(function(input)
            if dropFrame.Visible and input.UserInputType == Enum.UserInputType.MouseButton1 then
                local mouse = UIS:GetMouseLocation and UIS:GetMouseLocation() or Vector2.new(0,0)
                local abs = dropFrame.AbsolutePosition
                local size = dropFrame.AbsoluteSize
                if mouse.X < abs.X or mouse.X > abs.X+size.X or mouse.Y < abs.Y or mouse.Y > abs.Y+size.Y then
                    dropFrame.Visible = false
                end
            end
        end)

        return function(opt)
            selected = opt
            ddBtn.Text = labelText .. ": " .. tostring(selected)
        end
    end

    -- Responsive: auto-resize for mobile screen
    local UIS = game:GetService("UserInputService")
    local function updateSize()
        local sizeX = math.min(WINDOW_WIDTH, UIS:GetScreenSize().X - 20)
        local sizeY = math.min(WINDOW_HEIGHT, UIS:GetScreenSize().Y - 60)
        frame.Size = UDim2.new(0, sizeX, 0, sizeY)
        frame.Position = UDim2.new(0.5, -sizeX/2, 0.5, -sizeY/2)
    end
    UIS:GetPropertyChangedSignal("ScreenSize"):Connect(updateSize)
    updateSize()

    return windowAPI
end

return SimpleMobileUI
