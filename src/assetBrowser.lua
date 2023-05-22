SceneMachine.Editor = SceneMachine.Editor or {}
SceneMachine.Editor.AssetBrowser = SceneMachine.Editor.AssetBrowser or {}
local AssetBrowser = SceneMachine.Editor.AssetBrowser;
local Editor = SceneMachine.Editor;
local Win = ZWindowAPI;
local Renderer = SceneMachine.Renderer;

local thumbSize = 80;
local thumbSpacing = 2;
local thumbCountX = 3;
local thumbCountY = 5;
local toolbarHeight = 30;

local c1 = { 0.1757, 0.1757, 0.1875 };
local c2 = { 0.242, 0.242, 0.25 };
local c3 = { 0, 0.4765, 0.7968 };
local c4 = { 0.1171, 0.1171, 0.1171 };

function AssetBrowser.Create(parent, w, h)
    AssetBrowser.toolbar = Win.CreateRectangle(0, -thumbSpacing, w, toolbarHeight, parent, "TOPLEFT", "TOPLEFT", c1[1], c1[2], c1[3], 1);
    AssetBrowser.toolbar.upOneFolderButton = Win.CreateButton(1, 1, 30, 30, AssetBrowser.toolbar, "LEFT", "LEFT", "Up", nil, "BUTTON_VS");
    --AssetBrowser.toolbar.button2 = Win.CreateButton(30, 0, 30, 30, AssetBrowser.toolbar, "LEFT", "LEFT", "Btn", nil, "BUTTON_VS");
    AssetBrowser.toolbar.upOneFolderButton:SetScript("OnClick", function (self, button, down) AssetBrowser.UpOneFolder(); end)

    AssetBrowser.thumbnailGroup = Win.CreateRectangle(
        0, -toolbarHeight - (thumbSpacing * 2),
        w, h -toolbarHeight - thumbSpacing,
        parent, "TOPLEFT", "TOPLEFT", 0, 0, 0, 0.41);

    local data = SceneMachine.modelData[1];
    AssetBrowser.currentDirectory = data;

    AssetBrowser.breadcrumb = {};
    table.insert(AssetBrowser.breadcrumb, AssetBrowser.currentDirectory);

    AssetBrowser.CreateThumbnails(AssetBrowser.thumbnailGroup);
    AssetBrowser.RefreshThumbnails();
end

function AssetBrowser.UpOneFolder()
    local pos = table.getn(AssetBrowser.breadcrumb) - 1;

    if pos == 0 then return end

    AssetBrowser.currentDirectory = AssetBrowser.breadcrumb[pos];
    table.remove(AssetBrowser.breadcrumb, pos + 1);
    AssetBrowser.RefreshThumbnails();
end

function AssetBrowser.ComputeBreadcrumbString()
    local str = "";
    for i=1, table.getn(AssetBrowser.breadcrumb), 1 do
        if AssetBrowser.breadcrumb[i] ~= nil then
            str = str .. "/" .. AssetBrowser.breadcrumb[i]["N"];
        end
    end

    return str;
end

function AssetBrowser.CreateThumbnails(parent)
    local idx = 1;
    AssetBrowser.thumbnails = {};
    for y=0, thumbCountY - 1, 1 do
        for x=0, thumbCountX - 1, 1 do
            --local dirName = data["D"][idx]["N"];
            local X = (x * (thumbSize + thumbSpacing));
            local Y = -(y * (thumbSize + thumbSpacing + 20));
            local W = thumbSize;
            local H = (thumbSize + 20);
            AssetBrowser.thumbnails[idx] = AssetBrowser.CreateThumbnail(X, Y, W, H, parent, "");
            idx = idx + 1;
        end
    end
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

    local idx = 0;
    local lastThumbIdx = 1;
    for i = 1, thumbCount, 1 do
        if (idx < directoryCount) then
            local dirName = AssetBrowser.currentDirectory["D"][i]["N"];
            AssetBrowser.thumbnails[i].textBox.text:SetText(dirName);
            AssetBrowser.thumbnails[i].imageBox:Show();
            AssetBrowser.thumbnails[i].modelFrame:Hide();
            AssetBrowser.thumbnails[i]:Show();
            lastThumbIdx = i;
        elseif (idx < fileCount) then
            local fileName = AssetBrowser.currentDirectory["FN"][i];
            local fileID = AssetBrowser.currentDirectory["FI"][i];
            AssetBrowser.thumbnails[i].textBox.text:SetText(fileName);
            AssetBrowser.thumbnails[i]:Show();
            AssetBrowser.thumbnails[i].modelFrame:Show();
            AssetBrowser.thumbnails[i].imageBox:Hide();
            AssetBrowser.thumbnails[i].modelFrame:SetModel(fileID);
            AssetBrowser.thumbnails[i].modelFrame:SetCamera(1);
            --AssetBrowser.thumbnails[i].modelFrame:SetPosition(0,-10,0);
            --AssetBrowser.thumbnails[i].modelFrame:SetCameraDistance(2);
        else
            AssetBrowser.thumbnails[i]:Hide();
        end
        idx = idx + 1;
    end

    print(AssetBrowser.ComputeBreadcrumbString());
end

function AssetBrowser.CreateThumbnail(x, y, w, h, parent, name)
    local thumbnail = Win.CreateButton(x, y, w, h, parent, "TOPLEFT", "TOPLEFT", "", nil, Win.BUTTON_VS);

    thumbnail:SetScript("OnClick", function (self, button, down)
            AssetBrowser.OnThumbnailClick(self.textBox.text:GetText());
       end);

    thumbnail.imageBox = Win.CreateImageBox(0, 0, w, w, thumbnail, "TOP", "TOP", "Interface\\Addons\\scenemachine\\static\\textures\\folderIcon.png");
    thumbnail.textBox = Win.CreateTextBoxSimple(5, 0, w, 20, thumbnail, "BOTTOMLEFT", "BOTTOMLEFT", name, 9);

    thumbnail.modelFrame = CreateFrame("Model", "thumbnail_model_frame_" .. x .. y, thumbnail)
    thumbnail.modelFrame:SetSize(w, w);
    thumbnail.modelFrame:SetPoint("TOP", thumbnail, "TOP", 0, 0);

    return thumbnail;
end

function AssetBrowser.OnThumbnailClick(name)

    -- Directory scan
    if (AssetBrowser.currentDirectory["D"] ~= nil) then
        local directoryCount = table.getn(AssetBrowser.currentDirectory["D"]);
        for i = 1, directoryCount, 1 do
            local dirName = AssetBrowser.currentDirectory["D"][i]["N"];
            if dirName == name then
                AssetBrowser.currentDirectory = AssetBrowser.currentDirectory["D"][i];
                table.insert(AssetBrowser.breadcrumb, AssetBrowser.currentDirectory);
                AssetBrowser.RefreshThumbnails();
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
