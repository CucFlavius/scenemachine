-------------------------- Zee's Window API ---------------------------
-- Developed it for use in my addons, but feel free to use in yours ---
-----------------------------------------------------------------------

--Button--
local Win = ZWindowAPI;
Win.BUTTON_DEFAULT = "BUTTON_DEFAULT";
Win.BUTTON_WOW = "BUTTON_WOW";
Win.BUTTON_VS = "BUTTON_VS";

function Win.CreateButton(posX, posY, sizeX, sizeY, parent, buttonPoint, parentPoint, text, icon, theme)

	-- properties --
	local ButtonFont = "Interface\\AddOns\\ZWowEngine\\TestGame\\GameData\\Segoe UI.TTF";
	local ButtonFontSize = 12;

	-- defaults --
	if posX == nil then posX = 0; end
	if posY == nil then posY = 0; end
	if sizeX == nil or sizeX == 0 then sizeX = 10; end
	if sizeY == nil or sizeY == 0 then sizeY = 10; end	
	if parent == nil then parent = UIParent; end
	if buttonPoint == nil then buttonPoint = "CENTER"; end
	if parentPoint == nil then parentPoint = "CENTER"; end
	if theme == nil then theme = Win.BUTTON_DEFAULT; end

	-- main button frame --
	local Button = CreateFrame("Button", "Zee.WindowAPI.Button", parent)
	Button:SetPoint(buttonPoint, parent, parentPoint, posX, posY);
	Button:SetWidth(sizeX)
	Button:SetHeight(sizeY)
	Button.ntex = Button:CreateTexture()
	Button.htex = Button:CreateTexture()
	Button.ptex = Button:CreateTexture()
	if theme == Win.BUTTON_WOW then
		Button.ntex:SetTexture("Interface/Buttons/UI-Panel-Button-Up")
		Button.ntex:SetTexCoord(0, 0.625, 0, 0.6875)
		Button.htex:SetTexture("Interface/Buttons/UI-Panel-Button-Highlight")
		Button.htex:SetTexCoord(0, 0.625, 0, 0.6875)
		Button.ptex:SetTexture("Interface/Buttons/UI-Panel-Button-Down")
		Button.ptex:SetTexCoord(0, 0.625, 0, 0.6875)
	end
	if theme == Win.BUTTON_DEFAULT then
		Button.ntex:SetColorTexture(0.3,0.3,0.3,1);
		Button.htex:SetColorTexture(0.1,0.1,0.1,1);
		Button.ptex:SetColorTexture(0.1,0.1,0.1,1);
	end
	if theme == Win.BUTTON_VS then
		Button.ntex:SetColorTexture(0.1757, 0.1757, 0.1875 ,1);
		Button.htex:SetColorTexture(0.242, 0.242, 0.25,1);
		Button.ptex:SetColorTexture(0, 0.4765, 0.7968,1);
		ButtonFontSize = 9;
	end
	Button.ntex:SetAllPoints()	
	Button.ptex:SetAllPoints()
	Button.htex:SetAllPoints()
	Button:SetNormalTexture(Button.ntex)
	Button:SetHighlightTexture(Button.htex)
	Button:SetPushedTexture(Button.ptex)

	-- icon --
	if icon ~= nil then
		local iconSize = 10;
		if sizeX >= sizeY then iconSize = sizeY; end
		if sizeX <= sizeY then iconSize = sizeX; end
		Button.icon = CreateFrame("Frame", "Zee.WindowAPI.Button Icon", parent);
		Button.icon:SetPoint("CENTER", Button, "CENTER", 0, 0);
		Button.icon:SetSize(iconSize, iconSize);
		Button.icon.texture = Button.icon:CreateTexture("Zee.WindowAPI.Button Icon Texture", "BACKGROUND");
		Button.icon.texture:SetTexture(icon)
		Button.icon.texture:SetAllPoints(Button.icon);
	end

	-- text --
	if text ~= nil then
		Button.text = Button:CreateFontString("Zee.WindowAPI.Button Text");
		Button.text:SetFont(ButtonFont, ButtonFontSize, "NORMAL");
		Button.text:SetAllPoints(Button);
		Button.text:SetText(text);
	end

	return Button;

end