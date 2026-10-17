-- UI.lua
-- Progress UI helpers for Fishilizer.

local _progressUI = nil
local _progressEmitted = 0
local _progressTotal = 0
local BAR_TRACK_WIDTH = 304

local function destroyProgressUI()
    if _progressUI and _progressUI.gui then
        pcall(function() _progressUI.gui:Destroy() end)
    end
    _progressUI = nil
    _progressEmitted = 0
    _progressTotal = 0
end

local function buildProgressUI()
    if not Fish.Options.ShowStatus then return nil end
    local lp = Players.LocalPlayer
    if not lp then return nil end
    local pg = lp:FindFirstChildOfClass("PlayerGui")
    if not pg then return nil end

    pcall(function()
        local existing = pg:FindFirstChild("__FishilizerProgress__")
        if existing then existing:Destroy() end
    end)

    local gui = Instance.new("ScreenGui")
    gui.Name = "__FishilizerProgress__"
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 100
    gui.Parent = pg

    local contents = Instance.new("Frame")
    contents.Name = "Contents"
    contents.BorderSizePixel = 0
    contents.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
    contents.Size = UDim2.new(0, 338, 0, 28)
    contents.AnchorPoint = Vector2.new(1, 0)
    contents.Position = UDim2.new(1, -20, 0, 20)
    contents.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = contents

    local progress = Instance.new("Frame")
    progress.Name = "Progress"
    progress.BorderSizePixel = 0
    progress.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
    progress.Size = UDim2.new(0, 304, 0, 13)
    progress.Position = UDim2.new(0.04712, 0, 0.23695, 0)
    progress.Visible = false
    progress.Parent = contents

    local pcorner = Instance.new("UICorner")
    pcorner.CornerRadius = UDim.new(0, 5)
    pcorner.Parent = progress

    local bar = Instance.new("Frame")
    bar.Name = "Bar"
    bar.BorderSizePixel = 0
    bar.BackgroundColor3 = Color3.fromRGB(86, 86, 255)
    bar.Size = UDim2.new(0, 1, 0, 13)
    bar.Position = UDim2.new(-0.00222, 0, 0.00619, 0)
    bar.Parent = progress

    local bcorner = Instance.new("UICorner")
    bcorner.CornerRadius = UDim.new(0, 5)
    bcorner.Parent = bar

    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "text"
    textLabel.BorderSizePixel = 0
    textLabel.TextSize = 14
    textLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    textLabel.TextColor3 = Color3.fromRGB(183, 183, 183)
    textLabel.BackgroundTransparency = 1
    textLabel.Size = UDim2.new(0, 338, 0, 28)
    textLabel.Visible = true
    textLabel.Text = "Saving game.. (this may take time depending on size)"
    textLabel.Position = UDim2.new(0, 0, 0, 0)
    textLabel.Parent = contents

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 86, 128)
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = contents

    _progressUI = {
        gui = gui,
        contents = contents,
        progress = progress,
        bar = bar,
        text = textLabel,
    }

    return _progressUI
end

local function showTextStage()
    if not _progressUI then return end
    _progressUI.text.Visible = true
    _progressUI.progress.Visible = false
end

local function showProgressStage()
    if not _progressUI then return end
    _progressUI.text.Visible = false
    _progressUI.progress.Visible = true
    if _progressUI.bar then
        _progressUI.bar.Size = UDim2.new(0, 1, 0, 13)
    end
end

local function updateBar(ratio)
    if not _progressUI or not _progressUI.bar then return end
    if ratio < 0 then ratio = 0 end
    if ratio > 1 then ratio = 1 end
    local w = math.floor(BAR_TRACK_WIDTH * ratio)
    if w < 1 then w = 1 end
    _progressUI.bar.Size = UDim2.new(0, w, 0, 13)
end

local function bumpProgress()
    if not _progressUI then return end
    _progressEmitted = _progressEmitted + 1
    if _progressTotal > 0 then
        if _progressEmitted % 25 == 0 then
            updateBar(_progressEmitted / _progressTotal)
        end
    end
end

Fish._progressUI = _progressUI
Fish.buildProgressUI = buildProgressUI
Fish.destroyProgressUI = destroyProgressUI
Fish.showTextStage = showTextStage
Fish.showProgressStage = showProgressStage
Fish.updateBar = updateBar
Fish.bumpProgress = bumpProgress

return Fish
