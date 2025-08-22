local addonName, addon = "cDF", ...

local function ReplaceMinimapTextures()
    Minimap:SetCorpsePOIArrowTexture("Interface\\AddOns\\cDF\\Textures\\Minimap\\assets\\poi-corpse")
    Minimap:SetPOIArrowTexture("Interface\\AddOns\\cDF\\Textures\\Minimap\\assets\\poi-guard")
    Minimap:SetStaticPOIArrowTexture("Interface\\AddOns\\cDF\\Textures\\Minimap\\assets\\poi-static")
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        ReplaceMinimapTextures()
        self:UnregisterEvent("ADDON_LOADED")
    end
end)