-------------------------- Zee's Window API ---------------------------
-- Developed it for use in my addons, but feel free to use in yours ---
-----------------------------------------------------------------------

--Window--
local Win = ZWindowAPI;
Win.RESIZABLE_X = "RESIZABLE_X";
Win.RESIZABLE_Y = "RESIZABLE_Y";
Win.RESIZABLE_XY = "RESIZABLE_XY";
Win.RESIZABLE_NONE = "RESIZABLE_NONE";

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
	local TitleBarFont = "Interface\\AddOns\\ZWowEngine\\TestGame\\GameData\\Segoe UI.TTF"; --"Fonts\\FRIZQT__.TTF";
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
	WindowFrame.CloseButton = Win.CreateButton(-1, -1, TitleBarHeight - 1, TitleBarHeight - 1, WindowFrame.TitleBar, "TOPRIGHT", "TOPRIGHT", "x", nil, Win.BUTTON_DEFAULT)
	WindowFrame.CloseButton:SetScript("OnClick", function (self, button, down) WindowFrame:Hide(); end)
	return WindowFrame;

end