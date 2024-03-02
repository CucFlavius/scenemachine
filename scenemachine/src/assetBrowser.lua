local AssetBrowser = SceneMachine.Editor.AssetBrowser;
local Editor = SceneMachine.Editor;
local Renderer = SceneMachine.Renderer;
local SM = Editor.SceneManager;
local Gizmos = SceneMachine.Gizmos;
local Input = SceneMachine.Input;
local Camera = SceneMachine.Camera;
local Vector3 = SceneMachine.Vector3;
local UI = SceneMachine.UI;
local Resources = SceneMachine.Resources;
local SH = Editor.SceneHierarchy;
local OP = Editor.ObjectProperties;
local Debug = {};
local searchData = {};
local L = Editor.localization;
local Net = SceneMachine.Network;

local c1 = { 0.1757, 0.1757, 0.1875 };
local c2 = { 0.242, 0.242, 0.25 };
local c3 = { 0, 0.4765, 0.7968 };
local c4 = { 0.1171, 0.1171, 0.1171 };

AssetBrowser.dataSource = "Models";

function AssetBrowser.Create(parent, w, h, startLevel)

    local tabPanel = UI.TabPanel:New(0, 0, w, h, parent, "TOPRIGHT", "TOPRIGHT", 8);
    tabPanel:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 0, 0);
    tabPanel:SetFrameLevel(startLevel);

    AssetBrowser.tabs = {};
    
    AssetBrowser.tabs[1] = tabPanel:AddTab(w, h, "Models", 50, function() AssetBrowser.OnChangeTab(1); end, startLevel + 1);
    AssetBrowser.tabs[2] = tabPanel:AddTab(w, h, "Creatures", 70, function() AssetBrowser.OnChangeTab(2); end, startLevel + 1);
    AssetBrowser.tabs[3] = tabPanel:AddTab(w, h, "Debug", 70, function() AssetBrowser.OnChangeTab(3); end, startLevel + 1);
    
    AssetBrowser.CreateToolbar(AssetBrowser.tabs[1]:GetFrame(), -Editor.pmult, w, startLevel + 2);
    AssetBrowser.CreateSearchBar(0, -30 - Editor.pmult, 0, 0, AssetBrowser.tabs[1]:GetFrame(), startLevel + 3);
    AssetBrowser.CreateGridView(0, -50 - Editor.pmult, 0, 0, AssetBrowser.tabs[1]:GetFrame(), startLevel + 3);
    
    AssetBrowser.CreateDebugTab(AssetBrowser.tabs[3]:GetFrame(), 300, 100);

	AssetBrowser.gridList:MakePool();
    AssetBrowser.currentDirectory = SceneMachine.modelData[1];
    AssetBrowser.gridList:SetData(AssetBrowser.BuildFolderData(AssetBrowser.currentDirectory));
    AssetBrowser.breadcrumb = {};
    table.insert(AssetBrowser.breadcrumb, AssetBrowser.currentDirectory);

    -- DEBUG --
    --AssetBrowser.OnThumbnailDoubleClick(nil, "World");
    --AssetBrowser.OnThumbnailDoubleClick(nil, "Expansion07");
    --AssetBrowser.OnThumbnailDoubleClick(nil, "Doodads");
    --AssetBrowser.OnThumbnailDoubleClick(nil, "Kultiraszone");
    --AssetBrowser.OnChangeTab(3);
end

function AssetBrowser.OnChangeTab(idx)
    if (idx == 1) then
        -- Models --
        AssetBrowser.toolbar:Show();
        AssetBrowser.tabs[1]:Show();
        AssetBrowser.currentDirectory = SceneMachine.modelData[1];
        AssetBrowser.gridList:SetData(AssetBrowser.BuildFolderData(AssetBrowser.currentDirectory));
        AssetBrowser.ClearBreadcrumb();
        AssetBrowser.RefreshBreadcrumb();
        AssetBrowser.dataSource = "Models";
    elseif (idx == 2) then
        -- Creatures --
        AssetBrowser.toolbar:Hide();
        AssetBrowser.tabs[1]:Show();
        AssetBrowser.tabs[2]:Hide();
        AssetBrowser.gridList:SetData(AssetBrowser.BuildCreatureData());
        AssetBrowser.ClearBreadcrumb();
        AssetBrowser.RefreshBreadcrumb();
        AssetBrowser.dataSource = "Creatures";
    elseif (idx == 3) then
        -- Debug --
        AssetBrowser.tabs[1]:Hide();
        AssetBrowser.tabs[3]:Show();
        AssetBrowser.dataSource = nil;
    end

    AssetBrowser.searchBar:SetText("");
    AssetBrowser.SearchModelList("");
