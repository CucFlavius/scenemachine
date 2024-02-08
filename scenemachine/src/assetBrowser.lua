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

local thumbSize = 95;
local thumbCountX = 3;
local thumbCountY = 5;
local tabbarHeight = 20;

local c1 = { 0.1757, 0.1757, 0.1875 };
local c2 = { 0.242, 0.242, 0.25 };
local c3 = { 0, 0.4765, 0.7968 };
local c4 = { 0.1171, 0.1171, 0.1171 };

function AssetBrowser.Create(parent, w, h, startLevel)

    local tabPanel = UI.TabPanel:New(0, 0, w, h, parent, "TOPRIGHT", "TOPRIGHT", 8);
    tabPanel:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 0, 0);
    tabPanel:SetFrameLevel(startLevel);

    AssetBrowser.tabs = {};
    
    AssetBrowser.tabs[1] = tabPanel:AddTab(w, h, "Models", 50, function() AssetBrowser.OnChangeTab(1); end, startLevel + 1);
    AssetBrowser.tabs[2] = tabPanel:AddTab(w, h, "Creatures", 70, function() AssetBrowser.OnChangeTab(2); end, startLevel + 1);
    
    AssetBrowser.CreateToolbar(AssetBrowser.tabs[1]:GetFrame(), -Editor.pmult, w, startLevel);
    AssetBrowser.gridList = UI.PooledGridScrollList:NewP(AssetBrowser.tabs[1]:GetFrame(), 0, -30 - Editor.pmult, "TOPLEFT", "TOPLEFT", 0, 0, "BOTTOMRIGHT", "BOTTOMRIGHT");
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
				item.components[2] = UI.Label:New(10, 0, 94, 20, item.components[1]:GetFrame(), "BOTTOM", "BOTTOM", "", 9);
                item.components[2]:SetFrameLevel(startLevel + 4);

                -- on double click --
                item.components[1]:GetFrame():SetScript("OnDoubleClick", function (self, button, down)
                    AssetBrowser.OnThumbnailClick(item.components[2]:GetText());
                end);
            
                item.components[1]:GetFrame():SetScript("OnDragStart", function (self, button, down)
                    AssetBrowser.OnThumbnailDrag(item.components[2]:GetText());
                end);
            
                -- image --
                item.components[3] = UI.ImageBox:New(15, -15, 1, 1, item.components[1]:GetFrame(), "TOPLEFT", "TOPLEFT", Resources.textures["FolderIcon"]);
                item.components[3]:SetPoint("BOTTOMRIGHT", item.components[1]:GetFrame(), "BOTTOMRIGHT", -15, 15 + 15);

                -- model --
                item.components[4] = CreateFrame("PlayerModel", "thumbnail_model_frame", item.components[1]:GetFrame());
                item.components[4]:SetSize(w, w);
                item.components[4]:SetPoint("TOPLEFT", item.components[1]:GetFrame(), "TOPLEFT", 0, 0);
                item.components[4]:SetPoint("BOTTOMRIGHT", item.components[1]:GetFrame(), "BOTTOMRIGHT", 0, 0);
                item.components[4]:SetCustomCamera(1);
			end,
			refreshItem = function(entry, item)
				-- object name text --
				item.components[2]:SetText(entry["N"]);

                -- has model (file)
                if (entry.fileID) then
                    item.components[3]:Hide();
                    item.components[4]:Show();
                    if (item.components[4].fileID ~= entry.fileID) then
                        item.components[4]:SetModel(entry.fileID);
                        item.components[4].fileID = entry.fileID;
                    end
                -- doesn't have model (folder)
                else
                    item.components[3]:Show();
                    item.components[4]:Hide();
                end
			end,
	    }
    );

	AssetBrowser.gridList:MakePool();
    AssetBrowser.currentDirectory = SceneMachine.modelData[1];
    AssetBrowser.gridList:SetData(AssetBrowser.BuildFolderData(AssetBrowser.currentDirectory));
    AssetBrowser.breadcrumb = {};
    table.insert(AssetBrowser.breadcrumb, AssetBrowser.currentDirectory);

    -- DEBUG --
    AssetBrowser.OnThumbnailClick("World");
    AssetBrowser.OnThumbnailClick("Expansion07");
    AssetBrowser.OnThumbnailClick("Doodads");
    --AssetBrowser.OnThumbnailClick("Kultiraszone");
end

function AssetBrowser.OnChangeTab(idx)

end

