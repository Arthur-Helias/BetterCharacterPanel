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

    -- Character frame's gear score section
    GearScoreSectionWidth = 140,
    GearScoreSectionHeight = 30,
    GearScoreSectionTopPad = -24,
    GearScoreLabelFontSize = 12,
    GearScoreLabelTopOffset = 16,
    GearScoreValueFontSize = 54,

    -- Inspect frame's gear score section
    InspectGearScoreSectionWidth = 60,
    InspectGearScoreSectionHeight = 15,
    InspectGearScoreAnchorY = -32,
    InspectGearScoreLabelFontSize = 10,
    InspectGearScoreLabelTopOffset = 12,
    InspectGearScoreValueFontSize = 12,

    -- Resistance icons
    ResistanceItemWidth = 26,
    ResistanceFrameHeight = 26,
    ResistanceItemSpacing = 2,

    -- BCS stats frame
    StatValueWidth = 36,
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
    ScrollTopPad = 86,
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

function skin:GetGearScoreText(unit)
    if unit == "player" then
        return getglobal("BCPPFUIGearScoreTextCharacter")
    else
        return getglobal("BCPPFUIGearScoreTextInspect")
    end
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

local function BCP_CreateGearScoreSection(parent, sectionName, labelName, textName, sectionW, sectionH, anchorPt,
                                          anchorRelTo, anchorRelPt, anchorX, anchorY, labelFont, labelSize,
                                          labelTopOffset, textFont, textSize)
    local section = CreateFrame("Frame", sectionName, parent)
    section:SetWidth(sectionW)
    section:SetHeight(sectionH)
    section:SetPoint(anchorPt, anchorRelTo, anchorRelPt, anchorX, anchorY)

    -- Gradient background
    local bgL = section:CreateTexture(nil, "BACKGROUND")
    bgL:SetTexture("Interface\\Buttons\\WHITE8x8")
    bgL:SetPoint("TOPLEFT", section, "TOPLEFT", 0, 0)
    bgL:SetPoint("BOTTOMRIGHT", section, "BOTTOM", 0, 0)
    bgL:SetGradientAlpha("HORIZONTAL", 0, 0, 0, 0, 0, 0, 0, 0.55)
    section.Background = bgL

    local bgR = section:CreateTexture(nil, "BACKGROUND")
    bgR:SetTexture("Interface\\Buttons\\WHITE8x8")
    bgR:SetPoint("TOPLEFT", section, "TOP", 0, 0)
    bgR:SetPoint("BOTTOMRIGHT", section, "BOTTOMRIGHT", 0, 0)
    bgR:SetGradientAlpha("HORIZONTAL", 0, 0, 0, 0.55, 0, 0, 0, 0)

    -- Top separator line
    local topL = section:CreateTexture(nil, "BORDER")
    topL:SetTexture("Interface\\Buttons\\WHITE8x8")
    topL:SetHeight(1)
    topL:SetPoint("TOPLEFT", section, "TOPLEFT", 0, 0)
    topL:SetPoint("TOPRIGHT", section, "TOP", 0, 0)
    topL:SetGradientAlpha("HORIZONTAL", 1, 0.84, 0, 0, 1, 0.84, 0, 0.9)
    section.TopLine = topL

    local topR = section:CreateTexture(nil, "BORDER")
    topR:SetTexture("Interface\\Buttons\\WHITE8x8")
    topR:SetHeight(1)
    topR:SetPoint("TOPLEFT", section, "TOP", 0, 0)
    topR:SetPoint("TOPRIGHT", section, "TOPRIGHT", 0, 0)
    topR:SetGradientAlpha("HORIZONTAL", 1, 0.84, 0, 0.9, 1, 0.84, 0, 0)

    -- Bottom separator line
    local botL = section:CreateTexture(nil, "BORDER")
    botL:SetTexture("Interface\\Buttons\\WHITE8x8")
    botL:SetHeight(1)
    botL:SetPoint("BOTTOMLEFT", section, "BOTTOMLEFT", 0, 0)
    botL:SetPoint("BOTTOMRIGHT", section, "BOTTOM", 0, 0)
    botL:SetGradientAlpha("HORIZONTAL", 1, 0.84, 0, 0, 1, 0.84, 0, 0.9)
    section.BottomLine = botL

    local botR = section:CreateTexture(nil, "BORDER")
    botR:SetTexture("Interface\\Buttons\\WHITE8x8")
    botR:SetHeight(1)
    botR:SetPoint("BOTTOMLEFT", section, "BOTTOM", 0, 0)
    botR:SetPoint("BOTTOMRIGHT", section, "BOTTOMRIGHT", 0, 0)
    botR:SetGradientAlpha("HORIZONTAL", 1, 0.84, 0, 0.9, 1, 0.84, 0, 0)

    -- Label
    local label = section:CreateFontString(labelName, "OVERLAY")
    label:SetFont(labelFont, labelSize, "OUTLINE")
    label:SetPoint("TOP", section, "TOP", 0, labelTopOffset)
    label:SetTextColor(1, 1, 1)
    label:SetText(BCP_ILVL_LABEL)

    -- Value
    local value = section:CreateFontString(textName, "OVERLAY")
    value:SetFont(textFont, textSize, "OUTLINE")
    value:SetPoint("CENTER", section, "CENTER", 0, 0)
    value:SetTextColor(1, 0.84, 0)

    return section
