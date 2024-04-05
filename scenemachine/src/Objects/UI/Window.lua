local UI = SceneMachine.UI;
local Resources = SceneMachine.Resources;
UI.Window = {};

--- @class Window : Element
local Window = UI.Window;

Window.__index = Window;
setmetatable(Window, UI.Element)

--- Creates a new Window object.
--- @param x number? The x-coordinate of the window's position.
--- @param y number? The y-coordinate of the window's position.
--- @param w number? The width of the window.
--- @param h number? The height of the window.
--- @param parent Element? The parent element of the window.
--- @param point string? The anchor point of the window relative to its parent.
--- @param parentPoint string? The anchor point of the parent element.
--- @param title string? The title of the window.
--- @return Window: The newly created Window object.
function Window:New(x, y, w, h, parent, point, parentPoint, title)
	--- @class Window : Element
	local v =
	{
		x = x or 0,
		y = y or 0,
		w = w or 20,
		h = h or 20,
		parent = parent or nil,
		point = point or "TOPLEFT",
		parentPoint = parentPoint or "TOPLEFT",
		title = title or nil,
		visible = true,
	};

	setmetatable(v, Window);
	v:Build();
	return v;
end

--- Builds the window.
function Window:Build()
	-- main window frame --
	self.frame = CreateFrame("Frame", "UI.Window.frame " .. self.title, self.parent);
	self.frame:SetPoint(self.point, self.parent, self.parentPoint, self.x, self.y);
	self.frame:SetSize(self.w, self.h);
	self.frame_texture = self.frame:CreateTexture("UI.Window.frame_texture ".. self.title .. " texture", "BACKGROUND");
	self.frame_texture:SetColorTexture(0.1171, 0.1171, 0.1171, 1);
	self.frame_texture:SetAllPoints(self.frame);
	self.frame:SetMovable(true);
	self.frame:EnableMouse(true);
	self.frame:SetClampedToScreen(true);
	UI.AddBackdropShadow(self.frame, 0, 20);

	-- title bar frame --
	self.titleBar = CreateFrame("Frame", "UI.Window.titleBar ".. self.title.. " TitleBar", self.frame);
	self.titleBar:SetPoint("BOTTOMLEFT", self.frame, "TOPLEFT", 0, 0);
	self.titleBar:SetPoint("BOTTOMRIGHT", self.frame, "TOPRIGHT", 0, 0);
	self.titleBar:SetSize(self.w, 20);
	self.titleBar_texture = self.titleBar:CreateTexture("UI.Window.titleBar_texture ".. self.title.. " TitleBar texture", "BACKGROUND");
	self.titleBar_texture:SetColorTexture(0.1757, 0.1757, 0.1875, 1);
	self.titleBar_texture:SetAllPoints(self.titleBar);
	self.titleBar_text = self.titleBar:CreateFontString("UI.Window.titleBar_text ".. self.title.. " TitleBar text");
	self.titleBar_text:SetFont(Resources.defaultFont, Resources.defaultFontSize, "NORMAL");
	self.titleBar_text:SetAllPoints(self.titleBar);
	self.titleBar_text:SetText(self.title);
	self.titleBar:EnableMouse(true);
	self.titleBar:RegisterForDrag("LeftButton");
	self.titleBar:SetScript("OnDragStart", function() self.frame:StartMoving(); end);
	self.titleBar:SetScript("OnDragStop", function() self.frame:StopMovingOrSizing(); end);
	self.frame:SetClampedToScreen(true);

	-- Close Button --
	self.closeButton = UI.Button:New(-1, -1, 20 - 1, 20 - 1, self.titleBar, "TOPRIGHT", "TOPRIGHT", nil, Resources.textures["CloseButton"])
	self.closeButton:SetScript("OnClick", function() self:Hide(); end)
	self.closeButton:SetColor(UI.Button.State.Normal, 0.1757, 0.1757, 0.1875, 1);
	self.closeButton:SetColor(UI.Button.State.Highlight, 0.1757, 0.1757, 0.1875, 1);
	self.closeButton:SetColor(UI.Button.State.Pressed, 0, 0.4765, 0.7968, 1);

	-- Resize Handle --
	self.frame:SetResizable(true);
	self.frame:SetResizeBounds(200, 200, 1920, 1080);
	self.resizeFrame = UI.ImageBox:New(0, 0, 16, 16, self.frame, "BOTTOMRIGHT", "BOTTOMRIGHT", Resources.textures["CornerResize"]);
	self.resizeFrame:GetFrame():EnableMouse(true);
	self.resizeFrame:SetVertexColor(1,1,1,0.3);
	self.resizeFrame:GetFrame():RegisterForDrag("LeftButton");
	self.resizeFrame:GetFrame():SetScript("OnDragStart", function() self.frame:StartSizing("BOTTOMRIGHT"); SetCursor(Resources.textures["CursorResize"]); end);
	self.resizeFrame:GetFrame():SetScript("OnDragStop", function() self.frame:StopMovingOrSizing(); ResetCursor(); end);
	self.resizeFrame:GetFrame():SetScript('OnEnter', function() SetCursor(Resources.textures["CursorResize"]); end)
	self.resizeFrame:GetFrame():SetScript('OnLeave', function() ResetCursor(); end)
end

--- Makes the whole window draggable.
function Window:MakeWholeWindowDraggable()
	self.frame:RegisterForDrag("LeftButton");
	self.frame:SetScript("OnDragStart", function() self.frame:StartMoving(); end);
	self.frame:SetScript("OnDragStop", function() self.frame:StopMovingOrSizing(); end);
end