function AssetBrowser.CreateCreatureListTab(parent, w, h)
    local creatureDisplayIDText = UI.Label:New(0, 0, w * 0.3, 20, parent, "TOPLEFT", "TOPLEFT", "CreatureDisplayID", 9);
    local creatureDisplayIDEditBox = UI.TextBox:New(w * 0.3, 0, w * 0.7, 20, parent, "TOPLEFT", "TOPLEFT", "41918");
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

    local creatureIDText = UI.Label:New(0, -22, w * 0.3, 20, parent, "TOPLEFT", "TOPLEFT", "CreatureID", 9);
    local creatureIDEditBox = UI.TextBox:New(w * 0.3, -22, w * 0.7, 20, parent, "TOPLEFT", "TOPLEFT", "0");
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

    local creatureAnimationText = UI.Label:New(0, -44, w * 0.3, 20, parent, "TOPLEFT", "TOPLEFT", "PlayAnimID", 9);
    local creatureAnimationEditBox = UI.TextBox:New(w * 0.3, -44, w * 0.7, 20, parent, "TOPLEFT", "TOPLEFT", "0");
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

    local creatureAnimationKitText = UI.Label:New(0, -66, w * 0.3, 20, parent, "TOPLEFT", "TOPLEFT", "PlayAnimKitID", 9);
    local creatureAnimationKitEditBox = UI.TextBox:New(w * 0.3, -66, w * 0.7, 20, parent, "TOPLEFT", "TOPLEFT", "0");
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
end

function AssetBrowser.CreateToolbar(parent, y, w, startLevel)
    AssetBrowser.toolbar = UI.Rectangle:New(0, y, w, (Editor.toolbarHeight - 15), parent, "TOPLEFT", "TOPLEFT", c1[1], c1[2], c1[3], 1);
    AssetBrowser.toolbar:SetFrameLevel(startLevel);
    AssetBrowser.toolbar:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, 0);

    AssetBrowser.toolbar.upOneFolderButton = UI.Button:New(0, 0, (Editor.toolbarHeight - 15) - 2, (Editor.toolbarHeight - 15) - 2, AssetBrowser.toolbar:GetFrame(), "LEFT", "LEFT", nil, Resources.textures["FolderUpIcon"]);
    AssetBrowser.toolbar.upOneFolderButton:SetScript("OnClick", function (self, button, down) AssetBrowser.UpOneFolder(); end)
    AssetBrowser.toolbar.upOneFolderButton:SetFrameLevel(startLevel + 1);

    AssetBrowser.toolbar.breadCrumb = UI.Label:New((Editor.toolbarHeight - 15), 0, w - (Editor.toolbarHeight - 15), (Editor.toolbarHeight - 15), AssetBrowser.toolbar:GetFrame(),
        "TOPLEFT", "TOPLEFT", "Breadcrumb", 9);
    AssetBrowser.toolbar.breadCrumb:SetFrameLevel(startLevel + 1);
    -- Gave up on this because it requires resizing every element in the thumbnails too
    --AssetBrowser.toolbar.increaseThumbColumns = UI.Button:New(30, 0, toolbarHeight - 2, toolbarHeight - 2, AssetBrowser.toolbar, "LEFT", "LEFT", "+", nil);
    --AssetBrowser.toolbar.increaseThumbColumns:SetScript("OnClick", function (self, button, down) AssetBrowser.OnIncreaseThumbnailColumns(); end)
end

function AssetBrowser.UpOneFolder()
    local pos = table.getn(AssetBrowser.breadcrumb) - 1;

    if pos == 0 then return end

    AssetBrowser.currentDirectory = AssetBrowser.breadcrumb[pos];
    table.remove(AssetBrowser.breadcrumb, pos + 1);
    AssetBrowser.gridList:SetData(AssetBrowser.BuildFolderData(AssetBrowser.currentDirectory));
    AssetBrowser.RefreshBreadcrumb();
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
            data[idx] = { N = fileName, fileID = fileID };
            idx = idx + 1;
        end
    end

    return data;
end

function AssetBrowser.RefreshBreadcrumb()
    local str = "";
    for i=2, table.getn(AssetBrowser.breadcrumb), 1 do
        if AssetBrowser.breadcrumb[i] ~= nil then
            str = str .. ">" .. AssetBrowser.breadcrumb[i]["N"];
        end
    end

    AssetBrowser.toolbar.breadCrumb:SetText(str);
end

function AssetBrowser.OnThumbnailClick(name)
    -- Directory scan
    if (AssetBrowser.currentDirectory["D"] ~= nil) then
        local directoryCount = table.getn(AssetBrowser.currentDirectory["D"]);
        for i = 1, directoryCount, 1 do
            local dirName = AssetBrowser.currentDirectory["D"][i]["N"];
            if dirName == name then
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
            local fileName = AssetBrowser.currentDirectory["FN"][i];
            if fileName == name then
                local fileID = AssetBrowser.currentDirectory["FI"][i];
                SM.CreateObject(fileID, fileName, 0, 0, 0)
                return;
            end
        end
    end
end

function AssetBrowser.OnThumbnailDrag(name)
    -- File Scan
    if (AssetBrowser.currentDirectory["FN"] ~= nil) then
        local fileCount = table.getn(AssetBrowser.currentDirectory["FN"]);
        for i = 1, fileCount, 1 do
            local fileName = AssetBrowser.currentDirectory["FN"][i];
            if fileName == name then
                local fileID = AssetBrowser.currentDirectory["FI"][i];
                local mouseRay = Camera.GetMouseRay();
                local initialPosition = mouseRay:PlaneIntersection(Vector3.zero, Gizmos.up) or Vector3.zero;
                local object = SM.CreateObject(fileID, fileName, initialPosition.x, initialPosition.y, initialPosition.z);
                SM.selectedObject = object;
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