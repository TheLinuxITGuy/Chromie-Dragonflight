
local L = {}
local bankSort = false;
local guildSort = false;
local moves = {};
local depth = 0;
local frame = CreateFrame("Frame");
local t = 0;
local current = nil;
local log = {};

local function Log(msg)
    table.insert(log, msg);

    if (SOCD ~= nil) then
        SOCD.log = log;
    end
end

local function ClearLog()
    log = {};
end

function SOCD_SlashCommand(cmd, arg2)
    Log("SOCD_SlashCommand("..tostring(cmd)..", "..tostring(arg2)..")");
    InterfaceOptionsFrame_OpenToCategory("Sushi Sort"); 
end

local function GetIDFromLink(link)
    Log("GetIDFromLink("..tostring(link)..")");
    return link and tonumber(string.match(link, "item:(%d+)"));
end

local function DoMoves()
    Log("DoMoves()");

    while (current ~= nil or #moves > 0) do
        if current ~= nil then    
            Log("current.id = "..tostring(current.id));
            if CursorHasItem() then
                Log("Cursor Has Item");
                local type, id = GetCursorInfo();
                Log("type = "..tostring(type)..", id = "..tostring(id));
                if (current ~= nil and current.id == id) then
                    if (current.sourcebag ~= nill) then
                        Log("PickupContainerItem("..current.targetbag..", "..current.targetslot..")");

                        PickupContainerItem(current.targetbag, current.targetslot);

            	        local link = select(7, GetContainerItemInfo(current.targetbag, current.targetslot));
                        if (current.id ~= GetIDFromLink(link)) then
                            return;
                        end
                    else
                        Log("PickupGuildBankItem("..current.targettab..", "..current.targetslot..")");
    
                        PickupGuildBankItem(current.targettab, current.targetslot);    
    
                	    local link = GetGuildBankItemLink(current.targettab, current.targetslot);
                        if (current.id ~= GetIDFromLink(link)) then
                            return;
                        end
                    end
                else
                    Log("Sort Aborted");
                    --DEFAULT_CHAT_FRAME:AddMessage("Sort Aborted");
                    moves = {};
                    current = nil;
                    frame:Hide();
                    return;
                end
            else
                if (current.sourcebag ~= nill) then
        	        local link = select(7, GetContainerItemInfo(current.targetbag, current.targetslot));
                    if (current.id ~= GetIDFromLink(link)) then
                        return;
                    end
                else
            	    local link = GetGuildBankItemLink(current.targettab, current.targetslot);
                    if (current.id ~= GetIDFromLink(link)) then
                        return;
                    end
                end
                current = nil;
            end
        else      
            Log("current == nil");
            if (#moves > 0) then
                Log("("..#moves.." > 0)");
        
                current = table.remove(moves, 1);

                if (current.sourcebag ~= nill) then
                    Log("PickupContainerItem("..current.sourcebag..", "..current.sourceslot..")");
                    PickupContainerItem(current.sourcebag, current.sourceslot);
                    if CursorHasItem() == false then
                        return;
                    end 
                    
                    Log("PickupContainerItem("..current.targetbag..", "..current.targetslot..")");
                    PickupContainerItem(current.targetbag, current.targetslot);
        	        local link = select(7, GetContainerItemInfo(current.targetbag, current.targetslot));
                    if (current.id == GetIDFromLink(link)) then
                        Log("current = nil");
                        current = nil;
                    else
                        return;
                    end
                else
                    Log("PickupGuildBankItem("..current.sourcetab..", "..current.sourceslot..")");
                    PickupGuildBankItem(current.sourcetab, current.sourceslot);    
                    Log("PickupGuildBankItem("..current.targettab..", "..current.targetslot..")");
                    PickupGuildBankItem(current.targettab, current.targetslot);    
            	    local link = GetGuildBankItemLink(current.targettab, current.targetslot);
                    if (current.id == GetIDFromLink(link)) then
                        Log("current = nil");
                        current = nil;
                    else                        
                        return;
                    end
                end

            end        
        end
    end
    Log("Sorted!");
    --DEFAULT_CHAT_FRAME:AddMessage("Sorted!");
    frame:Hide();
end

local function CompareItems(lItem, rItem)
    Log("CompareItems("..lItem.name..", "..rItem.name..")");

    if (rItem.id == nil) then
        Log("(rItem.id == nil)");
        return true;
    elseif (lItem.id == nil) then
        Log("(lItem.id == nil)");
        return false;
    elseif (lItem.quality ~= rItem.quality) then
        Log("(lItem.quality ~= rItem.quality)");
        return (lItem.quality > rItem.quality);
    elseif (lItem.class ~= rItem.class) then
        Log("(lItem.class ~= rItem.class)");
        return (lItem.class < rItem.class);
    elseif (lItem.subclass ~= rItem.subclass) then
        Log("(lItem.subclass ~= rItem.subclass)");
        return (lItem.subclass < rItem.subclass);
    elseif (lItem.name ~= rItem.name) then
        Log("(lItem.name ~= rItem.name)");
        return (lItem.name < rItem.name);
    elseif ((lItem.count) ~= (rItem.count)) then
        Log("((lItem.count) ~= (rItem.count))");
        return ((lItem.count) >= (rItem.count));
    else
        Log("return true");
        return true;
    end
end

local function BeginSort()
    Log("BeginSort()");
    current = nil;
    moves = {};
    ClearCursor();
end

local function SortBag(bag)
    Log("SortBag(bag)");
    
    for i=1,#bag,1 do
        Log("i="..i);
        local lowest = i;
        for j=#bag,i+1,-1 do
            Log("j="..j);
            if (CompareItems(bag[lowest],bag[j]) == false) then
                Log("lowest="..j);
                lowest = j;
            end
        end
        if (i ~= lowest) then
            Log("(i ~= lowest)");

            -- store move
            move = {};
            move.id = bag[lowest].id;
            move.name = bag[lowest].name;
            move.sourcebag = bag[lowest].bag;
            move.sourcetab = bag[lowest].tab;
            move.sourceslot = bag[lowest].slot;
            move.targetbag = bag[i].bag;
            move.targettab = bag[i].tab;
            move.targetslot = bag[i].slot;
            table.insert(moves, move);
            Log("move "..move.name.." from "..move.sourceslot.." to "..move.targetslot);
            
            -- swap items
            local tmp = bag[i];
            bag[i] = bag[lowest];
            bag[lowest] = tmp;

            Log("bag[i] = "..bag[i].name.."("..bag[i].slot.."), bag[lowest] = "..bag[lowest].name.."("..bag[lowest].slot..")");

            -- swap slots
            tmp = bag[i].slot;
            bag[i].slot = bag[lowest].slot;
            bag[lowest].slot = tmp;
            tmp = bag[i].bag;
            bag[i].bag = bag[lowest].bag;
            bag[lowest].bag = tmp;
            tmp = bag[i].tab;
            bag[i].tab = bag[lowest].tab;
            bag[lowest].tab = tmp;

            Log("bag[i] = "..bag[i].name.."("..bag[i].slot.."), bag[lowest] = "..bag[lowest].name.."("..bag[lowest].slot..")");
        end
    end
end

local function CreateBagFromID(bagID)
    Log("CreateBagFromID("..bagID..")");

    local items = GetContainerNumSlots(bagID);
    local bag = {};

    Log("items = "..items);

	for i=1, items, 1 do
	    local item = {};

        Log("i = "..i);

	    local _, count, _, _, _, _, link = GetContainerItemInfo(bagID, i);
	    item.bag = bagID;
	    item.slot = i;
	    item.name = "<EMPTY>";
        item.id = GetIDFromLink(link);
        if (item.id ~= nil) then
            item.count = count;
            item.name, _, item.quality, _, _, item.class, item.subclass, _, item.type, _, item.price = GetItemInfo(item.id);
        end

        Log("item = "..item.name);

        table.insert(bag, item);
    end
    return bag;
end

local function CreateBagFromTab(tab)
    Log("CreateBagFromTab("..tab..")");

    local items = MAX_GUILDBANK_SLOTS_PER_TAB;
    local bag = {};

    Log("items = "..items);

	for i=1, items, 1 do
	    local item = {};

        Log("i = "..i);

	    local _, count = GetGuildBankItemInfo(tab, i);
	    local link = GetGuildBankItemLink(tab, i);
	    item.tab = tab;
	    item.slot = i;
	    item.name = "<EMPTY>";
        item.id = GetIDFromLink(link);
        if (item.id ~= nil) then
            item.count = count;
            item.name, _, item.quality, _, _, item.class, item.subclass, _, item.type, _, item.price = GetItemInfo(item.id);
        end
        table.insert(bag, item);

        Log("item = "..item.name);
    end
    return bag;
end

local function SOCD_BagSortButton(self) 
    ClearLog();

    Log("SOCD_BagSortButton(self)");
    local bags = {};

	for i=0, NUM_BAG_FRAMES, 1 do
	    local framenum = i + 1;
        if _G["ContainerFrame"..framenum.."SortCheck"]:GetChecked() then
            Log("Bag #"..i.." is checked");
            local bag = CreateBagFromID(i);
            local type = select(2, GetContainerNumFreeSlots(i));
            if type == nil then
                type = "ALL"
            else
                type = tostring(type);
            end
            Log("type = "..type);
            if bags[type] == nil then
                Log("bags[type] == nil");
                bags[type] = bag; 
            else
                Log("bags[type] ~= nil");
                Log("#bags[type] = "..#bags[type]);
                for j=1, #bag, 1 do
                    table.insert(bags[type], bag[j]);
                end
                Log("#bags[type] = "..#bags[type]);
            end
        end
    end

    BeginSort();
    for k,v in pairs(bags) do
	    if v ~= nil then
            Log("k = "..k..", v ~= nli");
	        SortBag(v);
	    end   
    end        
    frame:Show();
end

local function SOCD_BankSortButton(self) 
    ClearLog();

    Log("SOCD_BankSortButton(self)");
    local bags = {};

    if _G["BankFrameSortCheck"]:GetChecked() then
          Log("Bank is checked");
        bags["ALL"] = CreateBagFromID(-1);
    end
    
	for i=NUM_BAG_FRAMES+1, NUM_CONTAINER_FRAMES, 1 do
	    local framenum = i + 1;
	    local frame = _G["ContainerFrame"..framenum.."SortCheck"];
        if (frame ~= nil and frame:GetChecked()) then
            Log("Bag #"..i.." is checked");
            local bag = CreateBagFromID(i);
            local type = select(2, GetContainerNumFreeSlots(i));
            if type == nil then
                type = "ALL"
            else
                type = tostring(type);
            end
            Log("type = "..type);
            if bags[type] == nil then
                Log("bags[type] == nil");
                bags[type] = bag; 
            else
                Log("bags[type] ~= nil");
                Log("#bags[type] = "..#bags[type]);
                for j=1, #bag, 1 do
                    table.insert(bags[type], bag[j]);
                end
                Log("#bags[type] = "..#bags[type]);
            end
        end
    end

    BeginSort();
    for k,v in pairs(bags) do
	    if v ~= nil then
            Log("k = "..k..", v ~= nli");
	        SortBag(v);
	    end   
    end        
    frame:Show();

end

local function SOCD_GuildSortButton(self) 
    ClearLog();

    Log("SOCD_GuildSortButton(self)");
    local bag = CreateBagFromTab(GetCurrentGuildBankTab());
    SortBag(bag);
    frame:Show();
end

local function CreateSortCheck(name, parent, x, y)
    Log("CreateSortButton("..name..", parent, "..x..", "..y..", handler)");

    parent.sortButton = CreateFrame("CheckButton", name, parent, "SOCDCheckTemplate");
    parent.sortButton.parentFrame = parent;
    parent.sortButton:SetChecked(true);
	parent.sortButton.tooltipText = "Include this bag when sorting?";
    parent.sortButton:ClearAllPoints();
    parent.sortButton:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y);

    if SOCD.IsEnabled then
        parent.sortButton:Show();
    else
        parent.sortButton:Hide();
    end
end

local function CreateSortButton(name, parent, x, y, handler)
    Log("CreateSortButton("..name..", parent, "..x..", "..y..", handler)");

    parent.sortButton = CreateFrame("Button", name, parent, "UIPanelButtonTemplate");
    parent.sortButton.parentFrame = parent;
    parent.sortButton:SetWidth(45);
    parent.sortButton:SetHeight(18);
    parent.sortButton:SetText("Sort");
    parent.sortButton:ClearAllPoints();
    parent.sortButton:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y);

    if SOCD.IsEnabled then
        parent.sortButton:Show();
    else
        parent.sortButton:Hide();
    end

    parent.sortButton:SetScript("OnClick", handler);
end

function SOCD_MainFrame_OnLoad(self)
    Log("SOCD_MainFrame_OnLoad(self)");

    local fEnable = true;
    if (SOCD ~= nil and SOCD.IsEnabled ~= nil) then
        Log("(SOCD ~= nil and SOCD.IsEnabled ~= nil)");
        fEnable = SOCD.IsEnabled;
    end

    SOCD = {};
    Log("SOCD = {};");
    SOCD.IsEnabled = fEnable;
    Log("SOCD.IsEnabled = "..tostring(SOCD.IsEnabled));

    L = 
    {
	    SOCD_OPTIONSPANEL_CREDITS1 = "Sushi Sort was designed and built by the guildies of <Sushi Regular> on US-Draka.",
    	SOCD_OPTIONSPANEL_CREDITS2 = "Check out our website at http://www.sushi-regular.com",
    	SOCD_OPTIONSPANEL_ENABLE = "Enable Sort",
    	SOCD_OPTIONSPANEL_ENABLE_TIP = "Enable or disable this addon without uninstalling it.",
    	SOCD_OPTIONSPANEL_TITLE = "Sushi Sort Settings",
    }

    SOCD_OPTIONSPANEL_TITLE = L["SOCD_OPTIONSPANEL_TITLE"];
    SOCD_OPTIONSPANEL_ENABLE = L["SOCD_OPTIONSPANEL_ENABLE"];
    SOCD_OPTIONSPANEL_ENABLE_TIP = L["SOCD_OPTIONSPANEL_ENABLE_TIP"];
    SOCD_OPTIONSPANEL_CREDITS1 = L["SOCD_OPTIONSPANEL_CREDITS1"];
    SOCD_OPTIONSPANEL_CREDITS2 = L["SOCD_OPTIONSPANEL_CREDITS2"];

	for i=1, NUM_CONTAINER_FRAMES, 1 do
        CreateSortCheck("ContainerFrame"..i.."SortCheck", _G["ContainerFrame"..i], 42, -25)
    end

    CreateSortButton("ContainerFrame1SortButton", _G["ContainerFrame1"], 138, -28, SOCD_BagSortButton);

    frame:SetScript("OnUpdate", function()
        Log("OnUpdate("..arg1..")");
    	t = t + arg1;
        Log("t = "..t);
    	if t > 0.05 then
            Log("t > 0.05");
    		t = 0
            DoMoves();
    	end
    end)
    frame:Hide();

    --DEFAULT_CHAT_FRAME:AddMessage("Sushi Sort 3.3.5 Loaded");
    --DEFAULT_CHAT_FRAME:AddMessage("To access settings use \"/ss\"");
	self:RegisterEvent("BANKFRAME_OPENED");
	self:RegisterEvent("GUILDBANKFRAME_OPENED");
    self:RegisterEvent("VARIABLES_LOADED");
end

local function hook_GuildBankTab_OnClick(...)
    Log("hook_GuildBankTab_OnClick(...)");
    
    local tab = GetCurrentGuildBankTab();
    if (tab > GetNumGuildBankTabs()) then
        Log("(tab > GetNumGuildBankTabs())");
        _G["GuildBankFrame"].sortButton:Disable();
    else
        Log("else");
        _G["GuildBankFrame"].sortButton:Enable();
    end
end

function SOCD_MainFrame_OnEvent(self, event, ...)
    Log("SOCD_MainFrame_OnEvent(self, "..event..", ...)");
	if (event == "BANKFRAME_OPENED") then 
        Log("(event == BANKFRAME_OPENED)");
	    if (bankSort == false) then
            Log("(bankSort == false)");
	        bankSort = true;
            CreateSortCheck("BankFrameSortCheck", _G["BankFrame"], 68, -32)
    	    CreateSortButton("BankFrameSortButton", _G["BankFrame"], 330, -45, SOCD_BankSortButton);
	    end
	elseif (event == "GUILDBANKFRAME_OPENED") then 
        Log("(event == GUILDBANKFRAME_OPENED)");
	    if (guildSort == false) then
            Log("(guildSort == false)");
	        guildSort = true;
    	    CreateSortButton("GBankFrameSortButton", _G["GuildBankFrame"], 700, -42, SOCD_GuildSortButton);

            hooksecurefunc("GuildBankTab_OnClick", hook_GuildBankTab_OnClick)
        end
    elseif(event == "VARIABLES_LOADED") then
        Log("(event == VARIABLES_LOADED)");
        InterfaceOptions_AddCategory(SOCD_OptionsPanel);
	end
end

function SOCD_OptionsPanel_OnOk(self)
    Log("SOCD_OptionsPanel_OnOk(self)");
    SOCD.IsEnabled = (SOCD_OptionsPanel_OCDEnabled:GetChecked() ~= nil);
    if (SOCD.IsEnabled == true) then
        Log("(SOCD.IsEnabled == true)");
    	for i=1, NUM_CONTAINER_FRAMES, 1 do
            Log("i="..i);
    	    _G["ContainerFrame"..i].sortButton:Show();
        end
	    _G["BankFrame"].sortButton:Show();
	    _G["GuildBankFrame"].sortButton:Show();
    else
        Log("else");
    	for i=1, NUM_CONTAINER_FRAMES, 1 do
            Log("i="..i);
    	    _G["ContainerFrame"..i].sortButton:Hide();
        end
	    _G["BankFrame"].sortButton:Hide();
	    _G["GuildBankFrame"].sortButton:Hide();
    end
 end

function SOCD_OptionsPanel_OnCancel(self)
    Log("SOCD_OptionsPanel_OnCancel(self)");
    SOCD_OptionsPanel_OCDEnabled:SetChecked(SOCD.IsEnabled);
 end

function SOCD_OptionsPanel_OnDefault(self)
    Log("SOCD_OptionsPanel_OnDefault(self)");
    SOCD.IsEnabled = false;
    SOCD_OptionsPanel_OnCancel()
 end

function SOCD_OptionsPanel_OnRefresh(self)
    Log("SOCD_OptionsPanel_OnRefresh(self)");
    SOCD_OptionsPanel_OnCancel()
end

function SOCD_OptionsPanel_OnLoad(panel)
    Log("SOCD_OptionsPanel_OnLoad(panel)");
    panel.name = "Sushi Sort";
    panel.okay = SOCD_OptionsPanel_OnOk;
    panel.cancel = SOCD_OptionsPanel_OnCancel;
    panel.default = SOCD_OptionsPanel_OnDefault;
    panel.refresh = SOCD_OptionsPanel_OnRefresh;
end

SLASH_SUSHISORT1 = "/SS";
SlashCmdList["SUSHISORT"] = SOCD_SlashCommand;

