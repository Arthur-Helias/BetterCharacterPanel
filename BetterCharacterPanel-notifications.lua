BCPNotifications = BCPNotifications or {}

function BCPNotifications:CreateNampowerError()
    local dialog = CreateFrame("Frame", "BCPErrorDialog", UIParent)
    dialog:SetWidth(370)
    dialog:SetHeight(140)
    dialog:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    dialog:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 },
    })
    dialog:SetBackdropColor(0, 0, 0, 1)
    dialog:SetFrameStrata("FULLSCREEN_DIALOG")
    dialog:SetMovable(true)
    dialog:EnableMouse(true)
    dialog:RegisterForDrag("LeftButton")
    dialog:SetScript("OnDragStart", function() dialog:StartMoving() end)
    dialog:SetScript("OnDragStop", function() dialog:StopMovingOrSizing() end)

    local title = dialog:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", dialog, "TOP", 0, -16)
    title:SetText("Better Character Panel [v" ..
        BCP_VERSION_MAJOR .. "." .. BCP_VERSION_MINOR .. "." .. BCP_VERSION_PATCH .. "]")

    local body = dialog:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    body:SetPoint("TOP", title, "BOTTOM", 0, -12)
    body:SetWidth(300)
    body:SetJustifyH("CENTER")
    body:SetText(BCP_ERR_NAM)

    local editBox = CreateFrame("EditBox", "BCPErrorDialogEditBox", dialog)
    editBox:SetPoint("TOP", body, "BOTTOM", 0, -10)
    editBox:SetWidth(240)
    editBox:SetHeight(20)
    editBox:SetFontObject(GameFontHighlightSmall)
    editBox:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    editBox:SetBackdropColor(0, 0, 0, 0.8)
    editBox:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8)
    editBox:SetText("https://gitea.com/avitasia/nampower")
    editBox:SetTextInsets(8, 0, 0, 0)
    editBox:SetAutoFocus(false)
    editBox:SetScript("OnEditFocusGained", function()
        this:HighlightText()
    end)
    editBox:SetScript("OnEscapePressed", function()
        this:ClearFocus()
    end)

    local okButton = CreateFrame("Button", "BCPErrorDialogOkButton", dialog, "UIPanelButtonTemplate")
    okButton:SetWidth(80)
    okButton:SetHeight(22)
    okButton:SetPoint("BOTTOM", dialog, "BOTTOM", 0, 14)
    okButton:SetText("Ok")
    okButton:SetScript("OnClick", function()
        dialog:Hide()
    end)

    if BCP_IS_USING_PFUI then
        BCPNotifications:SkinNampowerErrorpfUI()
    end
end

function BCPNotifications:SkinNampowerErrorpfUI()
    if BCP_IS_USING_PFUI and BCPErrorDialog then
        pfUI.api.CreateBackdrop(BCPErrorDialog, nil, nil, 0.75)
        pfUI.api.CreateBackdropShadow(BCPErrorDialog)
        pfUI.api.CreateBackdrop(BCPErrorDialogEditBox, nil, nil, 1)
        pfUI.api.SkinButton(BCPErrorDialogOkButton)
    end
end
