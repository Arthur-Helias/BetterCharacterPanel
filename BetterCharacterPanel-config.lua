local BCP_CONFIG_DEFAULTS = {
    MinimapButton = {
        Show = true,
        Free = false,
        Angle = 225,
        X = 0,
        Y = 0,
    },
    PermanentEnchants = {
        ShowOnCharPanel = true,
        ShowOnInspect = true,
    },
    TemporaryEnchants = {
        ShowOnCharPanel = true,
        ShowOnInspect = true,
    },
    MissingEnchants = {
        Show = true,
        OnlyAtLevel60 = false,
        MinimumQuality = 3,
    }
}

local BCP_MINIMAP_RADIUS = 80

local function BCP_InitConfig()
    if not BCPConfig then
        BCPConfig = {}
    end

    for section, defaults in pairs(BCP_CONFIG_DEFAULTS) do
        if type(BCPConfig[section]) ~= "table" then
            BCPConfig[section] = {}
        end

        for key, value in pairs(defaults) do
            if BCPConfig[section][key] == nil then
                BCPConfig[section][key] = value
            end
        end
    end
end


local function BCP_UpdateMinimapButtonPosition()
    if not BCPMinimapButton then
        return
    end

    BCPMinimapButton:ClearAllPoints()

    if BCPConfig.MinimapButton.Free then
        BCPMinimapButton:SetPoint(
            "CENTER", UIParent, "BOTTOMLEFT",
            BCPConfig.MinimapButton.X,
            BCPConfig.MinimapButton.Y
        )
    else
        local angle = math.rad(BCPConfig.MinimapButton.Angle)
        local x = math.cos(angle) * BCP_MINIMAP_RADIUS
        local y = math.sin(angle) * BCP_MINIMAP_RADIUS
        BCPMinimapButton:SetPoint("CENTER", Minimap, "CENTER", x, y)
    end
end

local function BCP_CreateMinimapButton()
    local btn = CreateFrame("Button", "BCPMinimapButton", Minimap)
    btn:SetWidth(32)
    btn:SetHeight(32)
    btn:SetFrameStrata("MEDIUM")
    btn:SetFrameLevel(8)
    btn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    local icon = btn:CreateTexture(nil, "BACKGROUND")
    icon:SetTexture("Interface\\Icons\\Ability_Warrior_BattleShout")
    icon:SetWidth(22)
    icon:SetHeight(22)
    icon:SetPoint("CENTER", btn, "CENTER", 0, 0)

    local border = btn:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    border:SetWidth(56)
    border:SetHeight(56)
    border:SetPoint("TOPLEFT", btn, "TOPLEFT", 0, 0)

    btn:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_LEFT")
        GameTooltip:SetText(BCP_MINIMAP_TOOLTIP, nil, nil, nil, nil, true)
        GameTooltip:Show()
    end)

    btn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    btn:SetScript("OnClick", function()
        if arg1 == "LeftButton" then
            if BCPConfigFrame:IsVisible() then
                BCPConfigFrame:Hide()
            else
                BCPConfigFrame:Show()
            end
        end
    end)

    btn:RegisterForDrag("LeftButton")

    btn:SetScript("OnDragStart", function()
        if IsControlKeyDown() then
            this.isDragging = true
        end
    end)

    btn:SetScript("OnDragStop", function()
        this.isDragging = false
    end)

    btn:SetScript("OnUpdate", function()
        if not this.isDragging then
            return
        end

        if BCPConfig.MinimapButton.Free then
            local scale = UIParent:GetEffectiveScale()
            local cx, cy = GetCursorPosition()
            BCPConfig.MinimapButton.X = cx / scale
            BCPConfig.MinimapButton.Y = cy / scale
        else
            local mx, my = Minimap:GetCenter()
            local scale = UIParent:GetEffectiveScale()
            local cx, cy = GetCursorPosition()
            cx = cx / scale
            cy = cy / scale
            BCPConfig.MinimapButton.Angle = math.deg(math.atan2(cy - my, cx - mx))
        end

        BCP_UpdateMinimapButtonPosition()
    end)

    BCP_UpdateMinimapButtonPosition()

    if not BCPConfig.MinimapButton.Show then
        btn:Hide()
    end

    return btn