end

function AssetBrowser.CreateDebugTab(parent, w, h)
    local creatureDisplayIDText = UI.Label:New(0, -5, 100, 20, parent, "TOPLEFT", "TOPLEFT", "CreatureDisplayID", 9);
    local creatureDisplayIDEditBox = UI.TextBox:New(100, -5, w * 0.3, 20, parent, "TOPLEFT", "TOPLEFT", "41918");
    creatureDisplayIDEditBox:SetScript('OnEnterPressed', function(self1)
        -- set value
        local valText = self1:GetText();
        if (valText == nil or valText == "") then
            return;
        end
        local val = tonumber(valText);
        if (val ~= nil) then
            SM.CreateCreature(val, "Creature", 0, 0, 0);
        end
        self1:ClearFocus();
        Editor.ui.focused = false;
    end);

    local creatureIDText = UI.Label:New(0, -27, 100, 20, parent, "TOPLEFT", "TOPLEFT", "CreatureID", 9);
    local creatureIDEditBox = UI.TextBox:New(100, -27, w * 0.3, 20, parent, "TOPLEFT", "TOPLEFT", "0");
    creatureIDEditBox:SetScript('OnEnterPressed', function(self1)
        -- set value
        local valText = self1:GetText();
        if (valText == nil or valText == "") then
            return;
        end
        local val = tonumber(valText);
        if (val ~= nil) then
            local creatureDisplayID = SceneMachine.creatureToDisplayID[val];
            if (creatureDisplayID) then
                SM.CreateCreature(creatureDisplayID, "Creature", 0, 0, 0);
            end
        end
        self1:ClearFocus();
        Editor.ui.focused = false;
    end);

    local creatureAnimationText = UI.Label:New(0, -49, 100, 20, parent, "TOPLEFT", "TOPLEFT", "PlayAnimID", 9);
    local creatureAnimationEditBox = UI.TextBox:New(100, -49, w * 0.3, 20, parent, "TOPLEFT", "TOPLEFT", "0");
    creatureAnimationEditBox:SetScript('OnEnterPressed', function(self1)
        -- set value
        local valText = self1:GetText();
        if (valText == nil or valText == "") then
            return;
        end
        local val = tonumber(valText);
        if (val ~= nil) then
            --SM.CreateCreature(val, "Creature", 0, 0, 0);
            if (SM.selectedObject) then
                SM.selectedObject:PlayAnimID(val);
            end
        end
        self1:ClearFocus();
        Editor.ui.focused = false;
    end);

    local creatureAnimationKitText = UI.Label:New(0, -71, 100, 20, parent, "TOPLEFT", "TOPLEFT", "PlayAnimKitID", 9);
    local creatureAnimationKitEditBox = UI.TextBox:New(100, -71, w * 0.3, 20, parent, "TOPLEFT", "TOPLEFT", "0");
    creatureAnimationKitEditBox:SetScript('OnEnterPressed', function(self1)
        -- set value
        local valText = self1:GetText();
        if (valText == nil or valText == "") then
            return;
        end
        local val = tonumber(valText);
        if (val ~= nil) then
            --SM.CreateCreature(val, "Creature", 0, 0, 0);
            if (SM.selectedObject) then
                SM.selectedObject:PlayAnimKitID(val);
            end
        end
        self1:ClearFocus();
        Editor.ui.focused = false;
    end);
    
    local characterButton = UI.Button:New(0, -93, 100, 20, parent, "TOPLEFT", "TOPLEFT", "Create Character");
    characterButton:SetScript("OnClick", function(_, button, up)
        SM.CreateCharacter(0, 0, 0);
    end);

    local undressButton = UI.Button:New(0, -113, 100, 20, parent, "TOPLEFT", "TOPLEFT", "Undress");
    local creatureDisplayID = 4;
    undressButton:SetScript("OnClick", function(_, button, up)
        if (SM.selectedObject) then
            SM.selectedObject.actor:Undress(true);
        end
    end);

    local dressButton = UI.Button:New(0, -133, 150, 20, parent, "TOPLEFT", "TOPLEFT", "Dress with current items");
    local creatureDisplayID = 4;
    dressButton:SetScript("OnClick", function(_, button, up)
        if (SM.selectedObject) then
            SM.selectedObject.actor:Dress();
        end
    end);

    local dalaranButton = UI.Button:New(0, -153, 150, 20, parent, "TOPLEFT", "TOPLEFT", "Make Dalaran");
    local dalaranIDs = { 1486995, 1486996, 1486997, 1486998, 1486999, 1487000, 1487001, 1487002, 1487010, 1487011, 1487012 };
    dalaranButton:SetScript("OnClick", function(_, button, up)
        local toDelete = {};
        for i = 1, #SM.loadedScene.objects, 1 do
            for j = 1, #dalaranIDs, 1 do
                if (SM.loadedScene.objects[i].fileID == dalaranIDs[j]) then
                    toDelete[#toDelete + 1] = SM.loadedScene.objects[i];
                end
            end
        end

        for i = 1, #toDelete, 1 do
            SM.DeleteObject(toDelete[i]);
        end

        for i = 1, #dalaranIDs, 1 do
            local obj = SM.CreateObject(dalaranIDs[i], "Dalaran_" .. i, 0, 0, 0);
            local xMin, yMin, zMin, xMax, yMax, zMax = obj:GetActiveBoundingBox();
            obj:SetPosition((xMin + xMax) / 2, (yMin + yMax) / 2, (zMin + zMax) / 2);
        end
    end);

    local testButton = UI.Button:New(0, -173, 100, 20, parent, "TOPLEFT", "TOPLEFT", "TEST");
    testButton:SetScript("OnClick", function(_, button, up)
        
    end);

    local testButtonB = UI.Button:New(0, -193, 100, 20, parent, "TOPLEFT", "TOPLEFT", "Connect");
    testButtonB:SetScript("OnClick", function(_, button, up)
        Net.InvitePlayer("Testpan");
    end);

    local testButtonB = UI.Button:New(101, -193, 100, 20, parent, "TOPLEFT", "TOPLEFT", "Disconnect");
    testButtonB:SetScript("OnClick", function(_, button, up)
        Net.Disconnect();
    end);


--[[
    local testButtonb = UI.Button:New(0, -193, 100, 20, parent, "TOPLEFT", "TOPLEFT", "BIG TEST");
    testButtonb:SetScript("OnClick", function(_, button, up)
        for x = 0, 100, 1 do
            for y = 0, 100, 1 do
                local obj = SM.CreateObject(5019440, "Test", x, y, 0);
            end
        end
    end);

    local testButtonb = UI.Button:New(0, -213, 100, 20, parent, "TOPLEFT", "TOPLEFT", "BIG CLEAR");
    testButtonb:SetScript("OnClick", function(_, button, up)
        local toDelete = {};
        for i = 1, #SM.loadedScene.objects, 1 do
            toDelete[#toDelete + 1] = SM.loadedScene.objects[i];
        end

        for i = 1, #toDelete, 1 do
            SM.DeleteObject(toDelete[i]);
        end
    end);
--]]
    --[[
    local testButton = UI.Button:New(0, -113, 100, 20, parent, "TOPLEFT", "TOPLEFT", "TEST");
    local creatureDisplayID = 4;
    testButton:SetScript("OnClick", function(_, button, up)
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
        GameTooltip:SetHyperlink(format("unit:Creature-0-0-0-0-%d-0", creatureDisplayID))
        for i=1, GameTooltip:NumLines() do 
            print(_G["GameTooltipTextLeft"..i]:GetText())
        end
        GameTooltip:Hide();
    end);
    --]]
end

function Debug.TablePrint(tbl)
	local indent = 4;
	local toprint = string.rep(" ", indent) .. "{\r\n"
	indent = indent + 2
	for k, v in pairs(tbl) do
		toprint = toprint .. string.rep(" ", indent)
		if (type(k) == "number") then
			toprint = toprint .. "[" .. k .. "] = "
		elseif (type(k) == "string") then
			toprint = toprint  .. k ..  "= "   
		end
		if (type(v) == "number") then
			toprint = toprint .. v .. ",\r\n"
		elseif (type(v) == "string") then
			toprint = toprint .. "\"" .. v .. "\",\r\n"
		elseif (type(v) == "table") then
			toprint = toprint .. tprint(v, indent + 2) .. ",\r\n"
		else
			toprint = toprint .. "\"" .. tostring(v) .. "\",\r\n"
		end
	end
	toprint = toprint .. string.rep(" ", indent-2) .. "}"
	print(toprint)
end

function AssetBrowser.CreateToolbar(parent, y, w, startLevel)
    local h = 30;
    AssetBrowser.toolbar = UI.Rectangle:New(0, y, w, h, parent, "TOPLEFT", "TOPLEFT", c1[1], c1[2], c1[3], 1);
    AssetBrowser.toolbar:SetFrameLevel(startLevel);
    AssetBrowser.toolbar:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, 0);

    AssetBrowser.toolbar.upOneFolderButton = UI.Button:New(0, 0, h - 2, h - 2, AssetBrowser.toolbar:GetFrame(), "LEFT", "LEFT", nil, Resources.textures["FolderUpIcon"]);
    AssetBrowser.toolbar.upOneFolderButton:SetScript("OnClick", function (self, button, down) AssetBrowser.UpOneFolder(); end)
    AssetBrowser.toolbar.upOneFolderButton:SetFrameLevel(startLevel + 1);
    AssetBrowser.toolbar.upOneFolderButton.tooltip = L["AB_TOOLBAR_TT_UP_ONE_FOLDER"];

    AssetBrowser.toolbar.breadCrumb = UI.Label:New(h, 0, w - h, h, AssetBrowser.toolbar:GetFrame(), "TOPLEFT", "TOPLEFT", L["AB_BREADCRUMB"], 9);
    AssetBrowser.toolbar.breadCrumb:SetFrameLevel(startLevel + 1);
end

function AssetBrowser.CreateSearchBar(xMin, yMin, xMax, yMax, parent, startLevel)
    local h = 20;

    AssetBrowser.searchBarBG = UI.Rectangle:New(xMin, yMin, 1, 1, parent, "TOPLEFT", "TOPLEFT", c1[1], c1[2], c1[3], 1);
    AssetBrowser.searchBarBG:SetPoint("TOPRIGHT", parent, "TOPRIGHT", xMax, yMax);
    AssetBrowser.searchBarBG:SetFrameLevel(startLevel);
    AssetBrowser.searchBarBG:SetHeight(h);

    local searchLabel = UI.Label:New(5, 0, 50, h, AssetBrowser.searchBarBG:GetFrame(), "TOPLEFT", "TOPLEFT", L["SEARCH"]);
    searchLabel:SetFrameLevel(startLevel + 1);

    AssetBrowser.searchBar = UI.TextBox:New(50, 0, 1, 1, AssetBrowser.searchBarBG:GetFrame(), "TOPLEFT", "TOPLEFT", "");
    AssetBrowser.searchBar:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, 0);
    AssetBrowser.searchBar:SetHeight(h);
    AssetBrowser.searchBar:SetFrameLevel(startLevel + 1);
    AssetBrowser.searchBar:SetScript('OnEnterPressed', function(self)
        -- set value
        local valText = self:GetText();
        AssetBrowser.SearchModelList(valText);
        self:ClearFocus();
        Editor.ui.focused = false;
    end);
