-- O―――――――――――――――――――――――――――――――――――――――O
-- |   Paperdoll skin for the default UI   |
-- O―――――――――――――――――――――――――――――――――――――――O

BCPSkin_Vanilla = BCPSkin_Vanilla or {}
local skin = BCPSkin_Vanilla

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
    LeftIconsPermEnchantOffsets = { 8, 7 },
    LeftIconsTempEnchantOffsets = { 8, -7 },
    RightIconsPermEnchantOffsets = { -7, 7 },
    RightIconsTempEnchantOffsets = { -7, -7 },

    -- Wrist enchant text
    WristsIconPermEnchantTextJustifyH = "LEFT",
    WristsIconPermEnchantTextAnchors = { "LEFT", "RIGHT" },
    WristsIconPermEnchantOffsets = { 8, 16 },
    WristsIconTempEnchantTextJustifyH = "LEFT",
    WristsIconTempEnchantTextAnchors = { "LEFT", "RIGHT" },
    WristsIconTempEnchantOffsets = { 8, 3 },

    -- Main hand enchant text
    MainHandIconPermEnchantTextJustifyH = "RIGHT",
    MainHandIconPermEnchantTextAnchors = { "BOTTOMRIGHT", "BOTTOMLEFT" },
    MainHandIconPermEnchantOffsets = { -8, 6 },
    MainHandIconTempEnchantTextJustifyH = "RIGHT",
    MainHandIconTempEnchantTextAnchors = { "BOTTOMRIGHT", "BOTTOMLEFT" },
    MainHandIconTempEnchantOffsets = { -8, -6 },

    -- Off-hand enchant text
    OffHandIconPermEnchantTextJustifyH = "RIGHT",
    OffHandIconPermEnchantTextAnchors = { "TOPRIGHT", "TOPRIGHT" },
    OffHandIconPermEnchantOffsets = { 0, 16 },
    OffHandIconTempEnchantTextJustifyH = "RIGHT",
    OffHandIconTempEnchantTextAnchors = { "BOTTOMRIGHT", "BOTTOMRIGHT" },
    OffHandIconTempEnchantOffsets = { 0, -12 },

    -- Ranged enchant text
    RangedIconPermEnchantTextJustifyH = "LEFT",
    RangedIconPermEnchantTextAnchors = { "TOPRIGHT", "TOPRIGHT" },
    RangedIconPermEnchantOffsets = { 92, 16 },
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
    InfoFrameWidth = 170,
    InfoFrameHeightPadding = 40,

    -- Resistance icons
    ResistanceItemWidth = 20,
    ResistanceFrameHeight = 20,
    ResistanceItemSpacing = 8,

    -- Scroll frame
    ScrollTopPad = 45,
    ScrollBottomPad = 15,

    -- Backdrop
    BackdropBgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    BackdropEdgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    BackdropTileSize = 32,
    BackdropEdgeSize = 32,
    BackdropInsets = { left = 12, right = 12, top = 12, bottom = 11 },

    -- BCS stats frame
    StatValueWidth = 60,
    StatValueRightPad = 9,
    StatValueFontSize = 9,
    StatLabelRightPad = 10,
    StatLabelLeftPad = 9,
    StatLabelFontSize = 9,

    -- Card layout
    StatCardTitleTopPad = 12,
    StatCardBottomPad = 12,
    StatRowSpacing = 0,

    -- Native stats row height and card widths
    NativeCardWidthExtra = 20,
    NativeStatCardXOffset = -1,
    NativeStatRowHeight = 13,
    NativeStatFrameWidthExtra = -5,
    NativeStatFrameXOffset = 9,

    -- Font
    TitleFont = "Fonts\\FRIZQT__.TTF",
    TitleFontSize = 12,
    TitleFontFlags = "OUTLINE",
}

function skin:ApplyCardBackdrop(card)
    local cfg = self.Config
    card:SetBackdrop({
        bgFile = cfg.BackdropBgFile,
        tile = true,
        tileSize = cfg.BackdropTileSize,
        edgeFile = cfg.BackdropEdgeFile,
        edgeSize = cfg.BackdropEdgeSize,
        insets = cfg.BackdropInsets,
    })
    card:SetBackdropColor(0, 0, 0, 0.65)
end

function skin:GetCardTitleFont()
    local cfg = self.Config

    return cfg.TitleFont, cfg.TitleFontSize, cfg.TitleFontFlags
end

function skin:GetStatFrameFonts()
    return "GameFontNormalSmall", "GameFontHighlightSmall"
end

-- =============================
-- =   Character Frame Hooks   =
-- =============================
function skin:OnCharacterFrameShow() end

function skin:OnCharacterFrameHide() end

function skin:OnCharacterFrameTabClick() end

function skin:OnCharacterFrameShowSubFrame() end

