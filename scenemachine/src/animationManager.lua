local Win = ZWindowAPI;
local AM = SceneMachine.Editor.AnimationManager;
local SM = SceneMachine.Editor.SceneManager;
local SH = SceneMachine.Editor.SceneHierarchy;
local OP = SceneMachine.Editor.ObjectProperties;
local Renderer = SceneMachine.Renderer;
local Editor = SceneMachine.Editor;
local Input = SceneMachine.Input;
local Toolbar = Editor.Toolbar;
local Track = SceneMachine.Track;

local tabButtonHeight = 20;
local tabPool = {};

AM.needlePoolSize = 10;
AM.usedNeedles = 0;
AM.minShownNeedles = 10;
AM.maxShownNeedles = 25;
AM.needles = {};
AM.currentCrop = {
    min = 0;
    max = 0.3;
};
AM.inputState = {
    minFramePosStart = 0;
    maxFramePosStart = 0;
    centerFramePosStart = 0;
    mousePosStartX = 0;
    mousePosStartY = 0;
    movingMin = false;
    movingMax = false;
    movingCenter = false;

    movingScrollbar = false;
    scrollbarFramePosStart = 0;
};
AM.loadedTimelineIndex = 1;
AM.loadedTimeline = nil;
AM.selectedTrack = nil;

AM.TrackPoolSize = 10;
AM.usedTracks = 0;
AM.trackElementH = 30;

function AM.Update()

    if (AM.inputState.movingMin) then
        local groupBgW = AM.groupBG:GetWidth() - 30;
        local mouseDiff = (AM.inputState.mousePosStartX - Input.mouseXRaw) * Renderer.scale;
        local nextPoint = AM.inputState.minFramePosStart - mouseDiff;
        local newPoint = 0;
        if (nextPoint >= 0 and nextPoint < AM.inputState.maxFramePosStart - 32) then
            AM.cropperLeftDrag:ClearAllPoints();
            newPoint = nextPoint;
            AM.cropperLeftDrag:SetPoint("LEFT", nextPoint, 0);
        else
            if (nextPoint <= 0) then
                AM.cropperLeftDrag:ClearAllPoints();
                newPoint = 0;
                AM.cropperLeftDrag:SetPoint("LEFT", 0, 0);
            end
            if (nextPoint >= AM.inputState.maxFramePosStart - 32) then
                AM.cropperLeftDrag:ClearAllPoints();
                newPoint = AM.inputState.maxFramePosStart - 32;
                AM.cropperLeftDrag:SetPoint("LEFT", AM.inputState.maxFramePosStart - 32, 0);
            end
        end

        AM.cropperSlider:ClearAllPoints();
        AM.cropperSlider:SetPoint("LEFT", AM.cropperBg, "LEFT", newPoint + 16, 0);
        AM.cropperSlider:SetPoint("RIGHT", AM.cropperBg, "LEFT", AM.inputState.maxFramePosStart, 0);
        local newPointNormalized = newPoint / groupBgW;
        AM.currentCrop.min = newPointNormalized;
        AM.RefreshTimebar();
    end

    if (AM.inputState.movingMax) then
        local groupBgW = AM.groupBG:GetWidth() - 30;
        local mouseDiff = (AM.inputState.mousePosStartX - Input.mouseXRaw) * Renderer.scale;
        local nextPoint = AM.inputState.maxFramePosStart - mouseDiff;
        local newPoint = 0;
        if (nextPoint > AM.inputState.minFramePosStart + 32 and nextPoint < groupBgW) then
            AM.cropperRightDrag:ClearAllPoints();
            newPoint = nextPoint;
            AM.cropperRightDrag:SetPoint("LEFT", nextPoint, 0);
        else
            if (nextPoint <= AM.inputState.minFramePosStart + 32) then
                AM.cropperRightDrag:ClearAllPoints();
                newPoint = AM.inputState.minFramePosStart + 32;
                AM.cropperRightDrag:SetPoint("LEFT", AM.inputState.minFramePosStart + 32, 0);
            end
            if (nextPoint > groupBgW) then
                AM.cropperRightDrag:ClearAllPoints();
                newPoint = groupBgW;
                AM.cropperRightDrag:SetPoint("LEFT", groupBgW, 0);
            end
        end

        AM.cropperSlider:ClearAllPoints();
        AM.cropperSlider:SetPoint("RIGHT", AM.cropperBg, "LEFT", newPoint, 0);
        AM.cropperSlider:SetPoint("LEFT", AM.cropperBg, "LEFT", AM.inputState.minFramePosStart + 16, 0);
        local newPointNormalized = newPoint / groupBgW;
        AM.currentCrop.max = newPointNormalized;
        AM.RefreshTimebar();
    end

    if (AM.inputState.movingCenter) then
        local groupBgW = AM.groupBG:GetWidth() - 30;
        local sliderSize = AM.inputState.maxFramePosStart - AM.inputState.minFramePosStart;
        local mouseDiff = (AM.inputState.mousePosStartX - Input.mouseXRaw) * Renderer.scale;
        local nextPoint = AM.inputState.centerFramePosStart - mouseDiff;
        local newPoint = 0;
        if (nextPoint > 0 and nextPoint < (groupBgW) - sliderSize) then
            newPoint = nextPoint;
        else
            if (nextPoint <= 0) then
                newPoint = 0;
            end
            if (nextPoint > groupBgW - sliderSize) then
                newPoint = groupBgW - sliderSize;
            end
        end

        AM.cropperSlider:ClearAllPoints();
        AM.cropperSlider:SetPoint("RIGHT", AM.cropperBg, "LEFT", newPoint + sliderSize, 0);
        AM.cropperSlider:SetPoint("LEFT", AM.cropperBg, "LEFT", newPoint + 16, 0);
        
        AM.cropperRightDrag:ClearAllPoints();
        AM.cropperRightDrag:SetPoint("LEFT", newPoint + sliderSize, 0);
        
        AM.cropperLeftDrag:ClearAllPoints();
        AM.cropperLeftDrag:SetPoint("LEFT", newPoint, 0);

        local newPointMinNormalized = newPoint / groupBgW;
        local newPointMaxNormalized = (newPoint + sliderSize) / groupBgW;
        AM.currentCrop.max = newPointMaxNormalized;
        AM.currentCrop.min = newPointMinNormalized;
        AM.RefreshTimebar();
    end

    if (AM.inputState.movingScrollbar) then
        local groupBgH = AM.scrollbarBg:GetHeight();
        local sliderSize = AM.scrollbarSlider:GetHeight();
        local mouseDiff = (AM.inputState.mousePosStartY - Input.mouseYRaw) * Renderer.scale;
        local nextPoint = AM.inputState.scrollbarFramePosStart - mouseDiff;
        local newPoint = 0;

        if (nextPoint < 0 and nextPoint > -(groupBgH - sliderSize)) then
            newPoint = nextPoint;
        else
            if (nextPoint >= 0) then
                newPoint = 0;
            end
            if (nextPoint < -(groupBgH - sliderSize)) then
                newPoint = -(groupBgH - sliderSize);
            end
        end

        AM.scrollbarSlider:ClearAllPoints();
        AM.scrollbarSlider:SetPoint("TOP", AM.scrollbarBg, "TOP", 0, newPoint);
        
        -- Scroll the items list --
        local newPointNormalized = math.abs(newPoint) / (groupBgH - sliderSize);
        AM.workAreaList:ClearAllPoints();
        local height = AM.workAreaList:GetHeight() - AM.workAreaBG:GetHeight();
        local pos = newPointNormalized * height;
        AM.workAreaList:SetPoint("TOPLEFT", AM.workAreaBG, "TOPLEFT", 0, math.floor(pos));
    end
