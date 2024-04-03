local AB = SceneMachine.Editor.AssetBrowser;
local Editor = SceneMachine.Editor;
local Renderer = SceneMachine.Renderer;
local SM = Editor.SceneManager;
local GM = SceneMachine.GizmoManager
local Input = SceneMachine.Input;
local Camera = SceneMachine.Camera;
local Vector3 = SceneMachine.Vector3;
local UI = SceneMachine.UI;
local Resources = SceneMachine.Resources;
local SH = Editor.SceneHierarchy;
local OP = Editor.ObjectProperties;
local searchData = {};
local L = Editor.localization;
local Net = SceneMachine.Network;
local Actions = SceneMachine.Actions;
local Scene = SceneMachine.Scene;
local Gizmo = SceneMachine.Gizmos.Gizmo;

local c1 = { 0.1757, 0.1757, 0.1875 };
local c2 = { 0.242, 0.242, 0.25 };
local c3 = { 0, 0.4765, 0.7968 };
local c4 = { 0.1171, 0.1171, 0.1171 };

AB.dataSource = "Models";
AB.selectedCollection = nil;
AB.selectedCollectionIndex = -1;
AB.selectedGridViewItem = nil;
AB.entryToAddToCollection = nil;
AB.draggingItem = false;
AB.itemBeingDragged = nil;
local tabButtonHeight = 20;
local draggableShrinkSpeed = 200;

AB.COLLECTION_DATA_VERSION = 1;

function AB.Create(parent, w, h, startLevel)

    AB.tabGroup = UI.TabGroup:NewTLTR(0, 0, 0, 0, tabButtonHeight, parent, startLevel + 2, false);
	AB.tabGroup:SetItemTemplate(
    {
        height = tabButtonHeight,
        lmbAction = function(index)
            AB.OnChangeTab(index);
        end,
        refreshItem = function(data, item, index)
            -- timeline name text --
            item.components[2]:SetWidth(1000);
            item.components[2]:SetText(data.name);
            local strW = item.components[2].frame.text:GetStringWidth() + 20;
            item:SetWidth(strW);
            item.components[1]:SetWidth(strW);
            item.components[2]:SetWidth(strW);
            return strW;
        end,
    });

    AB.tabGroup:SetData({
        { name = "Models" },
        { name = "Creatures" },
        { name = "Collections" },
        { name = "Debug" },
     });

    AB.tabs = {};
    AB.tabs[1] = UI.Rectangle:NewTLBR(0, -20, 0, 0, parent, 0, 0, 0, 0.0);
    AB.tabs[1]:SetFrameLevel(startLevel + 3);
    AB.tabs[2] = UI.Rectangle:NewTLBR(0, -20, 0, 0, parent, 0, 0, 0, 0.0);
    AB.tabs[2]:SetFrameLevel(startLevel + 3);
    AB.tabs[3] = UI.Rectangle:NewTLBR(0, -20, 0, 0, parent, 0, 0, 0, 0.0);
    AB.tabs[3]:SetFrameLevel(startLevel + 3);
    AB.tabs[4] = UI.Rectangle:NewTLBR(0, -20, 0, 0, parent, 0, 0, 0, 0.0);
    AB.tabs[4]:SetFrameLevel(startLevel + 3);

    AB.RefreshTabs();

    AB.CreateToolbar(AB.tabs[1]:GetFrame(), -Editor.pmult, w, startLevel + 10);
    AB.CreateSearchBar(0, -30 - Editor.pmult, 0, 0, AB.tabs[1]:GetFrame(), startLevel + 3);
    AB.CreateGridView(0, -50 - Editor.pmult, 0, 0, AB.tabs[1]:GetFrame(), startLevel + 3);
    AB.CreateCollectionsTab(0, -30 - Editor.pmult, AB.tabs[3]:GetFrame(), startLevel + 3);
    AB.CreateDebugTab(AB.tabs[4]:GetFrame(), 300);

	AB.gridList:MakePool();
    AB.currentDirectory = SceneMachine.modelData[1];
    AB.gridList:SetData(AB.BuildFolderData(AB.currentDirectory));
    AB.breadcrumb = {};
    table.insert(AB.breadcrumb, AB.currentDirectory);
    AB.OnChangeTab(1);

    AB.LoadCollections();

	AB.draggableItem = UI.Rectangle:New(0, 0, 50, 50, nil, "TOPLEFT", "TOPLEFT", 1, 1, 1, 0.5);
	AB.draggableItem:SetWidth(50);
	AB.draggableItem:SetFrameLevel(AB.gridList.viewport:GetFrameLevel() + 100);
	AB.draggableItem:SetFrameStrata(Editor.MESSAGE_BOX_FRAME_STRATA);
	AB.draggableItem:Hide();

    -- DEBUG --
    --AB.OnThumbnailDoubleClick(nil, "World");
    --AB.OnThumbnailDoubleClick(nil, "Expansion07");
    --AB.OnThumbnailDoubleClick(nil, "Doodads");
    --AB.OnThumbnailDoubleClick(nil, "Kultiraszone");
    --AB.OnChangeTab(3);
end

function AB.Update(deltaTime)
    if (AB.draggingItem) then
        -- Check if mouse is over asset browser
        local isOver = MouseIsOver(AB.tabs[1]:GetFrame());
        if (isOver) then
            if (not AB.draggableItem:IsVisible()) then
                AB.draggableItem:Show();

                if (AB.itemBeingDragged.components[2].fileID) then
                    AB.itemBeingDragged.components[2]:SetModel(AB.itemBeingDragged.components[2].fileID);
                elseif (AB.itemBeingDragged.components[2].displayID) then
                    AB.itemBeingDragged.components[2]:SetDisplayInfo(AB.itemBeingDragged.components[2].displayID);
                end
            end
            local mx, my = Input.mouseXRaw, Input.mouseYRaw;
            local w = AB.draggableItem:GetWidth();
            local h = AB.draggableItem:GetHeight();
            if (w > 80 or h > 80) then
                w = w - deltaTime * draggableShrinkSpeed;
                AB.draggableItem:SetWidth(w);
                h = h - deltaTime * draggableShrinkSpeed
                AB.draggableItem:SetHeight(h);
            end
            local centerX = w / 2;
            local centerY = h / 2;
            AB.draggableItem:SetSinglePoint("BOTTOMLEFT", mx - centerX, my - centerY);
        else
            AB.draggableItem:Hide();
        end
    end

end

function AB.LoadCollections()

    if (not scenemachine_collections) then
        AB.CreateDefaultCollection();
    end

    AB.collectionScrollList:SetData(scenemachine_collections);
end

function AB.CreateDefaultCollection()
    scenemachine_collections = {};

    local index = AB.NewCollection("Base Floors");
    AB.AddFileIDToCollection(947328, index);
    AB.AddFileIDToCollection(1093938, index);
    AB.AddFileIDToCollection(1247674, index);
    AB.AddFileIDToCollection(1247671, index);
    AB.AddFileIDToCollection(948613, index);
    AB.AddFileIDToCollection(4186667, index);
    AB.AddFileIDToCollection(306960, index);
    AB.AddFileIDToCollection(194010, index);
    AB.AddFileIDToCollection(3656582, index);
    AB.AddFileIDToCollection(657869, index);

    local index = AB.NewCollection("Point Lights");
    AB.AddFileIDToCollection(193039, index);
    AB.AddFileIDToCollection(1250693, index);
    AB.AddFileIDToCollection(1376353, index);
    AB.AddFileIDToCollection(1376386, index);
    AB.AddFileIDToCollection(1398885, index);
    AB.AddFileIDToCollection(1398890, index);
    AB.AddFileIDToCollection(1398891, index);
    AB.AddFileIDToCollection(1398892, index);
    AB.AddFileIDToCollection(1398893, index);
    AB.AddFileIDToCollection(1398894, index);
    AB.AddFileIDToCollection(1375444, index);
    AB.AddFileIDToCollection(1303476, index);
