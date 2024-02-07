local Editor = SceneMachine.Editor;
local UI = SceneMachine.UI;
UI.TabPanel = {};
local TabPanel = UI.TabPanel;
TabPanel.__index = TabPanel;
setmetatable(TabPanel, UI.Element)

function TabPanel:New(x, y, w, h, parent, point, parentPoint, textHeight, textFont)
	local v = 
    {
        x = x or 0,
        y = y or 0,
        w = w or 20,
        h = h or 20,
        parent = parent or nil,
        point = point or "TOPLEFT",
        parentPoint = parentPoint or "TOPLEFT",
        textHeight = textHeight or 9,
        textFont = textFont or Editor.ui.defaultFont,
        visible = true,
    };

	setmetatable(v, TabPanel);
    v:Build();
	return v;
end

function TabPanel:Build()
    local tabPanel = UI.Rectangle:New(0, 0, self.w, self.h, self.parent, self.point, self.parentPoint, 0, 0, 0, 0.0);
    self.tabs = {};
    self.buttons = {};
    self.actions = {};
    self.tabBar = UI.Rectangle:New(0, -1.5, self.w, 20, tabPanel:GetFrame(), "TOPLEFT", "TOPLEFT", 0.1171, 0.1171, 0.1171, 1);
    self.tabBar:SetPoint("TOPRIGHT", tabPanel:GetFrame(), "TOPRIGHT", 0, 0)
    self.lastTabTitleOffset = 0;
    self.frame = tabPanel:GetFrame();
end


function TabPanel:AddTab(width, height, title, titleWidth, action, startLevel)
    local idx = #self.buttons + 1;
    self.actions[idx] = action;
    self.buttons[idx] = UI.Button:New(5 + self.lastTabTitleOffset, -1, titleWidth, 20 - 1, self.tabBar:GetFrame(), "LEFT", "LEFT", title, nil);
    self.buttons[idx]:SetFrameLevel(startLevel);
    self.buttons[idx]:SetScript("OnClick", function()
        self:OnChangeTab(idx);
        if (self.actions[idx]) then
            self.actions[idx]();
        end
    end)
    self.tabs[idx] = UI.Rectangle:New(0, -20, width, height - 20, self:GetFrame(), "TOPLEFT", "TOPLEFT", 0, 0, 0, 0.0);
    self.tabs[idx]:SetPoint("BOTTOMRIGHT", self:GetFrame(), "BOTTOMRIGHT", 0, 0);
    self.tabs[idx]:SetFrameLevel(startLevel);
    self.lastTabTitleOffset = self.lastTabTitleOffset + titleWidth;
    self:OnChangeTab(1);

    return self.tabs[idx];
end

function TabPanel:OnChangeTab(idx)
    for i = 1, #self.buttons, 1 do
        if (idx == i) then
            self.tabs[i]:Show();
            self.buttons[i]:SetColor(UI.Button.State.Normal, 0.1757, 0.1757, 0.1875 ,1);
        else
            self.tabs[i]:Hide();
            self.buttons[i]:SetColor(UI.Button.State.Normal, 0.1171, 0.1171, 0.1171 ,1);
        end
    end
end

TabPanel.__tostring = function(self)
	return string.format("TabPanel( %.3f, %.3f, %.3f, %.3f, %s )", self.x, self.y, self.w, self.h, self.parent);
end