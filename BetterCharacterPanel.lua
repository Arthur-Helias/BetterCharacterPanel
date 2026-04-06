BCP_VERSION_MAJOR = "1"
BCP_VERSION_MINOR = "3"
BCP_VERSION_PATCH = "5"

BCP_IS_USING_PFUI = false
BCP_IS_USING_PFUI_TURTLE = false -- Not used yet, could be useful for potential incompatibilities in the future.
BCP_IS_USING_BCS = false

SLASH_BCP1 = "/bcp"
SLASH_BCP2 = "/bettercharacterpanel"
SlashCmdList["BCP"] = function()
    if BCP_OpenConfig then
        BCP_OpenConfig()
    end
end

local BCP_InitFrame = CreateFrame("Frame")
BCP_InitFrame:RegisterEvent("PLAYER_LOGIN")
BCP_InitFrame:RegisterEvent("VARIABLES_LOADED")
BCP_InitFrame:SetScript("OnEvent", function()
    BCP_InitFrame:UnregisterEvent("PLAYER_LOGIN")

    -- UI detection
    if IsAddOnLoaded("pfUI") and pfUI and pfUI.api then
        BCP_IS_USING_PFUI = true

        if pfUI.skin and pfUI.skin["Character Frame Turtle"] then
            BCP_IS_USING_PFUI_TURTLE = true
        end

        if pfUI.addonskinner and pfUI.addonskinner.UnregisterSkin then
            pfUI.addonskinner:UnregisterSkin("BetterCharacterStats")
        end
    end

    if IsAddOnLoaded("BetterCharacterStats") and BCS and BCSFrame then
        BCP_IS_USING_BCS = true
    end

    -- Alert the user about missing Nampower
    if not GetNampowerVersion and BCPNotifications then
        BCPNotifications:CreateNampowerError()
        return
    end
end)
