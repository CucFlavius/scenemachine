-------------------------- Zee's Window API ---------------------------
-- Developed it for use in my addons, but feel free to use in yours ---
-----------------------------------------------------------------------

--Window--
local Win = ZWindowAPI;
Win.RESIZABLE_X = "RESIZABLE_X";
Win.RESIZABLE_Y = "RESIZABLE_Y";
Win.RESIZABLE_XY = "RESIZABLE_XY";
Win.RESIZABLE_NONE = "RESIZABLE_NONE";

local c1 = { 0.1757, 0.1757, 0.1875 };
local maxMenuOptions = 20;

--- Create a new Window
---@param posX number Window X position (horizontal)
---@param posY number Window Y position (vertical)
---@param sizeX number Window width
---@param sizeY number Window height
---@param parent table Parent frame
---@param windowPoint string Pivot point of the current window
---@param parentPoint string Pivot point of the parent
---@param resizable string Window resizing property : Win.RESIZABLE_X, Win.RESIZABLE_Y, Win.RESIZABLE_XY, Win.RESIZABLE_NONE (default)
---@param title string Title text
---@return table windowFrame Wow Frame that contains all of the window elements
function Win.CreateWindow(posX, posY, sizeX, sizeY, parent, windowPoint, parentPoint, resizable, title)

	-- properties --
	local TitleBarHeight = 20;
	local TitleBarFont = Win.defaultFont;
	local TitleBarFontSize = 10;

	-- defaults --
	if posX == nil then posX = 0; end
	if posY == nil then posY = 0; end
	if sizeX == nil or sizeX == 0 then sizeX = 50; end
	if sizeY == nil or sizeY == 0 then sizeY = 50; end	
	if parent == nil then parent = UIParent; end
	if windowPoint == nil then windowPoint = "CENTER"; end
	if parentPoint == nil then parentPoint = "CENTER"; end
	if resizable == nil then resizable = Win.RESIZABLE_NONE; end
	if title == nil then title = ""; end

	-- main window frame --
	local WindowFrame = CreateFrame("Frame", "Zee.WindowAPI.Window "..title, parent);
	WindowFrame:SetPoint(windowPoint, parent, parentPoint, posX, posY);
	WindowFrame:SetSize(sizeX, sizeY);
	WindowFrame.texture = WindowFrame:CreateTexture("Zee.WindowAPI.Window "..title.. " texture", "BACKGROUND");
	WindowFrame.texture:SetColorTexture(0.2,0.2,0.2,1);
	WindowFrame.texture:SetAllPoints(WindowFrame);
	WindowFrame:SetMovable(true);
	WindowFrame:EnableMouse(true);
	--WindowFrame:SetUserPlaced(true);

	-- title bar frame --
	WindowFrame.TitleBar = CreateFrame("Frame", "Zee.WindowAPI.Window "..title.. " TitleBar", WindowFrame);
	WindowFrame.TitleBar:SetPoint("BOTTOM", WindowFrame, "TOP", 0, 0);
	WindowFrame.TitleBar:SetSize(sizeX, TitleBarHeight);
	WindowFrame.TitleBar.texture = WindowFrame.TitleBar:CreateTexture("Zee.WindowAPI.Window "..title.. " TitleBar texture", "BACKGROUND");
	WindowFrame.TitleBar.texture:SetColorTexture(0.5,0.5,0.5,1);
	WindowFrame.TitleBar.texture:SetAllPoints(WindowFrame.TitleBar);
	WindowFrame.TitleBar.text = WindowFrame.TitleBar:CreateFontString("Zee.WindowAPI.Window "..title.. " TitleBar text");
	WindowFrame.TitleBar.text:SetFont(TitleBarFont, TitleBarFontSize, "NORMAL");
	WindowFrame.TitleBar.text:SetAllPoints(WindowFrame.TitleBar);
	WindowFrame.TitleBar.text:SetText(title);
	WindowFrame.TitleBar:EnableMouse(true);
	WindowFrame.TitleBar:RegisterForDrag("LeftButton");
	WindowFrame.TitleBar:SetScript("OnDragStart", function()  WindowFrame:StartMoving(); end);
	WindowFrame.TitleBar:SetScript("OnDragStop", function() WindowFrame:StopMovingOrSizing(); end);

	-- Close Button --
	WindowFrame.CloseButton = Win.CreateButton(-1, -1, TitleBarHeight - 1, TitleBarHeight - 1, WindowFrame.TitleBar, "TOPRIGHT", "TOPRIGHT", "x", nil, Win.BUTTON_DEFAULT, font)
	WindowFrame.CloseButton:SetScript("OnClick", function (self, button, down) WindowFrame:Hide(); end)
	return WindowFrame;

