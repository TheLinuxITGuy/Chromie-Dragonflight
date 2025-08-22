local cDF = LibStub('AceAddon-3.0'):NewAddon('cDF', 'AceConsole-3.0')
local AceConfig = LibStub("AceConfig-3.0")
local AceDB = LibStub("AceDB-3.0")
cDFDB = cDFDB or {}
if cDFDB.bagsExpanded == nil then
    cDFDB.bagsExpanded = false -- Standard: sichtbar
end

cDF.InterfaceVersion = select(4, GetBuildInfo())
cDF.Wrath = (cDF.InterfaceVersion >= 30300)
cDF.DB = nil

function cDF:OnInitialize()
	cDF.DB = AceDB:New("cDFDB", cDF.default, true)
	AceConfig:RegisterOptionsTable("|cff1974d2cDF Commands", cDF.optionsSlash, "cdf")
	print("|cffffd700Chromie |cff1974d2Dragonflight |cffffffffloaded. Welcome " .. UnitName("player") .. "!" .. " Type |cffffd700/cdf |cfffffffffor options")
end

function cDF:OnEnable()
    if GetCVar("useUiScale") == "0" then
        SetCVar("useUiScale", 1)
        SetCVar("uiScale", 0.75)
    end
end

function cDF:OnDisable() end

function CreateUIFrame(width, height, frameName)
	local frame = CreateFrame("Frame", 'cDF_' .. frameName, UIParent)
	frame:SetSize(width, height)

	frame:RegisterForDrag("LeftButton")
	frame:EnableMouse(false)
	frame:SetMovable(false)
	frame:SetScript("OnDragStart", function(self, button)
		self:StartMoving()
	end)
	frame:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
	end)

	frame:SetFrameLevel(100)
	frame:SetFrameStrata('FULLSCREEN')

	do
		local texture = frame:CreateTexture(nil, 'BACKGROUND')
		texture:SetAllPoints(frame)
		texture:SetTexture("Interface\\AddOns\\cDF\\Textures\\UI\\ActionBarHorizontal.blp")
		texture:SetTexCoord(0, 512 / 512, 14 / 2048, 85 / 2048)
		texture:Hide()

		frame.editorTexture = texture
	end

	do
		local fontString = frame:CreateFontString(nil, "BORDER", 'GameFontNormal')
		fontString:SetAllPoints(frame)
		fontString:SetText(frameName)
		fontString:Hide()

		frame.editorText = fontString
	end

	return frame
end

cDF.frames = {}

function ShowUIFrame(frame)
	frame:SetMovable(false)
	frame:EnableMouse(false)

	frame.editorTexture:Hide()
	frame.editorText:Hide()

	for _, target in pairs(cDF.frames[frame]) do
		target:SetAlpha(1)
	end

	cDF.frames[frame] = nil
end

function HideUIFrame(frame, exclude)
	frame:SetMovable(true)
	frame:EnableMouse(true)

	frame.editorTexture:Show()
	frame.editorText:Show()

	cDF.frames[frame] = {}

	exclude = exclude or {}

	for _, target in pairs(exclude) do
		target:SetAlpha(0)
		tinsert(cDF.frames[frame], target)
	end
end

function SaveUIFramePosition(frame, widgetName)
	local _, _, relativePoint, posX, posY = frame:GetPoint('CENTER')
	cDF.DB.profile.widgets[widgetName].anchor = relativePoint
	cDF.DB.profile.widgets[widgetName].posX = posX
	cDF.DB.profile.widgets[widgetName].posY = posY
end

function SaveUIFrameScale(input, widgetName)
    local scale = tonumber(input) -- Convert input to a number
	if not scale or scale <= 0 then -- validate
		print("Invalid scale. Please provide a positive number.")
		return
	end

	cDF.DB.profile.widgets[widgetName].scale = scale -- save the scale

    local UnitFrameModule = cDF:GetModule("UnitFrame") -- update the UI to reflect the changes
    UnitFrameModule:UpdateWidgets()
    print(widgetName .. " Frame Scale saved as " .. GetUIFrameScale(widgetName)) -- print confirmation to a user
end

function GetUIFrameScale(widgetName)
	return cDF.DB.profile.widgets[widgetName].scale
end

function CheckSettingsExists(self, widgets)
	for _, widget in pairs(widgets) do
		if cDF.DB.profile.widgets[widget] == nil then
			self:LoadDefaultSettings()
			break
		end
	end
	self:UpdateWidgets()
end

local function MoveChatOnFirstLoad()
    local chat = ChatFrame1
    if not chat then return end

    if chat:IsUserPlaced() then return end

    chat:ClearAllPoints()
    chat:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 32, 32)
    chat:SetWidth(chat:GetWidth() - 40)
    chat:SetMovable(true)
    chat:SetUserPlaced(true)
end

local function MovepfQuestOnFirstLoad()
local pfquest = pfQuestIcon
	if pfquest then
		pfquest:ClearAllPoints()
		pfquest:SetParent(UIParent)
		pfquest:SetPoint("BOTTOMLEFT", UIParent, 0, 0)
	end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function(self, event)
    MoveChatOnFirstLoad()
	MovepfQuestOnFirstLoad()
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end)
