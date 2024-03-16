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
local searchData = {};
local L = Editor.localization;
local Net = SceneMachine.Network;
local Actions = SceneMachine.Actions;

local c1 = { 0.1757, 0.1757, 0.1875 };
local c2 = { 0.242, 0.242, 0.25 };
local c3 = { 0, 0.4765, 0.7968 };
local c4 = { 0.1171, 0.1171, 0.1171 };

AssetBrowser.dataSource = "Models";
AssetBrowser.selectedCollection = nil;
AssetBrowser.selectedCollectionIndex = -1;
AssetBrowser.selectedGridViewItem = nil;
AssetBrowser.entryToAddToCollection = nil;
local tabButtonHeight = 20;

function AssetBrowser.Create(parent, w, h, startLevel)

    AssetBrowser.tabGroup = UI.TabGroup:New(0, 0, 100, tabButtonHeight, parent, "TOPLEFT", "TOPLEFT", startLevel + 2, false);
    AssetBrowser.tabGroup:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, 0);
    --AssetBrowser.tabGroup.dropdownButton.tooltip = L["AM_TT_LIST"];
    --AssetBrowser.tabGroup.addButton.tooltip = L["AM_TT_ADDTIMELINE"];

	AssetBrowser.tabGroup:SetItemTemplate(
    {
        height = tabButtonHeight,
        lmbAction = function(index)
            AssetBrowser.OnChangeTab(index);
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

    AssetBrowser.tabGroup:SetData({
        { name = "Models" },
        { name = "Creatures" },
        { name = "Collections" },
        { name = "Debug" },
     });

    AssetBrowser.tabs = {};
    AssetBrowser.tabs[1] = UI.Rectangle:New(0, -20, w, h, parent, "TOPRIGHT", "TOPRIGHT", 0, 0, 0, 0.0);
    AssetBrowser.tabs[1]:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 0, 0);
    AssetBrowser.tabs[1]:SetFrameLevel(startLevel + 3);
    AssetBrowser.tabs[2] = UI.Rectangle:New(0, -20, w, h, parent, "TOPRIGHT", "TOPRIGHT", 0, 0, 0, 0.0);
    AssetBrowser.tabs[2]:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 0, 0);
    AssetBrowser.tabs[2]:SetFrameLevel(startLevel + 3);
    AssetBrowser.tabs[3] = UI.Rectangle:New(0, -20, w, h, parent, "TOPRIGHT", "TOPRIGHT", 0, 0, 0, 0.0);
    AssetBrowser.tabs[3]:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 0, 0);
    AssetBrowser.tabs[3]:SetFrameLevel(startLevel + 3);
    AssetBrowser.tabs[4] = UI.Rectangle:New(0, -20, w, h, parent, "TOPRIGHT", "TOPRIGHT", 0, 0, 0, 0.0);
    AssetBrowser.tabs[4]:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 0, 0);
    AssetBrowser.tabs[4]:SetFrameLevel(startLevel + 3);

    AssetBrowser.RefreshTabs();

    AssetBrowser.CreateToolbar(AssetBrowser.tabs[1]:GetFrame(), -Editor.pmult, w, startLevel + 10);
    AssetBrowser.CreateSearchBar(0, -30 - Editor.pmult, 0, 0, AssetBrowser.tabs[1]:GetFrame(), startLevel + 3);
    AssetBrowser.CreateGridView(0, -50 - Editor.pmult, 0, 0, AssetBrowser.tabs[1]:GetFrame(), startLevel + 3);
    AssetBrowser.CreateCollectionsTab(0, -30 - Editor.pmult, AssetBrowser.tabs[3]:GetFrame(), startLevel + 3);
    AssetBrowser.CreateDebugTab(AssetBrowser.tabs[4]:GetFrame(), 300);

	AssetBrowser.gridList:MakePool();
    AssetBrowser.currentDirectory = SceneMachine.modelData[1];
    AssetBrowser.gridList:SetData(AssetBrowser.BuildFolderData(AssetBrowser.currentDirectory));
    AssetBrowser.breadcrumb = {};
    table.insert(AssetBrowser.breadcrumb, AssetBrowser.currentDirectory);
    AssetBrowser.OnChangeTab(1);

    AssetBrowser.LoadCollections();

    -- DEBUG --
    --AssetBrowser.OnThumbnailDoubleClick(nil, "World");
    --AssetBrowser.OnThumbnailDoubleClick(nil, "Expansion07");
    --AssetBrowser.OnThumbnailDoubleClick(nil, "Doodads");
    --AssetBrowser.OnThumbnailDoubleClick(nil, "Kultiraszone");
    --AssetBrowser.OnChangeTab(3);
end

function AssetBrowser.LoadCollections()

    if (not scenemachine_collections) then
        AssetBrowser.CreateDefaultCollection();
    end

    AssetBrowser.collectionScrollList:SetData(scenemachine_collections);
end

