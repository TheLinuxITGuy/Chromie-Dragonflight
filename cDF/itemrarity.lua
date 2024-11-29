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
    
    -- Create a function to reset the border color of empty bag slots
    local function ResetSlotBorderColor(frame)
        if frame and frame.borderTexture then
            --print("Resetting border color for frame")
            frame.borderTexture:SetVertexColor(1, 1, 1, 0) -- Set to transparent
        end
    end
    
    -- Create a function to set the border color of bag items based on rarity
    local function SetItemBorderColor()
        --print("SetItemBorderColor called")
        for bag = 0, NUM_BAG_SLOTS do
            local numSlots = GetContainerNumSlots(bag)
            --print("Bag", bag, "has", numSlots, "slots")
            for slot = 1, numSlots do
                local itemLink = GetContainerItemLink(bag, slot)
                local invertedSlot = numSlots - slot + 1
                local frame = _G["ContainerFrame"..(bag + 1).."Item"..invertedSlot]
                if itemLink then
                    local _, _, rarity = GetItemInfo(itemLink)
                    --print("Item Link: ", itemLink, " Item Rarity: ", rarity)
                    local r, g, b, a = GetRarityColor(rarity)
                    --print("Rarity Color: R=", r, " G=", g, " B=", b, " A=", a)
                    if frame then
                        --print("Frame found for bag", bag, "slot", slot, "inverted to slot", invertedSlot)
                        EnsureBorderTexture(frame, r, g, b, a)
                    else
                        --print("Frame not found for bag", bag, "slot", slot, "inverted to slot", invertedSlot)
                    end
                else
                    if frame then
                        ResetSlotBorderColor(frame)
                        --print("No itemLink found for bag", bag, "slot", slot, " - resetting color")
                    end
                end
            end
        end
    end
    
    -- Create the frame and hook the functions to the events
    local f = CreateFrame("Frame")
    f:RegisterEvent("BAG_UPDATE")
    f:RegisterEvent("PLAYER_LOGIN")
    f:SetScript("OnEvent", function(self, event)
        --print("Event triggered:", event)
        if event == "BAG_UPDATE" or event == "PLAYER_LOGIN" then
            SetItemBorderColor()
        end
    end)
    