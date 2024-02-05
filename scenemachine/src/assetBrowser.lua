local AssetBrowser = SceneMachine.Editor.AssetBrowser;
local Editor = SceneMachine.Editor;
local Renderer = SceneMachine.Renderer;
local SM = Editor.SceneManager;
local Gizmos = SceneMachine.Gizmos;
local Input = SceneMachine.Input;
local Camera = SceneMachine.Camera;
local Vector3 = SceneMachine.Vector3;
local UI = SceneMachine.UI;

local thumbSize = 95;
local thumbCountX = 3;
local thumbCountY = 5;
local tabbarHeight = 20;

local c1 = { 0.1757, 0.1757, 0.1875 };
local c2 = { 0.242, 0.242, 0.25 };
local c3 = { 0, 0.4765, 0.7968 };
local c4 = { 0.1171, 0.1171, 0.1171 };

function AssetBrowser.Create(parent, w, h)

    local tabPanel = UI.TabPanel:New(0, 0, w, h, parent, "TOPLEFT", "TOPLEFT", 8);
    AssetBrowser.tabs = {};

    AssetBrowser.tabs[1] = tabPanel:AddTab(w, h, "Models", 50, function() AssetBrowser.OnChangeTab(1); end);
    AssetBrowser.tabs[2] = tabPanel:AddTab(w, h, "Creatures", 70, function() AssetBrowser.OnChangeTab(2); end);

    AssetBrowser.CreateModelListTab(AssetBrowser.tabs[1]:GetFrame(), w, h -tabbarHeight);
    AssetBrowser.Refresh();

    AssetBrowser.CreateCreatureListTab(AssetBrowser.tabs[2]:GetFrame(), w, h -tabbarHeight);

    -- DEBUG --
    --AssetBrowser.OnThumbnailClick("World");
    --AssetBrowser.OnThumbnailClick("Arttest");
    --AssetBrowser.OnThumbnailClick("Shader");
end

function AssetBrowser.OnChangeTab(idx)

end

function AssetBrowser.CreateModelListTab(parent, w, h)

    AssetBrowser.CreateToolbar(parent, -Editor.pmult, w);

    AssetBrowser.thumbnailGroup = UI.Rectangle:New(
        0, -((Editor.toolbarHeight - 15) + (Editor.pmult * 2)),
        w, h -(((Editor.toolbarHeight - 15) * 2) + (Editor.pmult)),
        parent, "TOPLEFT", "TOPLEFT", 0, 0, 0, 0.41);

    local data = SceneMachine.modelData[1];
    AssetBrowser.currentDirectory = data;
    AssetBrowser.currentPage = 1;

    AssetBrowser.breadcrumb = {};
    table.insert(AssetBrowser.breadcrumb, AssetBrowser.currentDirectory);

    AssetBrowser.CreateThumbnails(AssetBrowser.thumbnailGroup:GetFrame());
    
    AssetBrowser.CreatePagination(parent);
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

function AssetBrowser.CreateToolbar(parent, y, w)
    AssetBrowser.toolbar = UI.Rectangle:New(0, y, w, (Editor.toolbarHeight - 15), parent, "TOPLEFT", "TOPLEFT", c1[1], c1[2], c1[3], 1);
    
    AssetBrowser.toolbar.upOneFolderButton = UI.Button:New(0, 0, (Editor.toolbarHeight - 15) - 2, (Editor.toolbarHeight - 15) - 2, AssetBrowser.toolbar:GetFrame(), "LEFT", "LEFT", nil, "Interface\\Addons\\scenemachine\\static\\textures\\folderUpIcon.png");
    AssetBrowser.toolbar.upOneFolderButton:SetScript("OnClick", function (self, button, down) AssetBrowser.UpOneFolder(); end)
    
    AssetBrowser.toolbar.breadCrumb = UI.Label:New((Editor.toolbarHeight - 15), 0, w - (Editor.toolbarHeight - 15), (Editor.toolbarHeight - 15), AssetBrowser.toolbar:GetFrame(),
        "TOPLEFT", "TOPLEFT", "Breadcrumb", 9);
    
    -- Gave up on this because it requires resizing every element in the thumbnails too
    --AssetBrowser.toolbar.increaseThumbColumns = UI.Button:New(30, 0, toolbarHeight - 2, toolbarHeight - 2, AssetBrowser.toolbar, "LEFT", "LEFT", "+", nil);
    --AssetBrowser.toolbar.increaseThumbColumns:SetScript("OnClick", function (self, button, down) AssetBrowser.OnIncreaseThumbnailColumns(); end)
