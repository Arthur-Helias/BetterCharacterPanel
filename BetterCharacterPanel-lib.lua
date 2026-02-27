BCPLib = BCPLib or {}

local BS = BCPDBEnchants.Slot

local SlotPermanentEnchants = {
    [BS.Head] = { BCPDBEnchants.HeadPermanentEnchants },
    [BS.Neck] = { BCPDBEnchants.NeckPermanentEnchants },
    [BS.Shoulder] = { BCPDBEnchants.ShoulderPermanentEnchants },
    [BS.Chest] = { BCPDBEnchants.ChestPermanentEnchants },
    [BS.Belt] = { BCPDBEnchants.BeltPermanentEnchants },
    [BS.Legs] = { BCPDBEnchants.LegsPermanentEnchants },
    [BS.Feet] = { BCPDBEnchants.FeetPermanentEnchants },
    [BS.Wrist] = { BCPDBEnchants.WristPermanentEnchants },
    [BS.Hands] = { BCPDBEnchants.HandsPermanentEnchants },
    [BS.Finger1] = { BCPDBEnchants.FingerPermanentEnchants },
    [BS.Finger2] = { BCPDBEnchants.FingerPermanentEnchants },
    [BS.Cloak] = { BCPDBEnchants.CloakPermanentEnchants },
    [BS.MainHand] = { BCPDBEnchants.OneHandedPermanentEnchants, BCPDBEnchants.TwoHandedPermanentEnchants },
    [BS.OffHand] = { BCPDBEnchants.OneHandedPermanentEnchants },
    [BS.Range] = { BCPDBEnchants.RangedPermanentEnchants },
}

-- There are other vanilla realms outside of TWoW; add them here and in the database when found
local function GetRealmPhase(realmName)
    if realmName == "Nordanaar" then
        return BCPDBEnchants.PhaseTWOWNordanaar
    end

    if realmName == "Tel'Abim" then
        return BCPDBEnchants.PhaseTWOWTelAbim
    end

    if realmName == "Ambershire" then
        return BCPDBEnchants.PhaseTWOWAmbershire
    end

    return nil
end

-- Taken from pfUI by Shagu
local function HookScript(f, script, func)
    local prev = f:GetScript(script)

    f:SetScript(script, function(a1, a2, a3, a4, a5, a6, a7, a8, a9)
        if prev then
            prev(a1, a2, a3, a4, a5, a6, a7, a8, a9)
        end

        func(a1, a2, a3, a4, a5, a6, a7, a8, a9)
    end)
end

-- Taken from pfUI by Shagu
function BCPLib:IsPlayingOnTurtleWoW()
    if not TargetHPText or not TargetHPPercText then
        return false
    end

    return true
end

function BCPLib:GetPermanentEnchantDataFromEnchantId(enchantId)
    local entry = BCPDBEnchants.PermanentEnchants[enchantId]

    if not entry then
        return nil
    end

    return {
        Name = entry[1],
        Effect = entry[2],
    }
end

function BCPLib:GetTemporyEnchantDataFromEnchantId(enchantId)
    local entry = BCPDBEnchants.TemporaryEnchants[enchantId]

    if not entry then
        return nil
    end

    return {
        Name = entry[1],
        Effect = entry[2],
    }
end