local function BCP_AnchorResistanceFrame(infoFrame, aboveSection, cfg)
    CharacterResistanceFrame:SetParent(infoFrame)
    CharacterResistanceFrame:ClearAllPoints()
    CharacterResistanceFrame:SetPoint("BOTTOM", aboveSection, "TOP", -6, 12)

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

    -- Allows click rotating the character's model instead of using the arrows
    -- Shift the model downward to center it
    if CharacterModelFrame then
        BCPLib:EnableClickRotate(CharacterModelFrame)
        CharacterModelFrame:ClearAllPoints()
        CharacterModelFrame:SetPoint("TOPLEFT", PaperDollFrame, "TOPLEFT", cfg.ModelOffsetX, cfg.ModelOffsetY)
    end

    if PaperDollFrame and not BCPVanillaCharacterInformationFrame then
        local fontScale = (BCPConfig and BCPConfig.StatPanel and BCPConfig.StatPanel.FontScale) or 1.0
        local scaledInfoWidth = math.floor(cfg.InfoFrameWidth * fontScale)
        local resistanceFrameWidth = ((cfg.ResistanceItemWidth + cfg.ResistanceItemSpacing) * 5) -
        cfg.ResistanceItemSpacing

        if scaledInfoWidth <= resistanceFrameWidth then
            scaledInfoWidth = resistanceFrameWidth + 35
        end

        local infoFrame = CreateFrame("Frame", "BCPVanillaCharacterInformationFrame", PaperDollFrame)
        infoFrame:SetPoint("LEFT", cfg.InfoFrameXOffset, cfg.InfoFrameYOffset)
        infoFrame:SetHeight(PaperDollFrame:GetHeight() - cfg.InfoFrameHeightPadding)
        infoFrame:SetWidth(scaledInfoWidth)
        infoFrame:SetBackdrop({
            bgFile = cfg.BackdropBgFile,
            tile = true,
            tileSize = cfg.BackdropTileSize,
            edgeFile = cfg.BackdropEdgeFile,
            edgeSize = cfg.BackdropEdgeSize,
            insets = cfg.BackdropInsets,
        })
        infoFrame:SetBackdropBorderColor(1, 1, 1, 1)
    end

    if not BCPVanillaStatsScrollFrame and BCPVanillaCharacterInformationFrame and CharacterResistanceFrame then
        local scrollFrame = CreateFrame("ScrollFrame", "BCPVanillaStatsScrollFrame", BCPVanillaCharacterInformationFrame)
        scrollFrame:SetPoint("TOPLEFT", BCPVanillaCharacterInformationFrame, "TOPLEFT", 12, -cfg.ScrollTopPad)
        scrollFrame:SetPoint("BOTTOMRIGHT", BCPVanillaCharacterInformationFrame, "BOTTOMRIGHT", -5, cfg.ScrollBottomPad)
        scrollFrame:EnableMouseWheel(true)

        local contentFrame = CreateFrame("Frame", "BCPVanillaStatsContent", scrollFrame)
        contentFrame:SetHeight(1)
        scrollFrame:SetScrollChild(contentFrame)

        if BCP_IS_USING_BCS then
            local scrollbar = CreateFrame("Slider", "BCPVanillaStatsScrollBar", scrollFrame, "UIPanelScrollBarTemplate")
            scrollbar:SetPoint("TOPLEFT", scrollFrame, "TOPRIGHT", -25, -16)
            scrollbar:SetPoint("BOTTOMLEFT", scrollFrame, "BOTTOMRIGHT", -25, 16)
            scrollbar:SetMinMaxValues(0, 0)
            scrollbar:SetValueStep(20)
            scrollbar:SetValue(0)

            scrollbar:SetScript("OnValueChanged", function()
                scrollFrame:SetVerticalScroll(scrollbar:GetValue())
            end)

            scrollFrame:SetScript("OnMouseWheel", function()
                local _, maxVal = scrollbar:GetMinMaxValues()
                local newVal = math.max(0, math.min(maxVal, scrollbar:GetValue() + arg1 * -20))
                scrollbar:SetValue(newVal)
            end)
        end

        scrollFrame:SetScript("OnUpdate", function()
            scrollFrame:SetScript("OnUpdate", nil)

            local w = scrollFrame:GetWidth()
            contentFrame:SetWidth(w)

            if BCPVanillaStatsContent and not BCPVanillaStatsContent.bcpContentBuilt then
                BCPVanillaStatsContent.bcpContentBuilt = true
                self:BuildScrollContent()
            end
        end)
    end

    if BCPVanillaStatsScrollFrame and CharacterResistanceFrame and not BCPVanillaResistanceAnchored then
        BCP_AnchorResistanceFrame(BCPVanillaCharacterInformationFrame, BCPVanillaStatsScrollFrame, cfg)
        BCPVanillaResistanceAnchored = true
    end

    if CharacterResistanceFrame then
        CharacterResistanceFrame:Show()
    end
end

-- ======================================
-- =   Inspect Paper Doll Frame Hooks   =
-- ======================================
function skin:OnInspectShow()
    -- Allows click rotating the character's model instead of using the arrows
    if InspectModelFrame then
        BCPLib:EnableClickRotate(InspectModelFrame)
    end
end

function skin:BuildScrollContent()
    BCP_BuildScrollContent(
        self,
        BCPVanillaStatsContent,
        BCPVanillaStatsScrollFrame,
        BCPVanillaStatsScrollBar,
        "BCPVanillaBCSCard",
        "BCPVanillaBCSCat",
        "BCPVanillaNativeCard"
    )
end
