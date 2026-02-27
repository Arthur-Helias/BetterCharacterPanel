-- O―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――O
-- |   Most of the gearscore/ilvl related code comes from ShaguScore by Shagu.   |
-- O―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――O
local BCP_TT_ILVL_FALLBACK_R, BCP_TT_ILVL_FALLBACK_G, BCP_TT_ILVL_FALLBACK_B = 1.0, 1.0, 1.0
local BSlot = BCPDBEnchants.Slot
local BCP_TT_EQUIP_SLOTS = {
    BSlot.Head, BSlot.Neck, BSlot.Shoulder, BSlot.Cloak, BSlot.Chest, BSlot.Wrist,
    BSlot.Hands, BSlot.Belt, BSlot.Legs, BSlot.Feet, BSlot.Finger1, BSlot.Finger2,
    BSlot.Trinket1, BSlot.Trinket2, BSlot.MainHand, BSlot.OffHand, BSlot.Range,
}
local BCP_SKIP_INVENTORY_TYPES = {
    [0] = true,
    [4] = true,
    [18] = true,
    [19] = true,
    [24] = true,
    [27] = true,
}

function BCP_ItemIdFromLink(link)
    if not link then
        return nil
    end

    local _, _, idStr = string.find(link, "item:(%d+):")

    return idStr and tonumber(idStr) or nil
end

function BCP_ILFromLink(link)
    local itemId = BCP_ItemIdFromLink(link)

    if not itemId then
        return nil
    end

    local il = BCPLib:GetGearScoreFromItemId(itemId)

    return (il and il > 0) and il or nil
end

function BCP_IsGear(link)
    local itemId = BCP_ItemIdFromLink(link)

    if not itemId then
        return false
    end

    local ok, invType = pcall(GetItemStatsField, itemId, "inventoryType")

    if not ok or invType == nil then
        return false
    end

    return not BCP_SKIP_INVENTORY_TYPES[invType]
end

function BCP_GearILFromLink(link)
    if not BCP_IsGear(link) then
        return nil
    end

    return BCP_ILFromLink(link)
end

function BCP_QualityColor(quality)
    local r, g, b = GetItemQualityColor(quality or 1)

    if r then
        return r, g, b
    end

    return BCP_TT_ILVL_FALLBACK_R, BCP_TT_ILVL_FALLBACK_G, BCP_TT_ILVL_FALLBACK_B
end

function BCP_ColorFromLink(link)
    local itemId = BCP_ItemIdFromLink(link)

    if not itemId then
        return BCP_TT_ILVL_FALLBACK_R, BCP_TT_ILVL_FALLBACK_G, BCP_TT_ILVL_FALLBACK_B
    end

    local ok, quality = pcall(GetItemStatsField, itemId, "quality")

    if not ok or quality == nil then
        return BCP_TT_ILVL_FALLBACK_R, BCP_TT_ILVL_FALLBACK_G, BCP_TT_ILVL_FALLBACK_B
    end

    return BCP_QualityColor(quality)
end

function BCP_AvgColorFromUnit(unit)
    local tr, tg, tb, count = 0, 0, 0, 0

    for _, slot in ipairs(BCP_TT_EQUIP_SLOTS) do
        local okInfo, itemInfo = pcall(GetEquippedItem, unit, slot)

        if okInfo and itemInfo then
            local ok, quality = pcall(GetItemStatsField, itemInfo.itemId, "quality")

            if ok and quality ~= nil then
                local r, g, b = BCP_QualityColor(quality)

                tr = tr + r; tg = tg + g; tb = tb + b
                count = count + 1
            end
        end
    end

    if count == 0 then
        return
    end

    return tr / count, tg / count, tb / count
end

function BCP_AverageIL(unit)
    if not UnitIsPlayer(unit) then
        return nil
    end

    local total = 0
    local slots = BCPLib:IsUsingTwoHandedWeapon(unit) and 16 or 17

    for _, slot in ipairs(BCP_TT_EQUIP_SLOTS) do
        local il = BCPLib:GetGearScoreFromEquipmentSlot(unit, slot)

        if il then
            total = total + il
        end
    end

    local averageIL = math.floor(total / slots)

    if averageIL == 0 then
        return nil
    end

    return averageIL