end


-- ===============
-- =   Helpers   =
-- ===============

local CFG_FRAME_W = 320
local CFG_CONTENT_W = 280
local CFG_ITEM_H = 24
local CFG_SECTION_H = 22
local CFG_INDENT = 16

local function BCP_AddSectionHeader(parent, text, yOffset)
    local label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("TOPLEFT", parent, "TOPLEFT", CFG_INDENT, yOffset)
    label:SetWidth(CFG_CONTENT_W - CFG_INDENT)
    label:SetJustifyH("LEFT")
    label:SetText("|cffffff00" .. text)

    local line = parent:CreateTexture(nil, "OVERLAY")
    line:SetHeight(1)
    line:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -2)
    line:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -CFG_INDENT, -(math.abs(yOffset) + CFG_SECTION_H - 2))
    line:SetTexture(0.4, 0.4, 0.4, 0.6)

    return yOffset - CFG_SECTION_H
end

local function BCP_AddCheckbox(parent, name, labelText, tooltipText, section, key, xIndent, yOffset)
    local cbName = "BCPConfigCheck_" .. name
    local cb = CreateFrame("CheckButton", cbName, parent, "UICheckButtonTemplate")
    cb:SetWidth(20)
    cb:SetHeight(20)
    cb:SetPoint("TOPLEFT", parent, "TOPLEFT", xIndent, yOffset + 2)

    local lbl = getglobal(cbName .. "Text")
    if lbl then
        lbl:SetText(labelText)
        lbl:SetFontObject(GameFontHighlight)
    end

    cb:SetChecked(BCPConfig[section][key])

    cb:SetScript("OnClick", function()
        BCPConfig[section][key] = (this:GetChecked() == 1)
    end)

    if tooltipText then
        local icon = parent:CreateTexture(nil, "OVERLAY")
        icon:SetTexture("Interface\\Common\\UI-Searchbox-Icon")
        icon:SetWidth(14)
        icon:SetHeight(14)
        icon:SetPoint("LEFT", lbl, "RIGHT", 10, 0)

        local ttBtn = CreateFrame("Button", nil, parent)
        ttBtn:SetWidth(16)
        ttBtn:SetHeight(16)
        ttBtn:SetPoint("CENTER", icon, "CENTER")
        ttBtn:SetScript("OnEnter", function()
            GameTooltip:SetOwner(this, "ANCHOR_CURSOR")
            GameTooltip:SetText(tooltipText, nil, nil, nil, nil, true)
            GameTooltip:Show()
        end)
        ttBtn:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
    end

    return yOffset - CFG_ITEM_H
end

local function BCP_AddQualityDropdown(parent, xIndent, yOffset)
    local label = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    label:SetPoint("TOPLEFT", parent, "TOPLEFT", xIndent, yOffset)
    label:SetText(BCP_CONFIG_ME_MIN_QUALITY)

    local ttBtn = CreateFrame("Button", nil, parent)
    ttBtn:SetWidth(16)
    ttBtn:SetHeight(16)
    ttBtn:SetPoint("LEFT", label, "RIGHT", 4, 0)
    ttBtn:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_CURSOR")
        GameTooltip:SetText(BCP_CONFIG_ME_MIN_QUALITY_TT, nil, nil, nil, nil, true)
        GameTooltip:Show()
    end)
    ttBtn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    local ttIcon = ttBtn:CreateTexture(nil, "OVERLAY")
    ttIcon:SetTexture("Interface\\Common\\UI-Searchbox-Icon")
    ttIcon:SetAllPoints(ttBtn)

    local dd = CreateFrame("Frame", "BCPQualityDropdown", parent, "UIDropDownMenuTemplate")
    dd:SetPoint("TOPLEFT", parent, "TOPLEFT", xIndent - 18, yOffset - 16)
    UIDropDownMenu_SetWidth(130, dd)

    local qualityNames = {
        [0] = BCP_CONFIG_QUALITY_0,
        [1] = BCP_CONFIG_QUALITY_1,
        [2] = BCP_CONFIG_QUALITY_2,
        [3] = BCP_CONFIG_QUALITY_3,
        [4] = BCP_CONFIG_QUALITY_4,
        [5] = BCP_CONFIG_QUALITY_5,
    }

    local qualityColors = {
        [0] = "|cff9d9d9d",
        [1] = "|cffffffff",
        [2] = "|cff1eff00",
        [3] = "|cff0070dd",
        [4] = "|cffa335ee",
        [5] = "|cffff8000",
    }

    UIDropDownMenu_Initialize(dd, function()
        for i = 0, 5 do
            local info = UIDropDownMenu_CreateInfo()
            info.text = qualityColors[i] .. qualityNames[i] .. "|r"
            info.value = i
            info.func = function()
                BCPConfig.MissingEnchants.MinimumQuality = this.value
                UIDropDownMenu_SetSelectedValue(BCPQualityDropdown, this.value)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)

    UIDropDownMenu_SetSelectedValue(dd, BCPConfig.MissingEnchants.MinimumQuality)

    local currentQuality = BCPConfig.MissingEnchants.MinimumQuality
    local displayText = qualityColors[currentQuality] .. qualityNames[currentQuality] .. "|r"
    UIDropDownMenu_SetText(displayText, dd)

    return yOffset - CFG_ITEM_H - 24
