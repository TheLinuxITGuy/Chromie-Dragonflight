-- Create a function to get the item's rarity color
    local function GetRarityColor(rarity)
        if rarity == 0 then -- Poor (gray)
            return 0.2, 0.2, 0.2, 1 -- Very subtle gray
        elseif rarity == 1 then -- Common (white)
            return 0.6, 0.6, 0.6, 1 -- Very subtle white
        elseif rarity == 2 then -- Uncommon (green)
            return 0, 0.5, 0, 1 -- Very subtle green
        elseif rarity == 3 then -- Rare (blue)
            return 0, 0.25, 0.5, 1 -- Very subtle blue
        elseif rarity == 4 then -- Epic (purple)
            return 0.4, 0.13, 0.58, 1 -- Very subtle purple
        elseif rarity == 5 then -- Legendary (orange)
            return 0.8, 0.35, 0, 1 -- Very subtle orange
        elseif rarity == 6 then -- Artifact (heirloom yellow)
            return 0.7, 0.6, 0.3, 1 -- Very subtle yellow
        else -- Default to very subtle white if rarity not found
            return 0.6, 0.6, 0.6, 1
        end
    end
    
    -- Function to ensure the frame has a border texture and set its color
    local function EnsureBorderTexture(frame, r, g, b, a)
        if not frame.borderTexture then
            --print("Creating border texture for frame")
            frame.borderTexture = frame:CreateTexture(nil, "OVERLAY")
            frame.borderTexture:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
            frame.borderTexture:SetBlendMode("ADD")
            frame.borderTexture:SetSize(68, 68)
            frame.borderTexture:SetPoint("CENTER", frame, "CENTER", 0, 0)
        end
        --print("Setting border color for frame")
        frame.borderTexture:SetVertexColor(r, g, b, a)
    end
    
    -- Create a function to set the border color of character equipment based on rarity
    local function SetCharacterBorderColor()
        --print("SetCharacterBorderColor called")
        local slotIDs = {
            "HeadSlot", "NeckSlot", "ShoulderSlot", "BackSlot", "ChestSlot",
            "WristSlot", "HandsSlot", "WaistSlot", "LegsSlot", "FeetSlot",
            "Finger0Slot", "Finger1Slot", "Trinket0Slot", "Trinket1Slot",
            "MainHandSlot", "SecondaryHandSlot", "RangedSlot", "TabardSlot"
        }
        
        for _, slotID in ipairs(slotIDs) do
            local itemLink = GetInventoryItemLink("player", GetInventorySlotInfo(slotID))
            if itemLink then
                local _, _, rarity = GetItemInfo(itemLink)
                --print("Item Link: ", itemLink, " Item Rarity: ", rarity)
                local r, g, b, a = GetRarityColor(rarity)
                --print("Rarity Color: R=", r, " G=", g, " B=", b, " A=", a)
                local frame = _G["Character"..slotID]
                --print("Trying Frame: Character"..slotID)
                if frame then
                    --print("Frame found for slot", slotID)
                    EnsureBorderTexture(frame, r, g, b, a)
                else
                    --print("Frame not found for slot", slotID)
                end
            else
                --print("No itemLink found for slot", slotID)
            end
        end
    end
    
    -- Create the frame and hook the functions to the events
    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    f:RegisterEvent("PLAYER_LOGIN")
    f:SetScript("OnEvent", function(self, event)
        --print("Event triggered:", event)
        if event == "PLAYER_EQUIPMENT_CHANGED" or event == "PLAYER_LOGIN" then
            SetCharacterBorderColor()
        end
    end)
    