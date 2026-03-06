-- O―――――――――――――――――――――――――――――O
-- |   Paperdoll skin for pfUI   |
-- O―――――――――――――――――――――――――――――O

BCPSkin_pfUI = BCPSkin_pfUI or {}
local skin = BCPSkin_pfUI

skin.FrameValues = {
    -- Missing enchant indicator bar
    LeftIconsMissingEnchantTexture = "Interface\\Buttons\\WHITE8x8",
    RightIconsMissingEnchantTexture = "Interface\\Buttons\\WHITE8x8",
    SpecialIconsMissingEnchantTexture = "Interface\\Buttons\\WHITE8x8",
    LeftIconsMissingEnchantSize = { 3, 35 },
    RightIconsMissingEnchantSize = { 3, 35 },
    SpecialIconsMissingEnchantSize = { 3, 35 },
    LeftIconsMissingEnchantOffsets = { -1, -1 },
    RightIconsMissingEnchantOffsets = { 1, -1 },
    SpecialIconsMissingEnchantOffsets = { -1, -1 },

    -- Standard left/right enchant text offsets
    LeftIconsPermEnchantOffsets = { 4, 7 },
    LeftIconsTempEnchantOffsets = { 4, -7 },
    RightIconsPermEnchantOffsets = { -4, 7 },
    RightIconsTempEnchantOffsets = { -4, -7 },

    -- Wrist enchant text
    WristsIconPermEnchantTextJustifyH = "LEFT",
    WristsIconPermEnchantTextAnchors = { "LEFT", "RIGHT" },
    WristsIconPermEnchantOffsets = { 4, 16 },
    WristsIconTempEnchantTextJustifyH = "LEFT",
    WristsIconTempEnchantTextAnchors = { "LEFT", "RIGHT" },
    WristsIconTempEnchantOffsets = { 4, 3 },

    -- Main hand enchant text
    MainHandIconPermEnchantTextJustifyH = "RIGHT",
    MainHandIconPermEnchantTextAnchors = { "BOTTOMRIGHT", "BOTTOMLEFT" },
    MainHandIconPermEnchantOffsets = { -4, 12 },
    MainHandIconTempEnchantTextJustifyH = "RIGHT",
    MainHandIconTempEnchantTextAnchors = { "BOTTOMRIGHT", "BOTTOMLEFT" },
    MainHandIconTempEnchantOffsets = { -4, 0 },

    -- Off-hand enchant text
    OffHandIconPermEnchantTextJustifyH = "RIGHT",
    OffHandIconPermEnchantTextAnchors = { "TOPRIGHT", "TOPRIGHT" },
    OffHandIconPermEnchantOffsets = { 0, 14 },
    OffHandIconTempEnchantTextJustifyH = "RIGHT",
    OffHandIconTempEnchantTextAnchors = { "BOTTOMRIGHT", "BOTTOMRIGHT" },
    OffHandIconTempEnchantOffsets = { 0, -12 },

    -- Ranged enchant text
    RangedIconPermEnchantTextJustifyH = "LEFT",
    RangedIconPermEnchantTextAnchors = { "TOPRIGHT", "TOPRIGHT" },
    RangedIconPermEnchantOffsets = { 92, 14 },
    RangedIconTempEnchantTextJustifyH = "LEFT",
    RangedIconTempEnchantTextAnchors = { "BOTTOMRIGHT", "BOTTOMRIGHT" },
    RangedIconTempEnchantOffsets = { 92, -12 },
}