end

function AssetBrowser.CreatePagination(parent)
    AssetBrowser.paginationText = UI.Label:New(0, 0, 100, 30, parent, "BOTTOM", "BOTTOM", "PaginationText", 9);
    AssetBrowser.paginationText:SetJustifyH("CENTER");

    AssetBrowser.pageLeftButton = UI.Button:New(0, 0, (Editor.toolbarHeight - 15) - 2, (Editor.toolbarHeight - 15) - 2, parent, "BOTTOMLEFT", "BOTTOMLEFT", "<", nil);
    AssetBrowser.pageLeftButton:SetScript("OnClick", function (self, button, down) AssetBrowser.OnPreviousPageClic(); end)

    AssetBrowser.pageRightButton = UI.Button:New(0, 0, (Editor.toolbarHeight - 15) - 2, (Editor.toolbarHeight - 15) - 2, parent, "BOTTOMRIGHT", "BOTTOMRIGHT", ">", nil);
    AssetBrowser.pageRightButton:SetScript("OnClick", function (self, button, down) AssetBrowser.OnNextPageClick(); end)
end

function AssetBrowser.OnIncreaseThumbnailColumns()
    if (thumbCountX == 5) then return; end

    thumbCountX = thumbCountX + 1;

    if (thumbCountX == 3) then
        thumbSize = 94;
        thumbCountY = 5;
    elseif (thumbCountX == 4) then
        thumbSize = 69;
    elseif (thumbCountX == 5) then
        thumbSize = 54.8;
        thumbCountY = 7;
    end

    local idx = 1;
    for y=0, 7 - 1, 1 do
        for x=0, 5 - 1, 1 do
            local X = (x * (thumbSize + Editor.pmult));
            local Y = -(y * (thumbSize + Editor.pmult + 20));
            local W = thumbSize;
            local H = (thumbSize + 20);

            AssetBrowser.thumbnails[idx]:SetSize(W, H);
            AssetBrowser.thumbnails[idx]:SetPoint("TOPLEFT", AssetBrowser.thumbnails[idx]:GetParent(), "TOPLEFT", X, Y);
            AssetBrowser.thumbnails[idx]:Hide();
            idx = idx + 1;
        end
    end

    for i=1, table.getn(AssetBrowser.thumbnails), 1 do
        
        AssetBrowser.thumbnails[i]:Hide();
    end

    AssetBrowser.Refresh();
end

function AssetBrowser.UpOneFolder()
    local pos = table.getn(AssetBrowser.breadcrumb) - 1;

    if pos == 0 then return end

    AssetBrowser.currentPage = 1;
    AssetBrowser.currentDirectory = AssetBrowser.breadcrumb[pos];
    table.remove(AssetBrowser.breadcrumb, pos + 1);
    AssetBrowser.Refresh();
end

function AssetBrowser.CreateThumbnails(parent)

    Editor.pmult = 1.0;
    local res = GetCVar("gxWindowedResolution")
    if res then
        local w,h = string.match(res, "(%d+)x(%d+)")
        Editor.pmult = (768 / h)
    end

    local idx = 1;
    AssetBrowser.thumbnails = {};
    for y=0, 5 - 1, 1 do
        for x=0, 3 - 1, 1 do
            local X = (x * (thumbSize + Editor.pmult));
            local Y = -(y * (thumbSize + Editor.pmult + 15));
            local W = thumbSize;
            local H = (thumbSize + 15);
            AssetBrowser.thumbnails[idx] = AssetBrowser.CreateThumbnail(X, Y, W, H, parent, "");
            AssetBrowser.thumbnails[idx]:Hide();
            idx = idx + 1;
        end
    end
end

function AssetBrowser.Refresh()
    AssetBrowser.RefreshThumbnails();
    AssetBrowser.RefreshBreadcrumb();
    AssetBrowser.RefreshPagination();
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

function AssetBrowser.RefreshPagination()
    local directoryCount = 0;
    if AssetBrowser.currentDirectory["D"] ~= nil then
        directoryCount = table.getn(AssetBrowser.currentDirectory["D"]);
    end
    
    local fileCount = 0;
    if AssetBrowser.currentDirectory["FN"] ~= nil then
        fileCount = table.getn(AssetBrowser.currentDirectory["FN"]);
    end

    AssetBrowser.totalPages = math.ceil((directoryCount + fileCount) / (thumbCountX * thumbCountY));
    AssetBrowser.paginationText:SetText(AssetBrowser.currentPage .. "/" .. AssetBrowser.totalPages);
