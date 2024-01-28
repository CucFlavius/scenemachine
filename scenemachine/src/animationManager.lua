local Win = ZWindowAPI;
local AM = SceneMachine.Editor.AnimationManager;
local SM = SceneMachine.Editor.SceneManager;
local Renderer = SceneMachine.Renderer;
local Editor = SceneMachine.Editor;
local Input = SceneMachine.Input;
local Toolbar = Editor.Toolbar;

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
    movingMin = false;
    movingMax = false;
    movingCenter = false;
};
AM.loadedTimelineIndex = 1;
AM.loadedTimeline = nil;

function AM.Update()

    if (AM.inputState.movingMin) then
        local mouseDiff = (AM.inputState.mousePosStartX - Input.mouseXRaw) * Renderer.scale;
        local nextPoint = AM.inputState.minFramePosStart - mouseDiff;
        local newPoint = 0;
        if (nextPoint >= 0 and nextPoint < AM.inputState.maxFramePosStart - 20) then
            AM.cropperLeftDrag:ClearAllPoints();
            newPoint = nextPoint;
            AM.cropperLeftDrag:SetPoint("LEFT", nextPoint, 0);
        else
            if (nextPoint <= 0) then
                AM.cropperLeftDrag:ClearAllPoints();
                newPoint = 0;
                AM.cropperLeftDrag:SetPoint("LEFT", 0, 0);
            end
            if (nextPoint >= AM.inputState.maxFramePosStart - 20) then
                AM.cropperLeftDrag:ClearAllPoints();
                newPoint = AM.inputState.maxFramePosStart - 20;
                AM.cropperLeftDrag:SetPoint("LEFT", AM.inputState.maxFramePosStart - 20, 0);
            end
        end

        AM.cropperSlider:ClearAllPoints();
        AM.cropperSlider:SetPoint("LEFT", AM.cropperBg, "LEFT", newPoint, 0);
        AM.cropperSlider:SetPoint("RIGHT", AM.cropperBg, "LEFT", AM.inputState.maxFramePosStart, 0);
        local newPointNormalized = newPoint / (AM.groupBG:GetWidth() - 10);
        AM.currentCrop.min = newPointNormalized;
        AM.RefreshTimebar();
    end

    if (AM.inputState.movingMax) then
        local mouseDiff = (AM.inputState.mousePosStartX - Input.mouseXRaw) * Renderer.scale;
        local nextPoint = AM.inputState.maxFramePosStart - mouseDiff;
        local newPoint = 0;
        if (nextPoint > AM.inputState.minFramePosStart + 20 and nextPoint < AM.groupBG:GetWidth() - 10) then
            AM.cropperRightDrag:ClearAllPoints();
            newPoint = nextPoint;
            AM.cropperRightDrag:SetPoint("LEFT", nextPoint, 0);
        else
            if (nextPoint <= AM.inputState.minFramePosStart + 20) then
                AM.cropperRightDrag:ClearAllPoints();
                newPoint = AM.inputState.minFramePosStart + 20;
                AM.cropperRightDrag:SetPoint("LEFT", AM.inputState.minFramePosStart + 20, 0);
            end
            if (nextPoint > AM.groupBG:GetWidth() - 10) then
                AM.cropperRightDrag:ClearAllPoints();
                newPoint = AM.groupBG:GetWidth() - 10;
                AM.cropperRightDrag:SetPoint("LEFT", AM.groupBG:GetWidth() - 10, 0);
            end
        end

        AM.cropperSlider:ClearAllPoints();
        AM.cropperSlider:SetPoint("RIGHT", AM.cropperBg, "LEFT", newPoint, 0);
        AM.cropperSlider:SetPoint("LEFT", AM.cropperBg, "LEFT", AM.inputState.minFramePosStart, 0);
        local newPointNormalized = newPoint / (AM.groupBG:GetWidth() - 10);
        AM.currentCrop.max = newPointNormalized;
        AM.RefreshTimebar();
    end

    if (AM.inputState.movingCenter) then
        local sliderSize = AM.inputState.maxFramePosStart - AM.inputState.minFramePosStart;
        local mouseDiff = (AM.inputState.mousePosStartX - Input.mouseXRaw) * Renderer.scale;
        local nextPoint = AM.inputState.centerFramePosStart - mouseDiff;
        local newPoint = 0;
        if (nextPoint > 0 and nextPoint < (AM.groupBG:GetWidth() - 10) - sliderSize) then
            newPoint = nextPoint;
        else
            if (nextPoint <= 0) then
                newPoint = 0;
            end
            if (nextPoint > (AM.groupBG:GetWidth() - 10) - sliderSize) then
                newPoint = (AM.groupBG:GetWidth() - 10) - sliderSize;
            end
        end

        AM.cropperSlider:ClearAllPoints();
        AM.cropperSlider:SetPoint("RIGHT", AM.cropperBg, "LEFT", newPoint + sliderSize, 0);
        AM.cropperSlider:SetPoint("LEFT", AM.cropperBg, "LEFT", newPoint, 0);
        
        AM.cropperRightDrag:ClearAllPoints();
        AM.cropperRightDrag:SetPoint("LEFT", newPoint + sliderSize, 0);
        
        AM.cropperLeftDrag:ClearAllPoints();
        AM.cropperLeftDrag:SetPoint("LEFT", newPoint, 0);

        local newPointMinNormalized = newPoint / (AM.groupBG:GetWidth() - 10);
        local newPointMaxNormalized = (newPoint + sliderSize) / (AM.groupBG:GetWidth() - 10);
        AM.currentCrop.max = newPointMaxNormalized;
        AM.currentCrop.min = newPointMinNormalized;
        AM.RefreshTimebar();
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
    local cropperBarH = 12;
    local cropperBarY = bottomPad;
    local workAreaX = 10;
    local workAreaY = -(timebarH + timelineTabH + toolbarH);
    local workAreaW = w - 20;
    local workAreaH = h - (timelineTabH + timebarH + cropperBarH + bottomPad + toolbarH);
    AM.CreateTimebar(0, timebarY, w, timebarH, AM.groupBG);
    AM.CreateToolbar(0, toolbarY, w, toolbarH, AM.groupBG);
    AM.CreateWorkArea(workAreaX, workAreaY, workAreaW, workAreaH, AM.groupBG);
    AM.CreateCropperBar(0, cropperBarY, w, cropperBarH, AM.groupBG);

    AM.RefreshTimelineTabs();
    AM.RefreshTimebar();