function AssetBrowser.CreateDefaultCollection()
    scenemachine_collections = {};

    local index = AssetBrowser.NewCollection("Base Floors");
    AssetBrowser.AddFileIDToCollection(947328, index);
    AssetBrowser.AddFileIDToCollection(1093938, index);
    AssetBrowser.AddFileIDToCollection(1247674, index);
    AssetBrowser.AddFileIDToCollection(1247671, index);
    AssetBrowser.AddFileIDToCollection(948613, index);
    AssetBrowser.AddFileIDToCollection(4186667, index);
    AssetBrowser.AddFileIDToCollection(306960, index);
    AssetBrowser.AddFileIDToCollection(194010, index);
    AssetBrowser.AddFileIDToCollection(3656582, index);
    AssetBrowser.AddFileIDToCollection(657869, index);

    local index = AssetBrowser.NewCollection("Point Lights");
    AssetBrowser.AddFileIDToCollection(193039, index);
    AssetBrowser.AddFileIDToCollection(1250693, index);
    AssetBrowser.AddFileIDToCollection(1376353, index);
    AssetBrowser.AddFileIDToCollection(1376386, index);
    AssetBrowser.AddFileIDToCollection(1398885, index);
    AssetBrowser.AddFileIDToCollection(1398890, index);
    AssetBrowser.AddFileIDToCollection(1398891, index);
    AssetBrowser.AddFileIDToCollection(1398892, index);
    AssetBrowser.AddFileIDToCollection(1398893, index);
    AssetBrowser.AddFileIDToCollection(1398894, index);
    AssetBrowser.AddFileIDToCollection(1375444, index);
    AssetBrowser.AddFileIDToCollection(1303476, index);
end

function AssetBrowser.NewCollection(name)
    local index = #scenemachine_collections + 1;
    scenemachine_collections[index] = {
        name = name,
        items = {},
    };

    AssetBrowser.collectionScrollList:SetData(scenemachine_collections);

    return index;
end

function AssetBrowser.RenameSelectedCollection(name)
    scenemachine_collections[AssetBrowser.selectedCollectionIndex].name = name;
    AssetBrowser.collectionScrollList:SetData(scenemachine_collections);
end

