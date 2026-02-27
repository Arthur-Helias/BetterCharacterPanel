-- O――――――――――――――――――――――――――――――――――――――――――――――O
-- |   Bag icon ilvl overlay for the default UI   |
-- O――――――――――――――――――――――――――――――――――――――――――――――O

BCPIlvlSkin_Vanilla = BCPIlvlSkin_Vanilla or {}

local skin = BCPIlvlSkin_Vanilla

local function BCP_UpdateVanillaBagSlot(bagId, itemButton)
    if not itemButton.bcpIlvlText then
        itemButton.bcpIlvlText = itemButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        itemButton.bcpIlvlText:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
        itemButton.bcpIlvlText:SetPoint("TOPRIGHT", itemButton, "TOPRIGHT", 0, -1)
    end

    local slotId = itemButton:GetID()
    local link = GetContainerItemLink(bagId, slotId)
    local il = BCP_GearILFromLink(link)

    if il then
        local r, g, b = BCP_ColorFromLink(link)

        itemButton.bcpIlvlText:SetText(il)
        itemButton.bcpIlvlText:SetTextColor(r, g, b)
    else
        itemButton.bcpIlvlText:SetText("")
    end
end

local function BCP_UpdateVanillaBagFrame(frame)
    local bagId = frame:GetID()
    local frameName = frame:GetName()

    for j = 1, frame.size, 1 do
        local itemButton = getglobal(frameName .. "Item" .. j)

        BCP_UpdateVanillaBagSlot(bagId, itemButton)
    end
end

function skin:ApplyBagIcons()
    local _Orig_ContainerFrame_GenerateFrame = ContainerFrame_GenerateFrame

    ContainerFrame_GenerateFrame = function(frame, size, id)
        _Orig_ContainerFrame_GenerateFrame(frame, size, id)
        BCP_UpdateVanillaBagFrame(frame)
    end

    local _Orig_ContainerFrame_Update = ContainerFrame_Update

    ContainerFrame_Update = function(frame)
        _Orig_ContainerFrame_Update(frame)
        BCP_UpdateVanillaBagFrame(frame)
    end
end

local function BCP_UpdateVanillaMerchantButton(itemButton, link)
    if not itemButton.bcpIlvlText then
        itemButton.bcpIlvlText = itemButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        itemButton.bcpIlvlText:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
        itemButton.bcpIlvlText:SetPoint("TOPRIGHT", itemButton, "TOPRIGHT", 0, -1)
    end

    local il = BCP_GearILFromLink(link)

    if il then
        local r, g, b = BCP_ColorFromLink(link)

        itemButton.bcpIlvlText:SetText(il)
        itemButton.bcpIlvlText:SetTextColor(r, g, b)
    else
        itemButton.bcpIlvlText:SetText("")
    end
end

local function BCP_ClearVanillaMerchantButton(itemButton)
    if itemButton and itemButton.bcpIlvlText then
        itemButton.bcpIlvlText:SetText("")
    end
end

function skin:ApplyMerchantIcons()
    local _Orig_MerchantFrame_UpdateMerchantInfo = MerchantFrame_UpdateMerchantInfo

    MerchantFrame_UpdateMerchantInfo = function()
        _Orig_MerchantFrame_UpdateMerchantInfo()

        for i = 1, MERCHANT_ITEMS_PER_PAGE do
            local itemButton = getglobal("MerchantItem" .. i .. "ItemButton")

            if itemButton then
                if itemButton:IsShown() then
                    BCP_UpdateVanillaMerchantButton(itemButton, GetMerchantItemLink(itemButton:GetID()))
                else
                    BCP_ClearVanillaMerchantButton(itemButton)
                end
            end
        end
    end
end