end

function AssetBrowser.CreateGridView(xMin, yMin, xMax, yMax, parent, startLevel)
    AssetBrowser.gridList = UI.PooledGridScrollList:NewP(parent, xMin, yMin, "TOPLEFT", "TOPLEFT", xMax, yMax, "BOTTOMRIGHT", "BOTTOMRIGHT");
    AssetBrowser.gridList:SetFrameLevel(startLevel + 2);
    AssetBrowser.gridList:SetItemTemplate(
		{
            width = 94,
			height = 94 + 15,
			buildItem = function(item)
				-- main button --
				item.components[1] = UI.Button:New(0, 0, 94, 94 + 15, item:GetFrame(), "CENTER", "CENTER", "");
				item.components[1]:ClearAllPoints();
				item.components[1]:SetAllPoints(item:GetFrame());
                item.components[1]:SetFrameLevel(startLevel + 3);
                item.components[1]:GetFrame():RegisterForDrag("LeftButton");
                item.components[1]:SetClipsChildren(true);

				-- name text --
				item.components[2] = UI.Label:New(10, 0, 94, 30, item.components[1]:GetFrame(), "BOTTOMLEFT", "BOTTOMLEFT", "", 9);
                item.components[2]:SetPoint("BOTTOMRIGHT", item.components[1]:GetFrame(), "BOTTOMRIGHT", -10, 0);
                item.components[2]:GetFrame().text:SetMaxLines(2);
                item.components[2]:GetFrame().text:SetNonSpaceWrap(true);
                item.components[2]:SetFrameLevel(startLevel + 4);

                -- on double click --
                item.components[1]:GetFrame():SetScript("OnDoubleClick", function (self, button, down)
                    AssetBrowser.OnThumbnailDoubleClick(item.ID, item.components[2]:GetText());
                end);
            
                item.components[1]:GetFrame():SetScript("OnDragStart", function (self, button, down)
                    AssetBrowser.OnThumbnailDrag(item.ID);
                end);
            
                -- image --
                item.components[3] = UI.ImageBox:New(15, -15, 1, 1, item.components[1]:GetFrame(), "TOPLEFT", "TOPLEFT", Resources.textures["FolderIcon"]);
                item.components[3]:SetPoint("BOTTOMRIGHT", item.components[1]:GetFrame(), "BOTTOMRIGHT", -15, 15 + 15);

                -- model --
                item.components[4] = CreateFrame("PlayerModel", "thumbnail_model_frame", item.components[1]:GetFrame());
                item.components[4]:SetPoint("TOPLEFT", item.components[1]:GetFrame(), "TOPLEFT", 0, 0);
                item.components[4]:SetPoint("BOTTOMRIGHT", item.components[1]:GetFrame(), "BOTTOMRIGHT", 0, 0);
                item.components[4]:SetCustomCamera(1);
			end,
			refreshItem = function(entry, item)
				-- object name text --
				item.components[2]:SetText(entry["N"]);

                -- object ID --
                item.ID = entry.ID;

                -- has model (file)
                if (entry.fileID) then
                    item.components[3]:Hide();
                    item.components[4]:Show();
                    if (item.components[4].fileID ~= entry.fileID) then
                        item.components[4]:SetModel(entry.fileID);
                        item.components[4].fileID = entry.fileID;
                    end
                -- doesn't have model (folder)
                elseif (entry.displayID) then
                    item.components[3]:Hide();
                    item.components[4]:Show();
                    if (item.components[4].displayID ~= entry.displayID) then
                        item.components[4]:SetDisplayInfo(entry.displayID);
                        item.components[4].displayID = entry.displayID;
                    end
                else
                    item.components[3]:Show();
                    item.components[4]:Hide();
                end
			end,
	    }
    );