function AssetBrowser.RemoveCollection(collectionIndex)
    if (collectionIndex < 0) then
        return;
    end

    if (scenemachine_collections[collectionIndex]) then

        if (#scenemachine_collections[collectionIndex].items > 0) then
            -- ask first
            Editor.OpenMessageBox(SceneMachine.mainWindow:GetFrame(), L["AM_MSG_REMOVE_COLLECTION_TITLE"], L["AB_MSG_REMOVE_COLLECTION_MESSAGE"], true, true, function() AssetBrowser.RemoveCollection_internal(collectionIndex); end, function() end);
        else
            AssetBrowser.RemoveCollection_internal(collectionIndex);
        end
    end
end

function AssetBrowser.RemoveCollection_internal(collectionIndex)    -- don't use directly
    table.remove(scenemachine_collections, collectionIndex);
    AssetBrowser.collectionScrollList:SetData(scenemachine_collections);
    AssetBrowser.selectedCollectionIndex = -1;
    AssetBrowser.selectedGridViewItem = nil;
    AssetBrowser.gridList:SetData(nil);
end

function AssetBrowser.AddFileIDToCollection(fileID, collectionIndex)
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

function AssetBrowser.AddDisplayIDToCollection(displayID, collectionIndex)
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

function AssetBrowser.AddObjectsToCollection(objects, collectionIndex)
    if (not objects) then
        return;
    end

    for i = 1, #objects, 1 do
        AssetBrowser.AddObjectToCollection(objects[i], collectionIndex);
    end
end

function AssetBrowser.AddObjectToCollection(object, collectionIndex)
    if (not object) then
        return;
    end

    if (collectionIndex < 0) then
        return;
    end

    -- switch based on object type
    if (object.type == SceneMachine.GameObjects.Object.Type.Model) then
        AssetBrowser.AddFileIDToCollection(object.fileID, collectionIndex)
    elseif(object.type == SceneMachine.GameObjects.Object.Type.Creature) then
        AssetBrowser.AddDisplayIDToCollection(object.displayID, collectionIndex)
    end

    AssetBrowser.gridList:SetData(AssetBrowser.BuildCollectionData(AssetBrowser.selectedCollection));
end

function AssetBrowser.RemoveSelectedObjectFromCollection()
    if (not AssetBrowser.selectedCollection) then
        return;
    end

    if (not AssetBrowser.selectedGridViewItem) then
        return;
    end

    table.remove(scenemachine_collections[AssetBrowser.selectedCollectionIndex].items, AssetBrowser.selectedGridViewItem.dataIndex);
    AssetBrowser.gridList:SetData(AssetBrowser.BuildCollectionData(AssetBrowser.selectedCollection));
end

function AssetBrowser.OpenCollection(index)
    AssetBrowser.selectedCollection = scenemachine_collections[index];
    AssetBrowser.selectedCollectionIndex = index;
    AssetBrowser.selectedGridViewItem = nil;
    AssetBrowser.collectionScrollList:RefreshStatic();

    AssetBrowser.gridList:SetData(AssetBrowser.BuildCollectionData(AssetBrowser.selectedCollection));

    if (AssetBrowser.entryToAddToCollection) then
        if (AssetBrowser.entryToAddToCollection.displayID ~= 0) then
            AssetBrowser.AddDisplayIDToCollection(AssetBrowser.entryToAddToCollection.displayID, index);
        elseif (AssetBrowser.entryToAddToCollection.fileID ~= 0) then
            AssetBrowser.AddFileIDToCollection(AssetBrowser.entryToAddToCollection.fileID, index);
        end
        AssetBrowser.gridList:SetData(AssetBrowser.BuildCollectionData(AssetBrowser.selectedCollection));
        AssetBrowser.entryToAddToCollection = nil;
    end
end

function AssetBrowser.GetFileName(fileID)
    return AssetBrowser.GetFileNameRecursive(fileID, SceneMachine.modelData[1]);
end

function AssetBrowser.GetFileNameRecursive(value, dir)
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
            local n = AssetBrowser.GetFileNameRecursive(value, dir["D"][i]);
            if (n) then return n; end
        end
    end

    return nil;
end

function AssetBrowser.RefreshTabs()
    AssetBrowser.tabGroup:Refresh(0);
end

function AssetBrowser.OnChangeTab(idx)
    AssetBrowser.tabGroup.selectedIndex = idx;
    AssetBrowser.selectedGridViewItem = nil;
    AssetBrowser.entryToAddToCollection = nil;
    local tabFrame = AssetBrowser.tabs[idx]:GetFrame();
    for i = 1, #AssetBrowser.tabs, 1 do
        AssetBrowser.tabs[i]:Hide();
    end
    AssetBrowser.toolbar:Hide();
    AssetBrowser.searchBarBG:Hide();
    AssetBrowser.gridList.frame:Hide();

    if (idx == 1) then
        -- Models --
        AssetBrowser.toolbar:Show();
        AssetBrowser.toolbar:SetParent(tabFrame);
        AssetBrowser.toolbar.modelsGroup:Show();
        AssetBrowser.toolbar.collectionsGroup:Hide();
        tabFrame:Show();
        AssetBrowser.searchBarBG:Show();
        AssetBrowser.searchBarBG:SetParent(tabFrame);
        AssetBrowser.searchBarBG:ClearAllPoints();
        AssetBrowser.searchBarBG:SetPoint("TOPLEFT", tabFrame, "TOPLEFT", 0, -30 - Editor.pmult);
        AssetBrowser.searchBarBG:SetPoint("BOTTOMRIGHT", tabFrame, "BOTTOMRIGHT", 0, 0);
        AssetBrowser.currentDirectory = SceneMachine.modelData[1];
        AssetBrowser.gridList.frame:Show();
        AssetBrowser.gridList.frame:SetParent(tabFrame);
        AssetBrowser.gridList.frame:ClearAllPoints();
        AssetBrowser.gridList.frame:SetPoint("TOPLEFT", tabFrame, "TOPLEFT", 0, -50 - Editor.pmult);
        AssetBrowser.gridList.frame:SetPoint("BOTTOMRIGHT", tabFrame, "BOTTOMRIGHT", 0, 0);
        AssetBrowser.gridList:SetFrameLevel(tabFrame:GetFrameLevel() + 20);
        AssetBrowser.gridList:SetData(AssetBrowser.BuildFolderData(AssetBrowser.currentDirectory));
        AssetBrowser.ClearBreadcrumb();
        AssetBrowser.RefreshBreadcrumb();
        AssetBrowser.dataSource = "Models";
    elseif (idx == 2) then
        -- Creatures --
        tabFrame:Show();
        AssetBrowser.searchBarBG:Show();
        AssetBrowser.searchBarBG:SetParent(tabFrame);
        AssetBrowser.searchBarBG:ClearAllPoints();
        AssetBrowser.searchBarBG:SetPoint("TOPLEFT", tabFrame, "TOPLEFT", 0, 0);
        AssetBrowser.searchBarBG:SetPoint("BOTTOMRIGHT", tabFrame, "BOTTOMRIGHT", 0, 0);
        AssetBrowser.gridList.frame:Show();
        AssetBrowser.gridList:SetParent(tabFrame);
        AssetBrowser.gridList:ClearAllPoints();
        AssetBrowser.gridList:SetPoint("TOPLEFT", tabFrame, "TOPLEFT", 0, -30 - Editor.pmult);
        AssetBrowser.gridList:SetPoint("BOTTOMRIGHT", tabFrame, "BOTTOMRIGHT", 0, 0);
        AssetBrowser.gridList:SetFrameLevel(tabFrame:GetFrameLevel() + 20);
        AssetBrowser.gridList:SetData(AssetBrowser.BuildCreatureData());
        AssetBrowser.ClearBreadcrumb();
        AssetBrowser.RefreshBreadcrumb();
        AssetBrowser.dataSource = "Creatures";
    elseif (idx == 3) then
        -- Collections --
        tabFrame:Show();
        AssetBrowser.toolbar:Show();
        AssetBrowser.toolbar:SetParent(tabFrame);
        AssetBrowser.toolbar.modelsGroup:Hide();
        AssetBrowser.toolbar.collectionsGroup:Show();
        AssetBrowser.gridList.frame:Show();
        AssetBrowser.gridList:SetParent(AssetBrowser.collectionsBottomGroup:GetFrame());
        AssetBrowser.gridList:ClearAllPoints();
        AssetBrowser.gridList:SetPoint("TOPLEFT", AssetBrowser.collectionsBottomGroup:GetFrame(), "TOPLEFT", 0, 0);
        AssetBrowser.gridList:SetPoint("BOTTOMRIGHT", AssetBrowser.collectionsBottomGroup:GetFrame(), "BOTTOMRIGHT", 0, 0);
        AssetBrowser.gridList:SetFrameLevel(AssetBrowser.collectionsBottomGroup:GetFrame():GetFrameLevel() + 20);
        AssetBrowser.dataSource = "Collections";
        AssetBrowser.gridList:SetData(nil);
        AssetBrowser.selectedCollection = nil;
        AssetBrowser.selectedCollectionIndex = -1;
        AssetBrowser.collectionScrollList:RefreshStatic();
        --AssetBrowser.OpenCollection(1);
    elseif (idx == 4) then
        -- Debug --
        tabFrame:Show();
        AssetBrowser.dataSource = nil;
    end

    AssetBrowser.searchBar:SetText("");
    AssetBrowser.SearchModelList("");
    AssetBrowser.RefreshTabs();
end

function AssetBrowser.CreateCollectionsTab(x, y, parent, startLevel)
    AssetBrowser.collectionsBottomGroup = UI.Rectangle:New(0, 0, 100, scenemachine_settings.collectionsPanelH, parent, "BOTTOMRIGHT", "BOTTOMRIGHT",  0.1757, 0.1757, 0.1875, 1);
    AssetBrowser.collectionsBottomGroup:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 0, 6);
    AssetBrowser.collectionsBottomGroup:SetFrameLevel(startLevel);
    AssetBrowser.collectionsBottomGroup.frame:SetResizable(true);
    AssetBrowser.collectionsBottomGroup.frame:SetUserPlaced(true);
    AssetBrowser.collectionsBottomGroup.frame:SetResizeBounds(120, 20, 800, 500);

    AssetBrowser.collectionsSeparator = UI.Rectangle:New(0, 6, 100, 6, AssetBrowser.collectionsBottomGroup:GetFrame(), "TOPLEFT", "TOPLEFT", 1,1,1,0);
    AssetBrowser.collectionsSeparator:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, 0);
    AssetBrowser.collectionsSeparator:SetFrameLevel(startLevel + 10);
    AssetBrowser.collectionsSeparator:GetFrame():EnableMouse(true);
    AssetBrowser.collectionsSeparator:GetFrame():RegisterForDrag("LeftButton");
    AssetBrowser.collectionsSeparator:GetFrame():SetScript("OnDragStart", function()
        AssetBrowser.collectionsBottomGroup.frame:StartSizing("TOP");
        SetCursor(Resources.textures["CursorResizeV"]);
    end);
	AssetBrowser.collectionsSeparator:GetFrame():SetScript("OnDragStop", function()
        scenemachine_settings.collectionsPanelH = (AssetBrowser.collectionsBottomGroup:GetTop() - 6) - SceneMachine.mainWindow:GetBottom();
        AssetBrowser.collectionsBottomGroup.frame:StopMovingOrSizing();
        AssetBrowser.collectionsBottomGroup:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 0);
        AssetBrowser.collectionsBottomGroup:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 0, 6);
        ResetCursor();
    end);
    AssetBrowser.collectionsSeparator:GetFrame():SetScript('OnEnter', function() SetCursor(Resources.textures["CursorResizeV"]); end)
    AssetBrowser.collectionsSeparator:GetFrame():SetScript('OnLeave', function() ResetCursor(); end)

    AssetBrowser.collectionsTopGroup = UI.Rectangle:New(0, -30 - Editor.pmult, 100, 100, parent, "TOPLEFT", "TOPLEFT",  0, 0, 0, 0);
    AssetBrowser.collectionsTopGroup:SetPoint("BOTTOMRIGHT", AssetBrowser.collectionsSeparator:GetFrame(), "BOTTOMRIGHT", 0, 6);
	AssetBrowser.collectionsTopGroup:SetFrameLevel(startLevel);

    AssetBrowser.collectionScrollList = UI.PooledScrollList:New(1, -1, 100, 100, AssetBrowser.collectionsTopGroup:GetFrame(), "TOPLEFT", "TOPLEFT");
	AssetBrowser.collectionScrollList:SetPoint("BOTTOMRIGHT", AssetBrowser.collectionsTopGroup:GetFrame(), "BOTTOMRIGHT", 0, 0);
	AssetBrowser.collectionScrollList:SetFrameLevel(startLevel + 3);
	AssetBrowser.collectionScrollList:SetItemTemplate(
		{
			height = 20,
			buildItem = function(item)
				-- main button --
				item.components[1] = UI.Button:New(0, 0, 50, 18, item:GetFrame(), "CENTER", "CENTER", "");
				item.components[1]:ClearAllPoints();
				item.components[1]:SetAllPoints(item:GetFrame());

				-- object name text --
				item.components[2] = UI.Label:New(10, 0, 200, 18, item.components[1]:GetFrame(), "LEFT", "LEFT", "", 9);
			end,
			refreshItem = function(data, item, index)
				-- main button --
				item.components[1]:SetScript("OnClick", function() AssetBrowser.OpenCollection(index); end);
				if (data == AssetBrowser.selectedCollection) then
					item.components[1]:SetColor(UI.Button.State.Normal, 0, 0.4765, 0.7968, 1);
				else
					item.components[1]:SetColor(UI.Button.State.Normal, 0.1757, 0.1757, 0.1875, 1);
				end

				-- object name text --
				item.components[2]:SetText(data.name);
			end,
		});

	AssetBrowser.collectionScrollList:MakePool();
