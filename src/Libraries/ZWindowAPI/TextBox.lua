-------------------------- Zee's Window API ---------------------------
-- Developed it for use in my addons, but feel free to use in yours ---
-----------------------------------------------------------------------

--TextBox--
local Win = ZWindowAPI;

function Win.CreateTextBoxSimple(posX, posY, sizeX, sizeY, parent, windowPoint, parentPoint, text, textHeight, textFont)

	-- defaults --
	if posX == nil then posX = 0; end
	if posY == nil then posY = 0; end
	if sizeX == nil or sizeX == 0 then sizeX = 50; end
	if sizeY == nil or sizeY == 0 then sizeY = 50; end	
	if parent == nil then parent = UIParent; end
	if windowPoint == nil then windowPoint = "CENTER"; end
	if parentPoint == nil then parentPoint = "CENTER"; end
	if text == nil then text = ""; end
	if textHeight == nil then textHeight = 12; end
	if textFont == nil then textFont = "Fonts\\FRIZQT__.TTF"; end

	-- text box frame --
	local TextBox = CreateFrame("Frame", "Zee.WindowAPI.TextBox", parent);
	TextBox:SetPoint(windowPoint, parent, parentPoint, posX, posY);
	TextBox:SetSize(sizeX, sizeY);
	TextBox.text = TextBox:CreateFontString("Zee.WindowAPI.TextBox text");
	TextBox.text:SetFont(textFont, textHeight, "NORMAL");
	TextBox.text:SetAllPoints(TextBox);
	TextBox.text:SetText(text);
	TextBox.text:SetJustifyV("CENTER");
	TextBox.text:SetJustifyH("LEFT");
	return TextBox;
end

function Win.CreateTextBox(posX, posY, sizeX, sizeY, parent, windowPoint, parentPoint, text, textHeight, textFont)

	-- defaults --
	if posX == nil then posX = 0; end
	if posY == nil then posY = 0; end
	if sizeX == nil or sizeX == 0 then sizeX = 50; end
	if sizeY == nil or sizeY == 0 then sizeY = 50; end	
	if parent == nil then parent = UIParent; end
	if windowPoint == nil then windowPoint = "CENTER"; end
	if parentPoint == nil then parentPoint = "CENTER"; end
	if text == nil then text = ""; end
	if textHeight == nil then textHeight = 12; end
	if textFont == nil then textFont = "Fonts\\FRIZQT__.TTF"; end

	-- text box frame --
	local TextBox = CreateFrame("Frame", "Zee.WindowAPI.TextBox", parent);
	TextBox:SetPoint(windowPoint, parent, parentPoint, posX, posY);
	TextBox:SetSize(sizeX, sizeY);
	TextBox.text = TextBox:CreateFontString("Zee.WindowAPI.TextBox text");
	TextBox.text:SetFont(textFont, textHeight, "NORMAL");
	TextBox.text:SetAllPoints(TextBox);
	TextBox.text:SetText(text);
	TextBox.texture = TextBox:CreateTexture("Zee.WindowAPI.TextBox texture", "BACKGROUND");
	TextBox.texture:SetColorTexture(0.1,0.1,0.1,1);
	TextBox.texture:SetAllPoints(TextBox);

	return TextBox;

end