end

function AssetBrowser.RefreshThumbnails()
    local directoryCount = 0;
    if AssetBrowser.currentDirectory["D"] ~= nil then
        directoryCount = table.getn(AssetBrowser.currentDirectory["D"]);
    end
    
    local fileCount = 0;
    if AssetBrowser.currentDirectory["FN"] ~= nil then
        fileCount = table.getn(AssetBrowser.currentDirectory["FN"]);
    end

    local thumbCount = thumbCountX * thumbCountY;

    local idx = (AssetBrowser.currentPage - 1) * thumbCount + 1;
    local lastThumbIdx = 1;
    for i = 1, thumbCount, 1 do
        if (idx <= directoryCount) then
            local dirName = AssetBrowser.currentDirectory["D"][idx]["N"];
            AssetBrowser.thumbnails[i].textBox:SetText(dirName);
            AssetBrowser.thumbnails[i].imageBox:Show();
            AssetBrowser.thumbnails[i].modelFrame:Hide();
            AssetBrowser.thumbnails[i]:Show();
            lastThumbIdx = i;
        elseif (idx <= directoryCount + fileCount) then
            local fileName = AssetBrowser.currentDirectory["FN"][idx];
            local fileID = AssetBrowser.currentDirectory["FI"][idx];
            AssetBrowser.thumbnails[i].textBox:SetText(fileName);
            AssetBrowser.thumbnails[i]:Show();
            AssetBrowser.thumbnails[i].modelFrame:Show();
            AssetBrowser.thumbnails[i].imageBox:Hide();
            if (fileID ~= nil) then
                AssetBrowser.thumbnails[i].modelFrame:SetModel(fileID);
            end
            --AssetBrowser.thumbnails[i].modelFrame:ZeroCachedCenterXY();
            --AssetBrowser.thumbnails[i].modelFrame:SetCameraPosition(0, 0, 0);
            --AssetBrowser.thumbnails[i].modelFrame:SetCamera(1);
            --AssetBrowser.thumbnails[i].modelFrame:SetPosition(0,0,0);
            --AssetBrowser.thumbnails[i].modelFrame:SetCameraDistance(2);
        else
            AssetBrowser.thumbnails[i]:Hide();
        end
        idx = idx + 1;
    end
end

function AssetBrowser.CreateThumbnail(x, y, w, h, parent, name)
    local thumbnail = UI.Button:New(x, y, w, h, parent, "TOPLEFT", "TOPLEFT", "", nil);
    thumbnail:GetFrame():RegisterForDrag("LeftButton");
    thumbnail:GetFrame():SetScript("OnDoubleClick", function (self, button, down)
            AssetBrowser.OnThumbnailClick(thumbnail.textBox:GetText());
       end);

    thumbnail:GetFrame():SetScript("OnDragStart", function (self, button, down)
            AssetBrowser.OnThumbnailDrag(thumbnail.textBox:GetText());
        end);

    thumbnail.imageBox = UI.ImageBox:New(0, -w / 4, w / 2, w / 2, thumbnail:GetFrame(), "TOP", "TOP", "Interface\\Addons\\scenemachine\\static\\textures\\folderIcon.png");
    thumbnail.textBox = UI.Label:New(5, 0, w, 20, thumbnail:GetFrame(), "BOTTOMLEFT", "BOTTOMLEFT", name, 9);

    thumbnail.modelFrame = CreateFrame("PlayerModel", "thumbnail_model_frame_" .. x .. y, thumbnail:GetFrame());
    thumbnail.modelFrame:SetSize(w, w);
    thumbnail.modelFrame:SetPoint("TOP", thumbnail:GetFrame(), "TOP", 0, 0);
    thumbnail.modelFrame:SetCustomCamera(1);

    return thumbnail;
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
                AssetBrowser.Refresh();
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

function AssetBrowser.OnNextPageClick()
    if (AssetBrowser.totalPages == AssetBrowser.currentPage) then return; end

    AssetBrowser.currentPage = AssetBrowser.currentPage + 1;
    AssetBrowser.Refresh();
end

function AssetBrowser.OnPreviousPageClic()
    if (AssetBrowser.currentPage == 1) then return; end

    AssetBrowser.currentPage = AssetBrowser.currentPage - 1;
    AssetBrowser.Refresh();
end