function BCPLib:IsEquippedItemMissingPermanentEnchant(unit, slot)
    if slot == BS.Shirt or slot == BS.Trinket1 or slot == BS.Trinket2 or slot == BS.Tabard then
        return false
    end

    local itemInfo = GetEquippedItem(unit, slot)

    if not itemInfo then
        return false
    end

    if itemInfo.permanentEnchantId and itemInfo.permanentEnchantId ~= 0 then
        return false
    end

    local enchantTables = SlotPermanentEnchants[slot]

    if not enchantTables then
        return false
    end

    local realmPhase = GetRealmPhase(GetRealmName())

    local okLevel, itemLevel = pcall(GetItemLevel, itemInfo.itemId)

    if not okLevel then
        return false
    end

    itemLevel = itemLevel or 0

    local okSub, itemSubClass = pcall(GetItemStatsField, itemInfo.itemId, "subclass")

    if not okSub then
        return false
    end


    local okClass, itemClass = pcall(GetItemStatsField, itemInfo.itemId, "class")

    if not okClass then
        return false
    end

    -- Dirty quick hack that offsets by 100 the subclass to share one item-type namespace with weapons
    if itemClass == 4 then
        itemSubClass = itemSubClass + 100
    end

    for _, enchantTable in ipairs(enchantTables) do
        for _, enchantData in pairs(enchantTable) do
            local itemTypes = enchantData[1]
            local itemLevelReq = enchantData[2]
            local phaseLocked = enchantData[3]
            local turtleWoWOnly = enchantData[4]

            if not turtleWoWOnly or BCPLib:IsPlayingOnTurtleWoW() then
                local phaseOk = true

                if phaseLocked then
                    phaseOk = realmPhase ~= nil and realmPhase[phaseLocked] == true
                end

                if phaseOk and itemLevel >= itemLevelReq then
                    local itemTypeOk = true

                    if itemTypes and table.getn(itemTypes) > 0 then
                        itemTypeOk = false

                        for _, requiredType in ipairs(itemTypes) do
                            if itemSubClass == requiredType then
                                itemTypeOk = true
                                break
                            end
                        end
                    end

                    if itemTypeOk then
                        return true
                    end
                end
            end
        end
    end

    return false
end

function BCPLib:GetItemLevelFromEquipmentSlot(unit, slot)
    local okEquippedItem, itemInfo = pcall(GetEquippedItem, unit, slot)

    if not okEquippedItem or not itemInfo then
        return nil
    end

    local okItemLevel, result = pcall(GetItemLevel, itemInfo.itemId)

    if not okItemLevel then
        return nil
    end

    return result
end

function BCPLib:GetColorFromEquipmentSlot(unit, slot)
    local itemInfo = GetEquippedItem(unit, slot)

    if not itemInfo then
        return nil
    end

    local ok, quality = pcall(GetItemStatsField, itemInfo.itemId, "quality")

    if not ok then
        return nil
    end

    if quality == 0 then     -- Poor
        return "|cff9d9d9d"
    elseif quality == 1 then -- Common
        return "|cffffffff"
    elseif quality == 2 then -- Uncommon
        return "|cff1eff00"
    elseif quality == 3 then -- Rare
        return "|cff0070dd"
    elseif quality == 4 then -- Epic
        return "|cffa335ee"
    else                     -- Legendary
        return "|cffff8000"
    end
end

-- Taken from pfUI by Shagu
function BCPLib:EnableClickRotate(frame)
    frame:EnableMouse(true)

    HookScript(frame, "OnUpdate", function()
        if this.rotate then
            local x, _ = GetCursorPosition()

            if this.curx > x then
                this.rotation = this.rotation - abs(x - this.curx) * 0.025
            elseif this.curx < x then
                this.rotation = this.rotation + abs(x - this.curx) * 0.025
            end

            this:SetRotation(this.rotation)
            this.curx, this.cury = x, y
        end
    end)

    HookScript(frame, "OnMouseDown", function()
        if arg1 == "LeftButton" then
            this.rotate = true
            this.curx, this.cury = GetCursorPosition()
        end
    end)

    HookScript(frame, "OnMouseUp", function()
        this.rotate, this.curx, this.cury = nil, nil, nil
    end)
end

function BCPLib:IsUsingTwoHandedWeapon(unit)
    local okInfo, itemInfo = pcall(GetEquippedItem, unit, BS.MainHand)

    if not okInfo or not itemInfo then
        return false
    end

    local okType, inventoryType = pcall(GetItemStatsField, itemInfo.itemId, "inventoryType")

    if not okType or not inventoryType then
        return nil
    end

    if inventoryType == 17 then
        return true
    end

    return false
end