--- Creates a menu bar for the window.
--- @param menu table The menu items to be displayed on the menu bar.
function Window:WindowCreateMenuBar(menu)
	-- Create the menu bar rectangle
	local menubar = UI.Rectangle:NewTLTR(0, 0, 0, 0, 15, self:GetFrame(), 0.1757, 0.1757, 0.1875, 1);
	menubar:GetFrame():EnableMouse(true);
	menubar:GetFrame():RegisterForDrag("LeftButton");
	menubar:GetFrame():SetScript("OnDragStart", function() self.frame:StartMoving(); end);
	menubar:GetFrame():SetScript("OnDragStop", function() self.frame:StopMovingOrSizing(); end);

	menubar.buttons = {};

	local scale = SceneMachine.mainWindow:GetEffectiveScale();

	-- Create buttons for each menu item
	for m = 1, #menu, 1 do
		menubar.buttons[m] = UI.Button:New((m - 1) * 50, 0, 50, 15, menubar:GetFrame(), "LEFT", "LEFT", menu[m]["Name"]);
		menubar.buttons[m]:SetScript("OnClick", function ()
			self:PopupWindowMenu((m - 1) * 50, -20, menu[m]["Options"], true);
		end);
		menubar.buttons[m]:EnableMouse(true);
		menubar.buttons[m]:HookScript("OnEnter", function ()
			if (self.menuIsOpen == true) then
				self:PopupWindowMenu((m - 1) * 50, -20, menu[m]["Options"], true);
			end
		end);
	end

	-- Create the popup menu if it doesn't exist
	if (self.popup == nil) then
		self.popup = self:CreateMenu(nil);
	end

	self.menuIsOpen = false;
end

--- Creates a menu for the Window object.
--- @param parent table The parent frame for the menu.
--- @return table: The created menu frame.
function Window:CreateMenu(parent)
	local popup = CreateFrame("Button", "Zee.WindowAPI.Button", parent)
	popup:SetPoint("TOPLEFT", self:GetFrame(), "TOPLEFT", 0, 0);
	popup:SetWidth(self:GetWidth());
	popup:SetHeight(self:GetHeight() - 30);
	popup:SetFrameStrata("FULLSCREEN_DIALOG");
	popup.ntex = popup:CreateTexture()
	popup.ntex:SetColorTexture(0,0,0,0.0);
	popup.ntex:SetAllPoints()	
	popup:SetNormalTexture(popup.ntex)
	popup:SetScript("OnClick", function ()
		self.menuIsOpen = false;
		popup:Hide();
	end)
	popup:Hide();
	popup:SetFrameStrata("FULLSCREEN");

	popup.menu = UI.Rectangle:New(0, 0, 200, 1000, popup, "TOPLEFT", "TOPLEFT", 0.1757, 0.1757, 0.1875, 1);
	popup.menu:SetFrameLevel(10);
	UI.AddBackdropShadow(popup.menu:GetFrame());
	popup.menu.buttons = {}

	for i = 1, 20, 1 do
		popup.menu.buttons[i] = UI.Button:New(0, -((i - 1) * 20), 200, 20, popup.menu:GetFrame(), "TOPLEFT", "TOPLEFT", "text");
		popup.menu.buttons[i]:SetJustifyH("LEFT");
	end

	popup.menu:Hide();

	return popup;
end

--- Displays a popup window menu at the specified coordinates.
--- @param mx number The x-coordinate of the menu's top-left corner.
--- @param my number The y-coordinate of the menu's top-left corner.
--- @param menuOptions table An array of menu options to be displayed.
--- @param scale boolean: Determines whether to scale the popup window based on the effective scale of the parent window.
function Window:PopupWindowMenu(mx, my, menuOptions, scale)
	self.menuIsOpen = true;
	if (scale) then
		self.popup:SetScale(self:GetEffectiveScale());
	else
		self.popup:SetScale(1);
	end
	if (menuOptions == nil) then return end
	local optionCount = #menuOptions;
	if (optionCount == 0) then return end
	self.popup:Show();
	self.popup.menu:Show();
	self.popup.menu:SetPoint("TOPLEFT", self.popup, "TOPLEFT", mx, my);

	local y = 0;
	for i = 1, 20, 1 do
		if (i <= optionCount) then
			if (menuOptions[i]["Name"] == nil) then
				-- spacer --
				y = y - 5;
				self.popup.menu.buttons[i]:Hide();
			else
				-- button --
				self.popup.menu.buttons[i]:Show();
				self.popup.menu.buttons[i]:ClearAllPoints();
				self.popup.menu.buttons[i]:SetPoint("TOPLEFT", self.popup.menu:GetFrame(), "TOPLEFT", 0, y);
				self.popup.menu.buttons[i]:SetText("    " .. menuOptions[i]["Name"]);
				self.popup.menu.buttons[i]:SetScript("OnClick", function ()
					self.popup:Hide();
					self.menuIsOpen = false;
					if (menuOptions[i]["Action"] ~= nil) then
						menuOptions[i]["Action"]();
					end
				end)

				y = y - 20;
			end
		else
			self.popup.menu.buttons[i]:Hide();
		end
	end

	self.popup.menu:SetHeight(-y);

	-- offscreen check
	local bottom = self.popup.menu:GetBottom();
	if (bottom <= 0) then
		my = my - bottom;
	end

	self.popup.menu:ClearAllPoints();
	self.popup.menu:SetPoint("TOPLEFT", self.popup, "TOPLEFT", mx, my);
end

--- Sets the text for the window title.
---@param t string The text to set as the window title.
function Window:SetTitleText(t)
	self:SetTitle(t);
end

--- Sets the title of the window.
---@param t string The new title for the window.
function Window:SetTitle(t)
	self.titleBar_text:SetText(t);
end

Window.__tostring = function(self)
	return string.format("Window( %.3f, %.3f, %.3f, %.3f, %s )", self.x, self.y, self.w, self.h, self.parent);
end