end

function AM.CreateAnimationManager(x, y, w, h, parent)

    local timelineTabH = 20;

    AM.groupBG = Win.CreateRectangle(x, y, w, h, parent, "TOPLEFT", "TOPLEFT",  0, 0, 0, 0);
    AM.parentFrame = parent;
    AM.groupBGy = y;
    AM.addTimelineButtonTab = AM.CreateNewTimelineTab(0, 0, timelineTabH, tabButtonHeight, AM.groupBG);
    AM.addTimelineButtonTab.text:SetText("+");
    AM.addTimelineButtonTab.ntex:SetColorTexture(0, 0, 0 ,0);
    AM.addTimelineButtonTab.text:SetAllPoints(AM.addTimelineButtonTab);
    AM.addTimelineButtonTab:Hide();

    AM.addTimelineEditBox = Win.CreateEditBox(0, 0, 100, tabButtonHeight, AM.groupBG, "TOPLEFT", "TOPLEFT", "Timeline Name");
    AM.addTimelineEditBox:Hide();

    local bottomPad = 4;
    local toolbarH = 25;
    local toolbarY = -timelineTabH
    local timebarH = 25;
    local timebarY = -timelineTabH - toolbarH;
    local cropperBarH = 16;
    local cropperBarY = bottomPad;
    local workAreaX = 10;
    local workAreaY = -(timebarH + timelineTabH + toolbarH);
    local workAreaW = w - 20;
    local workAreaH = h - (timelineTabH + timebarH + cropperBarH + bottomPad + toolbarH);
    AM.CreateTimebar(0, timebarY, w, timebarH, AM.groupBG);
    AM.CreateToolbar(0, toolbarY, w, toolbarH, AM.groupBG);
    AM.CreateToolbarTimer(toolbarH, AM.mainToolbar);
    AM.CreateScrollBar(0, workAreaY, cropperBarH, workAreaH, AM.groupBG);
    AM.CreateWorkArea(workAreaX - 6, workAreaY, workAreaW, workAreaH, AM.groupBG);
    AM.CreateCropperBar(0, cropperBarY, w - 14, cropperBarH, AM.groupBG);

    AM.RefreshTimelineTabs();
    AM.RefreshTimebar();
    AM.RefreshWorkspace();
end

function AM.CreateTimebar(x, y, w, h, parent)
    local c1 = { 0.1757, 0.1757, 0.1875 };
    local c2 = { 0.242, 0.242, 0.25 };
    local c3 = { 0, 0.4765, 0.7968 };
    local c4 = { 0.1171, 0.1171, 0.1171 };


    AM.timebarGroup = Win.CreateRectangle(x, y, w, h, parent, "TOPLEFT", "TOPLEFT",  c4[1], c4[2], c4[3], c4[4]);
    for i = 1, AM.needlePoolSize, 1 do
        local needle = AM.CreateNeedle();
        AM.needles[i] = needle;
    end
end

function AM.CreateNeedle()
    local needle = Win.CreateRectangle(0, 0, 1, 4, AM.timebarGroup, "TOPLEFT", "TOPLEFT",  1, 1, 1, 0.5);
    needle.text = needle:CreateFontString("needle text");
	needle.text:SetFont(Win.defaultFont, 8, "NORMAL");
	needle.text:SetPoint("TOP", needle, "TOP", 0, 12);
    needle.text:SetSize(30, 10);
    needle.text:SetTextColor(1,1,1,0.5);
	needle.text:SetJustifyV("CENTER");
	needle.text:SetJustifyH("CENTER");
    needle:Hide();
    return needle;
