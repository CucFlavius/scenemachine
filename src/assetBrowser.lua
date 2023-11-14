SceneMachine.Editor = SceneMachine.Editor or {}
SceneMachine.Editor.AssetBrowser = SceneMachine.Editor.AssetBrowser or {}
local AssetBrowser = SceneMachine.Editor.AssetBrowser;
local Editor = SceneMachine.Editor;
local Win = ZWindowAPI;
local Renderer = SceneMachine.Renderer;

local thumbSize = 95;
local thumbSpacing = 1.5;
local thumbCountX = 3;
local thumbCountY = 5;
local toolbarHeight = 30;
local tabbarHeight = 20;

local c1 = { 0.1757, 0.1757, 0.1875 };
local c2 = { 0.242, 0.242, 0.25 };
local c3 = { 0, 0.4765, 0.7968 };
local c4 = { 0.1171, 0.1171, 0.1171 };

function AssetBrowser.Create(parent, w, h)

    local tabPanel = Win.CreateTabPanel(0, 0, w, h, parent, "TOPLEFT", "TOPLEFT", 8);
    AssetBrowser.tabs = {};
    AssetBrowser.tabs[1] = Win.AddTabPanelTab(tabPanel, w, h, "Models", 50, function() AssetBrowser.OnChangeTab(1); end);
    AssetBrowser.tabs[2] = Win.AddTabPanelTab(tabPanel, w, h, "Creatures", 70, function() AssetBrowser.OnChangeTab(2); end);

    AssetBrowser.CreateModelListTab(AssetBrowser.tabs[1], w, h -tabbarHeight);
    AssetBrowser.Refresh();

    -- DEBUG --
    --AssetBrowser.OnThumbnailClick("World");
    --AssetBrowser.OnThumbnailClick("Dungeon");
    --AssetBrowser.OnThumbnailClick("Cave");
    --AssetBrowser.OnThumbnailClick("Passivedoodads");
    --AssetBrowser.OnThumbnailClick("Crystals");
end

function AssetBrowser.OnChangeTab(idx)

end

function AssetBrowser.CreateModelListTab(parent, w, h)

    AssetBrowser.CreateToolbar(parent, -thumbSpacing, w);

    AssetBrowser.thumbnailGroup = Win.CreateRectangle(
        0, -(toolbarHeight + (thumbSpacing * 2)),
        w, h -((toolbarHeight * 2) + (thumbSpacing)),
        parent, "TOPLEFT", "TOPLEFT", 0, 0, 0, 0.41);

    local data = SceneMachine.modelData[1];
    AssetBrowser.currentDirectory = data;
    AssetBrowser.currentPage = 1;

    AssetBrowser.breadcrumb = {};
    table.insert(AssetBrowser.breadcrumb, AssetBrowser.currentDirectory);

    AssetBrowser.CreateThumbnails(AssetBrowser.thumbnailGroup);
    
    AssetBrowser.CreatePagination(parent);
end

function AssetBrowser.CreateToolbar(parent, y, w)
    AssetBrowser.toolbar = Win.CreateRectangle(0, y, w, toolbarHeight, parent, "TOPLEFT", "TOPLEFT", c1[1], c1[2], c1[3], 1);
    
    AssetBrowser.toolbar.upOneFolderButton = Win.CreateButton(1, 1, toolbarHeight - 2, toolbarHeight - 2, AssetBrowser.toolbar, "LEFT", "LEFT", nil,
        "Interface\\Addons\\scenemachine\\static\\textures\\folderUpIcon.png", "BUTTON_VS");
    AssetBrowser.toolbar.upOneFolderButton:SetScript("OnClick", function (self, button, down) AssetBrowser.UpOneFolder(); end)
    
    AssetBrowser.toolbar.breadCrumb = Win.CreateTextBoxSimple(toolbarHeight, 0, w - toolbarHeight, toolbarHeight, AssetBrowser.toolbar,
        "TOPLEFT", "TOPLEFT", "Breadcrumb", 9);
    
    -- Gave up on this because it requires resizing every element in the thumbnails too
    --AssetBrowser.toolbar.increaseThumbColumns = Win.CreateButton(30, 0, toolbarHeight - 2, toolbarHeight - 2, AssetBrowser.toolbar, "LEFT", "LEFT", "+", nil, "BUTTON_VS");
    --AssetBrowser.toolbar.increaseThumbColumns:SetScript("OnClick", function (self, button, down) AssetBrowser.OnIncreaseThumbnailColumns(); end)