end

function AssetBrowser.CreateDebugTab(parent, w, h)
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
            SM.CreateObject(val, "Model", 0, 0, 0);
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
            SM.CreateCreature(val, "Creature", 0, 0, 0);
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
                SM.CreateCreature(creatureDisplayID, "Creature", 0, 0, 0);
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
        SM.CreateCharacter(0, 0, 0);
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
        for i = 1, #SM.loadedScene.objects, 1 do
            for j = 1, #dalaranIDs, 1 do
                if (SM.loadedScene.objects[i].fileID == dalaranIDs[j]) then
                    toDelete[#toDelete + 1] = SM.loadedScene.objects[i];
                end
            end
        end

        for i = 1, #toDelete, 1 do
            SM.DeleteObject_internal(toDelete[i]);
        end

        for i = 1, #dalaranIDs, 1 do
            local obj = SM.CreateObject(dalaranIDs[i], "Dalaran_" .. i, 0, 0, 0);
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
        --SM.ExportSceneForPrint(SM.loadedScene);
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
            SM.DeleteObject_internal(toDelete[i]);
        end
    end);
--]]

end

local Debug = {};
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
    AssetBrowser.toolbar = UI.Toolbar:New(0, y, w, h, parent, SceneMachine.mainWindow, Resources.iconData["AssetExplorerToolbar"]);
    AssetBrowser.toolbar:SetFrameLevel(startLevel + 2);
    AssetBrowser.toolbar.modelsGroup = AssetBrowser.toolbar:CreateGroup(0, 0, Editor.width, h,
        {
            { type = "DragHandle" },
            {
                type = "Button", name = "UpOneFolder", icon = AssetBrowser.toolbar:GetIcon("uponefolder"), action = function(self) AssetBrowser.UpOneFolder() end,
                tooltip = L["AB_TOOLBAR_TT_UP_ONE_FOLDER"],
            },
            { type = "Separator" },
            {
                type = "Label", name = "Breadcrumb", text = L["AB_BREADCRUMB"], width = w,
            },
        }
    );
    AssetBrowser.toolbar.modelsGroup:SetFrameLevel(startLevel + 3);

    AssetBrowser.toolbar.collectionsGroup = AssetBrowser.toolbar:CreateGroup(0, 0, Editor.width, h,
        {
            { type = "DragHandle" },
            {
                type = "Button", name = "NewCollection", icon = AssetBrowser.toolbar:GetIcon("newcollection"),
                action = function(self) Editor.OpenQuickTextbox(AssetBrowser.NewCollection, "MyCollection", L["AB_COLLECTION_NAME"]) end,
                tooltip = L["AB_TOOLBAR_TT_NEW_COLLECTION"],
            },
            {
                type = "Button", name = "RemoveCollection", icon = AssetBrowser.toolbar:GetIcon("removecollection"),
                action = function(self) AssetBrowser.RemoveCollection(AssetBrowser.selectedCollectionIndex); end,
                tooltip = L["AB_TOOLBAR_TT_REMOVE_COLLECTION"],
            },
            {
                type = "Button", name = "RenameCollection", icon = AssetBrowser.toolbar:GetIcon("renamecollection"),
                action = function(self)
                    if (AssetBrowser.selectedCollection) then
                        Editor.OpenQuickTextbox(AssetBrowser.RenameSelectedCollection, AssetBrowser.selectedCollection.name, L["AB_COLLECTION_RENAME"]);
                    end
                end,
                tooltip = L["AB_TOOLBAR_TT_RENAME_COLLECTION"],
            },
            {
                type = "Button", name = "AddObject", icon = AssetBrowser.toolbar:GetIcon("addsceneobject"),
                action = function(self) AssetBrowser.AddObjectsToCollection(SM.selectedObjects, AssetBrowser.selectedCollectionIndex); end,
                tooltip = L["AB_TOOLBAR_TT_ADD_OBJECT"],
            },
            {
                type = "Button", name = "RemoveObject", icon = AssetBrowser.toolbar:GetIcon("removeobject"),
                action = function(self) AssetBrowser.RemoveSelectedObjectFromCollection(); end,
                tooltip = L["AB_TOOLBAR_TT_REMOVE_OBJECT"],
            },
        }
    );

    AssetBrowser.toolbar.collectionsGroup:SetFrameLevel(startLevel + 3);
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