end

function AM.GetNeedle()
    local i = AM.usedNeedles + 1;
    AM.usedNeedles = AM.usedNeedles + 1;

    if i < #AM.needles then
        local needle = AM.needles[i];
        return needle;
    else
        -- create new needle
        local needle = AM.CreateNeedle();
        AM.needles[i] = needle;
        return needle;
    end
end

function AM.CreateToolbar(x, y, w, h, parent)
    local toolbar = Toolbar.Create(x, y, w, h, parent, 0.16);
    toolbar.CreateGroup(x, 0, w, h, toolbar,
    {
        { type = "DragHandle" },
        { type = "Button", name = "TimeSettings", icon = toolbar.getIcon("timesettings"), action = function(self) end },
        --{ type = "Dropdown", name = "ProjectList", width = 200, options = {}, action = function(index) Editor.ProjectManager.LoadProjectByIndex(index); end },
        { type = "Separator" },
        { type = "Button", name = "AddObject", icon = toolbar.getIcon("addobj"), action = function(self) AM.AddTrack(SM.selectedObject); end },
        { type = "Button", name = "RemoveObject", icon = toolbar.getIcon("removeobj"), action = function(self) AM.RemoveTrack(AM.selectedTrack) end },
        { type = "Separator" },
        { type = "Button", name = "AddAnim", icon = toolbar.getIcon("addanim"), action = function(self) end },
        { type = "Button", name = "RemoveAnim", icon = toolbar.getIcon("removeanim"), action = function(self)  end },
        { type = "Separator" },
        { type = "Button", name = "SkipToStart", icon = toolbar.getIcon("skiptoend", true), action = function(self)  end },
        { type = "Button", name = "SkipOneFrameBack", icon = toolbar.getIcon("skiponeframe", true), action = function(self)  end },
        { type = "Button", name = "PlayPause", icon = toolbar.getIcon("play"), action = function(self)  end },
        { type = "Button", name = "SkipOneFrameForward", icon = toolbar.getIcon("skiponeframe"), action = function(self)  end },
        { type = "Button", name = "SkipToEnd", icon = toolbar.getIcon("skiptoend"), action = function(self)  end },
        { type = "Separator" },
    });
    AM.mainToolbar = toolbar;
end

function AM.CreateToolbarTimer(h, parent)
    local font = "Interface\\Addons\\scenemachine\\static\\font\\digital-7.ttf"
    AM.timerTextBox = Win.CreateTextBoxSimple(0, 0, 90, h, parent, "RIGHT", "RIGHT", "00:00 / 00:00", 16, font);
end

function AM.CreateWorkArea(x, y, w, h, parent)
    local c1 = { 0.1757, 0.1757, 0.1875 };
    local c2 = { 0.242, 0.242, 0.25 };
    local c3 = { 0, 0.4765, 0.7968 };
    local c4 = { 0.1171, 0.1171, 0.1171 };
    
    AM.workAreaBG = Win.CreateRectangle(x, y, w, h, parent, "TOPLEFT", "TOPLEFT",  0, 0, 0, 0);
    AM.workAreaBG:SetClipsChildren(true);

    AM.workAreaViewport = Win.CreateRectangle(6, 0, w, h, AM.workAreaBG, "TOPLEFT", "TOPLEFT",  c1[1], c1[2], c1[3], c1[4]);

    AM.workAreaList = Win.CreateRectangle(0, 0, w, h, AM.workAreaViewport, "TOPLEFT", "TOPLEFT",  c1[1], c1[2], c1[3], c1[4]);
    AM.TrackPool = {};

    for i = 1, AM.TrackPoolSize, 1 do
        AM.TrackPool[i] = AM.GenerateTrackElement(i, 0, -((AM.trackElementH + Editor.pmult) * (i - 1)), w, AM.trackElementH, AM.workAreaList, c2[1], c2[2], c2[3], c2[4]);
    end

    -- track selection box thing
    AM.trackSelectionBox = Win.CreateRectangle(-6, 0, 5, AM.trackElementH, AM.workAreaList, "TOPLEFT", "TOPLEFT",  c3[1], c3[2], c3[3], c3[4]);
    AM.trackSelectionBox:Hide();

    AM.RefreshWorkspace();
end

function AM.GenerateTrackElement(index, x, y, w, h, parent, R, G, B, A)
    local element = Win.CreateButton(x, y, w, h, parent, "TOPLEFT", "TOPLEFT");--Win.CreateRectangle(x, y, w, h, parent, "TOPLEFT", "TOPLEFT",  R, G, B, A);
    element:SetAlpha(0.6);
    element.name = Win.CreateTextBoxSimple(2, 0, 200, 10, element, "TOPLEFT", "TOPLEFT", index, 8);
    element.name:SetAlpha(0.7);
    element:SetScript("OnClick", function (self, button, down)
        if (AM.loadedTimeline) then
            AM.SelectTrack(index);
        end
    end)
    element:Hide();

    return element;
end