end

function AssetBrowser.CreatePagination(parent)
    AssetBrowser.paginationText = Win.CreateTextBoxSimple(0, 0, 100, 30, parent, "BOTTOM", "BOTTOM", "PaginationText", 9);
    AssetBrowser.paginationText.text:SetJustifyH("CENTER");

    AssetBrowser.pageLeftButton = Win.CreateButton(0, 0, toolbarHeight - 2, toolbarHeight - 2, parent, "BOTTOMLEFT", "BOTTOMLEFT", "<", nil, "BUTTON_VS");
    AssetBrowser.pageLeftButton:SetScript("OnClick", function (self, button, down) AssetBrowser.OnPreviousPageClic(); end)

    AssetBrowser.pageRightButton = Win.CreateButton(0, 0, toolbarHeight - 2, toolbarHeight - 2, parent, "BOTTOMRIGHT", "BOTTOMRIGHT", ">", nil, "BUTTON_VS");
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
            local X = (x * (thumbSize + thumbSpacing));
            local Y = -(y * (thumbSize + thumbSpacing + 20));
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
    local idx = 1;
    AssetBrowser.thumbnails = {};
    for y=0, 5 - 1, 1 do
        for x=0, 3 - 1, 1 do
            local X = (x * (thumbSize + thumbSpacing));
            local Y = -(y * (thumbSize + thumbSpacing + 15));
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

    AssetBrowser.toolbar.breadCrumb.text:SetText(str);
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
    AssetBrowser.paginationText.text:SetText(AssetBrowser.currentPage .. "/" .. AssetBrowser.totalPages);
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
            AssetBrowser.thumbnails[i].textBox.text:SetText(dirName);
            AssetBrowser.thumbnails[i].imageBox:Show();
            AssetBrowser.thumbnails[i].modelFrame:Hide();
            AssetBrowser.thumbnails[i]:Show();
            lastThumbIdx = i;
        elseif (idx <= directoryCount + fileCount) then
            local fileName = AssetBrowser.currentDirectory["FN"][idx];
            local fileID = AssetBrowser.currentDirectory["FI"][idx];
            AssetBrowser.thumbnails[i].textBox.text:SetText(fileName);
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
    local thumbnail = Win.CreateButton(x, y, w, h, parent, "TOPLEFT", "TOPLEFT", "", nil, Win.BUTTON_VS);

    thumbnail:SetScript("OnClick", function (self, button, down)
            AssetBrowser.OnThumbnailClick(self.textBox.text:GetText());
       end);

    thumbnail.imageBox = Win.CreateImageBox(0, -w / 4, w / 2, w / 2, thumbnail, "TOP", "TOP", "Interface\\Addons\\scenemachine\\static\\textures\\folderIcon.png");
    thumbnail.textBox = Win.CreateTextBoxSimple(5, 0, w, 20, thumbnail, "BOTTOMLEFT", "BOTTOMLEFT", name, 9);

    thumbnail.modelFrame = CreateFrame("PlayerModel", "thumbnail_model_frame_" .. x .. y, thumbnail)
    thumbnail.modelFrame:SetSize(w, w);
    thumbnail.modelFrame:SetPoint("TOP", thumbnail, "TOP", 0, 0);
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
                Renderer.AddActor(fileID, 0, 0, 0);
                return;
            end
        end
    end

    -- Renderer.AddActor
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