function AssetBrowser.GridShowFileInfo(entry)
    if (entry.fileID) then
        Editor.ShowImportExportWindow(nil, "Model\nName: ".. entry.N .."\nFileID: " .. entry.fileID);
    elseif(entry.displayID) then
        Editor.ShowImportExportWindow(nil, "Creature\nName: ".. entry.N .."\nDisplayID: " .. entry.displayID);
    end
end

function AssetBrowser.GridAddToCollection(entry)
    AssetBrowser.OnChangeTab(3);
    AssetBrowser.entryToAddToCollection = { fileID = entry.fileID or 0, displayID = entry.displayID or 0 };
end

function AssetBrowser.GridLoad(entry)
    AssetBrowser.OnThumbnailDoubleClick(entry.ID, entry.N);
end

function AssetBrowser.GridCollectionRemove(entry)
    if (not AssetBrowser.selectedCollection) then
        return;
    end

    for i = 1, #AssetBrowser.selectedCollection.items, 1 do
        if (entry.displayID and entry.displayID ~= 0) then
            if (entry.displayID == AssetBrowser.selectedCollection.items[i].displayID) then
                table.remove(scenemachine_collections[AssetBrowser.selectedCollectionIndex].items, i);
                AssetBrowser.gridList:SetData(AssetBrowser.BuildCollectionData(AssetBrowser.selectedCollection));
                return;
            end
        end
        if (entry.fileID and entry.fileID ~= 0) then
            if (entry.fileID == AssetBrowser.selectedCollection.items[i].fileID) then
                table.remove(scenemachine_collections[AssetBrowser.selectedCollectionIndex].items, i);
                AssetBrowser.gridList:SetData(AssetBrowser.BuildCollectionData(AssetBrowser.selectedCollection));
                return;
            end
        end
    end
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
                item.components[1]:GetFrame():RegisterForClicks("LeftButtonUp", "RightButtonUp");
                item.components[1]:SetClipsChildren(true);

				-- name text --
				item.components[4] = UI.Label:New(10, 0, 94, 30, item.components[1]:GetFrame(), "BOTTOMLEFT", "BOTTOMLEFT", "", 9);
                item.components[4]:SetPoint("BOTTOMRIGHT", item.components[1]:GetFrame(), "BOTTOMRIGHT", -10, 0);
                item.components[4]:GetFrame().text:SetMaxLines(2);
                item.components[4]:GetFrame().text:SetNonSpaceWrap(true);
                item.components[4]:SetFrameLevel(startLevel + 4);
                
                -- on double click --
                item.components[1]:GetFrame():SetScript("OnDoubleClick", function (self, button, down)
                    if (button == "LeftButton") then
                        AssetBrowser.OnThumbnailDoubleClick(item.ID, item.components[4]:GetText());
                    end
                end);
            
                -- on drag --
                item.components[1]:GetFrame():SetScript("OnDragStart", function (self, button, down)
                    AssetBrowser.OnThumbnailDrag(item.ID);
                end);
            
                -- image --
                item.components[3] = UI.ImageBox:New(15, -15, 1, 1, item.components[1]:GetFrame(), "TOPLEFT", "TOPLEFT", Resources.textures["FolderIcon"]);
                item.components[3]:SetPoint("BOTTOMRIGHT", item.components[1]:GetFrame(), "BOTTOMRIGHT", -15, 15 + 15);

                -- model --
                item.components[2] = CreateFrame("PlayerModel", "thumbnail_model_frame", item.components[1]:GetFrame());
                item.components[2]:SetPoint("TOPLEFT", item.components[1]:GetFrame(), "TOPLEFT", 0, 0);
                item.components[2]:SetPoint("BOTTOMRIGHT", item.components[1]:GetFrame(), "BOTTOMRIGHT", 0, 0);
                item.components[2]:SetCustomCamera(1);
			end,
			refreshItem = function(entry, item, index)
                -- on click --
                item.components[1]:GetFrame():SetScript("OnClick", function (self, button, down)
                    if (button == "LeftButton") then
                        AssetBrowser.selectedGridViewItem = item;
                        AssetBrowser.gridList:RefreshStatic();
                    elseif (button == "RightButton") then
                        local scale = SceneMachine.mainWindow:GetEffectiveScale();
                        local rx = Input.mouseXRaw / scale - SceneMachine.mainWindow:GetLeft();
                        local ry = Input.mouseYRaw / scale - SceneMachine.mainWindow:GetTop();
                        
                        if (entry.fileID or entry.displayID) then
                            local menuOptions = {
                                [1] = { ["Name"] = L["LOAD"],
                                        ["Action"] = function() AssetBrowser.GridLoad(entry) end },
                                [2] = { ["Name"] = L["AB_RMB_FILE_INFO"],
                                        ["Action"] = function() AssetBrowser.GridShowFileInfo(entry) end },
                            };

                            if (entry.collectionItem) then
                                menuOptions[#menuOptions + 1] = { ["Name"] = L["DELETE"],
                                        ["Action"] = function() AssetBrowser.GridCollectionRemove(entry) end }
                            else
                                menuOptions[#menuOptions + 1] = { ["Name"] = L["AB_RMB_ADD_TO_COLLECTION"],
                                        ["Action"] = function() AssetBrowser.GridAddToCollection(entry) end }
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
                    end
                -- has creature (displayID)
                elseif (entry.displayID) then
                    item.components[3]:Hide();
                    item.components[2]:Show();
                    if (item.components[2].displayID ~= entry.displayID) then
                        item.components[2]:SetDisplayInfo(entry.displayID);
                        item.components[2].displayID = entry.displayID;
                    end
                -- doesn't have model (folder)
                else
                    item.components[3]:Show();
                    item.components[2]:Hide();
                end

                if (item == AssetBrowser.selectedGridViewItem) then
					item.components[1]:SetColor(UI.Button.State.Normal, 0, 0.4765, 0.7968, 1);
				else
					item.components[1]:SetColor(UI.Button.State.Normal, 0.1757, 0.1757, 0.1875, 1);
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
        AssetBrowser.selectedGridViewItem = nil;
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

function AssetBrowser.BuildCollectionData(collectionData)
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
            name = AssetBrowser.GetFileName(item.fileID);
        end

        data[idx] = { N = name, fileID = fileID, displayID = displayID, ID = ID, collectionItem = true };
        idx = idx + 1;
    end

    return data;
end

function AssetBrowser.BuildSearchDataRecursive(value, dir)

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
 
    for c = 1, #AssetBrowser.toolbar.modelsGroup.components, 1 do
        local component = AssetBrowser.toolbar.modelsGroup.components[c];

        if (component.type == "Label") then
            if (component.name == "Breadcrumb") then
                --AssetBrowser.toolbar.modelsGroup.components[c]:SetOptions(projectNames);
                --AssetBrowser.toolbar.modelsGroup.components[c]:ShowSelectedName(selectedName);
                if (#searchData > 0) then
                    component:SetText(string.format(L["AB_RESULTS"], #searchData));
                else
                    local str = "";
                    for i=2, #AssetBrowser.breadcrumb, 1 do
                        if AssetBrowser.breadcrumb[i] ~= nil then
                            str = str .. ">" .. AssetBrowser.breadcrumb[i]["N"];
                        end
                    end
                    component:SetText(str);
                end
            end
        end
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
                    Editor.StartAction(Actions.Action.Type.CreateObject, { object });
                    Editor.FinishAction();
                    SM.selectedObjects = { object };
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
                        AssetBrowser.selectedGridViewItem = nil;
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
                        Editor.StartAction(Actions.Action.Type.CreateObject, { object });
                        Editor.FinishAction();
                        SM.selectedObjects = { object };
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
                    Editor.StartAction(Actions.Action.Type.CreateObject, { object });
                    Editor.FinishAction();
                    SM.selectedObjects = { object };
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
                    Editor.StartAction(Actions.Action.Type.CreateObject, { object });
                    Editor.FinishAction();
                    SM.selectedObjects = { object };
                    Editor.lastSelectedType = "obj";
                    SH.RefreshHierarchy();
                    OP.Refresh();
                    return;
                end
            end
        end

    end

    if (AssetBrowser.dataSource == "Collections") then
        if (AssetBrowser.selectedCollection) then
            for i = 1, #AssetBrowser.selectedCollection.items, 1 do
                local item = AssetBrowser.selectedCollection.items[i];
                if (item.displayID == ID) then
                    local name = "Creature";
                    for creatureID, displayID in pairs(SceneMachine.creatureToDisplayID) do
                        if (displayID == item.displayID) then
                            name = SceneMachine.creatureData[creatureID];
                        end
                    end
                    local object = SM.CreateCreature(item.displayID, name or "Creature", 0, 0, 0);
                    Editor.StartAction(Actions.Action.Type.CreateObject, { object });
                    Editor.FinishAction();
                    SM.selectedObjects = { object };
                    Editor.lastSelectedType = "obj";
                    SH.RefreshHierarchy();
                    OP.Refresh();
                    return;
                elseif (item.fileID == ID) then
                    local name = AssetBrowser.GetFileName(item.fileID);
                    local object = SM.CreateObject(item.fileID, name or "Model", 0, 0, 0);
                    Editor.StartAction(Actions.Action.Type.CreateObject, { object });
                    Editor.FinishAction();
                    SM.selectedObjects = { object };
                    Editor.lastSelectedType = "obj";
                    SH.RefreshHierarchy();
                    OP.Refresh();
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
                    Editor.StartAction(Actions.Action.Type.CreateObject, { object });
                    local xMin, yMin, zMin, xMax, yMax, zMax = object:GetActiveBoundingBox();
                    object:SetPosition(initialPosition.x, initialPosition.y, initialPosition.z + ((zMax - zMin) / 2));
                    SM.selectedObjects = { object };
                    Editor.lastSelectedType = "obj";
                    SH.RefreshHierarchy();
                    OP.Refresh();
                    Input.mouseState.LMB = true;
                    Input.mouseState.isDraggingAssetFromUI = true;
                    Gizmos.activeTransformGizmo = 1;
                    Gizmos.highlightedAxis = 4;
                    Gizmos.selectedAxis = 4;
                    Gizmos.OnLMBDown(Input.mouseX, Input.mouseY, false);
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
                        Editor.StartAction(Actions.Action.Type.CreateObject, { object });
                        local xMin, yMin, zMin, xMax, yMax, zMax = object:GetActiveBoundingBox();
                        object:SetPosition(initialPosition.x, initialPosition.y, initialPosition.z + ((zMax - zMin) / 2));
                        SM.selectedObjects = { object };
                        Editor.lastSelectedType = "obj";
                        SH.RefreshHierarchy();
                        OP.Refresh();
                        Input.mouseState.LMB = true;
                        Input.mouseState.isDraggingAssetFromUI = true;
                        Gizmos.activeTransformGizmo = 1;
                        Gizmos.highlightedAxis = 4;
                        Gizmos.selectedAxis = 4;
                        Gizmos.OnLMBDown(Input.mouseX, Input.mouseY, false);
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
                    Editor.StartAction(Actions.Action.Type.CreateObject, { object });
                    --local object = SM.CreateObject(fileID, fileName, initialPosition.x, initialPosition.y, initialPosition.z);
                    local xMin, yMin, zMin, xMax, yMax, zMax = object:GetActiveBoundingBox();
                    local mouseRay = Camera.GetMouseRay();
                    local initialPosition = mouseRay:PlaneIntersection(Vector3.zero, Gizmos.up) or Vector3.zero;
                    object:SetPosition(initialPosition.x, initialPosition.y, initialPosition.z + ((zMax - zMin) / 2));
                    SM.selectedObjects = { object };
                    Editor.lastSelectedType = "obj";
                    SH.RefreshHierarchy();
                    OP.Refresh();
                    Input.mouseState.LMB = true;
                    Input.mouseState.isDraggingAssetFromUI = true;
                    Gizmos.activeTransformGizmo = 1;
                    Gizmos.highlightedAxis = 4;
                    Gizmos.selectedAxis = 4;
                    Gizmos.OnLMBDown(Input.mouseX, Input.mouseY, false);
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
                    Editor.StartAction(Actions.Action.Type.CreateObject, { object });
                    local xMin, yMin, zMin, xMax, yMax, zMax = object:GetActiveBoundingBox();
                    local mouseRay = Camera.GetMouseRay();
                    local initialPosition = mouseRay:PlaneIntersection(Vector3.zero, Gizmos.up) or Vector3.zero;
                    object:SetPosition(initialPosition.x, initialPosition.y, initialPosition.z + ((zMax - zMin) / 2));
                    SM.selectedObjects = { object };
                    Editor.lastSelectedType = "obj";
                    SH.RefreshHierarchy();
                    OP.Refresh();
                    Input.mouseState.LMB = true;
                    Input.mouseState.isDraggingAssetFromUI = true;
                    Gizmos.activeTransformGizmo = 1;
                    Gizmos.highlightedAxis = 4;
                    Gizmos.selectedAxis = 4;
                    Gizmos.OnLMBDown(Input.mouseX, Input.mouseY, false);
                    return;
                end
            end
        end
    end

    if (AssetBrowser.dataSource == "Collections") then
        if (AssetBrowser.selectedCollection) then
            for i = 1, #AssetBrowser.selectedCollection.items, 1 do
                local item = AssetBrowser.selectedCollection.items[i];
                if (item.displayID == ID) then
                    local name = "Creature";
                    for creatureID, displayID in pairs(SceneMachine.creatureToDisplayID) do
                        if (displayID == item.displayID) then
                            name = SceneMachine.creatureData[creatureID];
                        end
                    end
                    local object = SM.CreateCreature(item.displayID, name or "Creature", 0, 0, 0);
                    Editor.StartAction(Actions.Action.Type.CreateObject, { object });
                    local xMin, yMin, zMin, xMax, yMax, zMax = object:GetActiveBoundingBox();
                    local mouseRay = Camera.GetMouseRay();
                    local initialPosition = mouseRay:PlaneIntersection(Vector3.zero, Gizmos.up) or Vector3.zero;
                    object:SetPosition(initialPosition.x, initialPosition.y, initialPosition.z + ((zMax - zMin) / 2));
                    SM.selectedObjects = { object };
                    Editor.lastSelectedType = "obj";
                    SH.RefreshHierarchy();
                    OP.Refresh();
                    Input.mouseState.LMB = true;
                    Input.mouseState.isDraggingAssetFromUI = true;
                    Gizmos.activeTransformGizmo = 1;
                    Gizmos.highlightedAxis = 4;
                    Gizmos.selectedAxis = 4;
                    Gizmos.OnLMBDown(Input.mouseX, Input.mouseY, false);
                    return;
                elseif (item.fileID == ID) then
                    local name = AssetBrowser.GetFileName(item.fileID);
                    local mouseRay = Camera.GetMouseRay();
                    local initialPosition = mouseRay:PlaneIntersection(Vector3.zero, Gizmos.up) or Vector3.zero;
                    local object = SM.CreateObject(item.fileID, name, initialPosition.x, initialPosition.y, initialPosition.z);
                    Editor.StartAction(Actions.Action.Type.CreateObject, { object });
                    local xMin, yMin, zMin, xMax, yMax, zMax = object:GetActiveBoundingBox();
                    object:SetPosition(initialPosition.x, initialPosition.y, initialPosition.z + ((zMax - zMin) / 2));
                    SM.selectedObjects = { object };
                    Editor.lastSelectedType = "obj";
                    SH.RefreshHierarchy();
                    OP.Refresh();
                    Input.mouseState.LMB = true;
                    Input.mouseState.isDraggingAssetFromUI = true;
                    Gizmos.activeTransformGizmo = 1;
                    Gizmos.highlightedAxis = 4;
                    Gizmos.selectedAxis = 4;
                    Gizmos.OnLMBDown(Input.mouseX, Input.mouseY, false);
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