end

function AB.NewCollection(name)
    local index = #scenemachine_collections + 1;
    scenemachine_collections[index] = {
        name = name,
        items = {},
    };

    AB.collectionScrollList:SetData(scenemachine_collections);

    return index;
end

function AB.RenameSelectedCollection(name)
    scenemachine_collections[AB.selectedCollectionIndex].name = name;
    AB.collectionScrollList:SetData(scenemachine_collections);
end

function AB.RemoveCollection(collectionIndex)
    if (collectionIndex < 0) then
        return;
    end

    if (scenemachine_collections[collectionIndex]) then

        if (#scenemachine_collections[collectionIndex].items > 0) then
            -- ask first
            Editor.OpenMessageBox(SceneMachine.mainWindow:GetFrame(), L["AM_MSG_REMOVE_COLLECTION_TITLE"], L["AB_MSG_REMOVE_COLLECTION_MESSAGE"], true, true, function() AB.RemoveCollection_internal(collectionIndex); end, function() end);
        else
            AB.RemoveCollection_internal(collectionIndex);
        end
    end
end

function AB.RemoveCollection_internal(collectionIndex)    -- don't use directly
    table.remove(scenemachine_collections, collectionIndex);
    AB.collectionScrollList:SetData(scenemachine_collections);
    AB.selectedCollectionIndex = -1;
    AB.selectedGridViewItem = nil;
    AB.gridList:SetData(nil);
end

function AB.AddFileIDToCollection(fileID, collectionIndex)
    if (not fileID or fileID < 0) then
        return;
    end

    if (not scenemachine_collections[collectionIndex]) then
        return;
    end

    local index = #scenemachine_collections[collectionIndex].items + 1;

    scenemachine_collections[collectionIndex].items[index] = {
        fileID = fileID;
    }
end

function AB.AddDisplayIDToCollection(displayID, collectionIndex)
    if (not displayID or displayID < 0) then
        return;
    end

    if (not scenemachine_collections[collectionIndex]) then
        return;
    end

    local index = #scenemachine_collections[collectionIndex].items + 1;

    scenemachine_collections[collectionIndex].items[index] = {
        displayID = displayID;
    }
end

function AB.AddObjectsToCollection(objects, collectionIndex)
    if (not objects) then
        return;
    end

    for i = 1, #objects, 1 do
        AB.AddObjectToCollection(objects[i], collectionIndex);
    end
end

function AB.AddObjectToCollection(object, collectionIndex)
    if (not object) then
        return;
    end

    if (collectionIndex < 0) then
        return;
    end

    -- switch based on object type
    if (object.type == SceneMachine.GameObjects.Object.Type.Model) then
        AB.AddFileIDToCollection(object.fileID, collectionIndex)
    elseif(object.type == SceneMachine.GameObjects.Object.Type.Creature) then
        AB.AddDisplayIDToCollection(object.displayID, collectionIndex)
    end

    AB.gridList:SetData(AB.BuildCollectionData(AB.selectedCollection));
end

function AB.RemoveSelectedObjectFromCollection()
    if (not AB.selectedCollection) then
        return;
    end

    if (not AB.selectedGridViewItem) then
        return;
    end

    table.remove(scenemachine_collections[AB.selectedCollectionIndex].items, AB.selectedGridViewItem.dataIndex);
    AB.gridList:SetData(AB.BuildCollectionData(AB.selectedCollection));
end

function AB.OpenCollection(index)
    AB.selectedCollection = scenemachine_collections[index];
    AB.selectedCollectionIndex = index;
    AB.selectedGridViewItem = nil;
    AB.collectionScrollList:RefreshStatic();

    AB.gridList:SetData(AB.BuildCollectionData(AB.selectedCollection));

    if (AB.entryToAddToCollection) then
        if (AB.entryToAddToCollection.displayID ~= 0) then
            AB.AddDisplayIDToCollection(AB.entryToAddToCollection.displayID, index);
        elseif (AB.entryToAddToCollection.fileID ~= 0) then
            AB.AddFileIDToCollection(AB.entryToAddToCollection.fileID, index);
        end
        AB.gridList:SetData(AB.BuildCollectionData(AB.selectedCollection));
        AB.entryToAddToCollection = nil;
    end
end

function AB.GetFileName(fileID)
    return AB.GetFileNameRecursive(fileID, SceneMachine.modelData[1]);
end

function AB.GetFileNameRecursive(value, dir)
    -- File Scan
    if (not dir) then return nil; end

    if (dir["FN"] ~= nil) then
        local fileCount = #dir["FN"];
        for i = 1, fileCount, 1 do
            local fileID = dir["FI"][i];
            if (fileID == value) then
                local fileName = dir["FN"][i];
                return fileName;
            end
        end
    end

    -- Directory scan
    if (dir["D"] ~= nil) then
        local directoryCount = #dir["D"];
        for i = 1, directoryCount, 1 do
            local n = AB.GetFileNameRecursive(value, dir["D"][i]);
            if (n) then return n; end
        end
    end

    return nil;
end

function AB.RefreshTabs()
    AB.tabGroup:Refresh(0);
end

function AB.OnChangeTab(idx)
    AB.tabGroup.selectedIndex = idx;
    AB.selectedGridViewItem = nil;
    AB.entryToAddToCollection = nil;
    local tabFrame = AB.tabs[idx]:GetFrame();
    for i = 1, #AB.tabs, 1 do
        AB.tabs[i]:Hide();
    end
    AB.toolbar:Hide();
    AB.searchBarBG:Hide();
    AB.gridList.frame:Hide();

    if (idx == 1) then
        -- Models --
        AB.toolbar:Show();
        AB.toolbar:SetParent(tabFrame);
        AB.toolbar.modelsGroup:Show();
        AB.toolbar.collectionsGroup:Hide();
        tabFrame:Show();
        AB.searchBarBG:Show();
        AB.searchBarBG:SetParent(tabFrame);
        AB.searchBarBG:ClearAllPoints();
        AB.searchBarBG:SetPoint("TOPLEFT", tabFrame, "TOPLEFT", 0, -30 - Editor.pmult);
        AB.searchBarBG:SetPoint("BOTTOMRIGHT", tabFrame, "BOTTOMRIGHT", 0, 0);
        AB.currentDirectory = SceneMachine.modelData[1];
        AB.gridList.frame:Show();
        AB.gridList.frame:SetParent(tabFrame);
        AB.gridList.frame:ClearAllPoints();
        AB.gridList.frame:SetPoint("TOPLEFT", tabFrame, "TOPLEFT", 0, -50 - Editor.pmult);
        AB.gridList.frame:SetPoint("BOTTOMRIGHT", tabFrame, "BOTTOMRIGHT", 0, 0);
        AB.gridList:SetFrameLevel(tabFrame:GetFrameLevel() + 20);
        AB.gridList:SetData(AB.BuildFolderData(AB.currentDirectory));
        AB.ClearBreadcrumb();
        AB.RefreshBreadcrumb();
        AB.dataSource = "Models";
    elseif (idx == 2) then
        -- Creatures --
        tabFrame:Show();
        AB.searchBarBG:Show();
        AB.searchBarBG:SetParent(tabFrame);
        AB.searchBarBG:ClearAllPoints();
        AB.searchBarBG:SetPoint("TOPLEFT", tabFrame, "TOPLEFT", 0, 0);
        AB.searchBarBG:SetPoint("BOTTOMRIGHT", tabFrame, "BOTTOMRIGHT", 0, 0);
        AB.gridList.frame:Show();
        AB.gridList:SetParent(tabFrame);
        AB.gridList:ClearAllPoints();
        AB.gridList:SetPoint("TOPLEFT", tabFrame, "TOPLEFT", 0, -30 - Editor.pmult);
        AB.gridList:SetPoint("BOTTOMRIGHT", tabFrame, "BOTTOMRIGHT", 0, 0);
        AB.gridList:SetFrameLevel(tabFrame:GetFrameLevel() + 20);
        AB.gridList:SetData(AB.BuildCreatureData());
        AB.ClearBreadcrumb();
        AB.RefreshBreadcrumb();
        AB.dataSource = "Creatures";
    elseif (idx == 3) then
        -- Collections --
        tabFrame:Show();
        AB.toolbar:Show();
        AB.toolbar:SetParent(tabFrame);
        AB.toolbar.modelsGroup:Hide();
        AB.toolbar.collectionsGroup:Show();
        AB.gridList.frame:Show();
        AB.gridList:SetParent(AB.collectionsBottomGroup:GetFrame());
        AB.gridList:ClearAllPoints();
        AB.gridList:SetPoint("TOPLEFT", AB.collectionsBottomGroup:GetFrame(), "TOPLEFT", 0, 0);
        AB.gridList:SetPoint("BOTTOMRIGHT", AB.collectionsBottomGroup:GetFrame(), "BOTTOMRIGHT", 0, 0);
        AB.gridList:SetFrameLevel(AB.collectionsBottomGroup:GetFrame():GetFrameLevel() + 20);
        AB.dataSource = "Collections";
        AB.gridList:SetData(nil);
        AB.selectedCollection = nil;
        AB.selectedCollectionIndex = -1;
        AB.collectionScrollList:RefreshStatic();
        --AB.OpenCollection(1);
    elseif (idx == 4) then
        -- Debug --
        tabFrame:Show();
        AB.dataSource = nil;
    end

    AB.searchBar:SetText("");
    AB.SearchModelList("");
    AB.RefreshTabs();
end

function AB.CreateCollectionsTab(x, y, parent, startLevel)
    AB.collectionsBottomGroup = UI.Rectangle:NewBLBR(0, 0, 0, 6, scenemachine_settings.collectionsPanelH, parent, 0.1757, 0.1757, 0.1875, 1);
    AB.collectionsBottomGroup:SetFrameLevel(startLevel);
    AB.collectionsBottomGroup.frame:SetResizable(true);
    AB.collectionsBottomGroup.frame:SetUserPlaced(true);
    AB.collectionsBottomGroup.frame:SetResizeBounds(120, 20, 800, 500);

    AB.collectionsSeparator = UI.Rectangle:NewTLTR(0, 6, 0, 0, 6, AB.collectionsBottomGroup:GetFrame(), 1,1,1,0);
    AB.collectionsSeparator:SetFrameLevel(startLevel + 10);
    AB.collectionsSeparator:GetFrame():EnableMouse(true);
    AB.collectionsSeparator:GetFrame():RegisterForDrag("LeftButton");
    AB.collectionsSeparator:GetFrame():SetScript("OnDragStart", function()
        AB.collectionsBottomGroup.frame:StartSizing("TOP");
        SetCursor(Resources.textures["CursorResizeV"]);
    end);
	AB.collectionsSeparator:GetFrame():SetScript("OnDragStop", function()
        scenemachine_settings.collectionsPanelH = (AB.collectionsBottomGroup:GetTop() - 6) - SceneMachine.mainWindow:GetBottom();
        AB.collectionsBottomGroup.frame:StopMovingOrSizing();
        AB.collectionsBottomGroup:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 0);
        AB.collectionsBottomGroup:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 0, 6);
        ResetCursor();
    end);
    AB.collectionsSeparator:GetFrame():SetScript('OnEnter', function() SetCursor(Resources.textures["CursorResizeV"]); end)
    AB.collectionsSeparator:GetFrame():SetScript('OnLeave', function() ResetCursor(); end)

    AB.collectionsTopGroup = UI.Rectangle:NewTLBR(0, -30 - Editor.pmult, 0, 6, parent, 0, 0, 0, 0);
	AB.collectionsTopGroup:SetFrameLevel(startLevel);

    AB.collectionScrollList = UI.PooledScrollList:NewTLBR(1, -1, 0, 0, AB.collectionsTopGroup:GetFrame());
	AB.collectionScrollList:SetFrameLevel(startLevel + 3);
	AB.collectionScrollList:SetItemTemplate(
		{
			height = 20,
			buildItem = function(item)
				-- main button --
				item.components[1] = UI.Button:NewAP( item:GetFrame(), "");

				-- object name text --
				item.components[2] = UI.Label:New(10, 0, 200, 18, item.components[1]:GetFrame(), "LEFT", "LEFT", "", 9);
			end,
			refreshItem = function(data, item, index)
				-- main button --
				item.components[1]:SetScript("OnClick", function() AB.OpenCollection(index); end);
				if (data == AB.selectedCollection) then
					item.components[1]:SetColor(UI.Button.State.Normal, 0, 0.4765, 0.7968, 1);
				else
					item.components[1]:SetColor(UI.Button.State.Normal, 0.1757, 0.1757, 0.1875, 1);
				end

				-- object name text --
				item.components[2]:SetText(data.name);
			end,
		});

	AB.collectionScrollList:MakePool();
