-------------------------- Zee's Window API ---------------------------
-- Developed it for use in my addons, but feel free to use in yours ---
-----------------------------------------------------------------------

--Button--
local Win = ZWindowAPI;

function Win.CreateDropdown(posX, posY, sizeX, sizeY, parent, dropdownPoint, parentPoint, optionNames, onSelect)

	-- properties --
	local ButtonFont = Win.defaultFont;
	local ButtonFontSize = 9;

	-- defaults --
	if posX == nil then posX = 0; end
	if posY == nil then posY = 0; end
	if sizeX == nil or sizeX == 0 then sizeX = 10; end
	if sizeY == nil or sizeY == 0 then sizeY = 10; end	
	if parent == nil then parent = UIParent; end
	if dropdownPoint == nil then dropdownPoint = "CENTER"; end
	if parentPoint == nil then parentPoint = "CENTER"; end

	local pad = 5;
	local height = sizeY - (pad * 2);

	local dropdown = Win.CreateRectangle(posX, posY, sizeX, sizeY, parent, dropdownPoint, parentPoint, 0, 0, 0, 0);
	local button = Win.CreateButton(pad, -pad, sizeX - pad, height, dropdown, "TOPLEFT", "TOPLEFT", "", nil, Win.BUTTON_VS, nil);
	button.text:SetJustifyH("LEFT");
	
	--local box = Win.CreateTextBoxSimple(posX, posY, sizeX, sizeY, parent, windowPoint, parentPoint, text, textHeight, textFont);
	--Win.CreateRectangle(0, -pad, height, height, dropdown, "TOPRIGHT", "TOPRIGHT", "v", nil, Win.BUTTON_VS, nil)
	button.ntex:SetColorTexture(0.242, 0.242, 0.25, 1);
	local arrowSize = 4.0;
	local arrow = Win.CreateRectangle(-8, -8, arrowSize, arrowSize, button, "TOPRIGHT", "TOPRIGHT", 0.9, 0.9, 0.9, 1);
	arrow.texture:SetVertexOffset(LOWER_LEFT_VERTEX, arrowSize / 2, 0);
	arrow.texture:SetVertexOffset(UPPER_LEFT_VERTEX, -arrowSize / 8, 0);
	arrow.texture:SetVertexOffset(LOWER_RIGHT_VERTEX, -arrowSize / 2, 0);
	arrow.texture:SetVertexOffset(UPPER_RIGHT_VERTEX, arrowSize / 8, 0);

	dropdown.options = {};

	for o = 1, #optionNames, 1 do
		dropdown.options[o] = { ["Name"] = optionNames[o], ["Action"] = function() onSelect(o); end };
	end

	button:SetScript("OnClick", function (self, button, down)
		Win.PopupWindowMenu(posX, posY - sizeY, SceneMachine.mainWindow, dropdown.options);
	end);

	dropdown.SetOptions = function(newOptions)
		for o = 1, #newOptions, 1 do
			dropdown.options[o] = { ["Name"] = newOptions[o], ["Action"] = function() onSelect(o); end };
		end
	end

	dropdown.ShowSelectedName = function(name)
		button.text:SetText("  " .. name);
	end

	return dropdown;
end