skin.Config = {
    -- Character model position
    ModelOffsetX = 65,
    ModelOffsetY = -120,

    -- BCP added information panel
    InfoFrameXOffset = 357,
    InfoFrameYOffset = 31,
    InfoFrameWidth = 150,
    InfoFrameHeightPadding = 9,

    -- pfUI's character panel skin backdrop hack
    UnifiedBackdropAlpha = 0.75,

    -- Resistance icons
    ResistanceItemWidth = 26,
    ResistanceFrameHeight = 26,
    ResistanceItemSpacing = 2,

    -- BCS stats frame
    StatValueWidth = 80,
    StatLabelRightPad = 40,
    StatLabelLeftPad = 0,
    StatValueRightPad = 0,

    -- Card layout
    StatCardTitleTopPad = 4,
    StatCardBottomPad = 4,
    StatRowSpacing = 0,

    -- Native stats row height
    NativeStatRowHeight = 13,

    -- Scroll frame
    ScrollTopPad = 56,
    ScrollBottomPad = 15,
}

local originalFrameSaved = false
local origBorderR, origBorderG, origBorderB, origBorderA
local origBgR, origBgG, origBgB, origBgA
local origClosePoint, origCloseRelTo, origCloseRelPoint, origCloseX, origCloseY

local function SaveOriginals()
    origBorderR, origBorderG, origBorderB, origBorderA =
        CharacterFrame.backdrop:GetBackdropBorderColor()
    origBgR, origBgG, origBgB, origBgA =
        CharacterFrame.backdrop:GetBackdropColor()
    origClosePoint, origCloseRelTo, origCloseRelPoint, origCloseX, origCloseY =
        CharacterFrameCloseButton:GetPoint(1)

    originalFrameSaved = true
end

local function RestoreOriginals()
    CharacterFrameCloseButton:ClearAllPoints()
    CharacterFrameCloseButton:SetPoint(origClosePoint, origCloseRelTo,
        origCloseRelPoint, origCloseX, origCloseY)
    CharacterFrame.backdrop:SetBackdropBorderColor(origBorderR, origBorderG,
        origBorderB, origBorderA)
    CharacterFrame.backdrop:SetBackdropColor(origBgR, origBgG, origBgB, origBgA)

    if BCPPFUIUnifiedBackdrop then
        BCPPFUIUnifiedBackdrop:Hide()
    end
end

local function SetCustomPositionCloseButton()
    CharacterFrameCloseButton:ClearAllPoints()
    CharacterFrameCloseButton:SetPoint("TOPRIGHT",
        BCPPFUIUnifiedBackdrop.backdrop, "TOPRIGHT", -4, -4)
end

local function ChangeFrameValues()
    if PanelTemplates_GetSelectedTab(CharacterFrame) == 1 then
        SetCustomPositionCloseButton()

        if CharacterFrame and CharacterFrame.backdrop then
            CharacterFrame.backdrop:SetBackdropColor(0, 0, 0, 0)
            CharacterFrame.backdrop:SetBackdropBorderColor(0, 0, 0, 0)
        end

        if BCPPFUIUnifiedBackdrop then
            BCPPFUIUnifiedBackdrop:Show()
        end
    else
        RestoreOriginals()
    end
end

function skin:ApplyCardBackdrop(card)
    pfUI.api.CreateBackdrop(card, 0, nil, 0)
    card.backdrop:SetBackdropColor(0, 0, 0, 0.65)
end

function skin:GetCardTitleFont()
    return pfUI.font_default, 12, "OUTLINE"
end

function skin:GetStatFrameFonts()
    return "GameFontNormalSmall", "GameFontHighlightSmall"
end

-- =============================
-- =   Character Frame Hooks   =
-- =============================
function skin:OnCharacterFrameShow()
    if not originalFrameSaved and CharacterFrame.backdrop and CharacterFrameCloseButton then
        SaveOriginals()
    end

    ChangeFrameValues()
end

function skin:OnCharacterFrameHide()
    if originalFrameSaved then
        RestoreOriginals()
    end
end

function skin:OnCharacterFrameTabClick()
    ChangeFrameValues()
end

function skin:OnCharacterFrameShowSubFrame()
    if not originalFrameSaved and CharacterFrame.backdrop and CharacterFrameCloseButton then
        SaveOriginals()
    end

    ChangeFrameValues()