end

function AB.CreateDebugTab(parent, w, h)
    local fileIDText = UI.Label:New(0, -5, 100, 20, parent, "TOPLEFT", "TOPLEFT", "FileID", 9);
    local fileIDTextEditBox = UI.TextBox:New(100, -5, w * 0.3, 20, parent, "TOPLEFT", "TOPLEFT", "0");
    fileIDTextEditBox:SetScript('OnEnterPressed', function(self1)
        -- set value
        local valText = self1:GetText();
        if (valText == nil or valText == "") then
            return;
        end
        local val = tonumber(valText);
        if (val ~= nil) then
            SM.loadedScene:CreateObject(val, "Model", 0, 0, 0);
            SH.RefreshHierarchy();
            OP.Refresh();
        end
        self1:ClearFocus();
        Editor.ui.focused = false;
    end);

    local creatureDisplayIDText = UI.Label:New(0, -27, 100, 20, parent, "TOPLEFT", "TOPLEFT", "CreatureDisplayID", 9);
    local creatureDisplayIDEditBox = UI.TextBox:New(100, -27, w * 0.3, 20, parent, "TOPLEFT", "TOPLEFT", "41918");
    creatureDisplayIDEditBox:SetScript('OnEnterPressed', function(self1)
        -- set value
        local valText = self1:GetText();
        if (valText == nil or valText == "") then
            return;
        end
        local val = tonumber(valText);
        if (val ~= nil) then
            SM.loadedScene:CreateCreature(val, "Creature", 0, 0, 0);
            SH.RefreshHierarchy();
            OP.Refresh();
        end
        self1:ClearFocus();
        Editor.ui.focused = false;
    end);

    local creatureIDText = UI.Label:New(0, -49, 100, 20, parent, "TOPLEFT", "TOPLEFT", "CreatureID", 9);
    local creatureIDEditBox = UI.TextBox:New(100, -49, w * 0.3, 20, parent, "TOPLEFT", "TOPLEFT", "0");
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
                SM.loadedScene:CreateCreature(creatureDisplayID, "Creature", 0, 0, 0);
                SH.RefreshHierarchy();
                OP.Refresh();
            end
        end
        self1:ClearFocus();
        Editor.ui.focused = false;
    end);

    local creatureAnimationText = UI.Label:New(0, -71, 100, 20, parent, "TOPLEFT", "TOPLEFT", "PlayAnimID", 9);
    local creatureAnimationEditBox = UI.TextBox:New(100, -71, w * 0.3, 20, parent, "TOPLEFT", "TOPLEFT", "0");
    creatureAnimationEditBox:SetScript('OnEnterPressed', function(self1)
        -- set value
        local valText = self1:GetText();
        if (valText == nil or valText == "") then
            return;
        end
        local val = tonumber(valText);
        if (val ~= nil) then
            if (#SM.selectedObjects > 0) then
                SM.selectedObjects[1]:PlayAnimID(val);
            end
        end
        self1:ClearFocus();
        Editor.ui.focused = false;
    end);

    local creatureAnimationKitText = UI.Label:New(0, -93, 100, 20, parent, "TOPLEFT", "TOPLEFT", "PlayAnimKitID", 9);
    local creatureAnimationKitEditBox = UI.TextBox:New(100, -93, w * 0.3, 20, parent, "TOPLEFT", "TOPLEFT", "0");
    creatureAnimationKitEditBox:SetScript('OnEnterPressed', function(self1)
        -- set value
        local valText = self1:GetText();
        if (valText == nil or valText == "") then
            return;
        end
        local val = tonumber(valText);
        if (val ~= nil) then
            if (#SM.selectedObjects > 0) then
                SM.selectedObjects[1]:PlayAnimKitID(val);
            end
        end
        self1:ClearFocus();
        Editor.ui.focused = false;
    end);
    
    local characterButton = UI.Button:New(0, -113, 100, 20, parent, "TOPLEFT", "TOPLEFT", "Create Character");
    characterButton:SetScript("OnClick", function(_, button, up)
        SM.loadedScene:CreateCharacter(0, 0, 0);
        SH.RefreshHierarchy();
        OP.Refresh();
    end);

    local undressButton = UI.Button:New(0, -133, 100, 20, parent, "TOPLEFT", "TOPLEFT", "Undress");
    local creatureDisplayID = 4;
    undressButton:SetScript("OnClick", function(_, button, up)
        if (#SM.selectedObjects > 0) then
            SM.selectedObjects[1].actor:Undress(true);
        end
    end);

    local dressButton = UI.Button:New(0, -153, 150, 20, parent, "TOPLEFT", "TOPLEFT", "Dress with current items");
    local creatureDisplayID = 4;
    dressButton:SetScript("OnClick", function(_, button, up)
        if (#SM.selectedObjects > 0) then
            SM.selectedObjects[1].actor:Dress();
        end
    end);

    local dalaranButton = UI.Button:New(0, -173, 150, 20, parent, "TOPLEFT", "TOPLEFT", "Make Dalaran");
    local dalaranIDs = { 1486995, 1486996, 1486997, 1486998, 1486999, 1487000, 1487001, 1487002, 1487010, 1487011, 1487012 };
    dalaranButton:SetScript("OnClick", function(_, button, up)
        local toDelete = {};
        for i = 1, SM.loadedScene:GetObjectCount(), 1 do
            for j = 1, #dalaranIDs, 1 do
                if (SM.loadedScene:GetObject(i).fileID == dalaranIDs[j]) then
                    toDelete[#toDelete + 1] = SM.loadedScene:GetObject(i);
                end
            end
        end

        for i = 1, #toDelete, 1 do
            SM.DeleteObject_internal(toDelete[i]);
        end

        for i = 1, #dalaranIDs, 1 do
            local obj = SM.loadedScene:CreateObject(dalaranIDs[i], "Dalaran_" .. i, 0, 0, 0);
            SH.RefreshHierarchy();
            OP.Refresh();
            local xMin, yMin, zMin, xMax, yMax, zMax = obj:GetActiveBoundingBox();
            obj:SetPosition((xMin + xMax) / 2, (yMin + yMax) / 2, (zMin + zMax) / 2);
        end
    end);

    local spellKitText = UI.Label:New(0, -193, 100, 20, parent, "TOPLEFT", "TOPLEFT", "SetSpellVisualKitID", 9);
    local spellKitEditBox = UI.TextBox:New(100, -193, w * 0.3, 20, parent, "TOPLEFT", "TOPLEFT", "0");
    local currentKit = 0;
    spellKitEditBox:SetScript('OnEnterPressed', function(self1)
        -- set value
        local valText = self1:GetText();
        if (valText == nil or valText == "") then
            return;
        end
        local val = tonumber(valText);
        if (val ~= nil) then
            if (#SM.selectedObjects > 0) then
                currentKit = val;
                SM.selectedObjects[1]:SetSpellVisualKitID(val);
            end
        end
        self1:ClearFocus();
        Editor.ui.focused = false;
    end);
    local nextKitButton = UI.Button:New(100 + w * 0.3, -193, 30, 20, parent, "TOPLEFT", "TOPLEFT", " > ");
    nextKitButton:SetScript("OnClick", function(_, button, up)
        if (#SM.selectedObjects > 0) then
            currentKit = currentKit + 1;
            spellKitEditBox:SetText(tostring(currentKit));
            SM.selectedObjects[1]:SetSpellVisualKitID(currentKit);
        end
    end);
    local clearKitButton = UI.Button:New(100 + w * 0.3 + 30, -193, 30, 20, parent, "TOPLEFT", "TOPLEFT", " C ");
    clearKitButton:SetScript("OnClick", function(_, button, up)
        if (#SM.selectedObjects > 0) then
            SM.selectedObjects[1]:ClearSpellVisualKits();
        end
    end);

    local dispIDToNameButton = UI.Label:New(0, -213, 100, 20, parent, "TOPLEFT", "TOPLEFT", "DisplayID to Name", 9);
    local dispIDToNameEditBox = UI.TextBox:New(100, -213, w * 0.3, 20, parent, "TOPLEFT", "TOPLEFT", "0");
    local currentKit = 0;
    dispIDToNameEditBox:SetScript('OnEnterPressed', function(self1)
        -- set value
        local valText = self1:GetText();
        if (valText == nil or valText == "") then
            return;
        end
        local val = tonumber(valText);
        if (val ~= nil) then
            GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
            GameTooltip:SetHyperlink(format("unit:Creature-0-0-0-0-%d-0", val))
            for i=1, GameTooltip:NumLines() do 
                print(_G["GameTooltipTextLeft"..i]:GetText())
            end
            GameTooltip:Hide();
        end
        self1:ClearFocus();
        Editor.ui.focused = false;
    end);


    local testButton = UI.Button:New(0, -233, 100, 20, parent, "TOPLEFT", "TOPLEFT", "TEST");
    testButton:SetScript("OnClick", function(_, button, up)
        if (#SM.selectedObjects > 0) then
            print("TEST")
            --local path = Resources.resourcePath .. "\\7wd_warden_cavelight_felgreen01.m2";
            --SM.selectedObjects[1].actor:SetModelByPath(path);
            --SM.selectedObjects[1].actor:TryOn(167988);
            --SM.selectedObjects[1].actor:SetFrontEndLobbyModelFromDefaultCharacterDisplay(1);
            SM.selectedObjects[1].actor:SetPlayerModelFromGlues();
        end
        --SM.loadedScene:ExportSceneForPrint();
    end);
    
--[[
    local testButtonB = UI.Button:New(0, -193, 100, 20, parent, "TOPLEFT", "TOPLEFT", "Connect");
    testButtonB:SetScript("OnClick", function(_, button, up)
        Net.InvitePlayer("Testpan");
    end);

    local testButtonB = UI.Button:New(101, -193, 100, 20, parent, "TOPLEFT", "TOPLEFT", "Disconnect");
    testButtonB:SetScript("OnClick", function(_, button, up)
        Net.Disconnect();
    end);
--]]

end

function AB.CreateToolbar(parent, y, w, startLevel)
    local h = 30;
    AB.toolbar = UI.Toolbar:New(0, y, w, h, parent, SceneMachine.mainWindow, Resources.iconData["AssetExplorerToolbar"]);
    AB.toolbar:SetFrameLevel(startLevel + 2);
    AB.toolbar.modelsGroup = AB.toolbar:CreateGroup(0, 0, Editor.width, h,
        {
            { type = "DragHandle" },
            {
                type = "Button", name = "UpOneFolder", icon = AB.toolbar:GetIcon("uponefolder"), action = function(self) AB.UpOneFolder() end,
                tooltip = L["AB_TOOLBAR_TT_UP_ONE_FOLDER"],
            },
            { type = "Separator" },
            {
                type = "Label", name = "Breadcrumb", text = L["AB_BREADCRUMB"], width = w,
            },
        }
    );
    AB.toolbar.modelsGroup:SetFrameLevel(startLevel + 3);

    AB.toolbar.collectionsGroup = AB.toolbar:CreateGroup(0, 0, Editor.width, h,
        {
            { type = "DragHandle" },
            {
                type = "Button", name = "NewCollection", icon = AB.toolbar:GetIcon("newcollection"),
                action = function(self) Editor.OpenQuickTextbox(AB.NewCollection, "MyCollection", L["AB_COLLECTION_NAME"]) end,
                tooltip = L["AB_TOOLBAR_TT_NEW_COLLECTION"],
            },
            {
                type = "Button", name = "RemoveCollection", icon = AB.toolbar:GetIcon("removecollection"),
                action = function(self) AB.RemoveCollection(AB.selectedCollectionIndex); end,
                tooltip = L["AB_TOOLBAR_TT_REMOVE_COLLECTION"],
            },
            {
                type = "Button", name = "RenameCollection", icon = AB.toolbar:GetIcon("renamecollection"),
                action = function(self)
                    if (AB.selectedCollection) then
                        Editor.OpenQuickTextbox(AB.RenameSelectedCollection, AB.selectedCollection.name, L["AB_COLLECTION_RENAME"]);
                    end
                end,
                tooltip = L["AB_TOOLBAR_TT_RENAME_COLLECTION"],
            },
            {
                type = "Button", name = "ImportCollection", icon = AB.toolbar:GetIcon("importcollection"),
                action = function(self) AB.Button_ImportCollection(); end,
                tooltip = L["AB_TOOLBAR_TT_IMPORT_COLLECTION"],
            },
            {
                type = "Button", name = "ExportCollection", icon = AB.toolbar:GetIcon("exportcollection"),
                action = function(self) AB.Button_ExportCollection(AB.selectedCollectionIndex); end,
                tooltip = L["AB_TOOLBAR_TT_EXPORT_COLLECTION"],
            },
            { type = "Separator" },
            {
                type = "Button", name = "AddObject", icon = AB.toolbar:GetIcon("addsceneobject"),
                action = function(self) AB.AddObjectsToCollection(SM.selectedObjects, AB.selectedCollectionIndex); end,
                tooltip = L["AB_TOOLBAR_TT_ADD_OBJECT"],
            },
            {
                type = "Button", name = "RemoveObject", icon = AB.toolbar:GetIcon("removeobject"),
                action = function(self) AB.RemoveSelectedObjectFromCollection(); end,
                tooltip = L["AB_TOOLBAR_TT_REMOVE_OBJECT"],
            },
        }
    );

    AB.toolbar.collectionsGroup:SetFrameLevel(startLevel + 3);
end

function AB.CreateSearchBar(xMin, yMin, xMax, yMax, parent, startLevel)
    local h = 20;

    AB.searchBarBG = UI.Rectangle:NewTLTR(xMin, yMin, xMax, yMax, h, parent, c1[1], c1[2], c1[3], 1);
    AB.searchBarBG:SetFrameLevel(startLevel);

    local searchLabel = UI.Label:New(5, 0, 50, h, AB.searchBarBG:GetFrame(), "TOPLEFT", "TOPLEFT", L["SEARCH"]);
    searchLabel:SetFrameLevel(startLevel + 1);

    AB.searchBar = UI.TextBox:NewTLTR(50, 0, 0, 0, h, AB.searchBarBG:GetFrame(), "");
    AB.searchBar:SetFrameLevel(startLevel + 1);
    AB.searchBar:SetScript('OnEnterPressed', function(self)
        -- set value
        local valText = self:GetText();
        AB.SearchModelList(valText);
        self:ClearFocus();
        Editor.ui.focused = false;
    end);
end

function AB.GridShowFileInfo(entry)
    if (entry.fileID) then
        Editor.ShowImportExportWindow(nil, "Model\nName: ".. entry.N .."\nFileID: " .. entry.fileID);
    elseif(entry.displayID) then
        Editor.ShowImportExportWindow(nil, "Creature\nName: ".. entry.N .."\nDisplayID: " .. entry.displayID);
    end
end

function AB.GridAddToCollection(entry)
    AB.OnChangeTab(3);
    AB.entryToAddToCollection = { fileID = entry.fileID or 0, displayID = entry.displayID or 0 };
end

function AB.GridLoad(entry)
    AB.OnThumbnailDoubleClick(entry.ID, entry.N);
end

function AB.GridCollectionRemove(entry)
    if (not AB.selectedCollection) then
        return;
    end

    for i = 1, #AB.selectedCollection.items, 1 do
        if (entry.displayID and entry.displayID ~= 0) then
            if (entry.displayID == AB.selectedCollection.items[i].displayID) then
                table.remove(scenemachine_collections[AB.selectedCollectionIndex].items, i);
                AB.gridList:SetData(AB.BuildCollectionData(AB.selectedCollection));
                return;
            end
        end
        if (entry.fileID and entry.fileID ~= 0) then
            if (entry.fileID == AB.selectedCollection.items[i].fileID) then
                table.remove(scenemachine_collections[AB.selectedCollectionIndex].items, i);
                AB.gridList:SetData(AB.BuildCollectionData(AB.selectedCollection));
                return;
            end
        end
    end
end

function AB.CreateGridView(xMin, yMin, xMax, yMax, parent, startLevel)
    AB.gridList = UI.PooledGridScrollList:NewTLBR(xMin, yMin, xMax, yMax, parent);
    AB.gridList:SetFrameLevel(startLevel + 2);
    AB.gridList:SetItemTemplate(
		{
            width = 94,
			height = 94 + 15,
			buildItem = function(item)
				-- main button --
				item.components[1] = UI.Button:NewAP(item:GetFrame(), "");
                item.components[1]:SetFrameLevel(startLevel + 3);
                item.components[1]:GetFrame():RegisterForDrag("LeftButton");
                item.components[1]:GetFrame():RegisterForClicks("LeftButtonUp", "RightButtonUp");
                item.components[1]:SetClipsChildren(true);

				-- name text --
				item.components[4] = UI.Label:NewBLBR(10, 0, -10, 0, 30, item.components[1]:GetFrame(), "", 9);
                item.components[4]:GetFrame().text:SetMaxLines(2);
                item.components[4]:GetFrame().text:SetNonSpaceWrap(true);
                item.components[4]:SetFrameLevel(startLevel + 4);
                
                -- on drag --
                item.components[1]:GetFrame():SetScript("OnDragStart", function (self, button, down)
                    AB.OnThumbnailStartDrag(item, item.ID);
                end);

                -- on double click --
                item.components[1]:GetFrame():SetScript("OnDoubleClick", function (self, button, down)
                    if (button == "LeftButton") then
                        AB.OnThumbnailDoubleClick(item.ID, item.components[4]:GetText());
                    end
                end);
            
                -- image --
                item.components[3] = UI.ImageBox:NewTLBR(15, -15, -15, 30, item.components[1]:GetFrame(), Resources.textures["FolderIcon"]);

                -- model --
                item.components[2] = CreateFrame("PlayerModel", "thumbnail_model_frame", item.components[1]:GetFrame());
                item.components[2]:SetAllPoints(item.components[1]:GetFrame());
                item.components[2]:SetCustomCamera(1);
			end,
			refreshItem = function(entry, item, index)
                -- on click --
                item.components[1]:GetFrame():SetScript("OnClick", function (self, button, down)
                    if (button == "LeftButton") then
                        AB.selectedGridViewItem = item;
                        AB.gridList:RefreshStatic();
                    elseif (button == "RightButton") then
                        local scale = SceneMachine.mainWindow:GetEffectiveScale();
                        local rx = Input.mouseXRaw / scale - SceneMachine.mainWindow:GetLeft();
                        local ry = Input.mouseYRaw / scale - SceneMachine.mainWindow:GetTop();
                        
                        if (entry.fileID or entry.displayID) then
                            local menuOptions = {
                                [1] = { ["Name"] = L["LOAD"],
                                        ["Action"] = function() AB.GridLoad(entry) end },
                                [2] = { ["Name"] = L["AB_RMB_FILE_INFO"],
                                        ["Action"] = function() AB.GridShowFileInfo(entry) end },
                            };

                            if (entry.collectionItem) then
                                menuOptions[#menuOptions + 1] = { ["Name"] = L["DELETE"],
                                        ["Action"] = function() AB.GridCollectionRemove(entry) end }
                            else
                                menuOptions[#menuOptions + 1] = { ["Name"] = L["AB_RMB_ADD_TO_COLLECTION"],
                                        ["Action"] = function() AB.GridAddToCollection(entry) end }
                            end
                            SceneMachine.mainWindow:PopupWindowMenu(rx * scale, ry * scale, menuOptions);
                        end
                    end
                end);

				-- object name text --
				item.components[4]:SetText(entry["N"]);

                -- object ID --
                item.ID = entry.ID;
                item.dataIndex = index;

                item.components[2].displayID = nil;
                item.components[2].fileID = nil;

                -- has model (file)
                if (entry.fileID) then
                    item.components[3]:Hide();
                    item.components[2]:Show();
                    if (item.components[2].fileID ~= entry.fileID) then
                        item.components[2]:SetModel(entry.fileID);
                        item.components[2].fileID = entry.fileID;
                        item.components[2].displayID = nil;
                    end
                -- has creature (displayID)
                elseif (entry.displayID) then
                    item.components[3]:Hide();
                    item.components[2]:Show();
                    if (item.components[2].displayID ~= entry.displayID) then
                        item.components[2]:SetDisplayInfo(entry.displayID);
                        item.components[2].displayID = entry.displayID;
                        item.components[2].fileID = nil;
                    end
                -- doesn't have model (folder)
                else
                    item.components[3]:Show();
                    item.components[2]:Hide();
                    item.components[2].displayID = nil;
                    item.components[2].fileID = nil;
                end

                if (item == AB.selectedGridViewItem) then
					item.components[1]:SetColor(UI.Button.State.Normal, 0, 0.4765, 0.7968, 1);
				else
					item.components[1]:SetColor(UI.Button.State.Normal, 0.1757, 0.1757, 0.1875, 1);
				end
			end,
            clearItem = function(item)
                item.components[2]:ClearModel();
            end
	    }
    );
end

function AB.ClearBreadcrumb()
    AB.breadcrumb = {};
    table.insert(AB.breadcrumb, AB.currentDirectory);
end

function AB.UpOneFolder()
    if (#searchData > 0) then
        -- clear search
        AB.searchBar:SetText("");
        AB.SearchModelList("");
        AB.gridList:Refresh(0);
        AB.gridList:SetPosition(0);
    else
        local pos = table.getn(AB.breadcrumb) - 1;

        if pos == 0 then return end

        AB.currentDirectory = AB.breadcrumb[pos];
        table.remove(AB.breadcrumb, pos + 1);
        AB.selectedGridViewItem = nil;
        AB.gridList:SetData(AB.BuildFolderData(AB.currentDirectory));
        AB.RefreshBreadcrumb();
    end
end

function AB.BuildFolderData(dir)
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

function AB.BuildCreatureData()
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

function AB.BuildCollectionData(collectionData)
    local data = {};
    local idx = 1;

    for c in pairs(collectionData.items) do
        local item = collectionData.items[c];
        local name = "Item";
        local fileID = nil;
        local displayID = nil;
        local ID = nil;
        -- fetch name from displayID
        if (item.displayID and item.displayID ~= 0) then
            displayID = item.displayID;
            ID = displayID;
            for creatureID, displayID in pairs(SceneMachine.creatureToDisplayID) do
                if (displayID == item.displayID) then
                    name = SceneMachine.creatureData[creatureID];
                end
            end
        end

        -- fetch name from fileID
        if (item.fileID and item.fileID ~= 0) then
            fileID = item.fileID;
            ID = fileID;
            name = AB.GetFileName(item.fileID);
        end

        data[idx] = { N = name, fileID = fileID, displayID = displayID, ID = ID, collectionItem = true };
        idx = idx + 1;
    end

    return data;
end

function AB.BuildSearchDataRecursive(value, dir)

    -- File Scan
    if (dir["FN"] ~= nil) then
        local fileCount = #dir["FN"];
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
        local directoryCount = #dir["D"];
        for i = 1, directoryCount, 1 do
            AB.BuildSearchDataRecursive(value, dir["D"][i]);
        end
    end
end

function AB.BuildCreatureSearchData(value)
    for c in pairs(SceneMachine.creatureToDisplayID) do
        local d = SceneMachine.creatureToDisplayID[c];
        local n = SceneMachine.creatureData[c];
        if (string.find(n:lower(), value)) then
            searchData[#searchData + 1] = { N = n, displayID = d, ID = c };
        end
    end
end

function AB.RefreshBreadcrumb()
 
    for c = 1, #AB.toolbar.modelsGroup.components, 1 do
        local component = AB.toolbar.modelsGroup.components[c];

        if (component.type == "Label") then
            if (component.name == "Breadcrumb") then
                --AB.toolbar.modelsGroup.components[c]:SetOptions(projectNames);
                --AB.toolbar.modelsGroup.components[c]:ShowSelectedName(selectedName);
                if (#searchData > 0) then
                    component:SetText(string.format(L["AB_RESULTS"], #searchData));
                else
                    local str = "";
                    for i=2, #AB.breadcrumb, 1 do
                        if AB.breadcrumb[i] ~= nil then
                            str = str .. ">" .. AB.breadcrumb[i]["N"];
                        end
                    end
                    component:SetText(str);
                end
            end
        end
    end
end

function AB.OnThumbnailDoubleClick(ID, name)
    if (AB.dataSource == "Models") then
        if (#searchData > 0) then
            -- File Scan
            local fileCount = #searchData;
            for i = 1, fileCount, 1 do
                local fileID = searchData[i].fileID;
                if (fileID == ID) then
                    local fileName = searchData[i].N;
                    AB.LoadModel(fileID, fileName);
                    return;
                end
            end
        else
            -- Directory scan
            if (AB.currentDirectory["D"] ~= nil) then
                local directoryCount = #AB.currentDirectory["D"]
                for i = 1, directoryCount, 1 do
                    local dirName = AB.currentDirectory["D"][i]["N"];
                    if (dirName == name) then
                        AB.currentPage = 1;
                        AB.currentDirectory = AB.currentDirectory["D"][i];
                        AB.selectedGridViewItem = nil;
                        table.insert(AB.breadcrumb, AB.currentDirectory);
                        AB.RefreshBreadcrumb();
                        AB.gridList:SetData(AB.BuildFolderData(AB.currentDirectory));
                        return;
                    end
                end
            end

            -- File Scan
            if (AB.currentDirectory["FN"] ~= nil) then
                local fileCount = #AB.currentDirectory["FN"];
                for i = 1, fileCount, 1 do
                    local fileID = AB.currentDirectory["FI"][i];
                    if (fileID == ID) then
                        local fileName = AB.currentDirectory["FN"][i];
                        AB.LoadModel(fileID, fileName);
                        return;
                    end
                end
            end
        end
    end

    if (AB.dataSource == "Creatures") then
        if (#searchData > 0) then
            -- File Scan
            local fileCount = #searchData;
            for i = 1, fileCount, 1 do
                local creatureID = searchData[i].ID;
                local displayID = SceneMachine.creatureToDisplayID[creatureID];
                local name = SceneMachine.creatureData[creatureID];
                if (ID == creatureID) then
                    AB.LoadCreature(displayID, name);
                    return;
                end
            end
        else
            for c in pairs(SceneMachine.creatureToDisplayID) do
                local creatureID = c;
                local displayID = SceneMachine.creatureToDisplayID[creatureID];
                local name = SceneMachine.creatureData[creatureID];
                if (ID == creatureID) then
                    AB.LoadCreature(displayID, name);
                    return;
                end
            end
        end

    end

    if (AB.dataSource == "Collections") then
        if (AB.selectedCollection) then
            for i = 1, #AB.selectedCollection.items, 1 do
                local item = AB.selectedCollection.items[i];
                if (item.displayID == ID) then
                    local name = "Creature";
                    for creatureID1, displayID1 in pairs(SceneMachine.creatureToDisplayID) do
                        if (displayID1 == item.displayID) then
                            name = SceneMachine.creatureData[creatureID1];
                        end
                    end
                    AB.LoadCreature(item.displayID, name);
                    return;
                elseif (item.fileID == ID) then
                    AB.LoadModel(item.fileID);
                    return;
                end
            end
        end
    end
end

function AB.LoadModel(fileID, name)
    local name = name or AB.GetFileName(fileID);
    AB.LoadObject(fileID, name, SceneMachine.GameObjects.Object.Type.Model);
end

function AB.LoadCreature(displayID, name)
    AB.LoadObject(displayID, name, SceneMachine.GameObjects.Object.Type.Creature);
end

function AB.LoadObject(ID, name, type)
    local objectHierarchyBefore = Scene.RawCopyObjectHierarchy(SM.loadedScene:GetObjectHierarchy());

    local object = nil;
    if (type == SceneMachine.GameObjects.Object.Type.Model) then
        object = SM.loadedScene:CreateObject(ID, name or "Model", 0, 0, 0);
    elseif (type == SceneMachine.GameObjects.Object.Type.Creature) then
        object = SM.loadedScene:CreateCreature(ID, name or "Creature", 0, 0, 0);
    end

    if (object) then
        -- calculate a good position for the new object
        local xMin, yMin, zMin, xMax, yMax, zMax = object:GetActiveBoundingBox();
		local radius = math.max(xMax, math.max(yMax, zMax));
		local dist = radius / (math.sin(Camera.fov) * 0.3);
        local vector = Vector3:New();
        vector:SetVector3(Camera.forward);
		vector:Scale(dist);
        vector:Add(Camera.position);
        object:SetPositionVector3(vector);

        Editor.StartAction(Actions.Action.Type.CreateObject, { object }, objectHierarchyBefore);
        SM.selectedObjects = { object };
        Editor.lastSelectedType = Editor.SelectionType.Object;
        SH.RefreshHierarchy();
        OP.Refresh();
        local objectHierarchyAfter = Scene.RawCopyObjectHierarchy(SM.loadedScene:GetObjectHierarchy());
        Editor.FinishAction(objectHierarchyAfter);
    end
end

function AB.OnThumbnailStartDrag(item, ID)
    AB.draggingItem = true;
	AB.draggableItem:Show();
    AB.draggableItem:SetWidth(item:GetWidth());
    AB.draggableItem:SetHeight(item:GetHeight());
    item.components[2]:SetParent(AB.draggableItem:GetFrame());
    item.components[2]:SetAllPoints(AB.draggableItem:GetFrame());
    AB.itemBeingDragged = item;

    if (AB.dataSource == "Models") then
        if (#searchData > 0) then
            -- File Scan
            local fileCount = #searchData;
            for i = 1, fileCount, 1 do
                local fileID = searchData[i].fileID;
                if (fileID == ID) then
                    local fileName = searchData[i].N;
                    local objectHierarchyBefore = Scene.RawCopyObjectHierarchy(SM.loadedScene:GetObjectHierarchy());
                    local object = SM.loadedScene:CreateObject(fileID, fileName, 0, 0, 0);
                    AB.StartDraggingObjectFromUI(object, objectHierarchyBefore)
                    return;
                end
            end
        else
            -- File Scan
            if (AB.currentDirectory["FN"] ~= nil) then
                local fileCount = #AB.currentDirectory["FN"];
                for i = 1, fileCount, 1 do
                    local fileID = AB.currentDirectory["FI"][i];
                    if fileID == ID then
                        local fileName = AB.currentDirectory["FN"][i];
                        local objectHierarchyBefore = Scene.RawCopyObjectHierarchy(SM.loadedScene:GetObjectHierarchy());
                        local object = SM.loadedScene:CreateObject(fileID, fileName, 0, 0, 0);
                        AB.StartDraggingObjectFromUI(object, objectHierarchyBefore)
                        return;
                    end
                end
            end
        end
    end

    if (AB.dataSource == "Creatures") then
        if (#searchData > 0) then
            -- File Scan
            local fileCount = #searchData;
            for i = 1, fileCount, 1 do
                local creatureID = searchData[i].ID;
                if (creatureID == ID) then
                    local name = searchData[i].N;
                    local displayID = SceneMachine.creatureToDisplayID[creatureID];
                    local objectHierarchyBefore = Scene.RawCopyObjectHierarchy(SM.loadedScene:GetObjectHierarchy());
                    local object = SM.loadedScene:CreateCreature(displayID, name or "Creature", 0, 0, 0);
                    AB.StartDraggingObjectFromUI(object, objectHierarchyBefore)
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
                    local objectHierarchyBefore = Scene.RawCopyObjectHierarchy(SM.loadedScene:GetObjectHierarchy());
                    local object = SM.loadedScene:CreateCreature(displayID, name or "Creature", 0, 0, 0);
                    AB.StartDraggingObjectFromUI(object, objectHierarchyBefore)
                    return;
                end
            end
        end
    end

    if (AB.dataSource == "Collections") then
        if (AB.selectedCollection) then
            for i = 1, #AB.selectedCollection.items, 1 do
                local item = AB.selectedCollection.items[i];
                if (item.displayID == ID) then
                    local name = "Creature";
                    for creatureID, displayID in pairs(SceneMachine.creatureToDisplayID) do
                        if (displayID == item.displayID) then
                            name = SceneMachine.creatureData[creatureID];
                        end
                    end
                    local objectHierarchyBefore = Scene.RawCopyObjectHierarchy(SM.loadedScene:GetObjectHierarchy());
                    local object = SM.loadedScene:CreateCreature(item.displayID, name or "Creature", 0, 0, 0);
                    AB.StartDraggingObjectFromUI(object, objectHierarchyBefore)
                    return;
                elseif (item.fileID == ID) then
                    local name = AB.GetFileName(item.fileID);
                    local objectHierarchyBefore = Scene.RawCopyObjectHierarchy(SM.loadedScene:GetObjectHierarchy());
                    local object = SM.loadedScene:CreateObject(item.fileID, name, 0, 0, 0);
                    AB.StartDraggingObjectFromUI(object, objectHierarchyBefore);
                    return;
                end
            end
        end
    end
end

function AB.StartDraggingObjectFromUI(object, objectHierarchyBefore)
    Editor.StartAction(Actions.Action.Type.CreateObject, { object }, objectHierarchyBefore);
    local xMin, yMin, zMin, xMax, yMax, zMax = object:GetActiveBoundingBox();
    local mouseRay = Camera.GetMouseRay();
    local initialPosition = mouseRay:PlaneIntersection(Vector3.zero, GM.up) or Vector3.zero;
    object:SetPosition(initialPosition.x, initialPosition.y, initialPosition.z + ((zMax - zMin) / 2));
    SM.selectedObjects = { object };
    Editor.lastSelectedType = Editor.SelectionType.Object;
    SH.RefreshHierarchy();
    OP.Refresh();
    Input.mouseState.LMB = true;
    Input.mouseState.isDraggingAssetFromUI = true;
    GM.activeTransformGizmo = Gizmo.TransformType.Move;
    GM.highlightedAxis = Gizmo.Axis.XY;
    GM.selectedAxis = Gizmo.Axis.XY;
    GM.OnLMBDown(Input.mouseX, Input.mouseY, false);
end

function AB.OnThumbnailFinishedDrag()
    AB.draggingItem = false;
    AB.draggableItem:Hide();

    AB.itemBeingDragged.components[2]:SetParent(AB.itemBeingDragged.components[1]:GetFrame());
    AB.itemBeingDragged.components[2]:SetPoint("TOPLEFT", AB.itemBeingDragged.components[1]:GetFrame(), "TOPLEFT", 0, 0);
    AB.itemBeingDragged.components[2]:SetPoint("BOTTOMRIGHT", AB.itemBeingDragged.components[1]:GetFrame(), "BOTTOMRIGHT", 0, 0);

    AB.gridList:RefreshStatic();
end

function AB.SearchModelList(value)
    if (value == nil or value == "") then
        -- clear search
        searchData = {};
        if (AB.dataSource == "Models") then
            AB.gridList:SetData(AB.BuildFolderData(AB.currentDirectory));
        elseif (AB.dataSource == "Creatures") then
            AB.gridList:SetData(AB.BuildCreatureData());
        end
    else
        -- search
        searchData = {};
        if (AB.dataSource == "Models") then
            AB.BuildSearchDataRecursive(value:lower(), SceneMachine.modelData[1]);
        elseif (AB.dataSource == "Creatures") then
            AB.BuildCreatureSearchData(value:lower());
        end
        AB.gridList:SetData(searchData);
    end
    AB.RefreshBreadcrumb();
end

function AB.Button_ExportCollection(collectionIndex)
   
    if (not scenemachine_collections[collectionIndex]) then
        return;
    end

    local collection = scenemachine_collections[collectionIndex];
    local collectionString = AB.ExportCollectionForPrint(collection);

    Editor.ShowImportExportWindow(nil, collectionString);
end

function AB.ExportCollectionForPrint(collection)
    local collectionData = AB.ExportCollection(collection);
    local serialized = SceneMachine.Libs.LibSerialize:Serialize(collectionData);
    local compressed = SceneMachine.Libs.LibDeflate:CompressDeflate(serialized);
    local chatEncoded = SceneMachine.Libs.LibDeflate:EncodeForPrint(compressed);
    return chatEncoded;
end

function AB.ExportCollection(collection)
    local collectionData = {};

    collectionData.version = AB.COLLECTION_DATA_VERSION;
    collectionData.name = collection.name;
    collectionData.items = {};

    -- transfer items --
    if (#collection.items > 0) then
        for i = 1, #collection.items, 1 do
            collectionData.items[i] = {};
            if (collection.items[i].displayID) then
                collectionData.items[i].displayID = collection.items[i].displayID;
            end
            if (collection.items[i].fileID) then
                collectionData.items[i].fileID = collection.items[i].fileID;
            end
        end
    end

    return collectionData;
end

function AB.Button_ImportCollection()
    Editor.ShowImportExportWindow(AB.ImportCollectionFromPrint, "");
end

function AB.ImportCollectionFromPrint(chatEncoded)
    local decoded = SceneMachine.Libs.LibDeflate:DecodeForPrint(chatEncoded);
    if (not decoded) then print(L["DECODE_FAILED"]); return end
    local decompressed = SceneMachine.Libs.LibDeflate:DecompressDeflate(decoded);
    if (not decompressed) then print(L["DECOMPRESS_FAILED"]); return end
    local success, collectionData = SceneMachine.Libs.LibSerialize:Deserialize(decompressed);
    if (not success) then print(L["DESERIALIZE_FAILED"]); return end

    if(collectionData.version > AB.COLLECTION_DATA_VERSION) then
        -- handle newer version
        print(L["DATA_VERSION_TOO_NEW"]);
    else
        -- handle known versions
        if (collectionData.version == 1) then
            AB.ImportVersion1Collection(collectionData);
        end
    end
end

function AB.ImportVersion1Collection(collectionData)
    local index = AB.NewCollection(collectionData.name);
    local collection = scenemachine_collections[index];

    if (#collectionData.items > 0) then
        for i = 1, #collectionData.items, 1 do
            if (collectionData.items[i].displayID) then
                AB.AddDisplayIDToCollection(collectionData.items[i].displayID, index);
            end
            if (collectionData.items[i].fileID) then
                AB.AddFileIDToCollection(collectionData.items[i].fileID, index);
            end
        end
    end
end