end

function AssetBrowser.ClearBreadcrumb()
    AssetBrowser.breadcrumb = {};
    table.insert(AssetBrowser.breadcrumb, AssetBrowser.currentDirectory);
end

function AssetBrowser.UpOneFolder()
    if (#searchData > 0) then
        -- clear search
        AssetBrowser.searchBar:SetText("");
        AssetBrowser.SearchModelList("");
        AssetBrowser.gridList:Refresh(0);
        AssetBrowser.gridList:SetPosition(0);
    else
        local pos = table.getn(AssetBrowser.breadcrumb) - 1;

        if pos == 0 then return end

        AssetBrowser.currentDirectory = AssetBrowser.breadcrumb[pos];
        table.remove(AssetBrowser.breadcrumb, pos + 1);
        AssetBrowser.gridList:SetData(AssetBrowser.BuildFolderData(AssetBrowser.currentDirectory));
        AssetBrowser.RefreshBreadcrumb();
    end
end

function AssetBrowser.BuildFolderData(dir)
    local data = {};
    local idx = 1;
    
    -- Directory scan
    if (dir["D"] ~= nil) then
        local directoryCount = table.getn(dir["D"]);
        for i = 1, directoryCount, 1 do
            data[idx] = dir["D"][i];
            idx = idx + 1;
        end
    end

    -- File Scan
    if (dir["FN"] ~= nil) then
        local fileCount = table.getn(dir["FN"]);
        for i = 1, fileCount, 1 do
            local fileName = dir["FN"][i];
            local fileID = dir["FI"][i];
            data[idx] = { N = fileName, fileID = fileID, ID = fileID };
            idx = idx + 1;
        end
    end

    return data;
end

function AssetBrowser.BuildCreatureData()
    local data = {};
    local idx = 1;

    for c in pairs(SceneMachine.creatureToDisplayID) do
        local d = SceneMachine.creatureToDisplayID[c];
        local n = SceneMachine.creatureData[c];
        data[idx] = { N = n, displayID = d, ID = c };
        idx = idx + 1;
    end

    return data;
end

function AssetBrowser.BuildSearchDataRecursive(value, dir)

    -- File Scan
    if (dir["FN"] ~= nil) then
        local fileCount = table.getn(dir["FN"]);
        for i = 1, fileCount, 1 do
            local fileName = dir["FN"][i];
            if (string.find(fileName:lower(), value)) then
                local fileID = dir["FI"][i];
                searchData[#searchData + 1] = { N = dir["FN"][i], fileID = fileID, ID = fileID };
            end
        end
    end

    -- Directory scan
    if (dir["D"] ~= nil) then
        local directoryCount = table.getn(dir["D"]);
        for i = 1, directoryCount, 1 do
            AssetBrowser.BuildSearchDataRecursive(value, dir["D"][i]);
        end
    end
end

function AssetBrowser.BuildCreatureSearchData(value)
    for c in pairs(SceneMachine.creatureToDisplayID) do
        local d = SceneMachine.creatureToDisplayID[c];
        local n = SceneMachine.creatureData[c];
        if (string.find(n:lower(), value)) then
            searchData[#searchData + 1] = { N = n, displayID = d, ID = c };
        end
    end
end

function AssetBrowser.RefreshBreadcrumb()
    if (#searchData > 0) then
        AssetBrowser.toolbar.breadCrumb:SetText(string.format(L["AB_RESULTS"], #searchData));
    else
        local str = "";
        for i=2, #AssetBrowser.breadcrumb, 1 do
            if AssetBrowser.breadcrumb[i] ~= nil then
                str = str .. ">" .. AssetBrowser.breadcrumb[i]["N"];
            end
        end
        AssetBrowser.toolbar.breadCrumb:SetText(str);
    end
end

function AssetBrowser.OnThumbnailDoubleClick(ID, name)
    if (AssetBrowser.dataSource == "Models") then
        if (#searchData > 0) then
            -- File Scan
            local fileCount = #searchData;
            for i = 1, fileCount, 1 do
                local fileID = searchData[i].fileID;
                if (fileID == ID) then
                    local fileName = searchData[i].N;
                    local object = SM.CreateObject(fileID, fileName, 0, 0, 0);
                    SM.selectedObject = object;
                    Editor.lastSelectedType = "obj";
                    SH.RefreshHierarchy();
                    OP.Refresh();
                    return;
                end
            end
        else
            -- Directory scan
            if (AssetBrowser.currentDirectory["D"] ~= nil) then
                local directoryCount = table.getn(AssetBrowser.currentDirectory["D"]);
                for i = 1, directoryCount, 1 do
                    local dirName = AssetBrowser.currentDirectory["D"][i]["N"];
                    if (dirName == name) then
                        AssetBrowser.currentPage = 1;
                        AssetBrowser.currentDirectory = AssetBrowser.currentDirectory["D"][i];
                        table.insert(AssetBrowser.breadcrumb, AssetBrowser.currentDirectory);
                        AssetBrowser.RefreshBreadcrumb();
                        AssetBrowser.gridList:SetData(AssetBrowser.BuildFolderData(AssetBrowser.currentDirectory));
                        return;
                    end
                end
            end

            -- File Scan
            if (AssetBrowser.currentDirectory["FN"] ~= nil) then
                local fileCount = table.getn(AssetBrowser.currentDirectory["FN"]);
                for i = 1, fileCount, 1 do
                    local fileID = AssetBrowser.currentDirectory["FI"][i];
                    if (fileID == ID) then
                        local fileName = AssetBrowser.currentDirectory["FN"][i];
                        local object = SM.CreateObject(fileID, fileName, 0, 0, 0);
                        SM.selectedObject = object;
                        Editor.lastSelectedType = "obj";
                        SH.RefreshHierarchy();
                        OP.Refresh();
                        return;
                    end
                end
            end
        end
    end

    if (AssetBrowser.dataSource == "Creatures") then
        if (#searchData > 0) then
            -- File Scan
            local fileCount = #searchData;
            for i = 1, fileCount, 1 do
                local creatureID = searchData[i].ID;
                local displayID = SceneMachine.creatureToDisplayID[creatureID];
                local name = SceneMachine.creatureData[creatureID];
                if (ID == creatureID) then
                    local object = SM.CreateCreature(displayID, name or "Creature", 0, 0, 0);
                    SM.selectedObject = object;
                    Editor.lastSelectedType = "obj";
                    SH.RefreshHierarchy();
                    OP.Refresh();
                    return;
                end
            end
        else
            for c in pairs(SceneMachine.creatureToDisplayID) do
                local creatureID = c;
                local displayID = SceneMachine.creatureToDisplayID[creatureID];
                local name = SceneMachine.creatureData[creatureID];
                if (ID == creatureID) then
                    local object = SM.CreateCreature(displayID, name or "Creature", 0, 0, 0);
                    SM.selectedObject = object;
                    Editor.lastSelectedType = "obj";
                    SH.RefreshHierarchy();
                    OP.Refresh();
                    return;
                end
            end
        end

    end
end

function AssetBrowser.OnThumbnailDrag(ID)
    if (AssetBrowser.dataSource == "Models") then
        if (#searchData > 0) then
            -- File Scan
            local fileCount = #searchData;
            for i = 1, fileCount, 1 do
                local fileID = searchData[i].fileID;
                if (fileID == ID) then
                    local fileName = searchData[i].N;
                    local mouseRay = Camera.GetMouseRay();
                    local initialPosition = mouseRay:PlaneIntersection(Vector3.zero, Gizmos.up) or Vector3.zero;
                    local object = SM.CreateObject(fileID, fileName, initialPosition.x, initialPosition.y, initialPosition.z);
                    local xMin, yMin, zMin, xMax, yMax, zMax = object:GetActiveBoundingBox();
                    object:SetPosition(initialPosition.x, initialPosition.y, initialPosition.z + ((zMax - zMin) / 2));
                    SM.selectedObject = object;
                    Editor.lastSelectedType = "obj";
                    SH.RefreshHierarchy();
                    OP.Refresh();
                    Input.mouseState.LMB = true;
                    Input.mouseState.isDraggingAssetFromUI = true;
                    Gizmos.activeTransformGizmo = 1;
                    Gizmos.highlightedAxis = 4;
                    Gizmos.selectedAxis = 4;
                    Gizmos.OnLMBDown(Input.mouseX, Input.mouseY);
                    return;
                end
            end
        else
            -- File Scan
            if (AssetBrowser.currentDirectory["FN"] ~= nil) then
                local fileCount = table.getn(AssetBrowser.currentDirectory["FN"]);
                for i = 1, fileCount, 1 do
                    local fileID = AssetBrowser.currentDirectory["FI"][i];
                    if fileID == ID then
                        local fileName = AssetBrowser.currentDirectory["FN"][i];
                        local mouseRay = Camera.GetMouseRay();
                        local initialPosition = mouseRay:PlaneIntersection(Vector3.zero, Gizmos.up) or Vector3.zero;
                        local object = SM.CreateObject(fileID, fileName, initialPosition.x, initialPosition.y, initialPosition.z);
                        local xMin, yMin, zMin, xMax, yMax, zMax = object:GetActiveBoundingBox();
                        object:SetPosition(initialPosition.x, initialPosition.y, initialPosition.z + ((zMax - zMin) / 2));
                        SM.selectedObject = object;
                        Editor.lastSelectedType = "obj";
                        SH.RefreshHierarchy();
                        OP.Refresh();
                        Input.mouseState.LMB = true;
                        Input.mouseState.isDraggingAssetFromUI = true;
                        Gizmos.activeTransformGizmo = 1;
                        Gizmos.highlightedAxis = 4;
                        Gizmos.selectedAxis = 4;
                        Gizmos.OnLMBDown(Input.mouseX, Input.mouseY);
                        return;
                    end
                end
            end
        end
    end

    if (AssetBrowser.dataSource == "Creatures") then
        if (#searchData > 0) then
            -- File Scan
            local fileCount = #searchData;
            for i = 1, fileCount, 1 do
                local creatureID = searchData[i].ID;
                if (creatureID == ID) then
                    local name = searchData[i].N;
                    local displayID = SceneMachine.creatureToDisplayID[creatureID];
                    local object = SM.CreateCreature(displayID, name or "Creature", 0, 0, 0);
                    --local object = SM.CreateObject(fileID, fileName, initialPosition.x, initialPosition.y, initialPosition.z);
                    local xMin, yMin, zMin, xMax, yMax, zMax = object:GetActiveBoundingBox();
                    local mouseRay = Camera.GetMouseRay();
                    local initialPosition = mouseRay:PlaneIntersection(Vector3.zero, Gizmos.up) or Vector3.zero;
                    object:SetPosition(initialPosition.x, initialPosition.y, initialPosition.z + ((zMax - zMin) / 2));
                    SM.selectedObject = object;
                    Editor.lastSelectedType = "obj";
                    SH.RefreshHierarchy();
                    OP.Refresh();
                    Input.mouseState.LMB = true;
                    Input.mouseState.isDraggingAssetFromUI = true;
                    Gizmos.activeTransformGizmo = 1;
                    Gizmos.highlightedAxis = 4;
                    Gizmos.selectedAxis = 4;
                    Gizmos.OnLMBDown(Input.mouseX, Input.mouseY);
                    return;
                end
            end
        else
            -- File Scan
            for c in pairs(SceneMachine.creatureToDisplayID) do
                local creatureID = c;
                local displayID = SceneMachine.creatureToDisplayID[creatureID];
                local name = SceneMachine.creatureData[creatureID];
                if (ID == creatureID) then
                    local object = SM.CreateCreature(displayID, name or "Creature", 0, 0, 0);
                    local xMin, yMin, zMin, xMax, yMax, zMax = object:GetActiveBoundingBox();
                    local mouseRay = Camera.GetMouseRay();
                    local initialPosition = mouseRay:PlaneIntersection(Vector3.zero, Gizmos.up) or Vector3.zero;
                    object:SetPosition(initialPosition.x, initialPosition.y, initialPosition.z + ((zMax - zMin) / 2));
                    SM.selectedObject = object;
                    Editor.lastSelectedType = "obj";
                    SH.RefreshHierarchy();
                    OP.Refresh();
                    Input.mouseState.LMB = true;
                    Input.mouseState.isDraggingAssetFromUI = true;
                    Gizmos.activeTransformGizmo = 1;
                    Gizmos.highlightedAxis = 4;
                    Gizmos.selectedAxis = 4;
                    Gizmos.OnLMBDown(Input.mouseX, Input.mouseY);
                    return;
                end
            end
        end
    end
end

function AssetBrowser.SearchModelList(value)
    if (value == nil or value == "") then
        -- clear search
        searchData = {};
        if (AssetBrowser.dataSource == "Models") then
            AssetBrowser.gridList:SetData(AssetBrowser.BuildFolderData(AssetBrowser.currentDirectory));
        elseif (AssetBrowser.dataSource == "Creatures") then
            AssetBrowser.gridList:SetData(AssetBrowser.BuildCreatureData());
        end
    else
        -- search
        searchData = {};
        if (AssetBrowser.dataSource == "Models") then
            AssetBrowser.BuildSearchDataRecursive(value:lower(), SceneMachine.modelData[1]);
        elseif (AssetBrowser.dataSource == "Creatures") then
            AssetBrowser.BuildCreatureSearchData(value:lower());
        end
        AssetBrowser.gridList:SetData(searchData);
    end
    AssetBrowser.RefreshBreadcrumb();
end