end

local function BCP_AddIlvlToTooltip(link)
    local il = BCP_GearILFromLink(link)

    if il then
        local r, g, b = BCP_ColorFromLink(link)

        GameTooltip:AddLine(BCP_ILVL_LABEL .. ": " .. il, r, g, b)
        GameTooltip:Show()
    end
end

local _Orig_TT_SetBagItem = GameTooltip.SetBagItem

function GameTooltip.SetBagItem(self, bag, slot)
    local ret = _Orig_TT_SetBagItem(self, bag, slot)

    BCP_AddIlvlToTooltip(GetContainerItemLink(bag, slot))

    return ret
end

local _Orig_TT_SetInventoryItem = GameTooltip.SetInventoryItem

function GameTooltip.SetInventoryItem(self, unit, slot)
    local ret = _Orig_TT_SetInventoryItem(self, unit, slot)

    if unit == "bank" then
        BCP_AddIlvlToTooltip(GetInventoryItemLink(unit, slot))
    end

    return ret
end

local function BCP_GetCacheKey(unit)
    local playerName = UnitName(unit)
    local playerRealm = GetRealmName()

    if not playerName or not playerRealm then
        return nil
    end

    return playerName .. "-" .. playerRealm
end

local function BCP_GetCachedEntry(cacheKey)
    if not BCPUnitsIlvlCache then
        return nil
    end

    for _, entry in ipairs(BCPUnitsIlvlCache) do
        if entry[1] == cacheKey then
            return entry
        end
    end

    return nil
end

local function BCP_SetCachedEntry(cacheKey, avgIL, r, g, b)
    if not BCPUnitsIlvlCache then
        return
    end

    local entry = BCP_GetCachedEntry(cacheKey)

    if entry then
        entry[2] = avgIL
        entry[3] = r
        entry[4] = g
        entry[5] = b
    else
        table.insert(BCPUnitsIlvlCache, { cacheKey, avgIL, r, g, b })
    end
end

local function BCP_AddUnitAvgIlvlToTooltip(unit)
    if not UnitIsPlayer(unit) then
        return
    end

    if not BCPConfig.GearScore.ShowOnTooltips then
        return
    end

    local avgIL = BCP_AverageIL(unit)
    local cacheKey = BCP_GetCacheKey(unit)

    if avgIL then
        local r, g, b = BCP_AvgColorFromUnit(unit)

        if not r or not g or not b then
            return
        end

        if cacheKey then
            BCP_SetCachedEntry(cacheKey, avgIL, r, g, b)
        end

        GameTooltip:AddLine(BCP_ILVL_LABEL .. ": " .. avgIL, r, g, b)
        GameTooltip:Show()
    elseif cacheKey then
        local entry = BCP_GetCachedEntry(cacheKey)

        if entry and entry[2] then
            GameTooltip:AddLine(BCP_ILVL_LABEL .. ": " .. entry[2], entry[3], entry[4], entry[5])
            GameTooltip:Show()
        end
    end
end

local BCP_MouseoverFrame = CreateFrame("Frame")

BCP_MouseoverFrame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
BCP_MouseoverFrame:SetScript("OnEvent", function()
    if GameTooltip:IsVisible() then
        BCP_AddUnitAvgIlvlToTooltip("mouseover")
    end
end)

local _Orig_TT_SetUnit = GameTooltip.SetUnit

function GameTooltip.SetUnit(self, unit)
    local ret = _Orig_TT_SetUnit(self, unit)

    BCP_AddUnitAvgIlvlToTooltip(unit)

    return ret
end

local BCP_BagHookFrame = CreateFrame("Frame")

BCP_BagHookFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
BCP_BagHookFrame:SetScript("OnEvent", function()
    BCP_BagHookFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")

    if not BCPConfig.GearScore.ShowOnIcons then
        return
    end

    if BCP_IS_USING_PFUI then
        BCPIlvlSkin_pfUI:ApplyBagIcons()
        BCPIlvlSkin_pfUI:ApplyMerchantIcons()
    else
        BCPIlvlSkin_Vanilla:ApplyBagIcons()
        BCPIlvlSkin_Vanilla:ApplyMerchantIcons()
    end
end)
