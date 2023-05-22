-------------------------- Zee's Window API ---------------------------
-- Developed it for use in my addons, but feel free to use in yours ---
-----------------------------------------------------------------------

--TextBox--
local Win = ZWindowAPI;
local tabbarHeight = 20;
local c1 = { 0.1757, 0.1757, 0.1875 };
local c2 = { 0.242, 0.242, 0.25 };
local c3 = { 0, 0.4765, 0.7968 };
local c4 = { 0.1171, 0.1171, 0.1171 };

function Win.CreateTabPanel(posX, posY, sizeX, sizeY, parent, windowPoint, parentPoint, textHeight, textFont)

	-- defaults --
	if posX == nil then posX = 0; end
	if posY == nil then posY = 0; end
	if sizeX == nil or sizeX == 0 then sizeX = 50; end
	if sizeY == nil or sizeY == 0 then sizeY = 50; end	
	if parent == nil then parent = UIParent; end
	if windowPoint == nil then windowPoint = "CENTER"; end
	if parentPoint == nil then parentPoint = "CENTER"; end
	if textHeight == nil then textHeight = 12; end
	if textFont == nil then textFont = Win.defaultFont; end

    tabPanel = Win.CreateRectangle(0, 0, sizeX, sizeY, parent, "TOPLEFT", "TOPLEFT", 0, 0, 0, 0.0);
    tabPanel.tabs = {};
    tabPanel.buttons = {};
    tabPanel.actions = {};
    tabPanel.tabBar = Win.CreateRectangle(0, -1.5, sizeX, tabbarHeight, tabPanel, "TOPLEFT", "TOPLEFT", c4[1], c4[2], c4[3], 1);
    tabPanel.lastTabTitleOffset = 0;
    return tabPanel;
end

function Win.AddTabPanelTab(tabPanel, width, height, title, titleWidth, action)
    local idx = table.getn(tabPanel.buttons) + 1;
    tabPanel.actions[idx] = action;
    tabPanel.buttons[idx] = Win.CreateButton(5 + tabPanel.lastTabTitleOffset, -1, titleWidth, tabbarHeight - 1, tabPanel.tabBar, "LEFT", "LEFT", title, nil, "BUTTON_VS");
    tabPanel.buttons[idx]:SetScript("OnClick", function (self, button, down) 
        Win.TabPanelOnChangeTab(idx);
        if (tabPanel.actions[idx] ~= nil) then
            tabPanel.actions[idx]();
        end
    end)
    tabPanel.tabs[idx] = Win.CreateRectangle(0, -tabbarHeight, width, height -tabbarHeight, tabPanel, "TOPLEFT", "TOPLEFT", 0, 0, 0, 0.0);
    tabPanel.lastTabTitleOffset = tabPanel.lastTabTitleOffset + titleWidth;
    Win.TabPanelOnChangeTab(1);

    return tabPanel.tabs[idx];
end

function Win.TabPanelOnChangeTab(idx)
    for i = 1, table.getn(tabPanel.buttons), 1 do
        if (idx == i) then
            tabPanel.tabs[i]:Show();
            tabPanel.buttons[i].ntex:SetColorTexture(0.1757, 0.1757, 0.1875 ,1);
        else
            tabPanel.tabs[i]:Hide();
            tabPanel.buttons[i].ntex:SetColorTexture(0.1171, 0.1171, 0.1171 ,1);
        end
    end
end