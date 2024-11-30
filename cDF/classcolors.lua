-- Function to get the class color of the target
local function GetTargetClassColor()
    local _, targetClass = UnitClass("target")
    if targetClass then
        local color = RAID_CLASS_COLORS[targetClass]
        if color then
            return color.r, color.g, color.b
        end
    end
    return 1, 1, 1 -- Default to white if no class found or color not available
end

-- Function to update the target's name color based on the target's class
local function UpdateTargetNameColor()
    if UnitExists("target") and UnitIsPlayer("target") then
        local r, g, b = GetTargetClassColor()
        TargetFrameNameBackground:SetVertexColor(r, g, b)
        --TargetFrameTextureFrameName:SetTextColor(r, g, b)
        --print("Target name color updated: ", r, g, b)
    else
        -- Reset to default color for NPCs
        --TargetFrameNameBackground:SetVertexColor(1, 1, 1) -- default white background
        --TargetFrameTextureFrameName:SetTextColor(1, 1, 1) -- default white text
        --print("No player target selected or target is an NPC")
    end
end

-- Create the frame and register the necessary events
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_TARGET_CHANGED")
f:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_TARGET_CHANGED" then
        UpdateTargetNameColor()
    end
end)

-- Initial update when the script is loaded
UpdateTargetNameColor()