end

local function BCP_AnchorResistanceFrame(infoFrame, aboveSection, cfg)
    CharacterResistanceFrame:SetParent(infoFrame)
    CharacterResistanceFrame:ClearAllPoints()
    CharacterResistanceFrame:SetPoint("BOTTOM", aboveSection, "TOP", 0, 4)

    local xOffset = 0

    for _, child in ipairs({ CharacterResistanceFrame:GetChildren() }) do
        child:ClearAllPoints()
        child:SetPoint("TOPLEFT", CharacterResistanceFrame, "TOPLEFT", xOffset, 0)
        xOffset = xOffset + cfg.ResistanceItemWidth + cfg.ResistanceItemSpacing
    end

    CharacterResistanceFrame:SetWidth(xOffset)
    CharacterResistanceFrame:SetHeight(cfg.ResistanceFrameHeight)
end


-- ==============================
-- =   Paper Doll Frame Hooks   =
-- ==============================
function skin:OnPaperDollShow()
    local cfg = self.Config

    if not originalFrameSaved then
        SaveOriginals()
    end

    -- Shift the model downward to center it
    if CharacterModelFrame then
        CharacterModelFrame:ClearAllPoints()
        CharacterModelFrame:SetPoint("TOPLEFT", PaperDollFrame, "TOPLEFT", cfg.ModelOffsetX, cfg.ModelOffsetY)
    end

    local fontScale = (BCPConfig and BCPConfig.StatPanel and BCPConfig.StatPanel.FontScale) or 1.0
    local isWideMode = BCP_IS_USING_BCS and BCPConfig and BCPConfig.StatPanel and BCPConfig.StatPanel.WideMode

    if PaperDollFrame then
        local scaledInfoWidth = math.floor(cfg.InfoFrameWidth * fontScale)
        local resistanceFrameWidth = ((cfg.ResistanceItemWidth + cfg.ResistanceItemSpacing) * 5) -
            cfg.ResistanceItemSpacing

        if scaledInfoWidth <= resistanceFrameWidth then
            scaledInfoWidth = resistanceFrameWidth + 15
        end

        if not BCPPFUICharacterInformationFrame then
            local infoFrame = CreateFrame("Frame", "BCPPFUICharacterInformationFrame", PaperDollFrame)
            infoFrame:SetPoint("LEFT", cfg.InfoFrameXOffset, cfg.InfoFrameYOffset)
            infoFrame:SetHeight(PaperDollFrame:GetHeight() + 19 - cfg.InfoFrameHeightPadding)
            infoFrame:EnableMouse(true)
            infoFrame:RegisterForDrag("LeftButton")
            infoFrame:SetScript("OnDragStart", function()
                CharacterFrame:StartMoving()
            end)
            infoFrame:SetScript("OnDragStop", function()
                CharacterFrame:StopMovingOrSizing()
            end)
        end

        if not (isWideMode and BCPPFUIStatsContent and BCPPFUIStatsContent.bcpContentBuilt) then
            BCPPFUICharacterInformationFrame:SetWidth(scaledInfoWidth)
        end
    end

    if BCPPFUICharacterInformationFrame then
        if not BCPPFUIUnifiedBackdrop then
            local unified = CreateFrame("Frame", "BCPPFUIUnifiedBackdrop", CharacterFrame)
            unified:SetAllPoints(CharacterFrame)
            unified:EnableMouse(true)
            unified:RegisterForDrag("LeftButton")
            unified:SetScript("OnDragStart", function()
                CharacterFrame:StartMoving()
            end)
            unified:SetScript("OnDragStop", function()
                CharacterFrame:StopMovingOrSizing()
            end)

            pfUI.api.CreateBackdrop(unified, nil, nil, cfg.UnifiedBackdropAlpha)
            pfUI.api.CreateBackdropShadow(unified)

            -- pfUI's character frame skin magic numbers
            unified.backdrop:SetPoint("TOPLEFT", 10, -10)
            unified:Show()
        end

        BCPPFUIUnifiedBackdrop.backdrop:SetPoint("BOTTOMRIGHT", -30 + BCPPFUICharacterInformationFrame:GetWidth() + 5, 72)
    end

    ChangeFrameValues()

    if not BCPPFUIStatsScrollFrame and BCPPFUICharacterInformationFrame and CharacterResistanceFrame then
        local scrollFrame = CreateFrame("ScrollFrame", "BCPPFUIStatsScrollFrame", BCPPFUICharacterInformationFrame)
        scrollFrame:EnableMouseWheel(true)

        local contentFrame = CreateFrame("Frame", "BCPPFUIStatsContent", scrollFrame)
        contentFrame:SetHeight(1)
        scrollFrame:SetScrollChild(contentFrame)

        if BCP_IS_USING_BCS then
            local scrollbar = CreateFrame("Slider", "BCPPFUIStatsScrollBar", scrollFrame, "UIPanelScrollBarTemplate")
            scrollbar:SetPoint("TOPLEFT", scrollFrame, "TOPRIGHT", -20, -16)
            scrollbar:SetPoint("BOTTOMLEFT", scrollFrame, "BOTTOMRIGHT", -20, 16)
            scrollbar:SetMinMaxValues(0, 0)
            scrollbar:SetValueStep(20)
            scrollbar:SetValue(0)

            pfUI.api.SkinScrollbar(scrollbar)

            scrollbar:SetScript("OnValueChanged", function()
                scrollFrame:SetVerticalScroll(scrollbar:GetValue())
            end)

            scrollFrame:SetScript("OnMouseWheel", function()
                local _, maxVal = scrollbar:GetMinMaxValues()
                local newVal = math.max(0, math.min(
                    maxVal,
                    scrollbar:GetValue() + arg1 * -20
                ))
                scrollbar:SetValue(newVal)
            end)
        end

        scrollFrame:SetScript("OnUpdate", function()
            scrollFrame:SetScript("OnUpdate", nil)

            local w = scrollFrame:GetWidth()
            contentFrame:SetWidth(w)

            if BCPPFUIStatsContent and not BCPPFUIStatsContent.bcpContentBuilt then
                BCPPFUIStatsContent.bcpContentBuilt = true
                self:BuildScrollContent()
            end
        end)
    end

    if BCPPFUIStatsScrollFrame and BCPPFUICharacterInformationFrame then
        local bottomPad = isWideMode and 0 or cfg.ScrollBottomPad

        BCPPFUIStatsScrollFrame:ClearAllPoints()
        BCPPFUIStatsScrollFrame:SetPoint("TOPLEFT", BCPPFUICharacterInformationFrame, "TOPLEFT", 2, -cfg.ScrollTopPad)
        BCPPFUIStatsScrollFrame:SetPoint("BOTTOMRIGHT", BCPPFUICharacterInformationFrame, "BOTTOMRIGHT", 0, bottomPad)
    end

    if BCPPFUIStatsScrollFrame and CharacterResistanceFrame and not BCPPFUIResistanceAnchored then
        BCP_AnchorResistanceFrame(BCPPFUICharacterInformationFrame, BCPPFUIStatsScrollFrame, cfg)
        BCPPFUIResistanceAnchored = true
    end

    if CharacterResistanceFrame then
        CharacterResistanceFrame:Show()
    end
end

-- ======================================
-- =   Inspect Paper Doll Frame Hooks   =
-- ======================================
function skin:OnInspectShow() end

function skin:BuildScrollContent()
    BCP_BuildScrollContent(
        self,
        BCPPFUIStatsContent,
        BCPPFUIStatsScrollFrame,
        BCPPFUIStatsScrollBar,
        "BCPPFUIBCSCard",
        "BCPPFUIBCSCat",
        "BCPPFUINativeCard"
    )
end
