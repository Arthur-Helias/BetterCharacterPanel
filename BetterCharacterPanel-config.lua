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
    },
    StatPanel = {
        FontScale = 1.0,
        WideMode = false,
        CategoryOrder = {},
    },
    CharacterPanel = {
        EnchantFontScale = 1.0,
    },
    InspectPanel = {
        EnchantFontScale = 1.0,
    },
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

local CFG_FRAME_W = 340
local CFG_CONTENT_W = 280
local CFG_SECTION_H = 22
local CFG_INDENT = 16

local function BCP_AddCategoryOrderList(parent, xIndent, yOffset)
    if not BCP_IS_USING_BCS then
        return yOffset
    end

    local label = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    label:SetPoint("TOPLEFT", parent, "TOPLEFT", xIndent, yOffset)
    label:SetText(BCP_CONFIG_CATEGORY_ORDER)

    local ttBtn = CreateFrame("Button", nil, parent)
    ttBtn:SetWidth(16)
    ttBtn:SetHeight(16)
    ttBtn:SetPoint("LEFT", label, "RIGHT", 4, 0)
    ttBtn:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_CURSOR")
        GameTooltip:SetText(BCP_CONFIG_CATEGORY_ORDER_TT, nil, nil, nil, nil,
            true)
        GameTooltip:Show()
    end)

    ttBtn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    local ttIcon = ttBtn:CreateTexture(nil, "OVERLAY")
    ttIcon:SetTexture("Interface\\Common\\UI-Searchbox-Icon")
    ttIcon:SetWidth(14)
    ttIcon:SetHeight(14)
    ttIcon:SetAllPoints(ttBtn)

    yOffset = yOffset - 18

    local order = BCP_GetBCSCategoryOrder()
    local listFrame = CreateFrame("Frame", "BCPCategoryOrderFrame", parent)
    listFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", xIndent + 8, yOffset)
    listFrame:SetWidth(CFG_CONTENT_W - xIndent - 8)

    local rows = {}
    local rowHeight = 22

    local function RefreshList()
        local curOrder = BCP_GetBCSCategoryOrder()
        local totalRows = table.getn(curOrder)

        for i = 1, totalRows do
            if not rows[i] then
                local row = CreateFrame("Frame", "BCPOrderRow" .. i, listFrame)
                row:SetWidth(listFrame:GetWidth())
                row:SetHeight(rowHeight)
                row:SetPoint("TOPLEFT", listFrame, "TOPLEFT", 0, -(i - 1) * rowHeight)

                local txt = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                txt:SetPoint("LEFT", row, "LEFT", 0, 0)
                row.txt = txt

                local upBtn = CreateFrame("Button", "UpButton" .. i, row)
                upBtn:SetWidth(24)
                upBtn:SetHeight(24)
                upBtn:SetPoint("RIGHT", row, "RIGHT", -24, 0)
                upBtn:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Up")
                upBtn:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Down")
                upBtn:SetDisabledTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Disabled")
                upBtn:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
                row.upBtn = upBtn

                local downBtn = CreateFrame("Button", "DownButton" .. i, row)
                downBtn:SetWidth(24)
                downBtn:SetHeight(24)
                downBtn:SetPoint("RIGHT", row, "RIGHT", 0, 0)
                downBtn:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
                downBtn:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down")
                downBtn:SetDisabledTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Disabled")
                downBtn:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
                row.downBtn = downBtn

                rows[i] = row

                row.upBtn:SetScript("OnClick", function()
                    local idx = this.index
                    if idx > 1 then
                        local temp = BCPConfig.StatPanel.CategoryOrder[idx - 1]
                        BCPConfig.StatPanel.CategoryOrder[idx - 1] = BCPConfig.StatPanel.CategoryOrder[idx]
                        BCPConfig.StatPanel.CategoryOrder[idx] = temp
                        RefreshList()
                    end
                end)

                row.downBtn:SetScript("OnClick", function()
                    local idx = this.index
                    local maxIdx = table.getn(BCPConfig.StatPanel.CategoryOrder)
                    if idx < maxIdx then
                        local temp = BCPConfig.StatPanel.CategoryOrder[idx + 1]
                        BCPConfig.StatPanel.CategoryOrder[idx + 1] = BCPConfig.StatPanel.CategoryOrder[idx]
                        BCPConfig.StatPanel.CategoryOrder[idx] = temp
                        RefreshList()
                    end
                end)
            end

            rows[i].upBtn.index = i
            rows[i].downBtn.index = i

            local cat = curOrder[i]
            local name = (BCS and BCS.L and BCS.L[cat]) or cat

            rows[i].txt:SetText(name)

            rows[i].upBtn:Enable()
            rows[i].downBtn:Enable()
            if i == 1 then rows[i].upBtn:Disable() end
            if i == totalRows then rows[i].downBtn:Disable() end

            rows[i]:Show()
        end

        for i = totalRows + 1, table.getn(rows) do
            rows[i]:Hide()
        end

        listFrame:SetHeight(totalRows * rowHeight)
    end

    RefreshList()

    local notice = listFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    notice:SetPoint("TOPLEFT", listFrame, "BOTTOMLEFT", -8, -6)
    notice:SetText("|cff888888" .. BCP_CONFIG_FONT_SCALE_RELOAD .. "|r")

    return yOffset - (table.getn(order) * rowHeight) - 16