function AM.GetAvailableTrack()
    local i = AM.usedTracks + 1;
    AM.usedTracks = AM.usedTracks + 1;

    if (i >= #AM.TrackPool) then
        AM.TrackPool[i] = AM.GenerateTrackElement(i, 0, -((AM.trackElementH + Editor.pmult) * (i - 1)), w, AM.trackElementH, AM.workAreaList);
    end

    return AM.TrackPool[i];
end

function AM.CreateCropperBar(x, y, w, h, parent)
    AM.cropperBg = Win.CreateRectangle(x, y, w, h, parent, "BOTTOMLEFT", "BOTTOMLEFT",  0, 0, 0, 0);

    AM.cropperBgCenter = Win.CreateImageBox(0, 0, w - (h * 2), h, AM.cropperBg, "CENTER", "CENTER",
        "Interface\\Addons\\scenemachine\\static\\textures\\cropBar.png", { 0.25 + 0.125, 0.75 - 0.125, 0, 0.5 });
    AM.cropperBgCenter.texture:SetVertexColor(0.18,0.18,0.18,1);

    AM.cropperBgLeft = Win.CreateImageBox(0, 0, h, h, AM.cropperBg, "LEFT", "LEFT",
        "Interface\\Addons\\scenemachine\\static\\textures\\cropBar.png", { 0, 0.5, 0, 0.5 });
    AM.cropperBgLeft.texture:SetVertexColor(0.18,0.18,0.18,1);

    AM.cropperBgRight = Win.CreateImageBox(0, 0, h, h, AM.cropperBg, "RIGHT", "RIGHT",
        "Interface\\Addons\\scenemachine\\static\\textures\\cropBar.png", { 0.5, 1.0, 0, 0.5 });
    AM.cropperBgRight.texture:SetVertexColor(0.18,0.18,0.18,1);

    local initialSliderLength = w * (AM.currentCrop.max - AM.currentCrop.min) - 10;

    -- Left handle
    AM.cropperLeftDrag = CreateFrame("Button", "AM.cropperLeftDrag", AM.cropperBg)
	AM.cropperLeftDrag:SetPoint("LEFT", AM.cropperBg, "LEFT", 0, 0);
	AM.cropperLeftDrag:SetSize(h, h);
    --AM.cropperLeftDrag:SetAlpha(0.5);
    AM.cropperLeftDrag.ntex = AM.cropperLeftDrag:CreateTexture();
    AM.cropperLeftDrag.ntex:SetTexture("Interface\\Addons\\scenemachine\\static\\textures\\cropBar.png")
    AM.cropperLeftDrag.ntex:SetTexCoord(0, 0.5, 0, 0.5);    -- (left,right,top,bottom)
    AM.cropperLeftDrag.ntex:SetAllPoints();
    AM.cropperLeftDrag.ntex:SetVertexColor(0.3,0.3,0.3,1);
    AM.cropperLeftDrag:SetNormalTexture(AM.cropperLeftDrag.ntex);
    AM.cropperLeftDrag:RegisterForClicks("LeftButtonUp", "LeftButtonDown");
    AM.cropperLeftDrag:SetScript("OnMouseDown", function(self, button)
        AM.inputState.movingMin = true;
        local gpointL, grelativeToL, grelativePointL, gxOfsL, gyOfsL = AM.cropperLeftDrag:GetPoint(1);
        AM.inputState.minFramePosStart = gxOfsL;
        local gpointR, grelativeToR, grelativePointR, gxOfsR, gyOfsR = AM.cropperRightDrag:GetPoint(1);
        AM.inputState.maxFramePosStart = gxOfsR;
        AM.inputState.mousePosStartX = Input.mouseXRaw;
    end);
    AM.cropperLeftDrag:SetScript("OnMouseUp", function(self, button) AM.inputState.movingMin = false; end);
    local burgerLD = Win.CreateImageBox(0, 0, h, h, AM.cropperLeftDrag, "CENTER", "CENTER", "Interface\\Addons\\scenemachine\\static\\textures\\cropBar.png", { 0, 0.5, 0.5, 1 })
    burgerLD:SetAlpha(0.2);

    -- Right handle
    AM.cropperRightDrag = CreateFrame("Button", "AM.cropperRightDrag", AM.cropperBg)
	AM.cropperRightDrag:SetPoint("LEFT", AM.cropperBg, "LEFT", initialSliderLength, 0);
	AM.cropperRightDrag:SetSize(h, h);
    --AM.cropperRightDrag:SetAlpha(0.5);
    AM.cropperRightDrag.ntex = AM.cropperRightDrag:CreateTexture();
    AM.cropperRightDrag.ntex:SetTexture("Interface\\Addons\\scenemachine\\static\\textures\\cropBar.png")
    AM.cropperRightDrag.ntex:SetTexCoord(0.5, 1.0, 0, 0.5);    -- (left,right,top,bottom)
    AM.cropperRightDrag.ntex:SetAllPoints();
    AM.cropperRightDrag.ntex:SetVertexColor(0.3,0.3,0.3,1);
    AM.cropperRightDrag:SetNormalTexture(AM.cropperRightDrag.ntex);
    AM.cropperRightDrag:RegisterForClicks("LeftButtonUp", "LeftButtonDown");
    AM.cropperRightDrag:SetScript("OnMouseDown", function(self, button)
        AM.inputState.movingMax = true;
        local gpointL, grelativeToL, grelativePointL, gxOfsL, gyOfsL = AM.cropperLeftDrag:GetPoint(1);
        AM.inputState.minFramePosStart = gxOfsL;
        local gpointR, grelativeToR, grelativePointR, gxOfsR, gyOfsR = AM.cropperRightDrag:GetPoint(1);
        AM.inputState.maxFramePosStart = gxOfsR;
        AM.inputState.mousePosStartX = Input.mouseXRaw;
    end);
    AM.cropperRightDrag:SetScript("OnMouseUp", function(self, button) AM.inputState.movingMax = false; end);
    local burgerRD = Win.CreateImageBox(0, 0, h, h, AM.cropperRightDrag, "CENTER", "CENTER", "Interface\\Addons\\scenemachine\\static\\textures\\cropBar.png", { 0, 0.5, 0.5, 1 })
    burgerRD:SetAlpha(0.2);

    -- Middle handle
    AM.cropperSlider = CreateFrame("Button", "AM.cropperSlider", AM.cropperBg)
	AM.cropperSlider:SetPoint("LEFT", AM.cropperBg, "LEFT", h, 0);
	AM.cropperSlider:SetSize(initialSliderLength-h, h);
    --AM.cropperSlider:SetAlpha(0.5);
    AM.cropperSlider.ntex = AM.cropperSlider:CreateTexture();
    AM.cropperSlider.ntex:SetTexture("Interface\\Addons\\scenemachine\\static\\textures\\cropBar.png")
    AM.cropperSlider.ntex:SetTexCoord(0.25 + 0.125, 0.75 - 0.125, 0, 0.5);    -- (left,right,top,bottom)
    AM.cropperSlider.ntex:SetAllPoints();
    AM.cropperSlider.ntex:SetVertexColor(0.3,0.3,0.3,1);
    AM.cropperSlider:SetNormalTexture(AM.cropperSlider.ntex);
    AM.cropperSlider:SetScript("OnMouseDown", function(self, button)
        AM.inputState.movingCenter = true;
        local gpointC, grelativeToC, grelativePointC, gxOfsC, gyOfsC = AM.cropperSlider:GetPoint(1);
        AM.inputState.centerFramePosStart = gxOfsC - 16;
        local gpointL, grelativeToL, grelativePointL, gxOfsL, gyOfsL = AM.cropperLeftDrag:GetPoint(1);
        AM.inputState.minFramePosStart = gxOfsL;
        local gpointR, grelativeToR, grelativePointR, gxOfsR, gyOfsR = AM.cropperRightDrag:GetPoint(1);
        AM.inputState.maxFramePosStart = gxOfsR;
        AM.inputState.mousePosStartX = Input.mouseXRaw;
    end);
    AM.cropperSlider:SetScript("OnMouseUp", function(self, button) AM.inputState.movingCenter = false; end);
end

function AM.CreateScrollBar(x, y, w, h, parent)
    AM.scrollbarBg = Win.CreateRectangle(x, y, w, h, parent, "TOPRIGHT", "TOPRIGHT",  0, 0, 0, 0);
    
    AM.scrollbarBgCenter = Win.CreateImageBox(0, 0, w, h - w, AM.scrollbarBg, "CENTER", "CENTER",
        "Interface\\Addons\\scenemachine\\static\\textures\\scrollBar.png", { 0, 1, 0.4, 0.6 });
    AM.scrollbarBgCenter.texture:SetVertexColor(0.18,0.18,0.18,1);
    
    AM.scrollbarBgTop = Win.CreateImageBox(0, 0, w, w / 2, AM.scrollbarBg, "TOP", "TOP",
        "Interface\\Addons\\scenemachine\\static\\textures\\scrollBar.png", { 0, 1, 0, 0.5 });
    AM.scrollbarBgTop.texture:SetVertexColor(0.18,0.18,0.18,1);

    AM.scrollbarBgBottom = Win.CreateImageBox(0, 0, w, w / 2, AM.scrollbarBg, "BOTTOM", "BOTTOM",
        "Interface\\Addons\\scenemachine\\static\\textures\\scrollBar.png", { 0, 1, 0.5, 1 });
    AM.scrollbarBgBottom.texture:SetVertexColor(0.18,0.18,0.18,1);

    -- Scrollbar
    AM.scrollbarSlider = CreateFrame("Button", "AM.scrollbarSlider", AM.scrollbarBg)
	AM.scrollbarSlider:SetPoint("TOP", AM.scrollbarBg, "TOP", 0, 0);
	AM.scrollbarSlider:SetSize(w, 50);
    AM.scrollbarSlider.ntex = AM.scrollbarSlider:CreateTexture();
    AM.scrollbarSlider.ntex:SetColorTexture(0,0,0,0);
    AM.scrollbarSlider.ntex:SetAllPoints();
    AM.scrollbarSlider:SetNormalTexture(AM.scrollbarSlider.ntex);
    AM.scrollbarSlider:SetScript("OnMouseDown", function(self, button)
        if (math.ceil(self:GetHeight()) == AM.workAreaBG:GetHeight()) then
            return;
        end
        AM.inputState.movingScrollbar = true;
        AM.inputState.mousePosStartY = Input.mouseYRaw;
        local gpointC, grelativeToC, grelativePointC, gxOfsC, gyOfsC = AM.scrollbarSlider:GetPoint(1);
        AM.inputState.scrollbarFramePosStart = gyOfsC;
    end);
    AM.scrollbarSlider:SetScript("OnMouseUp", function(self, button) AM.inputState.movingScrollbar = false; end);

    AM.scrollbarSliderCenter = Win.CreateImageBox(0, 0, w, h, AM.scrollbarSlider, "CENTER", "CENTER",
        "Interface\\Addons\\scenemachine\\static\\textures\\scrollBar.png", { 0, 1, 0.4, 0.6 });
        AM.scrollbarSliderCenter:ClearAllPoints();
        AM.scrollbarSliderCenter:SetPoint("TOP", AM.scrollbarSlider, "TOP", 0, -w / 2);
        AM.scrollbarSliderCenter:SetPoint("BOTTOM", AM.scrollbarSlider, "BOTTOM", 0, w / 2);
    AM.scrollbarSliderCenter.texture:SetVertexColor(0.3,0.3,0.3,1);

    AM.scrollbarSliderTop = Win.CreateImageBox(0, 0, w, w / 2, AM.scrollbarSlider, "TOP", "TOP",
        "Interface\\Addons\\scenemachine\\static\\textures\\scrollBar.png", { 0, 1, 0, 0.5 });
    AM.scrollbarSliderTop.texture:SetVertexColor(0.3,0.3,0.3,1);

    AM.scrollbarSliderBottom = Win.CreateImageBox(0, 0, w, w / 2, AM.scrollbarSlider, "BOTTOM", "BOTTOM",
        "Interface\\Addons\\scenemachine\\static\\textures\\scrollBar.png", { 0, 1, 0.5, 1 });
    AM.scrollbarSliderBottom.texture:SetVertexColor(0.3,0.3,0.3,1);

    AM.scrollbarSlider:SetHeight(50);
end

function AM.CreateDefaultTimeline()
    return AM.CreateTimeline();
end

function AM.TimelineTabButton_OnClick(index)
    AM.LoadTimeline(index);
end

function AM.TimelineTabButton_OnRightClick(index, x, y)
    local gpoint, grelativeTo, grelativePoint, gxOfs, gyOfs = AM.parentFrame:GetPoint(1);   -- point is at bottom left of SceneMachine.mainWindow
    gyOfs = gyOfs - (SceneMachine.mainWindow:GetHeight() - AM.parentFrame:GetHeight());

	local menuOptions = {
        [1] = { ["Name"] = "Rename", ["Action"] = function() AM.Button_RenameTimeline(index, x) end },
        [2] = { ["Name"] = "Edit", ["Action"] = function()  AM.Button_EditTimeline(index) end },
        [3] = { ["Name"] = "Delete", ["Action"] = function() AM.Button_DeleteTimeline(index) end },
	};

    Win.PopupWindowMenu(x + gxOfs, y + gyOfs, SceneMachine.mainWindow, menuOptions);
end

function AM.Button_RenameTimeline(index, x)
    AM.addTimelineEditBox:Show();
    AM.addTimelineEditBox:SetText("Timeline " .. (#SM.loadedScene.timelines));
    AM.addTimelineButtonTab:Hide();
    AM.addTimelineEditBox:SetPoint("TOPLEFT", AM.groupBG, "TOPLEFT", x, 0);
    AM.addTimelineEditBox:SetFocus();

    local previousName = "";
    if (index ~= -1) then
        -- copy current text to edit box
        previousName = tabPool[index].text:GetText();
        AM.addTimelineEditBox:SetText(previousName);
        AM.addTimelineEditBox:SetPoint("TOPLEFT", AM.groupBG, "TOPLEFT", x + 10, 0);
        -- clearing current visible name
        tabPool[index].text:SetText("");
    end

    AM.addTimelineEditBox:SetScript('OnEscapePressed', function(self1) 
        self1:ClearFocus();
        Win.focused = false;
        self1:Hide();
        AM.addTimelineButtonTab:Show();
        if (index ~= -1) then
            -- restore previous visible name
            tabPool[index].text:SetText(previousName);
        end
    end);
    AM.addTimelineEditBox:SetScript('OnEnterPressed', function(self1)
        self1:ClearFocus();
        Win.focused = false;
        local text = self1:GetText();
        if (text ~= nil and text ~= "") then
            if (index == -1) then
                -- create a new timeline
                SM.loadedScene.timelines[#SM.loadedScene.timelines + 1] = AM.CreateTimeline(text);
            else
                -- rename existing timeline
                --PM.currentProject.scenes[index].name = text;
                SM.loadedScene.timelines[index].name = text;
            end
            AM.RefreshTimelineTabs();
        end
        self1:Hide();
        AM.addTimelineButtonTab:Show();
    end);
end

function AM.Button_EditTimeline()
    -- not sure what this will do
end

function AM.Button_DeleteTimeline()
    Win.OpenMessageBox(SceneMachine.mainWindow, 
    "Delete Timeline", "Are you sure you wish to continue?",
    true, true, function() 
        AM.DeleteTimeline(index);
    end, function() end);
    Win.messageBox:SetFrameStrata(Editor.MESSAGE_BOX_FRAME_STRATA);
end

function AM.CreateTimeline(timelineName)
    if (timelineName == nil) then
        timelineName = "Timeline " .. #SM.loadedScene.timelines;
    end

    return {
        name = timelineName,
        currentTime = 0,
        duration = 30000, -- 30000 miliseconds, 30 seconds
        tracks = {},
    }
end

function AM.AddTrack(object)
    if (not object) then
        return;
    end

    if (not AM.loadedTimeline) then
        return;
    end

    if (not AM.loadedTimeline.tracks) then
        AM.loadedTimeline.tracks = {};
    end

    local track = Track:New(object);

    AM.loadedTimeline.tracks[#AM.loadedTimeline.tracks + 1] = track;

    AM.RefreshWorkspace();
end

function AM.RemoveTrack(track)
    if (not AM.loadedTimeline) then
        return;
    end

    if (AM.selectedTrack == nil) then
        return;
    end

    if (AM.selectedTrack == track) then
        AM.selectedTrack = nil;
    end

    if (#AM.loadedTimeline.tracks > 0) then
        for i in pairs(AM.loadedTimeline.tracks) do
            if (AM.loadedTimeline.tracks[i] == track) then
                table.remove(AM.loadedTimeline.tracks, i);
            end
        end
    end

    AM.RefreshWorkspace();
end

function AM.SelectTrack(index)
    if (not AM.loadedTimeline.tracks[index]) then
        return;
    end

    AM.selectedTrack = AM.loadedTimeline.tracks[index];

    -- also select object
    if (AM.selectedTrack.objectID) then
        if (not SM.loadedScene.objects) then
            return;
        end
    
        for i in pairs(SM.loadedScene.objects) do
            if (SM.loadedScene.objects[i].id == AM.selectedTrack.objectID) then
                SM.selectedObject = SM.loadedScene.objects[i];
                SH.RefreshHierarchy();
                OP.Refresh();
            end
        end
    end

    AM.RefreshSelectedTrack(index);
end

function AM.LoadTimeline(index)
    AM.loadedTimelineIndex = index;

    if (#SM.loadedScene.timelines == 0) then
        -- current project has no timelines, create a default one
        SM.loadedScene.timelines[1] = AM.CreateDefaultTimeline();
        AM.RefreshTimelineTabs();
    end

    -- unload current --
    AM.UnloadTimeline();

    -- load new --
    local timeline = SM.loadedScene.timelines[index];
    AM.loadedTimeline = timeline;

    -- refresh the ui
    AM.RefreshTimebar();
    AM.RefreshTimelineTabs();
    AM.RefreshWorkspace();

    SM.selectedObject = nil;
end

function AM.UnloadTimeline()
    SM.selectedObject = nil;
end

function AM.DeleteTimeline()
    -- switch to a different timeline because the currently loaded is being deleted
    -- load first that isn't this one
    for i in pairs(SM.loadedScene.timelines) do
        local timeline = SM.loadedScene.timelines[i];
        if (i ~= index) then
            AM.LoadTimeline(i);
            break;
        end
    end

    -- delete it
    table.remove(SM.loadedScene.timelines, index);

    -- if this was the only scene then create a new default one
    if (#SM.loadedScene.timelines == 1) then
        AM.CreateDefaultTimeline();
        AM.LoadTimeline(1);
    end

    -- refresh ui
    AM.RefreshTimelineTabs();
    AM.RefreshWorkspace();
end

function AM.CreateNewTimelineTab(x, y, w, h, parent)
	local ButtonFont = Win.defaultFont;
	local ButtonFontSize = 9;

	-- main button frame --
	local item = CreateFrame("Button", "Zee.WindowAPI.Button", parent)
	item:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y);
	item:SetWidth(w);
	item:SetHeight(h)
	item.ntex = item:CreateTexture()
	item.htex = item:CreateTexture()
	item.ptex = item:CreateTexture()
	item.ntex:SetColorTexture(0.1757, 0.1757, 0.1875 ,1);
	item.htex:SetColorTexture(0.242, 0.242, 0.25,1);
	item.ptex:SetColorTexture(0, 0.4765, 0.7968,1);
	item.ntex:SetAllPoints()	
	item.ptex:SetAllPoints()
	item.htex:SetAllPoints()
	item:SetNormalTexture(item.ntex)
	item:SetHighlightTexture(item.htex)
	item:SetPushedTexture(item.ptex)

	-- project name text --
	item.text = item:CreateFontString("Zee.WindowAPI.Button Text");
	item.text:SetFont(ButtonFont, ButtonFontSize, "NORMAL");
	--item.text:SetPoint("LEFT", item, "LEFT", 10, 0);
    item.text:SetAllPoints(item);
	item.text:SetText(name);

	return item;
end

function AM.RefreshTimelineTabs()
    -- clear --
    for idx in pairs(tabPool) do
        tabPool[idx]:Hide();
    end

    -- add available timelines --
    local x = 0;
    if (SM.loadedScene ~= nil) then
        for i in pairs(SM.loadedScene.timelines) do
            local timeline = SM.loadedScene.timelines[i];
            if (tabPool[i] == nil) then
                tabPool[i] = AM.CreateNewTimelineTab(x, 0, 50, tabButtonHeight, AM.groupBG);
                tabPool[i].text:SetText(timeline.name);
                tabPool[i]:SetWidth(tabPool[i].text:GetStringWidth() + 20);
                tabPool[i]:RegisterForClicks("LeftButtonUp", "RightButtonUp");
                tabPool[i]:SetScript("OnClick", function(self, button, down)
                    if (button == "LeftButton") then
                        AM.TimelineTabButton_OnClick(i);
                    elseif (button == "RightButton") then
                        local point, relativeTo, relativePoint, xOfs, yOfs = tabPool[i]:GetPoint(1);
                        AM.TimelineTabButton_OnClick(i);
                        AM.TimelineTabButton_OnRightClick(i, xOfs, -5);
                    end
                end);
            else
                tabPool[i].text:SetText(timeline.name);
                tabPool[i]:SetWidth(tabPool[i].text:GetStringWidth() + 20);
            end

            tabPool[i]:Show();

            if (AM.loadedTimelineIndex == i) then
                tabPool[i].ntex:SetColorTexture(0.1757, 0.1757, 0.1875 ,1);
            else
                tabPool[i].ntex:SetColorTexture(0, 0, 0 ,0);
            end

            x = x + tabPool[i]:GetWidth() + 1;
        end
    end

    -- add new scene button --
    AM.addTimelineButtonTab:Show();
    AM.addTimelineEditBox:Hide();
    AM.addTimelineButtonTab:SetPoint("TOPLEFT", AM.groupBG, "TOPLEFT", x, 0);
    AM.addTimelineButtonTab:SetScript("OnClick", function(self) 
        AM.Button_RenameTimeline(-1, x);
    end);
end

function AM.RefreshTimebar()
    if (not AM.loadedTimeline) then return; end

    -- Clear needles
    AM.usedNeedles = 0;
    for i = 1, #AM.needles, 1 do
        AM.needles[i]:Hide();
    end

    -- Refresh needles
    local timeBarW = AM.timebarGroup:GetWidth();
    local workAreaW = AM.workAreaBG:GetWidth();
    local totalTimeMs = AM.loadedTimeline.duration;
    
    local startTimeMs = AM.currentCrop.min * totalTimeMs;
    local startTimeS = startTimeMs / 1000;
    local endTimeMs = AM.currentCrop.max * totalTimeMs;
    local endTimeS = endTimeMs / 1000;
    local croppedTimeMs = endTimeMs - startTimeMs;
    local croppedTimeS = croppedTimeMs / 1000;

    local needlesNeededF = croppedTimeS + 1;
    local needleSpacing = workAreaW / (needlesNeededF - 1);
    
    local needleTimeSpacing = 1;    -- 1 second
    while (needlesNeededF < AM.minShownNeedles) do
        needlesNeededF = needlesNeededF * 2;
        needleTimeSpacing = needleTimeSpacing / 2;
    end
    while (needlesNeededF > AM.maxShownNeedles) do
        needlesNeededF = needlesNeededF / 2;
        needleTimeSpacing = needleTimeSpacing * 2;
    end

    local needleStartOffs = 0;
    local numberOffs = 0;
    local dif = (math.ceil(startTimeS, 1) - startTimeS);
    if (needleTimeSpacing > 1) then
        dif = (math.ceil(startTimeS, (1 / needleTimeSpacing)) - startTimeS);
    end

    if (dif ~= 0) then
        needleStartOffs = -needleSpacing * (1.0 - dif);
        numberOffs = 1;
        if (needleTimeSpacing > 1) then
            needleStartOffs = -needleSpacing * (1.0 - dif);
        end
        --print(dif)
        --print(needleStartOffs)
    end

    local needlesNeededCount = math.ceil(needlesNeededF);
    if (needleTimeSpacing < 1) then
        needlesNeededCount = needlesNeededCount - (1 / needleTimeSpacing);
    end

    if (needleStartOffs ~= 0 and needleTimeSpacing < 1) then
        needlesNeededCount = needlesNeededCount + (1 / needleTimeSpacing);
    end

    needleSpacing = needleSpacing * needleTimeSpacing;

    if (needleTimeSpacing > 1) then
        --needleStartOffs = needleStartOffs * needleTimeSpacing;
        --startTimeS = startTimeS + 1.0
    end

    for i = 1, needlesNeededCount, 1 do
        local pos = needleStartOffs + ((i - 1) * needleSpacing) + 10;
        local text = math.ceil(startTimeS) + ((i - 1) * needleTimeSpacing) - numberOffs .. "s";
        local needle = AM.GetNeedle();
        needle:ClearAllPoints();
        needle:SetPoint("BOTTOMLEFT", pos, 0);
        needle.text:SetText(text);
        needle:Show();

        -- hide last one if out of bounds
        if (pos > timeBarW) then
            needle:Hide();
        end

        -- hide first one if out of bounds
        if (i == 1) then
            if (pos < 0) then
                needle:Hide();
            end
        end
    end
end

function AM.RefreshWorkspace()
    -- reset used
    AM.usedTracks = 0;

    -- load tracks
    local usedTracks = 0;
    if (AM.loadedTimeline) then
        print(#AM.loadedTimeline.tracks)
        usedTracks = #AM.loadedTimeline.tracks;
        for i = 1, #AM.loadedTimeline.tracks, 1 do
            local track = AM.loadedTimeline.tracks[i];
            local trackElement = AM.GetAvailableTrack();
            trackElement:Show();

            -- TODO : populate element with track data
            trackElement.name.text:SetText(track.name);
        end
        -- hide the rest
        for i = usedTracks + 1, #AM.TrackPool, 1 do
            if (AM.TrackPool[i]) then
                AM.TrackPool[i]:Hide();
            end
        end

    end
    
    -- make list fit elements
    local workAreaListHeight = usedTracks * (AM.trackElementH + Editor.pmult);
    AM.workAreaList:SetHeight(workAreaListHeight);
    
    -- resize scrollbar
    if (AM.scrollbarSlider) then
        local workAreaHeight = AM.workAreaBG:GetHeight();
        local minScrollbar = 20;
        local maxScrollbar = workAreaHeight;
        local desiredScrollbar = (workAreaHeight / workAreaListHeight) * workAreaHeight;
        local newScrollbarHeight = max(minScrollbar, min(maxScrollbar, desiredScrollbar));
        AM.scrollbarSlider:SetHeight(newScrollbarHeight);
    end

    -- update timer
    if (AM.loadedTimeline) then
        local totalTime = AM.TimeValueToString(AM.loadedTimeline.duration);
        local currentTime = AM.TimeValueToString(AM.loadedTimeline.currentTime or 0);
        AM.timerTextBox.text:SetText(currentTime .. "-" .. totalTime);
    end
end

function AM.RefreshSelectedTrack(index)
    AM.trackSelectionBox:Show();
    AM.trackSelectionBox:ClearAllPoints();
    AM.trackSelectionBox:SetPoint("TOPLEFT", AM.workAreaList, "TOPLEFT", -6, (index - 1) * -(AM.trackElementH + Editor.pmult));
end

function AM.TimeValueToString(duration)
    local durationS = duration / 1000;
    local durationM = math.floor(durationS / 60);
    durationS = durationS - (60 * durationM);
    return string.format("%02d:%02d", durationM, durationS);
end