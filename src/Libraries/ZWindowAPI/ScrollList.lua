-------------------------- Zee's Window API ---------------------------
-- Developed it for use in my addons, but feel free to use in yours ---
-----------------------------------------------------------------------

--Scroll List--
local Win = ZWindowAPI;

function Win.CreateScrollList(posX, posY, sizeX, sizeY, parent, windowPoint, parentPoint)

	-- defaults --
	if posX == nil then posX = 0; end
	if posY == nil then posY = 0; end
	if sizeX == nil or sizeX == 0 then sizeX = 50; end
	if sizeY == nil or sizeY == 0 then sizeY = 50; end	
	if parent == nil then parent = UIParent; end
	if windowPoint == nil then windowPoint = "CENTER"; end
	if parentPoint == nil then parentPoint = "CENTER"; end

	-- ScrollList parent frame 
	local ParentFrame = CreateFrame("Frame", "Zee.WindowAPI.ScrollList", parent) 
	ParentFrame:SetSize(sizeX, sizeY) 
	ParentFrame:SetPoint(windowPoint, parent, parentPoint, posX, posY);
	ParentFrame_Texture = ParentFrame:CreateTexture() 
	ParentFrame_Texture:SetAllPoints(ParentFrame) 
	ParentFrame_Texture:SetColorTexture(0,0,0,0.4) 
	ParentFrame.background = ParentFrame_Texture 

	-- ScrollList scroll frame 
	ParentFrame.ScrollFrame = CreateFrame("ScrollFrame", nil, ParentFrame) 
	ParentFrame.ScrollFrame:SetPoint("TOPLEFT", 4, -4) 
	ParentFrame.ScrollFrame:SetPoint("BOTTOMRIGHT", -4, 4) 
	ParentFrame.ScrollFrame:SetScript("OnMouseWheel", 
		function(self, delta)
			ParentFrame.Scrollbar:SetValue(ParentFrame.ScrollFrame:GetVerticalScroll()-(delta*20)) 
		end)

	-- ScrollList scrollbar 
	ParentFrame.Scrollbar = CreateFrame("Slider", nil, ParentFrame.ScrollFrame, "UIPanelScrollBarTemplate") 
	ParentFrame.Scrollbar:SetPoint("TOPLEFT", ParentFrame, "TOPRIGHT", -18, -16) 
	ParentFrame.Scrollbar:SetPoint("BOTTOMLEFT", ParentFrame, "BOTTOMRIGHT", 20, 16) 
	ParentFrame.Scrollbar:SetMinMaxValues(-1, 200) 
	ParentFrame.Scrollbar:SetValueStep(1) 
	ParentFrame.Scrollbar.scrollStep = 1
	ParentFrame.Scrollbar:SetValue(0) 
	ParentFrame.Scrollbar:SetWidth(16) 
	ParentFrame.Scrollbar:SetScript("OnValueChanged", 
	function (self, value) 
	self:GetParent():SetVerticalScroll(value) 
	end) 
	local scrollbg1 = ParentFrame.Scrollbar:CreateTexture(nil, "BACKGROUND") 
	scrollbg1:SetAllPoints(ParentFrame.Scrollbar) 
	scrollbg1:SetTexture(0, 0, 0, 0.4) 

	-- ScrollList content frame 
	ParentFrame.ContentFrame = CreateFrame("Frame", "Loot Scroll Frame", ParentFrame.ScrollFrame) 
	ParentFrame.ContentFrame:SetSize(sizeX, 380) 
	ParentFrame.ContentFrame:SetPoint("TOPLEFT",25,0) 
	ParentFrame.ContentFrame:EnableMouse();
	ParentFrame.ContentFrame:SetFrameLevel(100)
	ParentFrame.ContentFrame:SetToplevel(true)
	ParentFrame.ScrollFrame:SetScrollChild(ParentFrame.ContentFrame)
	return ParentFrame

end

function Win.AdjustScrollList(scrollList, height)
	scrollList.Scrollbar:SetMinMaxValues(-1, height);
	scrollList.ContentFrame:SetSize(scrollList.ContentFrame:GetWidth(), height);
end