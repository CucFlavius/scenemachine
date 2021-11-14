-------------------------- Zee's Window API ---------------------------
-- Developed it for use in my addons, but feel free to use in yours ---
-----------------------------------------------------------------------

--EditBox--
local Win = ZWindowAPI;

function Win.CreateEditBox(posX, posY, sizeX, sizeY, parent, windowPoint, parentPoint, text, textHeight, textFont)

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
	local EditBox = CreateFrame("EditBox", "Zee.WindowAPI.EditBox", parent);
	EditBox:SetPoint(windowPoint, parent, parentPoint, posX, posY);
	EditBox:SetSize(sizeX, sizeY);
	--EditBox:SetFont(textFont, textHeight, "OUTLINE");
	EditBox:SetText(text);
	EditBox.texture = EditBox:CreateTexture("Zee.WindowAPI.EditBox texture", "BACKGROUND");
	EditBox.texture:SetColorTexture(0.1,0.1,0.1,1);
	EditBox.texture:SetAllPoints(EditBox);
	EditBox:SetAutoFocus(false);
	EditBox:EnableMouse(true);
	EditBox:SetMaxLetters(100);
	EditBox:SetFont(textFont, textHeight, 'NORMAL');
	EditBox:SetScript('OnEscapePressed', function() EditBox:ClearFocus();  end);
	EditBox:SetScript('OnEnterPressed', function() EditBox:ClearFocus();  end);
	EditBox:EnableMouse();
	EditBox:SetScript('OnMouseDown', function() EditBox:SetFocus(); end);
	return EditBox;

end