end

local function BCP_AnchorResistanceFrame(infoFrame, belowSection, cfg)
    CharacterResistanceFrame:SetParent(infoFrame)
    CharacterResistanceFrame:ClearAllPoints()
    CharacterResistanceFrame:SetPoint("TOP", belowSection, "BOTTOM", 0, -4)

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

    if PaperDollFrame and not BCPPFUICharacterInformationFrame then
        local infoFrame = CreateFrame("Frame", "BCPPFUICharacterInformationFrame", PaperDollFrame)
        infoFrame:SetPoint("LEFT", cfg.InfoFrameXOffset, cfg.InfoFrameYOffset)
        infoFrame:SetHeight(PaperDollFrame:GetHeight() + 19 - cfg.InfoFrameHeightPadding)
        infoFrame:SetWidth(cfg.InfoFrameWidth)
        infoFrame:EnableMouse(true)
        infoFrame:RegisterForDrag("LeftButton")
        infoFrame:SetScript("OnDragStart", function()
            CharacterFrame:StartMoving()
        end)
        infoFrame:SetScript("OnDragStop", function()
            CharacterFrame:StopMovingOrSizing()
        end)
    end

    if BCPPFUICharacterInformationFrame and not BCPPFUIUnifiedBackdrop then
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
        unified.backdrop:SetPoint("BOTTOMRIGHT", -30 + BCPPFUICharacterInformationFrame:GetWidth() + 5, 72)
        unified:Show()
    end

    ChangeFrameValues()

    -- O――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――O
    -- |   The gearscore background design comes from ReforgedArmory by Repooc.   |
    -- O――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――O
    if BCPPFUICharacterInformationFrame and not BCPPFUIGearScoreCharacterSection then
        BCP_CreateGearScoreSection(
            BCPPFUICharacterInformationFrame,
            "BCPPFUIGearScoreCharacterSection",
            "BCPPFUIGearScoreLabelTextCharacter",
            "BCPPFUIGearScoreTextCharacter",
            cfg.GearScoreSectionWidth,
            cfg.GearScoreSectionHeight,
            "TOP", BCPPFUICharacterInformationFrame, "TOP", 0, cfg.GearScoreSectionTopPad,
            pfUI.font_default, cfg.GearScoreLabelFontSize, cfg.GearScoreLabelTopOffset,
            pfUI.font_combat, cfg.GearScoreValueFontSize
        )
    end

    if BCPPFUIGearScoreCharacterSection and CharacterResistanceFrame and not BCPPFUIResistanceAnchored then
        BCP_AnchorResistanceFrame(BCPPFUICharacterInformationFrame, BCPPFUIGearScoreCharacterSection, cfg)
        BCPPFUIResistanceAnchored = true
    end

    if CharacterResistanceFrame then
        CharacterResistanceFrame:Show()
    end

    if not BCPPFUIStatsScrollFrame and BCPPFUICharacterInformationFrame and CharacterResistanceFrame then
        local scrollFrame = CreateFrame("ScrollFrame", "BCPPFUIStatsScrollFrame", BCPPFUICharacterInformationFrame)
        scrollFrame:SetPoint("TOPLEFT", BCPPFUICharacterInformationFrame, "TOPLEFT", 2, -cfg.ScrollTopPad)
        scrollFrame:SetPoint("BOTTOMRIGHT", BCPPFUICharacterInformationFrame, "BOTTOMRIGHT", 0, cfg.ScrollBottomPad)
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
end

-- ======================================
-- =   Inspect Paper Doll Frame Hooks   =
-- ======================================
function skin:OnInspectShow()
    local cfg = self.Config

    if not BCPPFUIGearScoreInspectSection then
        BCP_CreateGearScoreSection(
            InspectPaperDollFrame,
            "BCPPFUIGearScoreInspectSection",
            "BCPPFUIGearScoreLabelTextInspect",
            "BCPPFUIGearScoreTextInspect",
            cfg.InspectGearScoreSectionWidth,
            cfg.InspectGearScoreSectionHeight,
            "TOP", InspectLevelText, "BOTTOM", 0, cfg.InspectGearScoreAnchorY,
            pfUI.font_default, cfg.InspectGearScoreLabelFontSize,
            cfg.InspectGearScoreLabelTopOffset,
            pfUI.font_combat, cfg.InspectGearScoreValueFontSize
        )
    end
end

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
