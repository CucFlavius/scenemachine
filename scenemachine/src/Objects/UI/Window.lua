local UI = SceneMachine.UI;
UI.Window = {};
local Window = UI.Window;
local Editor = SceneMachine.Editor;
Window.__index = Window;
setmetatable(Window, UI.Element)

function Window:New(x, y, w, h, parent, point, parentPoint, title)
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
	--self.frame:SetUserPlaced(true);
    --self.frame:SetIgnoreParentScale(true);

	-- title bar frame --
	self.titleBar = CreateFrame("Frame", "UI.Window.titleBar ".. self.title.. " TitleBar", self.frame);
	self.titleBar:SetPoint("BOTTOMLEFT", self.frame, "TOPLEFT", 0, 0);
	self.titleBar:SetPoint("BOTTOMRIGHT", self.frame, "TOPRIGHT", 0, 0);
	self.titleBar:SetSize(self.w, 20);
	self.titleBar_texture = self.titleBar:CreateTexture("UI.Window.titleBar_texture ".. self.title.. " TitleBar texture", "BACKGROUND");
	self.titleBar_texture:SetColorTexture(0.1757, 0.1757, 0.1875, 1);
	self.titleBar_texture:SetAllPoints(self.titleBar);
	self.titleBar_text = self.titleBar:CreateFontString("UI.Window.titleBar_text ".. self.title.. " TitleBar text");
	self.titleBar_text:SetFont(Editor.ui.defaultFont, 10, "NORMAL");
	self.titleBar_text:SetAllPoints(self.titleBar);
	self.titleBar_text:SetText(self.title);
	self.titleBar:EnableMouse(true);
	self.titleBar:RegisterForDrag("LeftButton");
	self.titleBar:SetScript("OnDragStart", function() self.frame:StartMoving(); end);
	self.titleBar:SetScript("OnDragStop", function() self.frame:StopMovingOrSizing(); end);

	-- Close Button --
	self.closeButton = UI.Button:New(-1, -1, 20 - 1, 20 - 1, self.titleBar, "TOPRIGHT", "TOPRIGHT",
		nil, Editor.ui.closeWindowIcon)
	self.closeButton:SetScript("OnClick", function() self:Hide(); end)
    self.closeButton:SetColor(UI.Button.State.Normal, 0.1757, 0.1757, 0.1875, 1);
    self.closeButton:SetColor(UI.Button.State.Highlight, 0.1757, 0.1757, 0.1875, 1);
    self.closeButton:SetColor(UI.Button.State.Pressed, 0, 0.4765, 0.7968, 1);

	-- Dropshadow --
    --self.dropShadow = UI.ImageBox:New(-self.w * 0.09, 0, self.w, self.h, self.frame, "TOPLEFT", "TOPLEFT", "Interface\\Addons\\scenemachine\\static\\textures\\dropShadowSquare.png");
    --self.dropShadow:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", 0, 0);
	--self.dropShadow:SetFrameLevel(100);
    --self.dropShadow:SetFrameStrata(Editor.MAIN_FRAME_STRATA);

    -- Resize Handle --
    self.frame:SetResizable(true);
	self.frame:SetResizeBounds(200, 200, 1280, 1024);
    self.resizeFrame = UI.ImageBox:New(0, 0, 16, 16, self.frame, "BOTTOMRIGHT", "BOTTOMRIGHT", "Interface\\Addons\\scenemachine\\static\\textures\\cornerResize.png");
    self.resizeFrame:GetFrame():EnableMouse(true);
	self.resizeFrame:SetVertexColor(1,1,1,0.3);
    self.resizeFrame:GetFrame():RegisterForDrag("LeftButton");
    self.resizeFrame:GetFrame():SetScript("OnDragStart", function() self.frame:StartSizing("BOTTOMRIGHT"); end);
	self.resizeFrame:GetFrame():SetScript("OnDragStop", function() self.frame:StopMovingOrSizing(); end);
end

function Window:WindowCreateMenuBar(menu)
	local menubar = UI.Rectangle:New(0, 0, self:GetWidth(), 15, self:GetFrame(), "TOP", "TOP", 0.1757, 0.1757, 0.1875, 1);
	menubar.buttons = {};

	for m = 1, #menu, 1 do
		menubar.buttons[m] = UI.Button:New((m - 1) * 50, 0, 50, 15, menubar:GetFrame(), "LEFT", "LEFT", menu[m]["Name"]);
		menubar.buttons[m]:SetScript("OnClick", function ()
			self:PopupWindowMenu((m - 1) * 50, 0, menu[m]["Options"]);
		end);
		menubar.buttons[m]:EnableMouse(true);
		menubar.buttons[m]:HookScript("OnEnter", function ()
			if (self.menuIsOpen == true) then
				self:PopupWindowMenu((m - 1) * 50, 0, menu[m]["Options"]);
			end
		end);
	end

	if (self.popup == nil) then
		self.popup = self:CreateMenu(nil);
	end

	self.menuIsOpen = false;
end

function Window:CreateMenu(parent)
	local popup = CreateFrame("Button", "Zee.WindowAPI.Button", parent)
	popup:SetPoint("CENTER", self:GetFrame(), "CENTER", 0, 0);
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

	popup.menu = UI.Rectangle:New(0, 0, 200, 1000, popup, "TOPLEFT", "TOPLEFT", 0.1757, 0.1757, 0.1875, 1)
	popup.menu.buttons = {}

	for i = 1, 20, 1 do
		popup.menu.buttons[i] = UI.Button:New(0, -((i - 1) * 20), 200, 20, popup.menu:GetFrame(), "TOPLEFT", "TOPLEFT", "text");
		popup.menu.buttons[i]:SetJustifyH("LEFT");
	end

	popup.menu:Hide();

	return popup;
end

function Window:PopupWindowMenu(x, y, menuOptions)
	self.menuIsOpen = true;
	self.popup:SetScale(self:GetEffectiveScale());
	if (menuOptions == nil) then return end
	local optionCount = #menuOptions;
	if (optionCount == 0) then return end
	self.popup:Show();
	self.popup.menu:Show();
	self.popup.menu:SetPoint("TOPLEFT", self.popup, "TOPLEFT", x, y);

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
end

function Window:SetTitle(t)
    self.titleBar_text:SetText(t);
end

Window.__tostring = function(self)
	return string.format("Window( %.3f, %.3f, %.3f, %.3f, %s )", self.x, self.y, self.w, self.h, self.parent);
end