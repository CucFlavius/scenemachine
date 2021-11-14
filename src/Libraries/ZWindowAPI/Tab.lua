
-------------------------- Zee's Window API ---------------------------
-- Developed it for use in my addons, but feel free to use in yours ---
-----------------------------------------------------------------------

--Tab--
local Win = ZWindowAPI;


function Win.CreateTabs(posX, posY, sizeX, sizeY, parent, windowPoint, parentPoint, tabNames, defaultTab)

	-- properties --
	local TabButtonHeight = 20;
	local TabButtonWidth = 80;
	local TabButtonFont = "Fonts\\FRIZQT__.TTF";
	local TabButtonFontSize = 12;

	-- defaults --
	if posX == nil then posX = 0; end
	if posY == nil then posY = 0; end
	if sizeX == nil or sizeX == 0 then sizeX = 50; end
	if sizeY == nil or sizeY == 0 then sizeY = 50; end	
	if parent == nil then parent = UIParent; end
	if windowPoint == nil then windowPoint = "CENTER"; end
	if parentPoint == nil then parentPoint = "CENTER"; end
	if tabNames == nil then return nil; end
	if defaultTab == nil then defaultTab = 1; end

	-- main tabs frame --
	local TabsParentFrame = CreateFrame("Frame", "Zee.WindowAPI.Tabs Main Frame", parent);
	TabsParentFrame:SetPoint(windowPoint, parent, parentPoint, posX, posY);
	TabsParentFrame:SetSize(sizeX, sizeY);

	-- create tabs --
	local numberOfTabs = getn(tabNames)
	local tabButtons = {}
	local currentTabButtonOffset = 0;
	for t = 1, numberOfTabs, 1 do

		-- tab button --
		TabButtonWidth = 20 + (strlen(tabNames[t]) * 8)
		local TabButton = CreateFrame("Frame", "Zee.WindowAPI.Tab Button " .. t, TabsParentFrame);
		TabButton:SetPoint("TOPLEFT", TabsParentFrame, "TOPLEFT", currentTabButtonOffset, 0);
		TabButton:SetSize(TabButtonWidth,TabButtonHeight);
		TabButton.texture = TabButton:CreateTexture("Zee.WindowAPI.Tab Button" .. t .. " texture", "BACKGROUND");
		TabButton.texture:SetColorTexture(1,1,1,0.2);
		TabButton.texture:SetAllPoints(TabButton);	
		TabButton.text = TabButton:CreateFontString("Zee.WindowAPI.Button Text");
		TabButton.text:SetFont(TabButtonFont, TabButtonFontSize, "OUTLINE");
		TabButton.text:SetAllPoints(TabButton);
		TabButton.text:SetText(tabNames[t]);
		currentTabButtonOffset = currentTabButtonOffset + TabButtonWidth;
		TabButton:SetScript("OnMouseDown", 
			function (self, button)
				for p = 1, numberOfTabs, 1 do
					tabButtons[p].TabPanel:Hide();
					tabButtons[p].texture:SetColorTexture(1,1,1,0.2);
				end
				self.TabPanel:Show();
				self.texture:SetColorTexture(1,1,1,0.5);
			 end)

		-- tab panel --
		TabButton.TabPanel = CreateFrame("Frame", "Zee.WindowAPI.Tab " .. t, TabsParentFrame);
		TabButton.TabPanel:SetPoint("BOTTOM", TabsParentFrame, "BOTTOM", 0, 0);
		TabButton.TabPanel:SetSize(sizeX, sizeY - TabButtonHeight);
		TabButton.TabPanel.texture = TabButton.TabPanel:CreateTexture("Zee.WindowAPI.Tab " .. t .. " texture", "BACKGROUND");
		TabButton.TabPanel.texture:SetColorTexture(1,1,1,0.5);
		TabButton.TabPanel.texture:SetAllPoints(TabButton.TabPanel);
		TabButton.TabPanel:Hide();
		tabButtons[t] = TabButton;

		if t == defaultTab then
			TabButton.TabPanel:Show();
			TabButton.texture:SetColorTexture(1,1,1,0.5);
		end

	end
	return tabButtons;

end