end

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

    return yOffset - 22
end

local function BCP_AddCheckbox(parent, name, labelText, tooltipText, section, key, xIndent, yOffset, reloadWarning)
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

    local extraOffset = 0

    if reloadWarning then
        local reloadNote = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        reloadNote:SetPoint("TOPLEFT", cb, "BOTTOMLEFT", 0, -3)
        reloadNote:SetText("|cff888888" .. BCP_CONFIG_FONT_SCALE_RELOAD .. "|r")

        extraOffset = -18
    end

    return yOffset - 22 + extraOffset
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

    return yOffset - 50
end

local function BCP_AddFontScaleSlider(parent, xIndent, yOffset, sliderName, section, key, tooltipText)
    local label = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    label:SetPoint("TOPLEFT", parent, "TOPLEFT", xIndent, yOffset)
    label:SetText(BCP_CONFIG_FONT_SCALE)

    local slider = CreateFrame("Slider", sliderName, parent, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", parent, "TOPLEFT", xIndent + 8, yOffset - 18)
    slider:SetWidth(CFG_CONTENT_W - xIndent - 36)
    slider:SetHeight(17)
    slider:SetOrientation("HORIZONTAL")
    slider:SetMinMaxValues(0.75, 2.0)
    slider:SetValueStep(0.05)
    slider:SetValue(BCPConfig[section][key])

    getglobal(sliderName .. "Low"):SetText("0.75x")
    getglobal(sliderName .. "High"):SetText("2.00x")
    getglobal(sliderName .. "Text"):SetText(string.format("%.2fx", BCPConfig[section][key]))

    if tooltipText then
        local ttBtn = CreateFrame("Button", nil, parent)
        ttBtn:SetWidth(16)
        ttBtn:SetHeight(16)
        ttBtn:SetPoint("LEFT", label, "RIGHT", 4, 0)
        ttBtn:SetScript("OnEnter", function()
            GameTooltip:SetOwner(this, "ANCHOR_CURSOR")
            GameTooltip:SetText(tooltipText, nil, nil, nil, nil, true)
            GameTooltip:Show()
        end)
        ttBtn:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)

        local ttIcon = ttBtn:CreateTexture(nil, "OVERLAY")
        ttIcon:SetTexture("Interface\\Common\\UI-Searchbox-Icon")
        ttIcon:SetWidth(14)
        ttIcon:SetHeight(14)
        ttIcon:SetAllPoints(ttBtn)
    end

    slider:SetScript("OnValueChanged", function()
        local snapped = math.floor(this:GetValue() * 20 + 0.5) / 20
        BCPConfig[section][key] = snapped
        getglobal(sliderName .. "Text"):SetText(string.format("%.2fx", snapped))
    end)

    local reloadNote = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    reloadNote:SetPoint("TOPLEFT", slider, "BOTTOMLEFT", -8, -20)
    reloadNote:SetText("|cff888888" .. BCP_CONFIG_FONT_SCALE_RELOAD .. "|r")

    return yOffset - 70
