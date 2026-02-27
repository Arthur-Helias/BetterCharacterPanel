-- O――――――――――――――――――――――――――――――――――――O
-- |   Bag icon ilvl overlay for pfUI   |
-- O――――――――――――――――――――――――――――――――――――O

BCPIlvlSkin_pfUI = BCPIlvlSkin_pfUI or {}

local skin = BCPIlvlSkin_pfUI

function skin:ApplyBagIcons()
    if not (pfUI.bag and pfUI.bag.UpdateSlot) then
        return
    end

    local _Orig_UpdateSlot = pfUI.bag.UpdateSlot

    pfUI.bag.UpdateSlot = function(self, bag, slot)
        _Orig_UpdateSlot(self, bag, slot)

        if not pfUI.bags[bag] or not pfUI.bags[bag].slots[slot] then
            return
        end

        local slotFrame = pfUI.bags[bag].slots[slot].frame

        if not slotFrame then
            return
        end

        if not slotFrame.bcpIlvlText then
            slotFrame.bcpIlvlText = slotFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            slotFrame.bcpIlvlText:SetFont(pfUI.font_default, 12, "OUTLINE")
            slotFrame.bcpIlvlText:SetPoint("TOPRIGHT", 1, 1)
        end

        local link = GetContainerItemLink(bag, slot)
        local il = BCP_GearILFromLink(link)

        if il then
            local r, g, b = BCP_ColorFromLink(link)

            slotFrame.bcpIlvlText:SetText(il)
            slotFrame.bcpIlvlText:SetTextColor(r, g, b)
        else
            slotFrame.bcpIlvlText:SetText("")
        end
    end
end

local function BCP_UpdatepfUIMerchantButton(itemButton, link)
    if not itemButton.bcpIlvlText then
        itemButton.bcpIlvlText = itemButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        itemButton.bcpIlvlText:SetFont(pfUI.font_default, 12, "OUTLINE")
        itemButton.bcpIlvlText:SetPoint("TOPRIGHT", 0, -1)
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

local function BCP_ClearpfUIMerchantButton(itemButton)
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
                    BCP_UpdatepfUIMerchantButton(itemButton, GetMerchantItemLink(itemButton:GetID()))
                else
                    BCP_ClearpfUIMerchantButton(itemButton)
                end
            end
        end
    end
end