end

local function BCP_SkinConfigFrame()
    if BCP_IS_USING_PFUI then
        pfUI.api.CreateBackdrop(BCPConfigFrame, nil, nil, 0.75)
        pfUI.api.CreateBackdropShadow(BCPConfigFrame)
        BCPConfigFrameTitleBackground:Hide()
        BCPConfigFrameTitleText:SetFont(pfUI.font_default, 14, "OUTLINE")
        pfUI.api.SkinCloseButton(BCPConfigFrameClose, BCPConfigFrame, -6, -6)
        pfUI.api.SkinDropDown(BCPQualityDropdown)

        for _, child in ipairs({ BCPConfigContent:GetChildren() }) do
            if child:GetObjectType() == "CheckButton" then
                pfUI.api.SkinCheckbox(child)
            end
        end
    end
end


-- ======================
-- =   Frame Creation   =
-- ======================
local function BCP_CreateConfigFrame()
    local frame = CreateFrame("Frame", "BCPConfigFrame", UIParent)
    frame:SetWidth(CFG_FRAME_W)
    frame:SetHeight(500)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 },
    })
    frame:SetBackdropColor(0, 0, 0, 0.95)
    frame:SetFrameStrata("DIALOG")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function() this:StartMoving() end)
    frame:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
    frame:SetToplevel(true)
    frame:Hide()
    table.insert(UISpecialFrames, "BCPConfigFrame")

    local titleBg = frame:CreateTexture("BCPConfigFrameTitleBackground", "ARTWORK")
    titleBg:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
    titleBg:SetWidth(356)
    titleBg:SetHeight(64)
    titleBg:SetPoint("TOP", frame, "TOP", 0, 12)

    local title = frame:CreateFontString("BCPConfigFrameTitleText", "OVERLAY", "GameFontHighlightSmall")
    title:SetPoint("TOP", frame, "TOP", 0, -3)
    title:SetText(BCP_CONFIG_TITLE ..
        " |cff888888v" .. BCP_VERSION_MAJOR .. "." .. BCP_VERSION_MINOR .. "." .. BCP_VERSION_PATCH .. "|r")

    local closeBtn = CreateFrame("Button", "BCPConfigFrameClose", frame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -4, -4)
    closeBtn:SetScript("OnClick", function() frame:Hide() end)

    local content = CreateFrame("Frame", "BCPConfigContent", frame)
    content:SetPoint("TOPLEFT", frame, "TOPLEFT", 14, -38)
    content:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -14, 14)

    local y = -8

    -- Minimap Button
    y = BCP_AddSectionHeader(content, BCP_CONFIG_SEC_MINIMAP, y)
    y = BCP_AddCheckbox(content, "ShowMinimap", BCP_CONFIG_SHOW_MINIMAP, nil, "MinimapButton", "Show", CFG_INDENT, y)

    getglobal("BCPConfigCheck_ShowMinimapText")

    local cbShowMinimap = getglobal("BCPConfigCheck_ShowMinimap")

    if cbShowMinimap then
        local origShowMinimapClick = cbShowMinimap:GetScript("OnClick")

        cbShowMinimap:SetScript("OnClick", function()
            if origShowMinimapClick then
                origShowMinimapClick()
            end

            if BCPMinimapButton then
                if BCPConfig.MinimapButton.Show then
                    BCPMinimapButton:Show()
                else
                    BCPMinimapButton:Hide()
                end
            end
        end)
    end

    y = BCP_AddCheckbox(content, "FreeMinimapButton", BCP_CONFIG_FREE_MINIMAP, BCP_CONFIG_FREE_MINIMAP_TT,
        "MinimapButton", "Free", CFG_INDENT, y)

    local cbFree = getglobal("BCPConfigCheck_FreeMinimapButton")

    if cbFree then
        local origFreeClick = cbFree:GetScript("OnClick")

        cbFree:SetScript("OnClick", function()
            if origFreeClick then
                origFreeClick()
            end

            if BCPConfig.MinimapButton.Free and BCPMinimapButton then
                local cx, cy = BCPMinimapButton:GetCenter()

                if cx and cy then
                    BCPConfig.MinimapButton.X = cx
                    BCPConfig.MinimapButton.Y = cy
                end
            end
            BCP_UpdateMinimapButtonPosition()
        end)
    end
    y = y - 4

    -- Permanent Enchants
    y = BCP_AddSectionHeader(content, BCP_CONFIG_SEC_PERM_ENCH, y)
    y = BCP_AddCheckbox(content, "PeCharPanel", BCP_CONFIG_PE_CHAR_PANEL, nil, "PermanentEnchants", "ShowOnCharPanel",
        CFG_INDENT, y)
    y = BCP_AddCheckbox(content, "PeInspect", BCP_CONFIG_PE_INSPECT, nil, "PermanentEnchants", "ShowOnInspect",
        CFG_INDENT, y)
    y = y - 4

    -- Temporary Enchants
    y = BCP_AddSectionHeader(content, BCP_CONFIG_SEC_TEMP_ENCH, y)
    y = BCP_AddCheckbox(content, "TeCharPanel", BCP_CONFIG_TE_CHAR_PANEL, nil, "TemporaryEnchants", "ShowOnCharPanel",
        CFG_INDENT, y)
    y = BCP_AddCheckbox(content, "TeInspect", BCP_CONFIG_TE_INSPECT, nil, "TemporaryEnchants", "ShowOnInspect",
        CFG_INDENT, y)
    y = y - 4

    -- Missing Enchants
    y = BCP_AddSectionHeader(content, BCP_CONFIG_SEC_MISS_ENCH, y)
    y = BCP_AddCheckbox(content, "MeShow", BCP_CONFIG_ME_SHOW, BCP_CONFIG_ME_SHOW_TT, "MissingEnchants", "Show",
        CFG_INDENT, y)
    y = BCP_AddCheckbox(content, "MeLvl60", BCP_CONFIG_ME_LVL60, BCP_CONFIG_ME_LVL60_TT, "MissingEnchants",
        "OnlyAtLevel60", CFG_INDENT, y)
    y = y - 4
    y = BCP_AddQualityDropdown(content, CFG_INDENT, y)
    y = y - 4
    y = y - 8 -- Bottom padding

    local contentHeight = math.abs(y)
    local maxH = GetScreenHeight() * 0.9
    local desiredH = math.min(contentHeight + 56, maxH)
    frame:SetHeight(desiredH)

    return frame
end

local function BCP_ToggleConfigFrame()
    if BCPConfigFrame then
        if BCPConfigFrame:IsVisible() then
            BCPConfigFrame:Hide()
        else
            BCPConfigFrame:Show()
        end
    end
end

local BCP_ConfigInitFrame = CreateFrame("Frame")
BCP_ConfigInitFrame:RegisterEvent("VARIABLES_LOADED")
BCP_ConfigInitFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
BCP_ConfigInitFrame:SetScript("OnEvent", function()
    if event == "VARIABLES_LOADED" then
        BCP_InitConfig()
        BCP_CreateConfigFrame()
        BCP_CreateMinimapButton()
        BCP_OpenConfig = BCP_ToggleConfigFrame
    end

    if event == "PLAYER_ENTERING_WORLD" then
        BCP_SkinConfigFrame()
    end
end)