end

function AM.CreateTimebar(x, y, w, h, parent)
    AM.timebarGroup = Win.CreateRectangle(x, y, w, h, parent, "TOPLEFT", "TOPLEFT",  0, 0, 0, 0.2);
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
    local toolbar = Toolbar.Create(x, y, w, h, parent);
--[[
    AM.ToolbarTransformGroup = AM.ToolbarCreateGroup(x, y, w, h, toolbar,
        {
            { type = "DragHandle" },
            { type = "Button", name = "Project", icon = getIcon("projects"), action = function(self) Editor.ProjectManager.OpenWindow() end },
            { type = "Dropdown", name = "ProjectList", width = 200, options = {}, action = function(index) Editor.ProjectManager.LoadProjectByIndex(index); end },
            { type = "Separator" },
            { type = "Button", name = "Select", icon = getIcon("select"), action = function(self) Gizmos.activeTransformGizmo = 0; end },
            { type = "Button", name = "Move", icon = getIcon("move"), action = function(self) Gizmos.activeTransformGizmo = 1; end },
            { type = "Button", name = "Rotate", icon = getIcon("rotate"), action = function(self) Gizmos.activeTransformGizmo = 2; end },
            { type = "Button", name = "Scale", icon = getIcon("scale"), action = function(self) Gizmos.activeTransformGizmo = 3; end },
            { type = "Separator" },
            { type = "Button", name = "L", icon = getIcon("localpivot"), action = function(self) Gizmos.space = 1; print("Local Space"); end },
            { type = "Button", name = "W", icon = getIcon("worldpivot"), action = function(self) Gizmos.space = 0; print("World Space"); end },
            { type = "Separator" },
            { type = "Button", name = "Center", icon = getIcon("centerpivot"), action = function(self) Gizmos.pivot = 0; print("Pivot Center"); end },
            { type = "Button", name = "Base", icon = getIcon("basepivot"), action = function(self) Gizmos.pivot = 1; print("Pivot Base"); end },
            { type = "Separator" },
        }
    );
--]]
end

