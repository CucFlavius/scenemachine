local Win = ZWindowAPI;
local AM = SceneMachine.Editor.AnimationManager;
local SM = SceneMachine.Editor.SceneManager;
local Renderer = SceneMachine.Renderer;
local Editor = SceneMachine.Editor;

local tabButtonHeight = 20;
local tabPool = {};

AM.loadedTimelineIndex = 1;
AM.loadedTimeline = nil;

function AM.CreateAnimationManager(x, y, w, h, parent)
    AM.groupBG = Win.CreateRectangle(x, y, w, h, parent, "TOPLEFT", "TOPLEFT",  0, 0, 0, 0);
    AM.parentFrame = parent;
    AM.groupBGy = y;
    AM.addTimelineButtonTab = AM.CreateNewTimelineTab(0, 0, 20, tabButtonHeight, AM.groupBG);
    AM.addTimelineButtonTab.text:SetText("+");
    AM.addTimelineButtonTab.ntex:SetColorTexture(0, 0, 0 ,0);
    AM.addTimelineButtonTab.text:SetAllPoints(AM.addTimelineButtonTab);
    AM.addTimelineButtonTab:Hide();

    AM.addTimelineEditBox = Win.CreateEditBox(0, 0, 100, tabButtonHeight, AM.groupBG, "TOPLEFT", "TOPLEFT", "Timeline Name");
    AM.addTimelineEditBox:Hide();

    AM.RefreshTimelineTabs();
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

end

function AM.RemoveSelectedObject()

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