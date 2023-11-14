-------------------------- Zee's Window API ---------------------------
-- Developed it for use in my addons, but feel free to use in yours ---
-----------------------------------------------------------------------

-- EXAMPLE --
--[[
	Win.OpenMessageBox(SceneMachine.mainWindow, 
        "MessageBox Title", "Lorem Ipsum is simply dummy text of the printing and typesetting industry." ..
        "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer "..
        "took a galley of type and scrambled it to make a type specimen book. It has survived not only five "..
        "centuries, but also the leap into electronic typesetting, remaining essentially unchanged. "..
        "It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, "..
        "and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
        true, true, function() print("Clicked Yes"); end, function() print("Clicked No"); end
    );
--]]

--Window--
local Win = ZWindowAPI;
local c1 = { 0.1757, 0.1757, 0.1875 };
local c2 = { 0.242, 0.242, 0.25 };
local c3 = { 0, 0.4765, 0.7968 };
local c4 = { 0.1171, 0.1171, 0.1171 };

function Win.OpenMessageBox( window, title, message, hasYesButton, hasNoButton, onYesButton, onNoButton )
	if (Win.messageBox == nil) then
		Win.messageBox = Win.CreatePopupWindow(0, 0, 300, 150, window, "CENTER", "CENTER", title);
		Win.messageBox:SetFrameStrata("HIGH");
		local dropShadow = Win.CreateImageBox(0, 10, 300 * 1.20, 150 * 1.29, Win.messageBox, "CENTER", "CENTER",
		"Interface\\Addons\\scenemachine\\static\\textures\\dropShadowSquare.png");
		dropShadow:SetFrameStrata("MEDIUM");
		Win.messageBox.texture:SetColorTexture(c4[1], c4[2], c4[3],1);
		Win.messageBox.TitleBar.texture:SetColorTexture(c1[1], c1[2], c1[3], 1);
		Win.messageBox.CloseButton.ntex:SetColorTexture(c1[1], c1[2], c1[3], 1);
		Win.messageBox.CloseButton.htex:SetColorTexture(c2[1], c2[2], c2[3], 1);
		Win.messageBox.CloseButton.ptex:SetColorTexture(c3[1], c3[2], c3[3], 1);
		Win.messageBox.TitleBar.text:SetText(title);

		Win.messageBox.textBox = Win.CreateTextBoxSimple(0, 10, 280, 100, Win.messageBox, "CENTER", "CENTER", message, 10);

		Win.messageBox.yesButton = Win.CreateButton(-75, 10, 50, 25, Win.messageBox, "BOTTOMRIGHT", "BOTTOMRIGHT", "YES", nil, "BUTTON_VS");
		Win.messageBox.noButton = Win.CreateButton(-20, 10, 50, 25, Win.messageBox, "BOTTOMRIGHT", "BOTTOMRIGHT", "NO", nil, "BUTTON_VS");
	end

	Win.messageBox:Show();

	if (hasYesButton == true) then
		Win.messageBox.yesButton:Show();
		Win.messageBox.yesButton:SetScript("OnClick", function (self, button, down)
			Win.messageBox:Hide();
			if (onYesButton ~= nil) then
				onYesButton();
			end
		end);
	else
		Win.messageBox.yesButton:Hide();
	end

	if (hasNoButton == true) then
		Win.messageBox.noButton:Show();
		Win.messageBox.noButton:SetScript("OnClick", function (self, button, down)
			Win.messageBox:Hide();
			if (onNoButton ~= nil) then
				onNoButton();
			end
		end);
	else
		Win.messageBox.noButton:Hide();
	end
end