function AM.CreateWorkArea(x, y, w, h, parent)
    AM.workAreaBG = Win.CreateRectangle(x, y, w, h, parent, "TOPLEFT", "TOPLEFT",  1, 0, 0, 0.1);
end

function AM.CreateCropperBar(x, y, w, h, parent)
    AM.cropperBg = Win.CreateRectangle(x, y, w, h, parent, "BOTTOMLEFT", "BOTTOMLEFT",  0, 0, 0, 0.4);

    local initialSliderLength = w * (AM.currentCrop.max - AM.currentCrop.min) - 10;

    AM.cropperLeftDrag = Win.CreateButton(0, 0, h, h, AM.cropperBg, "LEFT", "LEFT");
    AM.cropperLeftDrag.ntex:SetColorTexture(1,1,1,1);
    AM.cropperLeftDrag.htex:SetColorTexture(1,1,1,1);
    AM.cropperLeftDrag.ptex:SetColorTexture(1,1,1,1);
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
    
    AM.cropperRightDrag = Win.CreateButton(initialSliderLength, 0, h, h, AM.cropperBg, "LEFT", "LEFT");
    AM.cropperRightDrag.ntex:SetColorTexture(1,1,1,1);
    AM.cropperRightDrag.htex:SetColorTexture(1,1,1,1);
    AM.cropperRightDrag.ptex:SetColorTexture(1,1,1,1);
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

    AM.cropperSlider = Win.CreateButton(0, 0, initialSliderLength, 5, AM.cropperBg, "LEFT", "LEFT");
    AM.cropperSlider.ntex:SetColorTexture(0.5,0.5,0.5,1);
    AM.cropperSlider.htex:SetColorTexture(0.5,0.5,0.5,0);
    AM.cropperSlider.ptex:SetColorTexture(0.5,0.5,0.5,1);
    AM.cropperSlider:RegisterForClicks("LeftButtonUp", "LeftButtonDown");
    AM.cropperSlider:SetScript("OnMouseDown", function(self, button)
        AM.inputState.movingCenter = true;
        local gpointC, grelativeToC, grelativePointC, gxOfsC, gyOfsC = self:GetPoint(1);
        AM.inputState.centerFramePosStart = gxOfsC;
        local gpointL, grelativeToL, grelativePointL, gxOfsL, gyOfsL = AM.cropperLeftDrag:GetPoint(1);
        AM.inputState.minFramePosStart = gxOfsL;
        local gpointR, grelativeToR, grelativePointR, gxOfsR, gyOfsR = AM.cropperRightDrag:GetPoint(1);
        AM.inputState.maxFramePosStart = gxOfsR;
        AM.inputState.mousePosStartX = Input.mouseXRaw;
    end);
    AM.cropperSlider:SetScript("OnMouseUp", function(self, button) AM.inputState.movingCenter = false; end);
end

function AM.CreateDefaultTimeline()
    return AM.CreateTimeline();
end

function AM.TimelineTabButton_OnClick(index)
    AM.LoadTimeline(index);
    AM.RefreshTimelineTabs();
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
        length = 30000, -- 30000 miliseconds, 30 seconds
    }
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

    AM.RefreshTimebar();

    -- refresh the scene tabs
    AM.RefreshTimelineTabs();

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
end

function AM.AddSelectedObject()
    --
end

function AM.RemoveSelectedObject()
    --
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
    local totalTimeMs = AM.loadedTimeline.length;
    
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