end

local function BCP_SkinConfigFrame()
    if BCP_IS_USING_PFUI then
        pfUI.api.CreateBackdrop(BCPConfigFrame, nil, nil, 0.75)
        pfUI.api.CreateBackdropShadow(BCPConfigFrame)
        BCPConfigFrameTitleBackground:Hide()
        BCPConfigFrameTitleText:SetFont(pfUI.font_default, 14, "OUTLINE")
        pfUI.api.SkinCloseButton(BCPConfigFrameClose, BCPConfigFrame, -6, -6)

        -- NOTE: Reverted back to the default UI's skin, as otherwise the dropdown renders behind its background. I have no idea why, and I'm done trying to figure it out. If you have any solution, please make a PR.
        --pfUI.api.SkinDropDown(BCPQualityDropdown)

        if BCPConfigScrollBar then
            pfUI.api.SkinScrollbar(BCPConfigScrollBar)
        end

        for _, child in ipairs({ BCPConfigContent:GetChildren() }) do
            if child:GetObjectType() == "CheckButton" then
                -- NOTE: Reverted back to the default UI's skin, as otherwise the checkbox's tick renders behind the checkbox background. I have no idea why, and I'm done trying to figure it out. If you have any solution, please make a PR.
                -- pfUI.api.SkinCheckbox(child)
            end

            if child:GetName() == "BCPCategoryOrderFrame" then
                for _, row in ipairs({ child:GetChildren() }) do
                    if row.upBtn then
                        pfUI.api.SkinArrowButton(row.upBtn, "up", 16)
                    end
                    if row.downBtn then
                        pfUI.api.SkinArrowButton(row.downBtn, "down", 16)
                    end
                end
            end

            if child:GetObjectType() == "Slider" then
                pfUI.api.SkinSlider(child)
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

    local scrollFrame = CreateFrame("ScrollFrame", "BCPConfigScrollFrame", frame)
    scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 14, -38)
    scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -36, 14)
    scrollFrame:EnableMouseWheel(true)

    local content = CreateFrame("Frame", "BCPConfigContent", scrollFrame)
    content:SetWidth(CFG_CONTENT_W)
    content:SetHeight(1)
    scrollFrame:SetScrollChild(content)

    local scrollBar = CreateFrame("Slider", "BCPConfigScrollBar", scrollFrame, "UIPanelScrollBarTemplate")
    scrollBar:SetPoint("TOPLEFT", scrollFrame, "TOPRIGHT", 6, -16)
    scrollBar:SetPoint("BOTTOMLEFT", scrollFrame, "BOTTOMRIGHT", 6, 16)
    scrollBar:SetMinMaxValues(0, 0)
    scrollBar:SetValueStep(20)
    scrollBar:SetValue(0)

    scrollBar:SetScript("OnValueChanged", function()
        scrollFrame:SetVerticalScroll(this:GetValue())
    end)

    scrollFrame:SetScript("OnMouseWheel", function()
        local _, maxVal = scrollBar:GetMinMaxValues()
        local newVal = math.max(0, math.min(maxVal, scrollBar:GetValue() - arg1 * 40))
        scrollBar:SetValue(newVal)
    end)

    local y = -8

    -- Minimap Button
    y = BCP_AddSectionHeader(content, BCP_CONFIG_SEC_MINIMAP, y)
    y = BCP_AddCheckbox(content, "ShowMinimap", BCP_CONFIG_SHOW_MINIMAP, nil, "MinimapButton", "Show", CFG_INDENT, y)

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

    -- Character Panel Enchants
    y = BCP_AddSectionHeader(content, BCP_CONFIG_SEC_CHAR_ENCHANTS, y)
    y = BCP_AddCheckbox(content, "PeCharPanel", BCP_CONFIG_PE_CHAR_PANEL, nil, "PermanentEnchants", "ShowOnCharPanel",
        CFG_INDENT, y)
    y = BCP_AddCheckbox(content, "TeCharPanel", BCP_CONFIG_TE_CHAR_PANEL, nil, "TemporaryEnchants", "ShowOnCharPanel",
        CFG_INDENT, y)
    y = BCP_AddFontScaleSlider(content, CFG_INDENT, y,
        "BCPCharEnchantFontScaleSlider", "CharacterPanel", "EnchantFontScale",
        BCP_CONFIG_CHAR_ENCHANT_FONT_SCALE_TT)
    y = y - 4

    -- Inspect Panel Enchants
    y = BCP_AddSectionHeader(content, BCP_CONFIG_SEC_INSPECT_ENCHANTS, y)
    y = BCP_AddCheckbox(content, "PeInspect", BCP_CONFIG_PE_INSPECT, nil, "PermanentEnchants", "ShowOnInspect",
        CFG_INDENT, y)
    y = BCP_AddCheckbox(content, "TeInspect", BCP_CONFIG_TE_INSPECT, nil, "TemporaryEnchants", "ShowOnInspect",
        CFG_INDENT, y)
    y = BCP_AddFontScaleSlider(content, CFG_INDENT, y,
        "BCPInspectEnchantFontScaleSlider", "InspectPanel", "EnchantFontScale",
        BCP_CONFIG_INSPECT_ENCHANT_FONT_SCALE_TT)
    y = y - 4

    -- Missing Enchants
    y = BCP_AddSectionHeader(content, BCP_CONFIG_SEC_MISS_ENCH, y)
    y = BCP_AddCheckbox(content, "MeShow", BCP_CONFIG_ME_SHOW, BCP_CONFIG_ME_SHOW_TT, "MissingEnchants", "Show",
        CFG_INDENT, y)
    y = BCP_AddCheckbox(content, "MeLvl60", BCP_CONFIG_ME_LVL60, BCP_CONFIG_ME_LVL60_TT, "MissingEnchants",
        "OnlyAtLevel60", CFG_INDENT, y)
    y = BCP_AddQualityDropdown(content, CFG_INDENT, y)
    y = y - 4

    -- Stat Panel
    y = BCP_AddSectionHeader(content, BCP_CONFIG_SEC_STAT_PANEL, y)
    y = BCP_AddCheckbox(content, "SPWide", BCP_CONFIG_SP_WIDEMODE, BCP_CONFIG_SP_WIDEMODE_TT, "StatPanel", "WideMode",
        CFG_INDENT, y, true)

    y = BCP_AddFontScaleSlider(content, CFG_INDENT, y,
        "BCPStatPanelFontScaleSlider", "StatPanel", "FontScale", BCP_CONFIG_FONT_SCALE_TT)
    y = BCP_AddCategoryOrderList(content, CFG_INDENT, y)
    y = y - 4

    y = y - 8 -- Bottom padding

    local contentHeight = math.abs(y)
    content:SetHeight(contentHeight)

    local maxH = math.min(GetScreenHeight() * 0.9, 480)
    local desiredH = math.min(contentHeight + 52, maxH)
    frame:SetHeight(desiredH)

    local scrollFrameHeight = desiredH - 45
    if contentHeight > scrollFrameHeight then
        BCPConfigScrollBar:SetMinMaxValues(0, contentHeight - scrollFrameHeight)
        BCPConfigScrollBar:Show()
    else
        BCPConfigScrollBar:SetMinMaxValues(0, 0)
        BCPConfigScrollBar:Hide()
    end

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
        BCP_OpenConfig = BCP_ToggleConfigFrame
    end

    if event == "PLAYER_ENTERING_WORLD" and not BCP_ConfigFrameSkinned then
        BCP_CreateConfigFrame()
        BCP_CreateMinimapButton()
        BCP_SkinConfigFrame()
        BCP_ConfigFrameSkinned = true
    end
end)