end

function Win.WindowCreateMenuBar(window, menu)
	local menubar = Win.CreateRectangle(0, 0, window:GetWidth(), 15, window, "TOP", "TOP", c1[1], c1[2], c1[3], 1);
	menubar.buttons = {};

	for m=1, table.getn(menu), 1 do
		menubar.buttons[m] = Win.CreateButton((m - 1) * 50, 0, 50, 15, menubar, "LEFT", "LEFT", menu[m]["Name"], nil, "BUTTON_VS");
		menubar.buttons[m]:SetScript("OnClick", function (self, button, down)
			Win.PopupWindowMenu(window, menubar, menu, m);
		end);
		menubar.buttons[m]:EnableMouse(true);
		menubar.buttons[m]:HookScript("OnEnter", function (self)
			if (window.menuIsOpen == true) then
				Win.PopupWindowMenu(window, menubar, menu, m);
			end
		end);
	end

	menubar.popup = CreateFrame("Button", "Zee.WindowAPI.Button", parent)
	menubar.popup:SetPoint("CENTER", window, "CENTER", 0, 0);
	menubar.popup:SetWidth(window:GetWidth());
	menubar.popup:SetHeight(window:GetHeight() - 30);
	menubar.popup.ntex = menubar.popup:CreateTexture()
	menubar.popup.ntex:SetColorTexture(0,0,0,0.1);
	menubar.popup.ntex:SetAllPoints()	
	menubar.popup:SetNormalTexture(menubar.popup.ntex)
	menubar.popup:SetScript("OnClick", function (self, button, down)
		window.menuIsOpen = false;
		menubar.popup:Hide();
	end)
	menubar.popup:Hide();
	menubar.popup:SetFrameStrata("HIGH");

	menubar.popup.menu = Win.CreateRectangle(0, 0, 200, 1000, menubar.popup, "TOPLEFT", "TOPLEFT", c1[1], c1[2], c1[3], 1)
	menubar.popup.menu.buttons = {}

	for i = 1, maxMenuOptions, 1 do
		menubar.popup.menu.buttons[i] = Win.CreateButton(0, -((i - 1) * 20), 200, 20, menubar.popup.menu, "TOPLEFT", "TOPLEFT", "text", nil, "BUTTON_VS");
		menubar.popup.menu.buttons[i].text:SetJustifyH("LEFT");
	end

	menubar.popup.menu:Hide();
	window.menuIsOpen = false;
end

function Win.PopupWindowMenu(window, menubar, menu, index)
	window.menuIsOpen = true;

	if (menu[index]["Options"] == nil) then return end
	local optionCount = table.getn(menu[index]["Options"]);
	if (optionCount == 0) then return end
	menubar.popup:Show();
	menubar.popup.menu:Show();
	menubar.popup.menu:SetPoint("TOPLEFT", menubar.popup, "TOPLEFT", (index - 1) * 50, 0);
	menubar.popup.menu:SetHeight(optionCount * 20);

	for i = 1, maxMenuOptions, 1 do
		if (i <= optionCount) then
			menubar.popup.menu.buttons[i]:Show();
			menubar.popup.menu.buttons[i].text:SetText("    " .. menu[index]["Options"][i]["Name"]);
			menubar.popup.menu.buttons[i]:SetScript("OnClick", function (self, button, down)
				menubar.popup:Hide();
				window.menuIsOpen = false;
				if (menu[index]["Options"][i]["Action"] ~= nil) then
					menu[index]["Options"][i]["Action"]();
				end
			end)
		else
			menubar.popup.menu.buttons[i]:Hide();
		end
	end
end