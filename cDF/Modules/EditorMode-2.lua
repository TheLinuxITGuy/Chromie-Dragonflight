local cDF = LibStub('AceAddon-3.0'):GetAddon('cDF')
local moduleName = 'EditorMode'
local Module = cDF:NewModule(moduleName, 'AceConsole-3.0', 'AceHook-3.0', 'AceEvent-3.0')

local UnitFrameModule, CastingBarModule, ActionBarModule, MinimapModule, QuestTrackerModule, BuffFrameModule

Module.editorGridFrame = nil

local function CreateEditorGridFrame()
    local editorGridFrame = CreateFrame("Frame", 'cDF_EditorGridFrame', UIParent)
    editorGridFrame:SetPoint("TOPLEFT", 0, 0)
    editorGridFrame:SetSize(GetScreenWidth(), GetScreenHeight())
    editorGridFrame:SetFrameLevel(0)
    editorGridFrame:SetFrameStrata("BACKGROUND")

    do
        local texture = editorGridFrame:CreateTexture(nil, "BACKGROUND")
        texture:SetAllPoints(editorGridFrame)
        texture:SetTexture("Interface\\AddOns\\cDF\\Textures\\UI\\EditorGrid.blp", "REPEAT", "REPEAT")
        texture:SetTexCoord(0, 1, 0, 1)
        texture:SetVertTile(true)
        texture:SetHorizTile(true)
        texture:SetSize(32, 32)
        texture:SetAlpha(0.4)
    end

    editorGridFrame:Hide()
    return editorGridFrame
end

function Module:OnEnable()
    UnitFrameModule      = cDF:GetModule("UnitFrame")
    CastingBarModule     = cDF:GetModule("CastingBar")
    ActionBarModule      = cDF:GetModule("ActionBar")
    MinimapModule        = cDF:GetModule("Minimap")
    QuestTrackerModule   = cDF:GetModule("QuestTracker")
    BuffFrameModule      = cDF:GetModule("BuffFrame")

    self.editorGridFrame = CreateEditorGridFrame()
end

function Module:OnDisable() end

function Module:Show()
    if InCombatLockdown() then
        self:Printf(DEFAULT_CHAT_FRAME, "Cannot open settings while in combat")
        return
    end

    self.editorGridFrame:Show()

    ActionBarModule:ShowEditorTest()
    UnitFrameModule:ShowEditorTest()
    CastingBarModule:ShowEditorTest()
    MinimapModule:ShowEditorTest()
    QuestTrackerModule:ShowEditorTest()
    BuffFrameModule:ShowEditorTest()
end

function Module:Hide()
    self.editorGridFrame:Hide()

    ActionBarModule:HideEditorTest(true)
    UnitFrameModule:HideEditorTest(true)
    CastingBarModule:HideEditorTest(true)
    MinimapModule:HideEditorTest(true)
    QuestTrackerModule:HideEditorTest(true)
    BuffFrameModule:HideEditorTest(true)
end

function Module:IsShown()
    return self.editorGridFrame:IsShown()
end
